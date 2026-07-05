class ForumRequestsController < ApplicationController
  def new
    @forum_request = ForumRequest.new
  end

  def create
    @forum_request = ForumRequest.new(forum_request_params)
    if @forum_request.save
      redirect_to new_forum_request_path, notice: "Thanks! We'll be in touch soon."
    else
      flash.now[:alert] = @forum_request.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def forum_request_params
    params.require(:forum_request).permit(:name, :email, :phone, :company_name, :message)
  end
end
