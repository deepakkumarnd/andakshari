import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  connect() {
    this._handleOutsideClick = this._handleOutsideClick.bind(this)
  }

  toggle(event) {
    event.stopPropagation()
    if (this.panelTarget.classList.contains("hidden")) {
      this.panelTarget.classList.remove("hidden")
      document.addEventListener("click", this._handleOutsideClick)
    } else {
      this._close()
    }
  }

  _close() {
    this.panelTarget.classList.add("hidden")
    document.removeEventListener("click", this._handleOutsideClick)
  }

  _handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this._close()
    }
  }

  disconnect() {
    document.removeEventListener("click", this._handleOutsideClick)
  }
}
