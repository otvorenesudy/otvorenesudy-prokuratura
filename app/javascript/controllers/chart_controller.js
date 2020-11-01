import { Controller } from "stimulus";
import Highcharts from "highcharts";

export default class extends Controller {
  connect() {
    this.colors = ["#00aeef", "#ac3e53", "#73be1e", "#8392ac", "#73be1e", "#d34242", "#e19e41", "#1b325f"];

    const { years: categories, data } = JSON.parse(this.element.getAttribute("data-json"));
    const comparison = this.element.getAttribute("data-comparison");

    this.seriesNames = [...new Set(data.filter((e) => e[comparison]).map(({ name }) => name))];

    const series = data.filter(({ name }) => this.seriesNames.includes(name));
    const chartOptions =
      this.seriesNames.length < 2 || (categories.length <= 3 && this.seriesNames.length <= 5) || categories.length == 1
        ? this.barChartOptions(series)
        : this.lineChartOptions(series);

    this.chart = Highcharts.chart(this.element.getElementsByClassName("chart")[0], {
      colors: this.colors,

      credits: {
        enabled: false,
      },

      title: {
        text: undefined,
      },

      xAxis: {
        categories,
      },

      yAxis: {
        title: {
          text: undefined,
        },
      },

      legend: {
        enabled: false,
      },

      ...chartOptions,
    });

    setTimeout(() => this.resizeChart(), 0);
    (window.onresize = () => this.resizeChart())();
  }

  resizeChart() {
    this.chart.setSize(this.element.offsetWidth);

    const watermarkUrl = this.element.getAttribute("data-watermark-url");

    if (!watermarkUrl) return;

    if (this.watermark) this.watermark.destroy();

    this.watermark = this.chart.renderer.image(
      watermarkUrl,
      this.chart.plotLeft + this.chart.plotSizeX - 125,
      25,
      100,
      25
    );
    this.watermark.element.setAttribute("style", "opacity: 0.25;");
    this.watermark.add();
  }

  lineChartOptions(data) {
    const series =
      this.seriesNames.length > 20
        ? data
        : data.map((value, i) => {
            return {
              ...value,
              fillColor: {
                linearGradient: {
                  x1: 1,
                  y1: 0,
                  x2: 1,
                  y2: 1,
                },
                stops: [
                  [
                    0,
                    Highcharts.Color(this.colors[i % this.colors.length])
                      .setOpacity(0.15)
                      .get("rgba"),
                  ],
                  [
                    1,
                    Highcharts.Color(this.colors[i % this.colors.length])
                      .setOpacity(0)
                      .get("rgba"),
                  ],
                ],
              },
            };
          });

    return {
      series,

      chart: {
        type: "areaspline",
        backgroundColor: "transparent",
        height: 500,
      },

      legend: {
        enabled: this.seriesNames.length > 20 ? false : true,
      },

      plotOptions: {
        series: {
          fillOpacity: 0,
          animation: this.element.getAttribute("data-animation") === "false" ? null : { duration: 1000 },
          marker: {
            radius: 4,
            symbol: "dot",
            fillColor: "white",
            lineColor: null,
            lineWidth: 1,
          },
        },
      },
    };
  }

  barChartOptions(data) {
    const series = data.map((value, i) => {
      return {
        ...value,
        color: {
          linearGradient: {
            x1: 1,
            y1: 0,
            x2: 1,
            y2: 1,
          },
          stops: [
            [0, Highcharts.Color(this.colors[i % this.colors.length]).get("rgba")],
            [
              0.75,
              Highcharts.Color(this.colors[i % this.colors.length])
                .setOpacity(0.65)
                .get("rgba"),
            ],
            [
              1,
              Highcharts.Color(this.colors[i % this.colors.length])
                .setOpacity(0.35)
                .get("rgba"),
            ],
          ],
        },
      };
    });

    return {
      series,

      chart: {
        type: "column",
        backgroundColor: "transparent",
        height: 500,
      },

      plotOptions: {
        series: {
          animation: this.element.getAttribute("data-animation") === "false" ? null : { duration: 1000 },
        },
      },
    };
  }
}
