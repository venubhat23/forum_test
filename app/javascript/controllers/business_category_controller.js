import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="business-category"
//
// Picking a Business Category filters the Speciality dropdown down to that
// category's specialities. Fully client-side (the whole category => [specialities]
// map is passed in as JSON) — defaults to the first category's specialities on load.
export default class extends Controller {
  static targets = [ "category", "speciality" ]
  static values = { categories: Object, selected: String }

  connect() {
    this.populateSpecialities(this.selectedValue)
  }

  categoryChanged() {
    this.populateSpecialities()
  }

  populateSpecialities(preselect = "") {
    const specialities = this.categoriesValue[this.categoryTarget.value] || []
    const current = preselect || this.specialityTarget.value

    this.specialityTarget.innerHTML = ""
    specialities.forEach((speciality) => {
      const option = document.createElement("option")
      option.value = speciality
      option.textContent = speciality
      if (speciality === current) option.selected = true
      this.specialityTarget.appendChild(option)
    })
  }
}
