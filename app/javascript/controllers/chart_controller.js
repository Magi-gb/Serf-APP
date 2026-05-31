import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"

Chart.register(...registerables)

export default class extends Controller {
  static values = {
    type:     String,
    labels:   Array,
    datasets: Array,
    options:  { type: Object, default: {} }
  }

  connect() {
    this.chart = new Chart(this.element, {
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
