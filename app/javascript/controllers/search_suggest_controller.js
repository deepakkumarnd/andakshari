import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions"]
  static values = { url: String }

  connect() {
    this.debounceTimer = null
  }

  disconnect() {
    this.hideSuggestions()
  }

  onInput() {
    clearTimeout(this.debounceTimer)
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.hideSuggestions()
      return
    }

    this.debounceTimer = setTimeout(() => this.fetchSuggestions(query), 300)
  }

  async fetchSuggestions(query) {
    const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
      headers: { "Accept": "text/vnd.turbo-stream.html" }
    })
    const html = await response.text()
    Turbo.renderStreamMessage(html)

    if (this.suggestionsTarget.children.length > 0) {
      this.suggestionsTarget.classList.remove("hidden")
    } else {
      this.hideSuggestions()
    }
  }

  hideSuggestions() {
    this.suggestionsTarget.classList.add("hidden")
    this.suggestionsTarget.innerHTML = ""
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideSuggestions()
    }
  }
}
