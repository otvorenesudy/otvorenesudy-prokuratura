import ChartController from "./chart_controller";
import Highcharts from "highcharts";
import { compact } from "lodash";
import { convertSkkToEur } from "../helpers/money.helper";

export default class extends ChartController {
  connect() {
    const { years: categories, data } = JSON.parse(this.element.getAttribute("data-json"));

    this.chartData = data;
    this.categories = categories;

    this.prepareSeries();

    const yAxis = this.yAxisOptions();

    this.chart = Highcharts.chart(this.element.getElementsByClassName("chart")[0], {
      colors: this.colors,

      chart: {
        backgroundColor: "transparent",
        height: 500,
      },

      credits: {
        enabled: false,
      },

      title: {
        text: undefined,
      },

      xAxis: {
        categories: this.categories,
      },

      yAxis: yAxis,

      legend: {
        enabled: true,
        align: "left",
        verticalAlign: "top",
        width: "50%",
        y: 5,
        x: 50,
        itemMarginBottom: 5,
        floating: true,
      },

      plotOptions: {
        series: {
          animation: this.element.getAttribute("data-animation") === "false" ? null : { duration: 1000 },
        },
      },

      series: this.series,
    });

    this.setupChartResizing();
  }

  prepareSeries() {
    const comparison = this.element.getAttribute("data-comparison");

    this.seriesNames = [...new Set(this.chartData.filter((e) => e.comparison === comparison).map(({ name }) => name))];

    this.series = this.chartData
      .sort((a, b) => (a.monetary ? -1 : 1))
      .filter(({ name }) => this.seriesNames.includes(name))
      .map((series, i) => {
        const color = this.colors[i % this.colors.length];

        if (series.monetary) {
          series = {
            ...series,

            data: [
              ...series.data.slice(0, 12).map((e, i) => convertSkkToEur(e, this.categories[i])),
              ...series.data.slice(12, series.data.length),
            ],

            tooltip: {
              valueSuffix: " €",
            },

            yAxis: 1,
            index: 1,

            ...this.barChartOptions(color),
          };
        } else {
          series = {
            ...series,
            ...this.lineChartOptions(color),

            index: 0,
          };
        }

        return series;
      });
  }

  yAxisOptions() {
    const hasNonMonetarySeries = this.series.filter((e) => !e.monetary).length > 0;
    const hasMonetarySeries = this.series.filter((e) => e.monetary).length > 0;
    let monetaryAxis;

    if (hasMonetarySeries) {
      monetaryAxis = {
        title: {
          text: undefined,
        },
        labels: {
          formatter: ({ value }) => `${value.toLocaleString()} €`,
        },
        opposite: hasNonMonetarySeries ? true : false,
      };
    }

    return compact([
      {
        title: {
          text: undefined,
        },
      },
      monetaryAxis,
    ]);
  }

  lineChartOptions(color) {
    return {
      type: "areaspline",
      color: color,
      fillColor: {
        linearGradient: {
          x1: 1,
          y1: 0,
          x2: 1,
          y2: 1,
        },
        stops: [
          [0, Highcharts.Color(color).setOpacity(0.15).get("rgba")],
          [1, Highcharts.Color(color).setOpacity(0).get("rgba")],
        ],
      },
      fillOpacity: 0,
      marker: {
        radius: 4,
        symbol: "dot",
        fillColor: "white",
        lineColor: null,
        lineWidth: 1,
      },
    };
  }

  barChartOptions(color) {
    return {
      type: "column",
      borderColor: "transparent",
      color: {
        linearGradient: {
          x1: 1,
          y1: 0,
          x2: 1,
          y2: 1,
        },
        stops: [
          [0, Highcharts.Color(color).setOpacity(0.65).get("rgba")],
          [0.5, Highcharts.Color(color).setOpacity(0.45).get("rgba")],
          [0.75, Highcharts.Color(color).setOpacity(0.25).get("rgba")],
        ],
      },
    };
  }
}
