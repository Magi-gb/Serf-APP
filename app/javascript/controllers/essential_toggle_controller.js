import { Controller } from "@hotwired/stimulus"

// Shows/hides the Imprescindible/Substituïble segmented toggle when
// an ingredient checkbox is checked. Keeps the hidden essential input
// in sync with the active button.
export default class extends Controller {
  static targets = ["wrap", "essentialBtn", "substituibleBtn", "input"]

  connect() {
    this._syncButtons()
  }

  onCheck(event) {
    this.wrapTarget.hidden = !event.target.checked
    if (!event.target.checked) {
      this.inputTarget.checked = false
      this._syncButtons()
    }
  }

  setEssential() {
    this.inputTarget.checked = true
    this._syncButtons()
  }

  setSubstituible() {
    this.inputTarget.checked = false
    this._syncButtons()
  }

  _syncButtons() {
    const essential = this.inputTarget.checked
    this.essentialBtnTarget.classList.toggle("is-active", essential)
    this.substituibleBtnTarget.classList.toggle("is-active", !essential)
  }
}
