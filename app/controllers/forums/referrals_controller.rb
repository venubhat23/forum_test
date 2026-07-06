module Forums
  class ReferralsController < BaseController
    before_action :set_chapter
    before_action :set_referral, only: [ :show ]

    def index
      authorize! :read, Referral
      @referrals = Referral.joins("INNER JOIN users givers ON givers.id = referrals.giver_id")
        .where(givers: { chapter_id: @chapter.id }).order(created_at: :desc).page(params[:page])
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

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_referral
      @referral = Referral.joins("INNER JOIN users givers ON givers.id = referrals.giver_id")
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
