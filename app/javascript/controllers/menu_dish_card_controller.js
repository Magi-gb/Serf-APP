import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggleButton", "restrictionCheckbox", "alternativesContainer", "alternativesList"]
  static values = { dishId: Number, menuId: Number, menuPath: String }

  connect() {
    this.loadAlternatives()
  }

  toggleExpand(event) {
    event.preventDefault()
    this.alternativesContainerTarget.classList.toggle("hidden")
  }

  async toggleRestriction(event) {
    const checkbox = event.target
    checkbox.checked = !checkbox.checked
    await this.loadAlternatives()
  }

  async loadAlternatives() {
    const excludedIds = Array.from(this.restrictionCheckboxTargets)
      .filter(checkbox => !checkbox.checked)
      .map(checkbox => checkbox.dataset.restrictionId)
      .join(",")

    const url = new URL(this.menuPathValue, window.location.origin)
    url.searchParams.set("dish_id", this.dishIdValue)
    url.searchParams.set("excluded_restrictions", excludedIds)

    try {
      const response = await fetch(url.toString(), {
        headers: { "Accept": "text/vnd.turbo-stream.html" }
      })
      if (response.ok) {
        const html = await response.text()
        this.alternativesListTarget.innerHTML = html
      }
    } catch (error) {
      console.error("Error loading alternatives:", error)
    }
  }

  updateRestrictionStyle(checkbox) {
    const label = checkbox.closest("label")
    if (checkbox.checked) {
      label.classList.remove("unchecked")
    } else {
      label.classList.add("unchecked")
    }
  }
}
