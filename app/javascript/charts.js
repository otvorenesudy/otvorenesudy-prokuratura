// What the charts share, on Chart.js: the colors, the series' looks (columns filled with a fading gradient, smooth
// lines over a fading area with white dots, plain lines for averages), the brand watermark and the common options.
import { Chart, registerables } from 'chart.js';

Chart.register(...registerables);

Chart.defaults.font.family = 'Ubuntu, sans-serif';
Chart.defaults.color = '#1b325f';

export const COLORS = ['#00aeef', '#ac3e53', '#73be1e', '#8392ac', '#d34242', '#e19e41', '#1b325f'];

const GRID_COLOR = '#e6e6e6';

export function color(index) {
  return COLORS[index % COLORS.length];
}

// The color with the given opacity; a negative brightness darkens it (Highcharts' brighten).
export function rgba(hex, opacity = 1, brightness = 0) {
  const channels = [1, 3, 5].map((start) => parseInt(hex.slice(start, start + 2), 16));
  const [red, green, blue] = channels.map((value) => Math.min(255, Math.max(0, Math.round(value + 255 * brightness))));

  return `rgba(${red}, ${green}, ${blue}, ${opacity})`;
}

// A vertical gradient over the chart's plot, from the top down, through [offset, opacity] stops.
export function gradient(hex, stops, brightness = 0) {
  return ({ chart }) => {
    const { ctx, chartArea } = chart;
    if (!chartArea) return rgba(hex, stops[0][1], brightness);

    const fill = ctx.createLinearGradient(0, chartArea.top, 0, chartArea.bottom);
    stops.forEach(([offset, opacity]) => fill.addColorStop(offset, rgba(hex, opacity, brightness)));

    return fill;
  };
}

// A smooth line over an area fading downwards, with white dots; many series together leave the area out.
export function area(hex, { brightness = 0, filled = true } = {}) {
  const line = rgba(hex, 1, brightness);

  return {
    type: 'line',
    tension: 0.4,
    borderColor: line,
    borderWidth: 2,
    backgroundColor: filled
      ? gradient(
          hex,
          [
            [0, 0.15],
            [1, 0],
          ],
          brightness,
        )
      : 'transparent',
    fill: filled ? 'origin' : false,
    pointRadius: 4,
    pointHoverRadius: 5,
    pointBackgroundColor: '#fff',
    pointBorderColor: line,
    pointBorderWidth: 1,
  };
}

// Columns filled with a gradient through [offset, opacity] stops.
export function column(hex, stops) {
  return { type: 'bar', backgroundColor: gradient(hex, stops), borderWidth: 0 };
}

// A straight line without dots, for an average.
export function line(hex) {
  const stroke = rgba(hex, 0.75);

  return { type: 'line', borderColor: stroke, backgroundColor: stroke, borderWidth: 2, pointRadius: 0, fill: false };
}

// The brand at the top right of the plot, faded, so a shared picture of the chart says where it's from.
const watermark = {
  id: 'watermark',
  afterDraw(chart, _arguments, { image }) {
    if (!image?.complete || !image.naturalWidth) return;

    const { ctx, chartArea } = chart;

    ctx.save();
    ctx.globalAlpha = 0.25;
    ctx.drawImage(image, chartArea.right - 125, chartArea.top + 10, 100, 25);
    ctx.restore();
  },
};

// Options every chart starts from: it fills its container (whose height the stylesheet sets), animates unless told
// not to, and shows numbers in the page's language.
export function options({ animated = true, legend = false, shared = false, watermark: url } = {}) {
  return {
    responsive: true,
    maintainAspectRatio: false,
    animation: animated ? { duration: 1000 } : false,
    locale: document.documentElement.lang || 'sk',
    interaction: shared ? { mode: 'index', intersect: false } : { mode: 'nearest', intersect: true },
    scales: {
      x: { grid: { display: false } },
      y: { beginAtZero: true, grid: { color: GRID_COLOR } },
    },
    plugins: {
      legend: { display: legend, position: 'top', align: 'start', labels: { boxWidth: 12, boxHeight: 12 } },
      tooltip: {
        backgroundColor: 'rgba(247, 247, 247, 0.95)',
        titleColor: '#333',
        bodyColor: '#333',
        borderColor: '#d1dee8',
        borderWidth: 1,
      },
      watermark: { image: url ? load(url) : null },
    },
  };
}

// Draws the chart on the canvas, and redraws it once the watermark has loaded. The canvas is marked as drawn.
export function draw(canvas, config) {
  const chart = new Chart(canvas, { ...config, plugins: [watermark] });
  const image = config.options.plugins.watermark.image;

  image?.addEventListener('load', () => chart.draw(), { once: true });
  canvas.dataset.chartDrawn = '';

  return chart;
}

function load(url) {
  const image = new Image();
  image.src = url;

  return image;
}
