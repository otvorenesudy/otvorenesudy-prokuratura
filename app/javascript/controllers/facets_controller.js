import { Controller } from "stimulus";

export default class extends Controller {
  initialize() {
    $(this.element)
      .find("#facets")
      .on("hide.bs.collapse", () => {
        const element = this.element.querySelectorAll("[data-results-for-facets]")[0];

        this.resultsClassName = element.className;
        element.className += " col-lg-12";

        window.onresize();
      });

    $(this.element)
      .find("#facets")
      .on("show.bs.collapse", () => {
        const element = this.element.querySelectorAll("[data-results-for-facets]")[0];

        element.className = element.className.replace("col-lg-12", "");

        window.onresize();
      });
  }
}
