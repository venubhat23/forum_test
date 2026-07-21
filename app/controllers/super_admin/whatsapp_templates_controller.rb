module SuperAdmin
  class WhatsappTemplatesController < BaseController
    KEY = "invoice_share"

    def edit
      set_template
    end

    def update
      set_template
      if @template.update(template_params)
        redirect_to edit_super_admin_whatsapp_template_path, notice: "Template updated."
      else
        flash.now[:alert] = @template.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_template
      @template = WhatsappTemplate.find_or_initialize_by(forum_id: nil, key: KEY)
      @template.body = WhatsappTemplate::DEFAULTS.fetch(KEY) if @template.body.blank?
    end

    def template_params
      params.require(:whatsapp_template).permit(:body)
    end
  end
end
