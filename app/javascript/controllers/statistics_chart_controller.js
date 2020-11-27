import ChartController from "./chart_controller";
import Highcharts from "highcharts";

export default class extends ChartController {
  connect() {
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

    this.setupChartResizing();
  }

  lineChartOptions(data) {
    const series =
      this.seriesNames.length > 20
        ? data
        : data.map((value, i) => ({
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
          }));

    return {
      series,

      chart: {
        type: "areaspline",
        backgroundColor: "transparent",
        height: 500,
      },

      legend: {
        enabled: false,
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
    const series = data.map((value, i) => ({
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
    }));

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
