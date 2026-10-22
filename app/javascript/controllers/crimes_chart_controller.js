import { Controller } from '@hotwired/stimulus';
import { area, color, column, draw, options } from 'charts';

// The police's criminality statistics by year: the counts as lines over their areas, and damages in euros as columns
// on an axis of their own, on the right when counts share the chart.
export default class extends Controller {
  static targets = ['canvas'];
  static values = { data: Object, animated: { type: Boolean, default: true }, watermark: String };

  connect() {
    const { years, data } = this.dataValue;
    const series = [...data.filter(({ monetary }) => monetary), ...data.filter(({ monetary }) => !monetary)];
    const counts = series.some(({ monetary }) => !monetary);
    const damages = series.some(({ monetary }) => monetary);

    const datasets = series.map(({ name, data: values, monetary }, index) => ({
      label: name,
      data: values,
      monetary,
      ...(monetary ? { ...column(color(index), DAMAGE_STOPS), yAxisID: 'damages', order: 1 } : area(color(index))),
    }));

    const config = options({ animated: this.animatedValue, legend: true, watermark: this.watermarkValue });
    config.plugins.tooltip.callbacks = { label: label(config.locale) };

    if (damages) {
      config.scales.damages = {
        position: counts ? 'right' : 'left',
        beginAtZero: true,
        grid: { drawOnChartArea: !counts },
        ticks: { callback: (value) => `${value.toLocaleString(config.locale)} €` },
      };
    }

    if (!counts) config.scales.y.display = false;

    this.chart = draw(this.canvasTarget, {
      type: damages ? 'bar' : 'line',
      data: { labels: years, datasets },
      options: config,
    });
  }

  disconnect() {
    this.chart?.destroy();
  }
}

const DAMAGE_STOPS = [
  [0, 0.65],
  [0.5, 0.45],
  [0.75, 0.25],
];

// A point in the tooltip: the series and its value, damages in euros.
function label(locale) {
  return ({ dataset, parsed }) => {
    const value = parsed.y.toLocaleString(locale);

    return `${dataset.label}: ${dataset.monetary ? `${value} €` : value}`;
  };
}
