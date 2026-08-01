import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image-preview"
//
// Shows a thumbnail of whatever image file was just picked in a file input,
// so the person can confirm it's the right one before submitting.
export default class extends Controller {
  static targets = [ "input", "wrapper", "image" ]

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (event) => {
      this.imageTarget.src = event.target.result
      this.wrapperTarget.classList.remove("d-none")
    }
    reader.readAsDataURL(file)
  }
}
