import ChartController from "./chart_controller";
import Highcharts from "highcharts";

export default class extends ChartController {
  async connect() {
    const categories = [
      "Bratislava I",
      "Dunajská Streda",
      "Prievidza",
      "Piešťany",
      "Nitra",
      "Komárno",
      "Nové Mesto n./V",
      "Košice I",
      "Bratislava III",
      "Pezinok",
      "Nové Zámky",
      "P. Bystrica",
      "Bratislava II",
      "Vranov n./Topľou",
      "Partizánske",
      "Skalica",
      "Košice II",
      "Levice",
      "Trnava",
      "Martin",
      "Poprad",
      "Dolný Kubín",
      "Banská Bystrica",
      "Senica",
      "Spišská Nová Ves",
      "Topoľčany",
      "Námestovo",
      "Veľký Krtíš",
      "Čadca",
      "Bardejov",
      "L. Mikuláš",
      "Bratislava IV",
      "Zvolen",
      "Galanta",
      "Prešov",
      "Ružomberok",
      "Humenné",
      "Bánovce n./Bebravou",
      "Svidník",
      "Bratislava V",
      "Žiar n./Hronom",
      "Rimavská Sobota",
      "Michalovce",
      "Žilina",
      "Malacky",
      "Trenčín",
      "Trebišov",
      "Rožňava",
      "Lučenec",
      "Stará Ľubovňa",
      "Košice - okolie",
      "Revúca",
      "Brezno",
      "Kežmarok",
    ];

    const data = [
      {
        name: "Nápad vecí dozoru",
        data: [
          1541,
          1143,
          1083,
          579,
          2287,
          1004,
          698,
          1727,
          2254,
          695,
          1082,
          781,
          2156,
          768,
          457,
          489,
          2189,
          1154,
          2140,
          1126,
          1245,
          279,
          1319,
          692,
          1397,
          610,
          552,
          489,
          707,
          691,
          906,
          895,
          1437,
          1702,
          2041,
          625,
          1000,
          403,
          391,
          1803,
          765,
          896,
          1696,
          2505,
          917,
          1559,
          1233,
          704,
          1270,
          473,
          1335,
          567,
          648,
          680,
        ],
      },

      {
        name: "Prenesené veci z predchádzajúceho obdobia",
        data: [
          1211,
          859,
          713,
          377,
          1407,
          601,
          394,
          969,
          1250,
          379,
          587,
          405,
          1117,
          397,
          233,
          248,
          1109,
          582,
          1063,
          555,
          606,
          134,
          629,
          329,
          635,
          273,
          243,
          211,
          305,
          295,
          385,
          378,
          595,
          699,
          825,
          249,
          395,
          157,
          151,
          692,
          293,
          340,
          631,
          926,
          337,
          572,
          447,
          251,
          431,
          158,
          443,
          177,
          201,
          198,
        ],
      },
    ];

    const colorsByName = {
      "Nápad vecí dozoru": this.colors[0],
      "Prenesené veci z predchádzajúceho obdobia": this.colors[1],
    };

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
        type: "column",
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
