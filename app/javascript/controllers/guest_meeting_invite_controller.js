import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="guest-meeting-invite"
//
// Shows the "ask the guest to pay" checkbox only when the selected meeting
// actually has a fee attached.
export default class extends Controller {
  static targets = [ "select", "feeOption" ]

  toggleFee() {
    const option = this.selectTarget.selectedOptions[0]
    const hasFee = option && option.dataset.fee && parseFloat(option.dataset.fee) > 0
    this.feeOptionTarget.classList.toggle("d-none", !hasFee)
  }
}
