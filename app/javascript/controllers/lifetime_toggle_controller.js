import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lifetime-toggle"
// Hides the "duration in years" select once the "lifetime membership"
// checkbox is checked, since a lifetime fee has no year count.
export default class extends Controller {
  static targets = [ "checkbox", "durationWrap", "durationField" ]

  connect() {
    this.sync()
  }

  toggle() {
    this.sync()
  }

  sync() {
    const lifetime = this.checkboxTarget.checked
    this.durationWrapTarget.classList.toggle("d-none", lifetime)
    this.durationFieldTarget.disabled = lifetime
  }
}
