module SuperAdmin
  class WhatsappTemplatesController < BaseController
    before_action :set_template, only: [ :edit, :update, :reset ]

    def index
      @keys = WhatsappTemplate::KEYS
      @customized_keys = WhatsappTemplate.where(forum_id: nil, key: @keys).pluck(:key)
    end

    def edit
    end

    def update
      if @template.update(template_params)
        redirect_to super_admin_whatsapp_templates_path, notice: "Template updated."
      else
        flash.now[:alert] = @template.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def reset
      @template.destroy if @template.persisted?
      redirect_to super_admin_whatsapp_templates_path, notice: "Reset to default."
    end

    private

    def set_template
      key = params[:key]
      raise ActiveRecord::RecordNotFound unless WhatsappTemplate::KEYS.include?(key)

      @template = WhatsappTemplate.find_or_initialize_by(forum_id: nil, key: key)
      @template.body = WhatsappTemplate::DEFAULTS.fetch(key) if @template.body.blank?
    end

    def template_params
      params.require(:whatsapp_template).permit(:body)
    end
  end
end
