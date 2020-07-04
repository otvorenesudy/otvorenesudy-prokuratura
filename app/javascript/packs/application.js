// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
require("channels");

import "bootstrap/dist/js/bootstrap";

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// Cookie consent
window.addEventListener("load", () => {
  window.cookieconsent.initialise({
    palette: {
      popup: {
        background: "#8392ac",
        text: "#fff",
      },
    },
    content: {
      message:
        "Táto stránka využíva cookies. V prípade, že nesúhlasíte s ukladaním súborov cookies na Vašom zariadení, opustite túto stránku. ",
      dismiss: "Súhlasím",
    },
    showLink: false,
  });
});
