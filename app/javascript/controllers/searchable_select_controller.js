import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Connects to data-controller="searchable-select"
// Drop-in searchable/type-ahead dropdown for a single <select>.
export default class extends Controller {
  connect() {
    this.tomSelect = new TomSelect(this.element, {
      placeholder: this.element.dataset.placeholder || "Search...",
      searchField: [ "text" ],
      maxOptions: null,
      allowEmptyOption: true,
    })
  }

  disconnect() {
    this.tomSelect?.destroy()
  }
}
