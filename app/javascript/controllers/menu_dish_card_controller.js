import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["restrictionCheckbox", "alternativesContainer", "alternativesList"]
  static values = { dishId: Number, menuPath: String }

  connect() {
    this.updateRestrictionStyles()
  }

  toggleRestriction(event) {
    event.preventDefault()
    const label = event.currentTarget
    const checkbox = label.querySelector('input[type="checkbox"]')
    checkbox.checked = !checkbox.checked
    this.updateRestrictionStyles()
    this.loadAlternatives()
  }

  updateRestrictionStyles() {
    this.restrictionCheckboxTargets.forEach(checkbox => {
      const label = checkbox.closest("label")
      if (checkbox.checked) {
        label.classList.remove("unchecked")
      } else {
        label.classList.add("unchecked")
      }
    })
  }

  async loadAlternatives() {
    const uncheckedIds = Array.from(this.restrictionCheckboxTargets)
      .filter(checkbox => !checkbox.checked)
      .map(checkbox => checkbox.dataset.restrictionId)

    const hasUnchecked = uncheckedIds.length > 0

    if (!hasUnchecked) {
      this.alternativesContainerTarget.classList.add("hidden")
      return
    }

    this.alternativesContainerTarget.classList.remove("hidden")

    const excludedIds = uncheckedIds.join(",")
    const url = new URL(this.menuPathValue, window.location.origin)
    url.searchParams.set("dish_id", this.dishIdValue)
    url.searchParams.set("excluded_restrictions", excludedIds)

    try {
      const response = await fetch(url.toString())
      if (response.ok) {
        const html = await response.text()
        this.alternativesListTarget.innerHTML = html
      }
    } catch (error) {
      console.error("Error loading alternatives:", error)
    }
  }
}

