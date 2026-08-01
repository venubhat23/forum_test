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
    end

    def members
      @setting = ForumSetting.for(@current_forum)
      @categories = @current_forum.business_categories.top_level.order(:name)

      @members = @current_forum.members.where(suspended_at: nil).includes(:chapter, :business_category_ref)
      @members = @members.where("full_name ILIKE ? OR business_name ILIKE ? OR speciality ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @members = @members.where(business_category_id: params[:category_id]) if params[:category_id].present?
      @members = @members.order(:full_name)
    end

    private

    def set_current_forum
      @current_forum = Forum.find_by!(slug: params[:forum_slug])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "Forum not found."
    end
  end
end
