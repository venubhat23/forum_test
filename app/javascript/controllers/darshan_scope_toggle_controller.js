import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="darshan-scope-toggle"
export default class extends Controller {
  static targets = [ "radio", "memberWrap", "chapterWrap" ]

  connect() {
    this.sync()
  }

  toggle() {
    this.sync()
  }

  sync() {
    const selected = this.radioTargets.find((radio) => radio.checked)?.value
    this.memberWrapTarget.classList.toggle("d-none", selected !== "member")
    this.chapterWrapTarget.classList.toggle("d-none", selected !== "chapter")
  }
}
