import ChartController from "./chart_controller";
import Highcharts from "highcharts";

export default class extends ChartController {
  async connect() {
    const categories = [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022];

    const colorsByName = {
      "Priemer za okresné prokuratúry": this.colors[0],
      "Priemer za krajské prokuratúry": this.colors[1],
    };

    const data = [
      {
        name: "Priemer za okresné prokuratúry",
        data: [288, 293, 266, 282, 267, 246, 242, 245, 237, 215, 208, 206, 204],
      },

      {
        name: "Priemer za krajské prokuratúry",
        data: [141, 135, 140, 139, 144, 139, 136, 136, 148, 150, 136, 134, 122],
      },
    ];

    const series = data.map((value, i) => ({
      ...value,

      color: Highcharts.Color(colorsByName[value.name]).get("rgb"),

      fillColor: {
        linearGradient: {
          x1: 1,
          y1: 0,
          x2: 1,
          y2: 1,
        },

        stops: [
          [0, Highcharts.Color(colorsByName[value.name]).setOpacity(0.15).get("rgba")],
          [1, Highcharts.Color(colorsByName[value.name]).setOpacity(0).get("rgba")],
        ],
      },
    }));

    this.chart = Highcharts.chart(this.element, {
      colors: this.colors,

      credits: {
        enabled: false,
      },

      chart: {
        type: "areaspline",
        backgroundColor: "transparent",
        height: 300,
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
