module Forums
  class MembershipApplicationsController < BaseController
    before_action :set_application, only: [ :show, :approve, :reject ]

    def index
      authorize! :read, MembershipApplication
      base = @current_forum.membership_applications
      @pending_applications = base.where(status: :pending).count
      @approved_applications = base.where(status: :approved).count
      @rejected_applications = base.where(status: :rejected).count

      @applications = base.order(created_at: :desc)
      @applications = @applications.where(status: params[:status]) if params[:status].present?
    end

    def show
      authorize! :read, @application
    end

    def approve
      authorize! :update, @application
      chapter = @current_forum.chapters.find(params[:chapter_id])
      password = params[:password].presence || SecureRandom.alphanumeric(12)

      ActiveRecord::Base.transaction do
        member = chapter.members.new(
          full_name: @application.name,
          email: @application.email,
          phone: @application.phone,
          business_name: @application.business_name,
          password: password,
          password_confirmation: password
        )
        member.forum = @current_forum
        member.role = :member
        member.save!
        @application.update!(status: :approved, reviewed_by: current_user)
      end

      redirect_to forum_membership_application_path(forum_slug: @current_forum.slug, id: @application.id), notice: "#{@application.name} approved as a member. Temporary password: #{password}"
    rescue ActiveRecord::RecordInvalid => e
      redirect_to forum_membership_application_path(forum_slug: @current_forum.slug, id: @application.id), alert: e.record.errors.full_messages.to_sentence
    end

    def reject
      authorize! :update, @application
      @application.update!(status: :rejected, review_note: params[:review_note], reviewed_by: current_user)
      redirect_to forum_membership_applications_path(forum_slug: @current_forum.slug), notice: "Application from #{@application.name} rejected."
    end

    private

    def set_application
      @application = @current_forum.membership_applications.find(params[:id])
    end
  end
end
