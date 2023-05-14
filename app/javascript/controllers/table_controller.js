import { Controller } from "stimulus";
import $ from "jquery";
import "tablesorter";

$.extend($.tablesorter.characterEquivalents, {
  a: "áä",
  A: "ÁÄ",
  c: "č",
  C: "Ç",
  d: "ď",
  D: "Ď",
  e: "é",
  E: "É",
  i: "í",
  I: "Í",
  l: "ľ",
  L: "Ľ",
  n: "ň",
  N: "Ň",
  o: "óô",
  O: "ÓÔ",
  r: "ŕ",
  R: "Ŕ",
  s: "š",
  S: "Š",
  t: "ť",
  T: "Ť",
  u: "ú",
  U: "Ú",
  y: "ý",
  Y: "Ý",
  z: "ž",
  Z: "Ž",
});

const unaccent = (str) => str.normalize("NFD").replace(/[\u0300-\u036f]/g, "");

export default class extends Controller {
  initialize() {
    $(this.element)
      .find("table")
      .tablesorter({
        sortLocaleCompare: true,
        ignoreCase: true,
        textExtraction: (node) => {
          return node.getAttribute("data-value") || node.textContent;
        },
      });

    const searchQuery = $(this.element).find(".search-query");

    if (searchQuery.length > 0) {
      const resultsCount = $(this.element).find("table > tbody > tr").length;

      $(this.element)
        .find(".search-query-input")
        .on("input", (event) => {
          if (this.searchQueryHandle) clearTimeout(this.searchQueryHandle);

          this.searchQueryHandle = setTimeout(() => this.searchTable(event.target.value), resultsCount > 500 ? 450 : 0);
        });

      $(this.element)
        .find(".search-query-reset")
        .on("click", () => {
          $(this.element).find(".search-query-input").val("");
          this.searchTable("");
        });
    }
  }

  searchTable(query) {
    if (query.length === 0) {
      $(this.element)
        .find("table tr")
        .map((_, row) => $(row).show());

      $(this.element).find(".search-query-reset").hide();
    } else {
      $(this.element).find(".search-query-reset").show();

      const rows = $(this.element).find("table > tbody > tr");

      for (const row of rows) {
        const columns = $(row).find("td[data-search-value]");

        for (const column of columns) {
          const value = $(column).data("search-value");

          if (unaccent(value).toLowerCase().includes(unaccent(query).toLowerCase())) {
            $(column).parent().show();
            break;
          } else {
            $(column).parent().hide();
          }
        }
      }
    }

    const resultsCount = $(this.element).find("table > tbody > tr:not(.no-results):visible").length;

    if (resultsCount > 0) {
      $(this.element).find("table > tbody > tr.no-results").hide();
    } else {
      $(this.element).find("table > tbody > tr.no-results").show();
    }

    $(this.element).find(".search-query-count").text(resultsCount);
  }
}
