module SuperAdmin
  class SubscriptionsController < BaseController
    before_action :set_forum, only: [ :extend_trial, :change_renewal_date ]

    def index
      @active_forums = Forum.active.count
      @trial_forums = Forum.trial.count
      @suspended_forums = Forum.suspended.count
      @renewals_soon = Forum.where(renews_on: Date.current..30.days.from_now.to_date).count

      @forums = Forum.includes(:plan).order(:renews_on)
      @forums = @forums.where(status: params[:status]) if params[:status].present?
    end

    def extend_trial
      days = params[:days].to_i
      days = 7 if days <= 0
      @forum.update!(trial_ends_at: (@forum.trial_ends_at || Time.current) + days.days)
      redirect_to super_admin_subscriptions_path, notice: "Trial for #{@forum.name} extended by #{days} days."
    end

    def change_renewal_date
      new_date = Date.parse(params[:renews_on]) rescue nil
      if new_date
        @forum.update!(renews_on: new_date)
        redirect_to super_admin_subscriptions_path, notice: "Renewal date for #{@forum.name} updated to #{new_date.strftime('%d %b %Y')}."
      else
        redirect_to super_admin_subscriptions_path, alert: "Please provide a valid date."
      end
    end

    private

    def set_forum
      @forum = Forum.find_by!(slug: params[:id])
    end
  end
end
