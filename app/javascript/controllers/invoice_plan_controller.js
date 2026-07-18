import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="invoice-plan"
// Auto-fills the amount + description of the "Create Invoice" form from the
// selected plan's price and billing month, without clobbering values the
// admin has typed by hand.
export default class extends Controller {
  static targets = [ "planSelect", "monthField", "amountField", "descriptionField", "planSummary" ]

  connect() {
    this.amountTouched = this.amountFieldTarget.value.trim() !== ""
    this.descriptionTouched = this.descriptionFieldTarget.value.trim() !== ""
    this.sync()
  }

  markAmountTouched() {
    this.amountTouched = true
  }

  markDescriptionTouched() {
    this.descriptionTouched = true
  }

  sync() {
    const option = this.planSelectTarget.selectedOptions[0]
    const price = option ? option.dataset.price : null
    const cycle = option ? option.dataset.cycle : null
    const planName = option && option.value ? option.text.split(" — ")[0] : null

    if (planName && price) {
      if (!this.amountTouched) {
        this.amountFieldTarget.value = price
      }
      if (!this.descriptionTouched) {
        this.descriptionFieldTarget.value = `${planName} — ${this.monthLabel()} subscription charges`
      }
      this.planSummaryTarget.innerHTML =
        `<i class="bi bi-check-circle-fill text-success me-1"></i>` +
        `₹${Number(price).toLocaleString("en-IN")} / ${cycle} plan selected`
      this.planSummaryTarget.classList.remove("d-none")
    } else {
      this.planSummaryTarget.classList.add("d-none")
    }
  }

  monthLabel() {
    const raw = this.monthFieldTarget.value
    if (!raw) return "this month's"
    const [ year, month ] = raw.split("-").map(Number)
    const date = new Date(year, month - 1, 1)
    return date.toLocaleString("en-IN", { month: "long", year: "numeric" })
  }
}
