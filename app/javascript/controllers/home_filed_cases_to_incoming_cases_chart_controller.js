import ChartController from "./chart_controller";
import Highcharts from "highcharts";

export default class extends ChartController {
  async connect() {
    const categories = [
      "Rimavská Sobota",
      "Revúca",
      "Čadca",
      "Galanta",
      "Levice",
      "Lučenec",
      "Košice - okolie",
      "Trebišov",
      "Skalica",
      "Dunajská Streda",
      "Námestovo",
      "Bardejov",
      "Humenné",
      "Veľký Krtíš",
      "Kežmarok",
      "Vranov n./Topľou",
      "Michalovce",
      "Rožňava",
      "Stará Ľubovňa",
      "Brezno",
      "Zvolen",
      "Svidník",
      "Žiar n./Hronom",
      "Komárno",
      "Malacky",
      "Prievidza",
      "Bratislava II",
      "Nové Mesto n./V",
      "Prešov",
      "Nové Zámky",
      "Spišská Nová Ves",
      "Bratislava IV",
      "Martin",
      "Bánovce n./Bebravou",
      "Dolný Kubín",
      "Košice II",
      "Partizánske",
      "Trnava",
      "Bratislava III",
      "Nitra",
      "Topoľčany",
      "Bratislava V",
      "Žilina",
      "Senica",
      "Poprad",
      "Bratislava I",
      "P. Bystrica",
      "Pezinok",
      "Banská Bystrica",
      "Trenčín",
      "Ružomberok",
      "Piešťany",
      "L. Mikuláš",
      "Košice I",
    ];

    const data = [
      {
        name: "Pomer",
        data: [
          54,
          53,
          53,
          49,
          49,
          49,
          49,
          47,
          47,
          47,
          47,
          47,
          47,
          47,
          46,
          45,
          45,
          45,
          45,
          45,
          44,
          44,
          44,
          44,
          43,
          43,
          41,
          41,
          40,
          40,
          38,
          38,
          38,
          37,
          37,
          36,
          36,
          36,
          36,
          36,
          35,
          35,
          34,
          34,
          33,
          32,
          32,
          31,
          31,
          31,
          30,
          29,
          28,
        ],
      },

      {
        name: "Priemer",
        type: "line",
        data: [
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
          41,
        ],
      },
    ];

    const colorsByName = {
      Pomer: this.colors[0],
      Priemer: this.colors[1],
    };

    const series = data.map((value, i) => ({
      type: "column",

      ...value,

      color:
        value.type === "line"
          ? Highcharts.Color(colorsByName[value.name]).setOpacity(0.75).get("rgba")
          : {
              linearGradient: {
                x1: 1,
                y1: 0,
                x2: 1,
                y2: 1,
              },

              stops: [
                [0, Highcharts.Color(colorsByName[value.name]).setOpacity(1).get("rgba")],
                [1, Highcharts.Color(colorsByName[value.name]).setOpacity(0.25).get("rgba")],
              ],
            },
    }));

    this.chart = Highcharts.chart(this.element, {
      colors: this.colors,

      credits: {
        enabled: false,
      },

      chart: {
        type: "xy",
        backgroundColor: "transparent",
        height: 400,
      },

      legend: {
        enabled: true,
        layout: "horizontal",
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

      title: {
        text: undefined,
      },

      xAxis: [{ categories }],

      yAxis: {
        title: {
          text: undefined,
        },

        maxPadding: 0.75,
      },

      plotOptions: {
        line: {
          fillOpacity: 0,
          lineWidth: 2,
          marker: {
            radius: 0,
          },
        },

        column: {
          stacking: "normal",
        },
      },

      series,
    });

    setTimeout(() => this.resizeChart(), 0);
    (window.onresize = () => this.resizeChart())();
  }
}
