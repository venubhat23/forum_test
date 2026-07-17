import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Connects to data-controller="attendee-picker"
export default class extends Controller {
  static targets = ["select", "scope"]
  static values = { chapterId: Number }

  connect() {
    this.tomSelect = new TomSelect(this.selectTarget, {
      plugins: [ "remove_button" ],
      placeholder: "Search members to invite...",
      searchField: [ "text" ],
      maxOptions: null,
    })
    this.applyScope()
  }

  disconnect() {
    this.tomSelect?.destroy()
  }

  scopeChanged() {
    this.applyScope()
  }

  applyScope() {
    const scope = this.scopeTarget.value

    this.tomSelect.setTextboxValue()
    this.tomSelect.close()

    if (scope === "forum") {
      this.tomSelect.setValue(this.allValues(), true)
      this.tomSelect.lock()
    } else if (scope === "chapter") {
      this.tomSelect.setValue(this.chapterValues(), true)
      this.tomSelect.lock()
    } else {
      this.tomSelect.unlock()
    }
  }

  allValues() {
    return Array.from(this.selectTarget.options).map((opt) => opt.value)
  }

  chapterValues() {
    return Array.from(this.selectTarget.options)
      .filter((opt) => opt.dataset.chapterId === String(this.chapterIdValue))
      .map((opt) => opt.value)
  }
}
