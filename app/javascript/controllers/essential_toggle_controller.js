import { Controller } from "@hotwired/stimulus"

// Shows/hides the Imprescindible/Substituïble segmented toggle when
// an ingredient checkbox is checked. The hidden `input` target is checked
// when the ingredient is SUBSTITUÏBLE (so absent = essential by default).
export default class extends Controller {
  static targets = ["wrap", "essentialBtn", "substituibleBtn", "input"]

  connect() {
    this._syncButtons()
  }

  onCheck(event) {
    const checked = event.target.checked
    this.wrapTarget.hidden = !checked
    if (checked) {
      // Default to essential/mandatory when first selecting an ingredient
      this.inputTarget.checked = false
      this._syncButtons()
    } else {
      this.inputTarget.checked = false
      this._syncButtons()
    }
  }

  setEssential() {
    this.inputTarget.checked = false
    this._syncButtons()
  }

  setSubstituible() {
    this.inputTarget.checked = true
    this._syncButtons()
  }

  _syncButtons() {
    const substituible = this.inputTarget.checked
    this.essentialBtnTarget.classList.toggle("is-active", !substituible)
    this.substituibleBtnTarget.classList.toggle("is-active", substituible)
  }
}
