import { Controller } from "stimulus";
import { debounce } from "lodash";
import Rails from "@rails/ujs";

export default class extends Controller {
  initialize() {
    this.onChange = debounce(this.onChange, 500).bind(this);
  }

  get query() {
    return this.targets.find("query").value;
  }

  get url() {
    return this.element.getAttribute("data-url");
  }

  async onChange() {
    const response = await (await fetch(`${this.url}&suggest=${this.query}`)).json();

    this.targets.find("results").innerHTML = response.html;
  }
}
