import { Controller } from "stimulus";
import Highcharts from "highcharts";

export default class extends Controller {
  initialize() {
    const data = JSON.parse(this.element.getAttribute("data-json"));
    const categories = Object.keys(
      data.reduce((acc, data) => [...acc, ...data.years], []).reduce((acc, year) => ({ ...acc, [year]: 1 }), {})
    );

    Highcharts.chart("chart", {
      credits: {
        enabled: false,
      },

      chart: {
        type: "areaspline",
        backgroundColor: "transparent",
        height: 750,
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

      plotOptions: {
        series: {
          fillOpacity: 0,
          marker: {
            radius: 4,
            symbol: "circle",
            fillColor: "white",
            lineColor: null,
            lineWidth: 1,
          },
        },
      },

      legend: {
        align: "center",
        verticalAlign: "bottom",
        x: 0,
        y: 0,
        maxHeight: 1,
      },

      series: data,
    });
  }
}
