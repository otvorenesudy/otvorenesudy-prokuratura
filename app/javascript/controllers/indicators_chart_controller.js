import ChartController from "./chart_controller";
import Highcharts from "highcharts";

export default class extends ChartController {
  async connect() {
    const { years: categories, data } = JSON.parse(this.element.getAttribute("data-json"));

    const colorsByID = {
      convicted: this.colors[0],
      incoming_cases_per_prosecutor: this.colors[1],
      filed_prosecutions_per_prosecutor: this.colors[2],
      prosecutors_count: this.colors[5],
      rest_cases: this.colors[6],
      incoming_cases: this.colors[3],
      ratio_of_rest_to_incoming_cases: this.colors[4],
    };

    const series = data.map((value, i) => ({
      ...value,

      data: (value.data || []).map((value) => Math.round(value * 100) / 100),
      linkedTo: value.dependent,

      color: Highcharts.Color(colorsByID[value.id || value.dependent])
        .brighten(value.dependent ? -0.25 : 0)
        .get("rgb"),

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
            Highcharts.Color(colorsByID[value.id || value.dependent])
              .setOpacity(0.15)
              .brighten(value.dependent ? -0.25 : 0)
              .get("rgba"),
          ],
          [
            1,
            Highcharts.Color(colorsByID[value.id || value.dependent])
              .setOpacity(0)
              .brighten(value.dependent ? -0.25 : 0)
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
        itemMarginTop: 2,
        itemMarginBottom: 2,
        floating: true,
        itemStyle: {
          fontWeight: "normal",
        },
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

        maxPadding: 0.75,
      },

      series,
    });

    setTimeout(() => this.resizeChart(), 0);
    (window.onresize = () => this.resizeChart())();
  }
}
