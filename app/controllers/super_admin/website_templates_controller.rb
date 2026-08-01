module SuperAdmin
  class WebsiteTemplatesController < BaseController
    def index
      @templates = ForumSetting::TEMPLATES
    end

    # Renders the real public landing page with in-memory (never persisted)
    # demo data, so every template can be previewed with zero DB writes and
    # without depending on any real forum/member data existing yet.
    #
    # Deliberately NOT a real ForumSetting: that model guards website_template
    # reads/writes against the column not existing yet on a pending migration
    # (see ForumSetting for why), which would make every preview silently
    # collapse to "classic" here. PreviewSetting is a plain object so the
    # gallery works regardless of migration status.
    def preview
      template = ForumSetting::TEMPLATES.key?(params[:id]) ? params[:id] : ForumSetting::DEFAULT_TEMPLATE

      @current_forum = Forum.new(slug: "demo", name: "Riverside Business Network", created_at: 3.years.ago)
      @setting = PreviewSetting.new(template)

      @chapters_count = 4
      @members_count = 128
      @categories = demo_categories
      @featured_members = demo_members

      render "forums/websites/show"
    end

    private

    PreviewSetting = Struct.new(:website_template) do
      def theme_color
        "#4f46e5"
      end

      def logo
        NullLogo.new
      end

      NullLogo = Struct.new(:x) do
        def attached?
          false
        end
      end
    end

    def demo_categories
      [ "Marketing & Design", "Legal & Finance", "Construction", "Health & Wellness", "Technology" ]
        .map.with_index(1) { |name, id| BusinessCategory.new(id: id, name: name) }
    end

    def demo_members
      chapter = Chapter.new(id: 1, name: "Central Chapter")
      [
        { name: "Ananya Rao", business: "Rao Design Studio", cat: "Branding & Graphic Design", role: "President" },
        { name: "Vikram Shah", business: "Shah Legal Associates", cat: "Legal Services", role: "Secretary" },
        { name: "Priya Menon", business: "Menon Wellness Clinic", cat: "Health & Wellness", role: nil },
        { name: "Rahul Verma", business: "Verma Constructions", cat: "Civil Contractor", role: "Treasurer" },
        { name: "Sneha Iyer", business: "Iyer Digital Marketing", cat: "Digital Marketing", role: nil },
        { name: "Arjun Nair", business: "Nair IT Solutions", cat: "IT Consultant", role: nil }
      ].map.with_index(1) do |m, id|
        User.new(
          id: id, full_name: m[:name], email: "#{m[:name].downcase.tr(' ', '.')}@example.com",
          phone: "98765#{format('%05d', id)}", role: :member, forum: @current_forum, chapter: chapter,
          business_name: m[:business], business_category: m[:cat], speciality: m[:cat],
          designation: m[:role], service_area: "Bengaluru", capacity: "Owner", experience_years: 5 + id,
          website: "www.example.com", social_media_handle: "@#{m[:business].downcase.tr(' ', '')}"
        )
      end
    end
  end
end
