import { Controller } from "@hotwired/stimulus"

const GOOGLE_INPUT_TOOLS_URL = "https://inputtools.google.com/request?itc=ml-t-i0-und&num=1&cp=0&cs=1&ie=utf-8&oe=utf-8"

export default class extends Controller {
  static targets = ["input", "button"]

  connect() {
    this.active = true
    const btn = this.buttonTarget
    btn.setAttribute("aria-checked", true)
    btn.classList.add("bg-gray-700")
    btn.classList.remove("bg-gray-300")
    btn.querySelector("span").classList.add("translate-x-4")
  }

  toggle() {
    this.active = !this.active
    const btn = this.buttonTarget
    btn.setAttribute("aria-checked", this.active)
    btn.classList.toggle("bg-gray-700", this.active)
    btn.classList.toggle("bg-gray-300", !this.active)
    btn.querySelector("span").classList.toggle("translate-x-4", this.active)
  }

  async onKeydown(event) {
    if (!this.active || event.key !== " ") return

    const input = this.inputTarget
    const cursorPos = input.selectionStart
    const value = input.value
    const textBefore = value.slice(0, cursorPos)

    const wordStart = Math.max(textBefore.lastIndexOf(" "), textBefore.lastIndexOf("\n")) + 1
    const word = textBefore.slice(wordStart)

    if (!word.trim()) return

    event.preventDefault()

    const converted = await this.transliterate(word)
    input.value = value.slice(0, wordStart) + converted + " " + value.slice(cursorPos)
    const newPos = wordStart + converted.length + 1
    input.setSelectionRange(newPos, newPos)
  }

  async convertAll() {
    const text = this.inputTarget.value
    if (!text.trim()) return

    const parts = text.split(/(\s+)/)
    const converted = await Promise.all(
      parts.map(part => /^\s+$/.test(part) ? part : this.transliterate(part))
    )
    this.inputTarget.value = converted.join("")
  }

  async transliterate(word) {
    try {
      const url = `${GOOGLE_INPUT_TOOLS_URL}&text=${encodeURIComponent(word)}`
      const response = await fetch(url)
      const data = await response.json()
      return data[0] === "SUCCESS" ? (data[1]?.[0]?.[1]?.[0] ?? word) : word
    } catch {
      return word
    }
  }
}
