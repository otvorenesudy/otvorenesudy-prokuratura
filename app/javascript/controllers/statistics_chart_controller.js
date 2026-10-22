import { Controller } from '@hotwired/stimulus';
import { area, color, column, draw, options } from 'charts';

// The prosecutors' criminality statistics by year: the series compared (all offices, each office or each paragraph)
// as columns when there are few of them or few years, otherwise as lines, without their areas when there are many.
export default class extends Controller {
  static targets = ['canvas'];
  static values = { data: Object, comparison: String, animated: { type: Boolean, default: true }, watermark: String };

  connect() {
    const { years, data } = this.dataValue;
    const names = [...new Set(data.filter((series) => series[this.comparisonValue]).map(({ name }) => name))];
    const series = data.filter(({ name }) => names.includes(name));
    const columns = names.length < 2 || (years.length <= 3 && names.length <= 5) || years.length === 1;

    const datasets = series.map(({ name, data: values }, index) => ({
      label: name,
      data: values,
      ...(columns ? column(color(index), COLUMN_STOPS) : area(color(index), { filled: names.length <= 20 })),
    }));

    const config = options({ animated: this.animatedValue, watermark: this.watermarkValue });

    this.chart = draw(this.canvasTarget, {
      type: columns ? 'bar' : 'line',
      data: { labels: years, datasets },
      options: config,
    });
  }

  disconnect() {
    this.chart?.destroy();
  }
}

const COLUMN_STOPS = [
  [0, 1],
  [0.75, 0.65],
  [1, 0.35],
];
