module SuperAdmin
  class RolesController < BaseController
    def index
      @roles = User.roles.keys
      sample_forums = Forum.order(:created_at).limit(2)
      @own_forum = sample_forums.first
      @other_forum = sample_forums.second
    end
  end
end
