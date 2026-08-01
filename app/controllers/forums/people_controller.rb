module Forums
  class PeopleController < BaseController
    # Directory of every other member in the forum, so a member can browse
    # who's around and invite them straight into a One-to-One or Office
    # Darshan — regardless of which chapter they belong to.
    def index
      authorize! :read, User
      @people = @current_forum.users.where(role: [ :member, :committee_member ])
        .where.not(id: current_user.id)
        .includes(:chapter, :business_category_ref)
        .order(:full_name)
      @people = @people.where("full_name ILIKE ? OR business_name ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @people = @people.page(params[:page])
    end
  end
end
