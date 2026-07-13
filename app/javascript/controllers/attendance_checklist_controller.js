import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="attendance-checklist"
export default class extends Controller {
  static targets = ["checkbox"]

  markAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach((cb) => { cb.checked = true })
  }

  clearAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach((cb) => { cb.checked = false })
  }
}
