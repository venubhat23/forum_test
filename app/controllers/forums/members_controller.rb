require "csv"
require "roo"

module Forums
  class MembersController < BaseController
    before_action :set_chapter, except: [ :import, :bulk_import ]
    before_action :set_member, only: [ :show, :edit, :update, :suspend, :activate, :reset_password, :force_logout, :renew, :print ]

    def index
      authorize! :read, User
      @total_members = @chapter.members.count
      @active_members = @chapter.members.where(suspended_at: nil).count
      @suspended_members = @chapter.members.where.not(suspended_at: nil).count

      @members = @chapter.members.order(:full_name)
      @members = @members.where("full_name ILIKE ? OR email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @members = @members.where(suspended_at: nil) if params[:status] == "active"
      @members = @members.where.not(suspended_at: nil) if params[:status] == "suspended"
      @members = @members.page(params[:page])
      respond_to do |format|
        format.html
        format.csv { send_data members_csv(@chapter.members.order(:full_name)), filename: "members-#{@chapter.name.parameterize}-#{Date.current}.csv" }
      end
    end

    def show
      authorize! :read, @member
    end

    def new
      authorize! :create, User
      @member = @chapter.members.new
    end

    def create
      @member = @chapter.members.new(member_params)
      @member.forum = @current_forum
      @member.role = :member
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

    def print
      authorize! :read, @member
      render layout: false
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

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_member
      @member = @chapter.members.find(params[:id])
    end

    def member_params
      params.require(:member).permit(:full_name, :email, :phone, :password, :password_confirmation,
        :business_name, :business_category, :speciality, :gst_number, :pan_number, :aadhaar_number,
        :website, :address, :experience_years, :date_of_birth, :business_category_id, :photo, kyc_documents: [])
    end

    def member_update_params
      params.require(:member).permit(:full_name, :email, :phone,
        :business_name, :business_category, :speciality, :gst_number, :pan_number, :aadhaar_number,
        :website, :address, :experience_years, :date_of_birth, :business_category_id, :photo, kyc_documents: [])
    end

    def members_csv(members)
      CSV.generate(headers: true) do |csv|
        csv << [ "Full Name", "Email", "Phone", "Business Name", "Membership Status", "Renews On", "Joined" ]
        members.each do |m|
          csv << [ m.full_name, m.email, m.phone, m.business_name, m.membership_status, m.renews_on, m.created_at ]
        end
      end
    end
  end
end
