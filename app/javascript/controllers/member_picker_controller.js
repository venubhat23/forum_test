import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="member-picker"
export default class extends Controller {
  static targets = ["select", "chapterFilter"]

  selectAll(event) {
    event.preventDefault()
    Array.from(this.selectTarget.options).forEach((opt) => { opt.selected = true })
  }

  selectChapter(event) {
    event.preventDefault()
    const chapterId = this.chapterFilterTarget.value
    if (!chapterId) return

    Array.from(this.selectTarget.options).forEach((opt) => {
      if (opt.dataset.chapterId === chapterId) opt.selected = true
    })
  }

  clearAll(event) {
    event.preventDefault()
    Array.from(this.selectTarget.options).forEach((opt) => { opt.selected = false })
  }
}
