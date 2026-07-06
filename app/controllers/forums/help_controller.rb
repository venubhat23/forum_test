module Forums
  class HelpController < BaseController
    FAQ = [
      { q: "How do I add a new member?", a: "Go to Chapters, open a chapter, and use Add Member." },
      { q: "How do I record attendance?", a: "Open a chapter, go to Meetings or Attendance, and record who was present." },
      { q: "How do I reset a member's password?", a: "Go to the member's profile page and click Reset Password." },
      { q: "How do I mark a fee as paid?", a: "Go to Fees within the chapter and click Mark Paid on the relevant row." },
      { q: "Who can I contact for further help?", a: "Raise a support ticket below and the platform team will get back to you." }
    ].freeze

    def show
      @faq = FAQ
    end
  end
end
