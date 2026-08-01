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

  // Checks only the checkboxes tagged with the clicked button's day (e.g.
  // data-attendance-checklist-day-param="Friday") — used by the meeting
  // invite screen's "All Friday meetings" style shortcuts.
  markDay(event) {
    event.preventDefault()
    const day = event.params.day
    this.checkboxTargets.forEach((cb) => {
      if (cb.dataset.day === day) cb.checked = true
    })
  }
}
