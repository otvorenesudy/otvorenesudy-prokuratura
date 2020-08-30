import { Controller } from "stimulus";
import Highcharts from "highcharts";

export default class extends Controller {
  initialize() {
    const { years: categories, data } = JSON.parse(this.element.getAttribute("data-json"));

    this.chart = Highcharts.chart(this.element.getElementsByClassName("chart")[0], {
      credits: {
        enabled: false,
      },

      chart: {
        type: "areaspline",
        backgroundColor: "transparent",
        height: 500,
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
        enabled: false,
      },

      series: data,
    });

    setTimeout(() => this.chart.setSize(this.element.offsetWidth), 0);

    (window.onresize = () => {
      this.chart.setSize(this.element.offsetWidth);
    })();
  }
}
