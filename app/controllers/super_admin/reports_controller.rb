require "csv"

module SuperAdmin
  class ReportsController < BaseController
    def index
    end

    def forums
      @forums = Forum.includes(:plan, :chapters).order(:name)
      respond_to do |format|
        format.html
        format.csv { send_data forums_csv(@forums), filename: "forums-#{Date.current}.csv" }
      end
    end

    def users
      @users = User.includes(:forum).order(:email)
      @users = @users.where(role: params[:role]) if params[:role].present?
      respond_to do |format|
        format.html
        format.csv { send_data users_csv(@users), filename: "users-#{Date.current}.csv" }
      end
    end

    def invoices_payments
      @invoices = Invoice.includes(:forum).order(created_at: :desc)
      respond_to do |format|
        format.html
        format.csv { send_data invoices_csv(@invoices), filename: "invoices-#{Date.current}.csv" }
      end
    end

    def attendance
      @attendances = Attendance.includes(:user).order(occurred_on: :desc)
      respond_to do |format|
        format.html
        format.csv { send_data attendance_csv(@attendances), filename: "attendance-#{Date.current}.csv" }
      end
    end

    def referrals_business
      @slips = ThanksgivingSlip.includes(:given_by, referral: [ :giver, :receiver ]).order(created_at: :desc)
      respond_to do |format|
        format.html
        format.csv { send_data referrals_csv(@slips), filename: "business-generated-#{Date.current}.csv" }
      end
    end

    private

    def forums_csv(forums)
      CSV.generate(headers: true) do |csv|
        csv << [ "Name", "Slug", "Plan", "Status", "Chapters", "Created" ]
        forums.each do |f|
          csv << [ f.name, f.slug, f.plan.name, f.status, f.chapters.size, f.created_at ]
        end
      end
    end

    def users_csv(users)
      CSV.generate(headers: true) do |csv|
        csv << [ "Email", "Role", "Forum", "Full Name", "Joined" ]
        users.each do |u|
          csv << [ u.email, u.role, u.forum&.name, u.full_name, u.created_at ]
        end
      end
    end

    def invoices_csv(invoices)
      CSV.generate(headers: true) do |csv|
        csv << [ "Invoice #", "Forum", "Amount", "Status", "Due Date", "Paid On" ]
        invoices.each do |i|
          csv << [ i.invoice_number, i.forum.name, i.amount, i.status, i.due_date, i.paid_on ]
        end
      end
    end

    def attendance_csv(attendances)
      CSV.generate(headers: true) do |csv|
        csv << [ "User", "Event Type", "Date", "Present" ]
        attendances.each do |a|
          csv << [ a.user.display_name, a.event_type, a.occurred_on, a.present ]
        end
      end
    end

    def referrals_csv(slips)
      CSV.generate(headers: true) do |csv|
        csv << [ "Given By", "Referral Giver", "Referral Receiver", "Amount", "Date" ]
        slips.each do |s|
          csv << [ s.given_by.display_name, s.referral.giver.display_name, s.referral.receiver.display_name, s.amount, s.created_at ]
        end
      end
    end
  end
end
