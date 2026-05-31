import { Controller } from "@hotwired/stimulus"

// Chart.js is loaded as a <script> tag (IIFE build) and exposes window.Chart.
export default class extends Controller {
  static values = {
    type:     String,
    labels:   Array,
    datasets: Array,
    options:  { type: Object, default: {} }
  }

  connect() {
    this.chart = new window.Chart(this.element, {
      type: this.typeValue,
      data: { labels: this.labelsValue, datasets: this.datasetsValue },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: true } },
        ...this.optionsValue
      }
    })
  }

  disconnect() {
    this.chart?.destroy()
  }
}
