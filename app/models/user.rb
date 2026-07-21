class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, { super_admin: 0, forum_admin: 1, chapter_admin: 2, committee_member: 3, member: 4, guest: 5, admin: 6, accountant: 7, support_staff: 8 }
  enum :membership_status, { pending: 0, active: 1, suspended: 2 }, prefix: :membership

  # Internal (Krama Consultancy staff) roles: not tied to any Forum tenant, managed from super_admin/users.
  INTERNAL_ROLES = %w[super_admin admin accountant support_staff].freeze

  DESIGNATIONS = [ "President", "Vice President", "Associate Vice President", "Secretary", "Treasurer", "Coordinator" ].freeze

  has_one_attached :photo
  has_many_attached :kyc_documents

  belongs_to :forum, optional: true
  belongs_to :chapter, optional: true
  belongs_to :invited_by, class_name: "User", optional: true
  belongs_to :business_category_ref, class_name: "BusinessCategory", foreign_key: "business_category_id", optional: true
  belongs_to :membership_plan, optional: true
  has_many :invitees, class_name: "User", foreign_key: :invited_by_id, dependent: :nullify, inverse_of: :invited_by
  has_many :fee_payments, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :referrals_given, class_name: "Referral", foreign_key: :referrer_id, dependent: :destroy, inverse_of: :giver
  has_many :referrals_received, class_name: "Referral", foreign_key: :referred_user_id, dependent: :destroy, inverse_of: :receiver
  has_many :thanksgiving_slips_given, class_name: "ThanksgivingSlip", foreign_key: :given_by_id, dependent: :destroy, inverse_of: :given_by
  has_many :notifications, dependent: :destroy
  has_many :badges, dependent: :destroy
  has_many :created_leads, class_name: "Lead", foreign_key: :created_by_id, dependent: :destroy, inverse_of: :created_by
  has_many :accepted_leads, class_name: "Lead", foreign_key: :accepted_by_id, dependent: :nullify, inverse_of: :accepted_by
  has_many :lead_taggings, dependent: :destroy
  has_many :tagged_leads, through: :lead_taggings, source: :lead
  has_many :event_registrations, dependent: :destroy
  has_many :invited_event_registrations, class_name: "EventRegistration", foreign_key: :invited_by_id, dependent: :nullify, inverse_of: false
  has_many :weekly_presentations, foreign_key: :member_id, dependent: :destroy, inverse_of: :member
  has_many :office_darshans_as_host, class_name: "OfficeDarshan", foreign_key: :host_id, dependent: :destroy, inverse_of: :host
  has_many :office_darshans_as_visitor, class_name: "OfficeDarshan", foreign_key: :visitor_id, dependent: :destroy, inverse_of: :visitor
  has_many :one_to_one_meetings_as_requester, class_name: "OneToOneMeeting", foreign_key: :requester_id, dependent: :destroy, inverse_of: :requester
  has_many :one_to_one_meetings_as_requested, class_name: "OneToOneMeeting", foreign_key: :requested_with_id, dependent: :destroy, inverse_of: :requested_with
  has_many :membership_applications_reviewed, class_name: "MembershipApplication", foreign_key: :reviewed_by_id, dependent: :nullify, inverse_of: :reviewed_by
  has_many :support_tickets_raised, class_name: "SupportTicket", foreign_key: :raised_by_id, dependent: :destroy, inverse_of: :raised_by
  has_many :support_ticket_replies, dependent: :destroy
  has_many :announcements_created, class_name: "Announcement", foreign_key: :created_by_id, dependent: :destroy, inverse_of: :created_by
  has_many :targeted_announcements, class_name: "Announcement", foreign_key: :target_user_id, dependent: :nullify, inverse_of: :target_user
  has_many :payments_recorded, class_name: "Payment", foreign_key: :recorded_by_id, dependent: :destroy, inverse_of: :recorded_by
  has_many :meeting_schedule_attendances, class_name: "MeetingScheduleAttendee", dependent: :destroy
  has_many :meeting_schedules_created, class_name: "MeetingSchedule", foreign_key: :created_by_id, dependent: :destroy, inverse_of: :created_by
  has_many :membership_applications_submitted, class_name: "MembershipApplication", foreign_key: :user_id, dependent: :nullify, inverse_of: :user
  has_many :membership_applications_invited, class_name: "MembershipApplication", foreign_key: :invited_by_id, dependent: :nullify, inverse_of: :invited_by
  has_many :forum_requests_reviewed, class_name: "ForumRequest", foreign_key: :reviewed_by_id, dependent: :nullify, inverse_of: :reviewed_by

  validates :forum, presence: true, unless: -> { INTERNAL_ROLES.include?(role) }
  validates :chapter, presence: true, if: -> { member? || guest? || committee_member? }
  validates :full_name, presence: true, if: -> { member? || guest? || committee_member? }
  validates :phone, presence: true, if: -> { member? || guest? || committee_member? }
  validates :nature_of_business, presence: true, if: :guest?
  validates :designation, presence: true, if: :committee_member?
  validate :within_forum_member_limit, on: :create, if: :member?

  before_validation :assign_placeholder_password, if: -> { guest? && password.blank? }
  before_validation :ensure_session_token, on: :create
  before_save :capture_original_password, if: -> { password.present? }

  def display_name
    full_name.presence || email.split("@").first
  end

  # The calendar year this membership runs for (Jan 1 - Dec 31). Falls back
  # to the signup date for members created before this field existed.
  def member_since
    membership_year.present? ? Date.new(membership_year, 1, 1) : created_at.to_date
  end

  def designation_rank
    rank = DESIGNATIONS.index(designation)
    rank.nil? ? DESIGNATIONS.size : rank
  end

  def internal?
    INTERNAL_ROLES.include?(role)
  end

  # True when this member's annual dues are currently covered, either via a
  # lifetime membership or an unexpired renewal date. Used to waive per-event/
  # per-meeting fees for members who've already paid their annual fee.
  def annual_fee_paid?
    membership_active? && (lifetime_member? || (renews_on.present? && renews_on >= Date.current))
  end

  def suspended?
    suspended_at.present?
  end

  def suspend!
    update_column(:suspended_at, Time.current)
  end

  def unsuspend!
    update_column(:suspended_at, nil)
  end

  def force_logout!
    update_column(:session_token, SecureRandom.hex(32))
  end

  # Permanently deletes the user and every associated record, including the
  # legacy session_activities table which has no ActiveRecord model.
  def purge!
    ActiveRecord::Base.transaction do
      self.class.connection.execute(
        ActiveRecord::Base.sanitize_sql([ "DELETE FROM session_activities WHERE user_id = ?", id ])
      )
      destroy!
    end
  end

  private

  def ensure_session_token
    self.session_token ||= SecureRandom.hex(32)
  end

  def within_forum_member_limit
    return unless forum

    if forum.member_limit_reached?
      errors.add(:base, "#{forum.name} has reached its #{forum.plan.name} plan limit of #{forum.member_limit} members. Ask your platform admin to upgrade the plan.")
    end
  end

  def assign_placeholder_password
    generated = SecureRandom.hex(12)
    self.password = generated
    self.password_confirmation = generated
  end

  def capture_original_password
    self.original_password = password
  end
end
