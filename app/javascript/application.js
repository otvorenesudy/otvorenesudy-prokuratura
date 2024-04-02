// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from '@rails/ujs';
import Turoblinks from 'turbolinks';
import * as ActiveStorage from '@rails/activestorage';

Rails.start();
Turoblinks.start();
ActiveStorage.start();

require('./src/channels');

import 'bootstrap/dist/js/bootstrap';
import 'leaflet';
import 'leaflet.snogylop';
import 'leaflet.markercluster';

import './src/controllers';
import './src/bootstrap';
import './src/fixes';

// Cookie consent
window.addEventListener('load', () => {
  if (!window.cookieconsent) return;

  window.cookieconsent.initialise({
    palette: {
      popup: {
        background: '#8392ac',
        text: '#fff',
      },
    },
    content: {
      message:
        'Táto stránka využíva cookies. V prípade, že nesúhlasíte s ukladaním súborov cookies na Vašom zariadení, prosím, opustite túto stránku.',
      dismiss: 'Súhlasím',
    },
    showLink: false,
  });
});
