import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lead-tagging"
export default class extends Controller {
  static targets = ["checkbox", "search", "option", "group", "noResults"]

  selectAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach((cb) => { cb.checked = true })
  }

  clearAll(event) {
    event.preventDefault()
    this.checkboxTargets.forEach((cb) => { cb.checked = false })
    if (this.hasSearchTarget) {
      this.searchTarget.value = ""
      this.filter()
    }
  }

  selectChapter(event) {
    event.preventDefault()
    const chapterId = event.currentTarget.dataset.chapterId
    this.checkboxTargets.forEach((cb) => {
      if (cb.dataset.chapterId === chapterId) cb.checked = true
    })
  }

  filter() {
    const query = this.searchTarget.value.trim().toLowerCase()
    let anyVisible = false

    this.groupTargets.forEach((group) => {
      let groupHasVisible = false

      group.querySelectorAll("[data-lead-tagging-target='option']").forEach((option) => {
        const matches = query === "" || option.dataset.searchText.includes(query)
        option.classList.toggle("d-none", !matches)
        if (matches) groupHasVisible = true
      })

      group.classList.toggle("d-none", !groupHasVisible)
      if (groupHasVisible) anyVisible = true
    })

    if (this.hasNoResultsTarget) this.noResultsTarget.classList.toggle("d-none", anyVisible)
  }
}
