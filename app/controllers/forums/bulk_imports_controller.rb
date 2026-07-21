require "csv"
require "roo"

module Forums
  class BulkImportsController < BaseController
    def new
      authorize! :create, Chapter
    end

    def create
      authorize! :create, Chapter
      file = params[:file]
      if file.blank?
        redirect_to new_forum_bulk_import_path(forum_slug: @current_forum.slug), alert: "Please choose a file to upload."
        return
      end

      spreadsheet = Roo::Spreadsheet.open(file.tempfile.path, extension: File.extname(file.original_filename))
      header = spreadsheet.row(1).map { |h| h.to_s.strip.downcase }

      @results = []
      @imported = false

      chapters_by_name = {}

      ActiveRecord::Base.transaction do
        (2..spreadsheet.last_row).each do |i|
          row = Hash[header.zip(spreadsheet.row(i))]
          row_errors = []

          chapter_name = row["chapter_name"].to_s.strip
          chapter = chapters_by_name[chapter_name] ||= @current_forum.chapters.find_or_initialize_by(name: chapter_name)
          row_errors.concat(chapter.errors.full_messages) unless chapter.persisted? || chapter.save

          if row_errors.empty?
            member = chapter.members.new(
              full_name: row["full_name"],
              email: row["email"],
              phone: row["phone"],
              business_name: row["business_name"]
            )
            member.forum = @current_forum
            member.role = :member
            member.password = SecureRandom.alphanumeric(12)
            member.password_confirmation = member.password
            row_errors.concat(member.errors.full_messages) unless member.save
          end

          @results << {
            row: i,
            chapter_name: row["chapter_name"],
            full_name: row["full_name"],
            email: row["email"],
            errors: row_errors
          }
        end

        if @results.any? { |r| r[:errors].any? }
          raise ActiveRecord::Rollback
        else
          @imported = true
        end
      end

      render :create
    end

    def sample
      authorize! :create, Chapter
      csv = CSV.generate do |c|
        c << %w[chapter_name full_name email phone business_name]
        c << [ "Koramangala Chapter", "Asha Rao", "asha@example.com", "9876543210", "Rao Textiles" ]
        c << [ "Koramangala Chapter", "Vikram Shah", "vikram@example.com", "9876543211", "Shah Electricals" ]
        c << [ "Indiranagar Chapter", "Priya Nair", "priya@example.com", "9876543212", "" ]
      end
      send_data csv, filename: "bulk_import_sample.csv", type: "text/csv"
    end
  end
end
