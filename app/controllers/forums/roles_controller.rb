module Forums
  class RolesController < BaseController
    ROLES = %w[forum_admin chapter_admin committee_member member guest].freeze

    def index
      @roles = ROLES
      @own_chapter = @current_forum.chapters.first
      @other_chapter = @current_forum.chapters.where.not(id: @own_chapter&.id).first
    end
  end
end
