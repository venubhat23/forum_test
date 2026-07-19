import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="invoice-form"
//
// Selecting a forum auto-loads its plan (name + price); picking a billing
// month/year auto-computes the period's from/to dates. Amount, due date and
// description all start out auto-filled but "lock" as soon as the admin
// edits them by hand, so later forum/period changes stop overwriting
// whatever was typed.
export default class extends Controller {
  static targets = [
    "forumSelect", "planIdField", "planName",
    "monthSelect", "yearSelect", "periodFrom", "periodTo",
    "amountField", "dueDateField", "descriptionField"
  ]

  connect() {
    this.updatePeriod()
    this.updateForum()
  }

  forumChanged() {
    this.updateForum()
  }

  periodChanged() {
    this.updatePeriod()
  }

  markManual(event) {
    event.target.dataset.autofilled = "false"
  }

  updateForum() {
    const option = this.forumSelectTarget.selectedOptions[0]
    const planName = option?.dataset.planName
    const planPrice = option?.dataset.planPrice

    this.planIdFieldTarget.value = (option && option.value) ? (option.dataset.planId || "") : ""
    this.planNameTarget.textContent = (option && option.value && planName) ? `${planName} plan` : "Select a forum to auto-load its plan"

    if (this.hasAmountFieldTarget && this.amountFieldTarget.dataset.autofilled !== "false" && planPrice) {
      this.amountFieldTarget.value = planPrice
    }

    this.updateDescription()
  }

  updatePeriod() {
    if (!this.hasMonthSelectTarget || !this.hasYearSelectTarget) return

    const month = parseInt(this.monthSelectTarget.value, 10)
    const year = parseInt(this.yearSelectTarget.value, 10)
    if (!month || !year) return

    const from = new Date(year, month - 1, 1)
    const to = new Date(year, month, 0)

    if (this.hasPeriodFromTarget) this.periodFromTarget.textContent = this.formatDisplayDate(from)
    if (this.hasPeriodToTarget) this.periodToTarget.textContent = this.formatDisplayDate(to)

    if (this.hasDueDateFieldTarget && this.dueDateFieldTarget.dataset.autofilled !== "false") {
      this.dueDateFieldTarget.value = this.formatInputDate(to)
    }

    this.updateDescription()
  }

  updateDescription() {
    if (!this.hasDescriptionFieldTarget) return
    if (this.descriptionFieldTarget.dataset.autofilled === "false") return
    if (!this.hasMonthSelectTarget || !this.hasYearSelectTarget) return

    const option = this.forumSelectTarget.selectedOptions[0]
    const planName = (option && option.value && option.dataset.planName) ? option.dataset.planName : "Membership"
    const monthLabel = this.monthSelectTarget.selectedOptions[0]?.text
    const year = this.yearSelectTarget.value
    const from = this.hasPeriodFromTarget ? this.periodFromTarget.textContent : ""
    const to = this.hasPeriodToTarget ? this.periodToTarget.textContent : ""

    this.descriptionFieldTarget.value = `${planName} plan charges — ${monthLabel} ${year} (${from} to ${to})`
  }

  formatDisplayDate(date) {
    return date.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" })
  }

  formatInputDate(date) {
    const yyyy = date.getFullYear()
    const mm = String(date.getMonth() + 1).padStart(2, "0")
    const dd = String(date.getDate()).padStart(2, "0")
    return `${yyyy}-${mm}-${dd}`
  }
}
