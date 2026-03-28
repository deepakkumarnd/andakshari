import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "tags", "suggestions", "tag"]
  static values = { url: String, fieldName: String }

  connect() {
    this.selectedIndex = -1
  }

  async suggest() {
    const query = this.inputTarget.value.trim()
    if (query.length === 0) {
      this.hideSuggestions()
      return
    }

    const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
    const tags = await response.json()
    const existing = this.currentTags()
    const filtered = tags.filter(t => !existing.includes(t))

    if (filtered.length === 0) {
      this.hideSuggestions()
      return
    }

    this.selectedIndex = -1
    this.suggestionsTarget.innerHTML = filtered.map((tag) =>
      `<li class="px-3 py-2 cursor-pointer hover:bg-gray-100 text-sm" data-action="click->tag-input#selectSuggestion" data-tag="${tag}">${tag}</li>`
    ).join("")
    this.suggestionsTarget.classList.remove("hidden")
  }

  keydown(event) {
    const items = this.suggestionsTarget.querySelectorAll("li")

    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
      this.highlightItem(items)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
      this.highlightItem(items)
    } else if (event.key === "Enter") {
      event.preventDefault()
      if (this.selectedIndex >= 0 && items[this.selectedIndex]) {
        this.addTag(items[this.selectedIndex].dataset.tag)
      } else {
        const value = this.inputTarget.value.trim()
        if (value && /^[a-zA-Z0-9]+$/.test(value)) {
          this.addTag(value)
        }
      }
    }
  }

  selectSuggestion(event) {
    this.addTag(event.currentTarget.dataset.tag)
  }

  addTag(name) {
    if (this.currentTags().includes(name)) return

    const span = document.createElement("span")
    span.className = "inline-flex items-center gap-1 bg-gray-200 text-gray-700 px-2 py-1 rounded-md text-sm"
    span.dataset.tagInputTarget = "tag"

    const hidden = document.createElement("input")
    hidden.type = "hidden"
    hidden.name = this.fieldNameValue
    hidden.value = name

    const removeBtn = document.createElement("button")
    removeBtn.type = "button"
    removeBtn.dataset.action = "tag-input#removeTag"
    removeBtn.className = "text-gray-500 hover:text-gray-800 cursor-pointer"
    removeBtn.textContent = "×"

    span.appendChild(document.createTextNode(name))
    span.appendChild(hidden)
    span.appendChild(removeBtn)
    this.tagsTarget.appendChild(span)

    this.inputTarget.value = ""
    this.hideSuggestions()
  }

  removeTag(event) {
    event.currentTarget.closest("[data-tag-input-target='tag']").remove()
  }

  currentTags() {
    return this.tagTargets.map(el => el.textContent.trim().replace("×", "").trim())
  }

  highlightItem(items) {
    items.forEach((item, i) => {
      item.classList.toggle("bg-gray-100", i === this.selectedIndex)
    })
  }

  hideSuggestions() {
    this.suggestionsTarget.classList.add("hidden")
    this.suggestionsTarget.innerHTML = ""
    this.selectedIndex = -1
  }
}
