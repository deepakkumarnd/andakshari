import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  copy() {
    navigator.clipboard.writeText(this.textValue).then(() => {
      this._toast("Lyrics copied")
    })
  }

  _toast(message) {
    const el = document.createElement("div")
    el.setAttribute("data-controller", "toast")
    el.className = "flex items-start gap-3 bg-white border border-green-200 text-green-800 text-sm font-medium px-4 py-3 rounded-xl shadow-lg transition-all duration-300 max-w-sm"
    el.innerHTML = `<span class="flex-1">${message}</span><button data-action="click->toast#dismiss" class="text-green-500 hover:text-green-700 leading-none mt-0.5">&times;</button>`

    const container = document.querySelector("[id='toast-container']") ||
                      document.querySelector(".fixed.top-20.right-4")
    if (container) {
      container.appendChild(el)
    } else {
      el.classList.add("fixed", "top-20", "right-4", "z-50")
      document.body.appendChild(el)
    }
  }
}
