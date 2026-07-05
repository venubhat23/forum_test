module SuperAdmin
  class BillingController < BaseController
    def edit
      @setting = PlatformSetting.instance
      @plans = Plan.ordered
    end

    def update
      @setting = PlatformSetting.instance
      if @setting.update(setting_params)
        redirect_to edit_super_admin_billing_path, notice: "Billing settings updated."
      else
        @plans = Plan.ordered
        flash.now[:alert] = @setting.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def setting_params
      params.require(:platform_setting).permit(:site_name, :support_email, :currency, :invoice_prefix, :tax_percent, :default_plan_id)
    end
  end
end
