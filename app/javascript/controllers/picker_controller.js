import { Controller } from "@hotwired/stimulus"

// Searchable checkbox-card picker.
// - `search` target filters items whose label text doesn't match the query.
// - `count` target is updated with the number of selected items, using
//   I18n strings injected via data-picker-{singular,plural}-template.
// - `onlySelected` toggle hides unchecked items.
// - `empty` target is shown when no item matches the current filters.
export default class extends Controller {
  static targets = ["item", "search", "count", "empty", "onlySelected"]
  static values = {
    singular: String,
    plural: String,
    none: String
  }

  connect() {
    this.refresh()
  }

  refresh() {
    const q = (this.searchTarget.value || "").trim().toLowerCase()
    const onlySelected = this.hasOnlySelectedTarget && this.onlySelectedTarget.getAttribute("aria-pressed") === "true"

    let visible = 0
    let selected = 0

    this.itemTargets.forEach((item) => {
      const text = (item.dataset.searchText || item.textContent).toLowerCase()
      const checkbox = item.querySelector("input[type='checkbox']")
      const checked = checkbox && checkbox.checked
      if (checked) selected += 1

      const matchesQuery = !q || text.includes(q)
      const matchesSelected = !onlySelected || checked

      const show = matchesQuery && matchesSelected
      item.hidden = !show
      if (show) visible += 1
    })

    // Hide empty groups (any element with [data-picker-group] whose visible items count = 0)
    this.element.querySelectorAll("[data-picker-group]").forEach((group) => {
      const groupItems = group.querySelectorAll("[data-picker-target='item']")
      const groupVisible = Array.from(groupItems).some((i) => !i.hidden)
      group.hidden = !groupVisible
    })

    if (this.hasCountTarget) {
      this.countTarget.textContent = this.formatCount(selected)
      this.countTarget.classList.toggle("is-active", selected > 0)
    }

    if (this.hasEmptyTarget) {
      this.emptyTarget.hidden = visible > 0
    }
  }

  toggleOnlySelected(event) {
    const btn = event.currentTarget
    const next = btn.getAttribute("aria-pressed") === "true" ? "false" : "true"
    btn.setAttribute("aria-pressed", next)
    this.refresh()
  }

  // Stop Enter from submitting the surrounding form while the user is typing
  // in the picker search field. It's a filter, not a form input.
  preventSubmit(event) {
    if (event.key === "Enter") {
      event.preventDefault()
    }
  }

  formatCount(n) {
    if (n === 0) return this.singularValue || this.pluralValue || `${n}`
    if (n === 1) return this.singularValue.replace("%{count}", n)
    return this.pluralValue.replace("%{count}", n)
  }
}
