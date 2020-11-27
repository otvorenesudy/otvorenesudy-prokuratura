import ChartController from "./chart_controller";
import Highcharts from "highcharts";

export default class extends ChartController {
  async connect() {
    const { years: categories, data } = JSON.parse(this.element.getAttribute("data-json"));

    const series = data.map((value, i) => ({
      ...value,

      data: (value.data || []).map((value) => Math.round(value * 100) / 100),
      linkedTo: value.dependent,

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

    this.chart = Highcharts.chart(this.element.getElementsByClassName("chart")[0], {
      colors: this.colors,

      credits: {
        enabled: false,
      },

      chart: {
        type: "areaspline",
        backgroundColor: "transparent",
        height: 400,
      },

      legend: {
        enabled: true,
        layout: "vertical",
        align: "left",
        verticalAlign: "top",
        x: 50,
        y: 0,
        itemMarginTop: 5,
        itemMarginBottom: 5,
        floating: true,
      },

      tooltip: {
        shared: true,
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

        maxPadding: 0.5,
      },

      series,
    });

    setTimeout(() => this.resizeChart(), 0);
    (window.onresize = () => this.resizeChart())();
  }
}
