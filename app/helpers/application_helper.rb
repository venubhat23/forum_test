module ApplicationHelper
  def current_area
    if controller_path.start_with?("super_admin/")
      :super_admin
    elsif controller_path.start_with?("forums/")
      :forum
    end
  end

  def brand_header_text
    case current_area
    when :super_admin then "Krama Consultancy"
    when :forum then @current_forum&.name || "Business Network"
    else "Business Network"
    end
  end

  def brand_logo
    return nil unless current_area == :forum
    @current_forum&.forum_setting&.logo
  end
end
