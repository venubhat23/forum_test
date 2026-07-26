import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="member-fee-status"
// Three mutually-exclusive fee options (unpaid / lifetime / monthly) share
// the same "member[fee_status]" radio group as the annual sub-options
// (full/partial), so the browser enforces exclusivity automatically. The
// "Annual Member" checkbox just shows/hides + enables/disables those two
// annual radios, and picking lifetime/monthly clears the checkbox back off.
export default class extends Controller {
  static targets = [ "radio", "annualCheckbox", "annualWrap", "annualRadio", "partialWrap", "partialField" ]

  connect() {
    this.sync()
  }

  toggle() {
    const selected = this.radioTargets.find((radio) => radio.checked)
    const isAnnual = selected?.value === "full" || selected?.value === "partial"

    if (!isAnnual) this.annualCheckboxTarget.checked = false
    this.syncAnnualWrap()

    const isPartial = selected?.value === "partial"
    this.partialWrapTarget.classList.toggle("d-none", !isPartial)
    this.partialFieldTarget.disabled = !isPartial
    if (!isPartial) this.partialFieldTarget.value = ""
  }

  toggleAnnual() {
    this.syncAnnualWrap()

    if (this.annualCheckboxTarget.checked) {
      if (!this.annualRadioTargets.some((radio) => radio.checked)) {
        this.annualRadioTargets[0].checked = true
      }
    } else {
      this.annualRadioTargets.forEach((radio) => { radio.checked = false })
      this.radioTargets.find((radio) => radio.value === "unpaid").checked = true
    }

    this.toggle()
  }

  sync() {
    this.syncAnnualWrap()
    this.toggle()
  }

  syncAnnualWrap() {
    const checked = this.annualCheckboxTarget.checked
    this.annualWrapTarget.classList.toggle("d-none", !checked)
    this.annualRadioTargets.forEach((radio) => { radio.disabled = !checked })
  }
}
