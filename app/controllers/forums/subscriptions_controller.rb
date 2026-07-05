module Forums
  class SubscriptionsController < BaseController
    def show
      @members_count = @current_forum.users.member.count
    end
  end
end
