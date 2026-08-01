module Forums
  # Public-facing marketing site for a forum (no login required) — a home
  # page plus an "Our Members" directory of business portfolios. Unlike
  # Forums::BaseController, this is reachable by anyone with the forum's
  # public URL, so it must only ever expose business-card-level info
  # (never KYC/financial fields like GST, PAN, Aadhaar).
  class WebsitesController < ApplicationController
    before_action :set_current_forum

    def show
      @setting = ForumSetting.for(@current_forum)
      @chapters_count = @current_forum.chapters.active.count
      @members_count = @current_forum.members.where(suspended_at: nil).count
      @categories = @current_forum.business_categories.top_level.order(:name)
      @featured_members = @current_forum.members
        .where(suspended_at: nil)
        .where.not(business_name: [ nil, "" ])
        .order(Arel.sql("RANDOM()"))
        .limit(6)
      ensure_profile_tokens!(@featured_members)
    end

    def members
      @setting = ForumSetting.for(@current_forum)
      @categories = @current_forum.business_categories.top_level.order(:name)

      @members = @current_forum.members.where(suspended_at: nil).includes(:chapter, :business_category_ref)
      @members = @members.where("full_name ILIKE ? OR business_name ILIKE ? OR speciality ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @members = @members.where(business_category_id: params[:category_id]) if params[:category_id].present?
      @members = @members.order(:full_name).to_a
      ensure_profile_tokens!(@members)
    end

    # A member's own public "mini website" — their portfolio page, reachable
    # via their profile_token so the URL doesn't leak sequential user ids.
    def member
      @setting = ForumSetting.for(@current_forum)
      @member = @current_forum.members.where(suspended_at: nil).find_by!(profile_token: params[:profile_token])

      @related_members = @current_forum.members.where(suspended_at: nil).where.not(id: @member.id)
      @related_members = @related_members.where(business_category_id: @member.business_category_id) if @member.business_category_id.present?
      @related_members = @related_members.order(Arel.sql("RANDOM()")).limit(3).to_a
      ensure_profile_tokens!(@related_members)
    rescue ActiveRecord::RecordNotFound
      redirect_to forum_website_members_path(forum_slug: @current_forum.slug), alert: "That member profile couldn't be found."
    end

    private

    # profile_token is generated on create (has_secure_token), but members
    # created before that column existed have a blank one — backfill lazily
    # the first time they're shown on a public page, so every member ends up
    # with a stable link without a one-off data migration.
    def ensure_profile_tokens!(members)
      members.select { |m| m.profile_token.blank? }.each(&:regenerate_profile_token)
    end

    def set_current_forum
      @current_forum = Forum.find_by!(slug: params[:forum_slug])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "Forum not found."
    end
  end
end
