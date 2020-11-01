// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
require("channels");

import "bootstrap/dist/js/bootstrap";
import "leaflet";
import "leaflet.snogylop";
import "leaflet.markercluster";

import "controllers";
import "./bootstrap";
import "./fixes";

// Cookie consent
window.addEventListener("load", () => {
  if (!window.cookieconsent) return;

  window.cookieconsent.initialise({
    palette: {
      popup: {
        background: "#8392ac",
        text: "#fff",
      },
    },
    content: {
      message:
        "Táto stránka využíva cookies. V prípade, že nesúhlasíte s ukladaním súborov cookies na Vašom zariadení, opustite túto stránku.",
      dismiss: "Súhlasím",
    },
    showLink: false,
  });
});

// Google Analytics
document.addEventListener("turbolinks:load", () => {
  if (!window.GOOGLE_ANALYTICS_TRACKING_ID) return;

  window.dataLayer = window.dataLayer || [];
  const gtag = (...params) => dataLayer.push(...params);

  gtag("js", new Date());
  gtag("config", GOOGLE_ANALYTICS_TRACKING_ID);
});
