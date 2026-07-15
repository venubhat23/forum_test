import { Controller } from "@hotwired/stimulus"

const CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$%&*"
const LENGTH = 14

// Connects to data-controller="password-generator"
export default class extends Controller {
  static targets = ["password", "confirmation"]

  generate() {
    const value = this.randomPassword()
    this.passwordTarget.value = value
    this.confirmationTarget.value = value
    this.reveal(this.passwordTarget)
    this.reveal(this.confirmationTarget)
  }

  reveal(input) {
    input.type = "text"
    const icon = input.closest("[data-controller~='password-toggle']")?.querySelector("[data-password-toggle-target='icon']")
    if (icon) {
      icon.classList.remove("bi-eye")
      icon.classList.add("bi-eye-slash")
    }
  }

  randomPassword() {
    const values = new Uint32Array(LENGTH)
    crypto.getRandomValues(values)
    return Array.from(values, (v) => CHARS[v % CHARS.length]).join("")
  }
}
