module Forums
  class WhatsappTemplatesController < BaseController
    before_action :set_template, only: [ :edit, :update, :reset ]

    def index
      authorize! :manage, WhatsappTemplate
      @keys = WhatsappTemplate::FORUM_KEYS
      @customized_keys = WhatsappTemplate.where(forum: @current_forum, key: @keys).pluck(:key)
    end

    def edit
      authorize! :manage, WhatsappTemplate
    end

    def update
      authorize! :manage, WhatsappTemplate
      if @template.update(template_params)
        redirect_to forum_whatsapp_templates_path(forum_slug: @current_forum.slug), notice: "Template updated."
      else
        flash.now[:alert] = @template.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def reset
      authorize! :manage, WhatsappTemplate
      @template.destroy if @template.persisted?
      redirect_to forum_whatsapp_templates_path(forum_slug: @current_forum.slug), notice: "Reset to default."
    end

    private

    def set_template
      key = params[:key]
      raise ActiveRecord::RecordNotFound unless WhatsappTemplate::FORUM_KEYS.include?(key)

      @template = WhatsappTemplate.find_or_initialize_by(forum: @current_forum, key: key)
      @template.body = WhatsappTemplate::DEFAULTS.fetch(key) if @template.body.blank?
    end

    def template_params
      params.require(:whatsapp_template).permit(:body)
    end
  end
end
