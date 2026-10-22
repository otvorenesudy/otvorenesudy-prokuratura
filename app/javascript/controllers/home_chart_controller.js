import { Controller } from '@hotwired/stimulus';
import charts from 'home_charts';
import { area, color, column, draw, line, options } from 'charts';

// One of the home page's charts (home_charts.js): each office's or year's columns stacked, an average as a line, or
// areas. Its legend shows and hides a series, some of which start hidden.
export default class extends Controller {
  static targets = ['canvas'];
  static values = { name: String, watermark: String };

  connect() {
    const { labels, series } = charts[this.nameValue];
    const stacked = series.some(({ type }) => type === 'column');
    const datasets = series.map(({ name, type, color: index, hidden, data }) => ({
      label: name,
      data,
      hidden: Boolean(hidden),
      ...style(type, color(index)),
    }));

    const config = options({ legend: true, shared: true, watermark: this.watermarkValue });
    config.scales.x.stacked = stacked;
    config.scales.y.stacked = stacked;

    this.chart = draw(this.canvasTarget, {
      type: stacked ? 'bar' : 'line',
      data: { labels, datasets },
      options: config,
    });
  }

  disconnect() {
    this.chart?.destroy();
  }
}

function style(type, hex) {
  if (type === 'line') return line(hex);
  if (type === 'area') return area(hex);

  return column(hex, [
    [0, 1],
    [1, 0.25],
  ]);
}
