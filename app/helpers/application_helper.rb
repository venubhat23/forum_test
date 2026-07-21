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

  # Category name => [speciality names], sourced from the forum's own Business Categories
  # (Forum > Business Categories, forum_admin/super_admin managed). Feeds the
  # business-category Stimulus controller that cascades the Speciality dropdown.
  def business_categories_map(forum)
    forum.business_categories.top_level.includes(:children).order(:name).each_with_object({}) do |category, map|
      map[category.name] = category.children.map(&:name)
    end
  end
end
