module SuperAdmin
  class CouponsController < BaseController
    before_action :set_coupon, only: [ :edit, :update, :archive, :activate ]

    def index
      @total_coupons = Coupon.count
      @active_coupons = Coupon.where(active: true).count
      @inactive_coupons = Coupon.where(active: false).count

      @coupons = Coupon.order(created_at: :desc)
      @coupons = @coupons.where("code ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @coupons = @coupons.where(active: params[:status] == "active") if params[:status].present?
    end

    def new
      @coupon = Coupon.new(discount_type: :percentage, active: true)
    end

    def create
      @coupon = Coupon.new(coupon_params)
      if @coupon.save
        redirect_to super_admin_coupons_path, notice: "Coupon #{@coupon.code} created."
      else
        flash.now[:alert] = @coupon.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @coupon.update(coupon_params)
        redirect_to super_admin_coupons_path, notice: "Coupon #{@coupon.code} updated."
      else
        flash.now[:alert] = @coupon.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def archive
      @coupon.update!(active: false)
      redirect_to super_admin_coupons_path, notice: "Coupon #{@coupon.code} deactivated."
    end

    def activate
      @coupon.update!(active: true)
      redirect_to super_admin_coupons_path, notice: "Coupon #{@coupon.code} activated."
    end

    private

    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    def coupon_params
      params.require(:coupon).permit(:code, :discount_type, :discount_value, :expires_on, :max_redemptions)
    end
  end
end
