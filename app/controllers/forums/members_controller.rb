require "csv"
require "roo"

module Forums
  class MembersController < BaseController
    before_action :set_chapter, except: [ :import, :bulk_import, :all ]
    before_action :set_member, only: [ :show, :edit, :update, :destroy, :suspend, :activate, :reset_password, :force_logout, :renew, :print, :update_role ]

    def all
      authorize! :read, User
      @total_members = @current_forum.members.count
      @active_members = @current_forum.members.where(suspended_at: nil).count
      @suspended_members = @current_forum.members.where.not(suspended_at: nil).count

      @members = @current_forum.members.includes(:chapter, :business_category_ref).order(:full_name)
      @members = @members.where("full_name ILIKE ? OR email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @members = @members.where(suspended_at: nil) if params[:status] == "active"
      @members = @members.where.not(suspended_at: nil) if params[:status] == "suspended"
      @members = @members.page(params[:page])
      @annual_fees_by_user = FeePayment.where(fee_type: :annual_membership, user_id: @members.map(&:id))
                                        .select("DISTINCT ON (user_id) *")
                                        .order(:user_id, created_at: :desc)
                                        .index_by(&:user_id)
    end

    def index
      authorize! :read, User
      @total_members = @chapter.members.count
      @active_members = @chapter.members.where(suspended_at: nil).count
      @suspended_members = @chapter.members.where.not(suspended_at: nil).count
      @upcoming_event = @current_forum.events.where("starts_at >= ?", Time.current).order(:starts_at).first
      @renewing_this_month = @chapter.members.where(renews_on: Date.current.beginning_of_month..Date.current.end_of_month).count

      @members = @chapter.members.includes(:business_category_ref).order(role_order_sql, :full_name)
      @members = @members.where("full_name ILIKE ? OR email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @members = @members.where(suspended_at: nil) if params[:status] == "active"
      @members = @members.where.not(suspended_at: nil) if params[:status] == "suspended"
      @members = @members.page(params[:page])
      @annual_fees_by_user = FeePayment.where(fee_type: :annual_membership, user_id: @members.map(&:id))
                                        .select("DISTINCT ON (user_id) *")
                                        .order(:user_id, created_at: :desc)
                                        .index_by(&:user_id)
      respond_to do |format|
        format.html
        format.csv { send_data members_csv(@chapter.members.order(:full_name)), filename: "members-#{@chapter.name.parameterize}-#{Date.current}.csv" }
      end
    end

    def show
      authorize! :read, @member
      @fee_payments = @member.fee_payments.order(created_at: :desc)
      @pending_annual_fee = @fee_payments.find { |f| f.annual_membership? && !f.paid? }
      @paid_annual_fee = @fee_payments.find { |f| f.annual_membership? && f.paid? }
    end

    def new
      authorize! :create, User
      @member = @chapter.members.new(membership_year: Date.current.year)
    end

    def create
      @member = @chapter.members.new(member_params)
      @member.forum = @current_forum
      @member.role = :member
      @member.membership_year ||= Date.current.year
      @member.renews_on = Date.new(@member.membership_year, 12, 31)
      authorize! :create, @member

      if @member.save
        redirect_to forum_chapter_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "#{@member.display_name} was added as a member."
      else
        flash.now[:alert] = @member.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @member
    end

    def update
      authorize! :update, @member
      if @member.update(member_update_params)
        redirect_to forum_chapter_member_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @member.id), notice: "#{@member.display_name} was updated."
      else
        flash.now[:alert] = @member.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @member
      name = @member.display_name
      @member.purge!
      redirect_to forum_chapter_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "#{name} and all their data have been permanently deleted."
    rescue ActiveRecord::InvalidForeignKey, ActiveRecord::RecordNotDestroyed => e
      redirect_to forum_chapter_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), alert: "Could not delete #{name}: #{e.message}"
    end

    def bulk_destroy
      authorize! :destroy, User
      deleted = []
      failed = []
      @chapter.members.where(id: params[:member_ids]).find_each do |member|
        name = member.display_name
        begin
          member.purge!
          deleted << name
        rescue ActiveRecord::InvalidForeignKey, ActiveRecord::RecordNotDestroyed => e
          failed << "#{name} (#{e.message})"
        end
      end

      redirect_to forum_chapter_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id),
        notice: (deleted.any? ? "Permanently deleted: #{deleted.join(', ')}." : nil),
        alert: (failed.any? ? "Could not delete: #{failed.join('; ')}." : nil)
    end

    def suspend
      authorize! :update, @member
      @member.suspend!
      redirect_to forum_chapter_member_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @member.id), notice: "#{@member.display_name} has been suspended."
    end

    def activate
      authorize! :update, @member
      @member.unsuspend!
      redirect_to forum_chapter_member_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @member.id), notice: "#{@member.display_name} has been reactivated."
    end

    def reset_password
      authorize! :update, @member
      new_password = SecureRandom.alphanumeric(12)
      @member.password = new_password
      @member.password_confirmation = new_password
      @member.save!
      @member.force_logout!
      redirect_to forum_chapter_member_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @member.id),
        notice: "New password for #{@member.email}: #{new_password} (copy this now, it won't be shown again)."
    end

    def force_logout
      authorize! :update, @member
      @member.force_logout!
      redirect_to forum_chapter_member_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @member.id), notice: "#{@member.display_name} has been signed out of all active sessions."
    end

    def renew
      authorize! :update, @member
      @member.update!(renews_on: 1.year.from_now.to_date, membership_status: :active)
      redirect_to forum_chapter_member_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @member.id), notice: "Membership renewed until #{@member.renews_on.strftime('%d %b %Y')}."
    end

    def update_role
      authorize! :update, @member
      @member.update!(designation: params[:designation].presence)
      notice = @member.designation.present? ? "#{@member.display_name} is now #{@member.designation}." : "#{@member.display_name}'s role was removed."
      redirect_to forum_chapter_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: notice
    end

    def print
      authorize! :read, @member
      render layout: false
    end

    def invite_to_event
      authorize! :update, User
      event = @current_forum.events.find(params[:event_id])
      member = @chapter.members.find(params[:member_id])

      when_text = event.starts_at.strftime("%d %b %Y at %I:%M %p")
      venue_text = event.venue.present? ? " at #{event.venue}" : ""
      member.notifications.create!(body: "You're invited to #{event.title} on #{when_text}#{venue_text}! 🎉")

      redirect_to forum_chapter_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "#{member.display_name} was invited to #{event.title}."
    end

    def import
      authorize! :create, User
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def bulk_import
      authorize! :create, User
      @chapter = @current_forum.chapters.find(params[:chapter_id])
      file = params[:file]

      if file.blank?
        redirect_to import_forum_chapter_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), alert: "Please choose a file to upload."
        return
      end

      created = 0
      errors = []
      spreadsheet = Roo::Spreadsheet.open(file.tempfile.path, extension: File.extname(file.original_filename))
      header = spreadsheet.row(1).map { |h| h.to_s.strip.downcase }

      (2..spreadsheet.last_row).each do |i|
        row = Hash[header.zip(spreadsheet.row(i))]
        member = @chapter.members.new(
          full_name: row["full_name"],
          email: row["email"],
          phone: row["phone"],
          business_name: row["business_name"]
        )
        member.forum = @current_forum
        member.role = :member
        member.password = SecureRandom.alphanumeric(12)
        member.password_confirmation = member.password

        if member.save
          created += 1
        else
          errors << "Row #{i} (#{row['email']}): #{member.errors.full_messages.to_sentence}"
        end
      end

      notice = "#{created} member(s) imported."
      notice += " #{errors.size} row(s) failed: #{errors.join('; ')}" if errors.any?
      redirect_to forum_chapter_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: notice
    end

    private

    def role_order_sql
      cases = User::DESIGNATIONS.each_with_index.map { |d, i| "WHEN #{User.connection.quote(d)} THEN #{i}" }.join(" ")
      Arel.sql("CASE designation #{cases} ELSE #{User::DESIGNATIONS.size} END ASC")
    end

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_member
      @member = @chapter.members.find(params[:id])
    end

    def member_params
      params.require(:member).permit(:full_name, :email, :phone, :password, :password_confirmation,
        :business_name, :business_category, :speciality, :designation, :gst_number, :pan_number, :aadhaar_number,
        :website, :address, :city, :service_area, :capacity, :experience_years, :date_of_birth, :business_category_id, :photo,
        :membership_year, kyc_documents: [])
    end

    def member_update_params
      params.require(:member).permit(:full_name, :email, :phone,
        :business_name, :business_category, :speciality, :designation, :gst_number, :pan_number, :aadhaar_number,
        :website, :address, :city, :service_area, :capacity, :experience_years, :date_of_birth, :business_category_id, :photo,
        :membership_year, kyc_documents: [])
    end

    def members_csv(members)
      CSV.generate(headers: true) do |csv|
        csv << [ "Full Name", "Email", "Phone", "Business Name", "Membership Status", "Renews On", "Member Since" ]
        members.each do |m|
          csv << [ m.full_name, m.email, m.phone, m.business_name, m.membership_status, m.renews_on, m.member_since ]
        end
      end
    end
  end
end
