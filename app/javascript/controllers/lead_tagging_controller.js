import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lead-tagging"
export default class extends Controller {
  static targets = ["checkbox"]

  selectAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach((cb) => { cb.checked = true })
  }

  clearAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach((cb) => { cb.checked = false })
  }

  selectChapter(event) {
    event.preventDefault()
    const chapterId = event.currentTarget.dataset.chapterId
    this.checkboxTargets.forEach((cb) => {
      if (cb.dataset.chapterId === chapterId) cb.checked = true
    })
  }
}
