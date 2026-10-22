import { Controller } from '@hotwired/stimulus';
import { area, color, draw, options } from 'charts';

// The color of each indicator's series; the average of the office's type follows it, darker.
const COLORS = {
  convicted: 0,
  incoming_cases_per_prosecutor: 1,
  filed_prosecutions_per_prosecutor: 2,
  incoming_cases: 3,
  ratio_of_rest_to_incoming_cases: 4,
  prosecutors_count: 5,
  rest_cases: 6,
};

// An office's indicators by year, each beside the average of the offices of its type. The legend lists the office's
// indicators; showing or hiding one shows or hides its average with it.
export default class extends Controller {
  static targets = ['canvas'];
  static values = { years: Array, series: Array, watermark: String };

  connect() {
    const hidden = new Set(this.seriesValue.filter(({ visible }) => visible === false).map(({ id }) => id));
    const datasets = this.seriesValue.map(({ id, name, data, dependent }) => ({
      label: name,
      id,
      dependent,
      data: (data || []).map((value) => (value === null ? null : Math.round(value * 100) / 100)),
      hidden: hidden.has(id ?? dependent),
      ...area(color(COLORS[id ?? dependent]), { brightness: dependent ? -0.25 : 0 }),
    }));

    const config = options({ legend: true, shared: true, watermark: this.watermarkValue });
    config.plugins.legend.labels.filter = ({ datasetIndex }, { datasets }) => !datasets[datasetIndex].dependent;
    config.plugins.legend.onClick = (_event, { datasetIndex }) => this.toggle(datasetIndex);

    this.chart = draw(this.canvasTarget, {
      type: 'line',
      data: { labels: this.yearsValue, datasets },
      options: config,
    });
  }

  disconnect() {
    this.chart?.destroy();
  }

  toggle(index) {
    const { datasets } = this.chart.data;
    const visible = !this.chart.isDatasetVisible(index);

    datasets.forEach((dataset, other) => {
      if (other === index || dataset.dependent === datasets[index].id) this.chart.setDatasetVisibility(other, visible);
    });

    this.chart.update();
  }
}
