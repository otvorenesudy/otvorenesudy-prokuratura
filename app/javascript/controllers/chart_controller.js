import { Controller } from "stimulus";

export default class extends Controller {
  initialize() {
    this.colors = ["#00aeef", "#ac3e53", "#73be1e", "#8392ac", "#73be1e", "#d34242", "#e19e41", "#1b325f"];
  }

  setupChartResizing() {
    setTimeout(() => this.resizeChart(), 0);
    (window.onresize = () => this.resizeChart())();
  }

  resizeChart() {
    this.chart.setSize(this.element.offsetWidth);

    const watermarkUrl = this.element.getAttribute("data-watermark-url");

    if (!watermarkUrl) return;
    if (this.watermark) this.watermark.destroy();

    this.watermark = this.chart.renderer.image(
      watermarkUrl,
      this.chart.plotLeft + this.chart.plotSizeX - 125,
      25,
      100,
      25
    );

    this.watermark.element.setAttribute("style", "opacity: 0.25;");
    this.watermark.add();
  }
}
