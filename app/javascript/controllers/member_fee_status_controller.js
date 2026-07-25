import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="member-fee-status"
// Shows the "amount paid now" field only when the "Partially Paid" radio
// is selected among the membership fee status options.
export default class extends Controller {
  static targets = [ "radio", "partialWrap", "partialField" ]

  connect() {
    this.sync()
  }

  toggle() {
    this.sync()
  }

  sync() {
    const selected = this.radioTargets.find((radio) => radio.checked)
    const isPartial = selected?.value === "partial"
    this.partialWrapTarget.classList.toggle("d-none", !isPartial)
    this.partialFieldTarget.disabled = !isPartial
    if (!isPartial) this.partialFieldTarget.value = ""
  }
}
