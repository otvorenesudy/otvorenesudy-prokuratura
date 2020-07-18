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
  }
}
