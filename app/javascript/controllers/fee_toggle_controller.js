import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fee-toggle"
export default class extends Controller {
  static targets = [ "checkbox", "amountWrap", "amountField" ]

  connect() {
    this.sync()
  }

  toggle() {
    this.sync()
  }

  sync() {
    const checked = this.checkboxTarget.checked
    this.amountWrapTarget.classList.toggle("d-none", !checked)
    this.amountFieldTarget.disabled = !checked
    if (!checked) this.amountFieldTarget.value = ""
  }
}
