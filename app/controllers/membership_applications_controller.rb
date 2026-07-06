class MembershipApplicationsController < ApplicationController
  before_action :set_forum

  def new
    @application = @forum.membership_applications.new
  end

  def create
    @application = @forum.membership_applications.new(application_params)
    if @application.save
      redirect_to forum_apply_path(forum_slug: @forum.slug), notice: "Thanks! Your application has been submitted."
    else
      flash.now[:alert] = @application.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_forum
    @forum = Forum.find_by!(slug: params[:forum_slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Forum not found."
  end

  def application_params
    params.require(:membership_application).permit(:name, :email, :phone, :business_name, :nature_of_business)
  end
end
