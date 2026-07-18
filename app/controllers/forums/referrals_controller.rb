module Forums
  class ReferralsController < BaseController
    before_action :set_chapter
    before_action :set_referral, only: [ :show, :accept, :reject ]

    def index
      authorize! :read, Referral
      base = Referral.joins("INNER JOIN users givers ON givers.id = referrals.referrer_id")
        .where(givers: { chapter_id: @chapter.id })

      @total_referrals = base.count
      @pending_referrals = base.where(status: :pending).count
      @accepted_referrals = base.where(status: :accepted).count
      @converted_referrals = base.where(status: :converted).count
      @monthly_stats = base.group_by_month(:created_at, last: 6).count

      @referrals = base.order(created_at: :desc)
      @referrals = @referrals.where("prospect_name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @referrals = @referrals.where(status: params[:status]) if params[:status].present?
      @referrals = @referrals.page(params[:page])
    end

    def show
      authorize! :read, @referral
    end

    def new
      authorize! :create, Referral
      @referral = Referral.new
      @people = chapter_members
    end

    def create
      @referral = Referral.new(referral_params)
      authorize! :create, @referral

      if @referral.giver && @referral.giver.chapter_id == @chapter.id && @referral.save
        redirect_to forum_chapter_referral_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @referral.id), notice: "Referral recorded."
      else
        @referral.errors.add(:giver, "must belong to this chapter") if @referral.giver && @referral.giver.chapter_id != @chapter.id
        @people = chapter_members
        flash.now[:alert] = @referral.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def accept
      authorize! :update, @referral
      @referral.update!(status: :accepted)
      redirect_to forum_chapter_referral_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @referral.id), notice: "Referral accepted."
    end

    def reject
      authorize! :update, @referral
      @referral.update!(status: :rejected)
      redirect_to forum_chapter_referral_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @referral.id), notice: "Referral rejected."
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_referral
      @referral = Referral.joins("INNER JOIN users givers ON givers.id = referrals.referrer_id")
        .where(givers: { chapter_id: @chapter.id }).find(params[:id])
    end

    def chapter_members
      @current_forum.users.member.order(:full_name)
    end

    def referral_params
      params.require(:referral).permit(:giver_id, :receiver_id, :referral_type, :prospect_name, :prospect_phone, :notes)
    end
  end
end
