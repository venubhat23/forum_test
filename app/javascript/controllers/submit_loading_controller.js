import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="submit-loading"
export default class extends Controller {
  static targets = ["button", "label", "spinner"]

  start(event) {
    if (this.buttonTarget.disabled) {
      event.preventDefault()
      return
    }
    this.buttonTarget.disabled = true
    this.labelTarget.textContent = this.buttonTarget.dataset.loadingText || "Loading..."
    this.spinnerTarget.classList.remove("d-none")
  }
}
