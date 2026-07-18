module Forums
  class ThanksgivingSlipsController < BaseController
    before_action :set_chapter
    before_action :set_referral

    def new
      authorize! :create, ThanksgivingSlip
      @thanksgiving_slip = @referral.thanksgiving_slips.new(given_by: @referral.receiver)
    end

    def create
      @thanksgiving_slip = @referral.thanksgiving_slips.new(thanksgiving_slip_params)
      @thanksgiving_slip.given_by = @referral.receiver
      authorize! :create, @thanksgiving_slip

      if @thanksgiving_slip.save
        redirect_to forum_chapter_referral_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @referral.id), notice: "Thanksgiving slip recorded."
      else
        flash.now[:alert] = @thanksgiving_slip.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_referral
      @referral = Referral.joins("INNER JOIN users givers ON givers.id = referrals.referrer_id")
        .where(givers: { chapter_id: @chapter.id }).find(params[:referral_id])
    end

    def thanksgiving_slip_params
      params.require(:thanksgiving_slip).permit(:amount, :notes, :proof)
    end
  end
end
