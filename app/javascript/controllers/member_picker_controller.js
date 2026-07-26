import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="member-picker"
export default class extends Controller {
  static targets = ["checkbox", "chapterFilter"]

  selectAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach((checkbox) => { checkbox.checked = true })
  }

  selectChapter(event) {
    event.preventDefault()
    const chapterId = this.chapterFilterTarget.value
    if (!chapterId) return

    this.checkboxTargets.forEach((checkbox) => {
      if (checkbox.dataset.chapterId === chapterId) checkbox.checked = true
    })
  }

  clearAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach((checkbox) => { checkbox.checked = false })
  }
}
