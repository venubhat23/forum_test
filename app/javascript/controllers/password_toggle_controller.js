import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="password-toggle"
export default class extends Controller {
  static targets = ["input", "icon"]

  toggle() {
    const isPassword = this.inputTarget.type === "password"
    this.inputTarget.type = isPassword ? "text" : "password"
    this.iconTarget.classList.toggle("bi-eye", !isPassword)
    this.iconTarget.classList.toggle("bi-eye-slash", isPassword)
  }
}
