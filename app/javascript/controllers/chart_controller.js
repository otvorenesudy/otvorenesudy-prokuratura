import { Controller } from "stimulus";
import Highcharts from "highcharts";

export default class extends Controller {
  connect() {
    this.colors = ["#00aeef", "#ac3e53", "#73be1e", "#8392ac", "#73be1e", "#d34242", "#e19e41", "#1b325f"];

    const { years: categories, data } = JSON.parse(this.element.getAttribute("data-json"));
    const selectedOffices = JSON.parse(this.element.getAttribute("data-selected-offices"));

    const series = data.filter(({ name }) => selectedOffices.includes(name));
    const chartOptions =
      selectedOffices.length < 2 || categories.length < 2
        ? this.barChartOptions(series)
        : this.lineChartOptions(series);

    this.chart = Highcharts.chart(this.element.getElementsByClassName("chart")[0], {
      ...chartOptions,

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
    });

    setTimeout(() => this.chart.setSize(this.element.offsetWidth), 0);

    (window.onresize = () => {
      this.chart.setSize(this.element.offsetWidth);
    })();
  }

  lineChartOptions(data) {
    const series =
      data.length > this.colors.length
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

      plotOptions: {
        series: {
          fillOpacity: 0,
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
    };
  }
}
