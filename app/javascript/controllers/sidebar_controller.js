import { Controller } from "@hotwired/stimulus"

// Toggles a body-level class so CSS can slide the sidebar in as an overlay
// on small screens. Used by the hamburger button on the topbar.
export default class extends Controller {
  toggle() {
    document.body.classList.toggle("sidebar-open")
  }

  close() {
    document.body.classList.remove("sidebar-open")
  }
}
