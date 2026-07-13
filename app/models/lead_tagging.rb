class LeadTagging < ApplicationRecord
  belongs_to :lead
  belongs_to :user

  validates :user_id, uniqueness: { scope: :lead_id }

  after_create :notify_user

  private

  def notify_user
    business_text = lead.business_name.present? ? " (#{lead.business_name})" : ""
    user.notifications.create!(body: "New lead request: #{lead.prospect_name}#{business_text} from #{lead.created_by.display_name}.")
  end
end
