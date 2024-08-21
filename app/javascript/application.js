// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from '@rails/ujs';
import * as ActiveStorage from '@rails/activestorage';
import '@hotwired/turbo-rails';

Rails.start();
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
window.addEventListener('load', function () {
  const language = document.documentElement.lang || 'en';

  CookieConsent.run({
    categories: {
      necessary: {
        enabled: true,
        readOnly: true,
      },
      analytics: {
        enabled: true,
      },
    },

    language: {
      default: language,
      translations: {
        en: {
          consentModal: {
            title: 'Cookies',
            description:
              'We use cookies to ensure you get the best experience on our website. Please choose your preferences.',
            acceptAllBtn: 'Accept All',
            acceptNecessaryBtn: 'Reject All',
            showPreferencesBtn: 'Manage Individual Preferences',
          },
          preferencesModal: {
            title: 'Manage Your Cookie Preferences',
            acceptAllBtn: 'Accept All',
            acceptNecessaryBtn: 'Reject All',
            savePreferencesBtn: 'Accept Current Selection',
            closeIconLabel: 'Close Modal',
            sections: [
              {
                title: 'Strictly Necessary Cookies',
                description:
                  'These cookies are essential for the proper functioning of the website and cannot be disabled.',

                linkedCategory: 'necessary',
              },
              {
                title: 'Performance and Analytics',
                description:
                  'These cookies collect information about how you use our website. All of the data is anonymized and cannot be used to identify you.',
                linkedCategory: 'analytics',
              },
              {
                title: 'More information',
                description:
                  'For any queries in relation to our policy on cookies and your choices, please <a href="/contact">contact us</a>',
              },
            ],
          },
        },

        sk: {
          consentModal: {
            title: 'Cookies',
            description:
              'Používame cookies, aby sme zaistili, že na našej webovej stránke získate čo najlepší zážitok. Prosím, vyberte si svoje preferencie.',
            acceptAllBtn: 'Prijať všetky',
            acceptNecessaryBtn: 'Odmietnuť všetky',
            showPreferencesBtn: 'Spravovať individuálne preferencie',
          },
          preferencesModal: {
            title: 'Spravujte svoje preferencie cookies',
            acceptAllBtn: 'Prijať všetky',
            acceptNecessaryBtn: 'Odmietnuť všetky',
            savePreferencesBtn: 'Prijať aktuálny výber',
            closeIconLabel: 'Zatvoriť okno',
            sections: [
              {
                title: 'Nevyhnutné cookies',
                description:
                  'Tieto cookies sú nevyhnutné pre správne fungovanie webovej stránky a nemožno ich deaktivovať.',
                linkedCategory: 'necessary',
              },
              {
                title: 'Výkon a analytika',
                description:
                  'Tieto cookies zhromažďujú informácie o tom, ako používate našu webovú stránku. Všetky údaje sú anonymizované a nemožno ich použiť na vašu identifikáciu.',
                linkedCategory: 'analytics',
              },
              {
                title: 'Viac informácií',
                description:
                  'Pre akékoľvek otázky týkajúce sa našej politiky cookies a vašich možností, prosím <a href="/contact">kontaktujte nás</a>',
              },
            ],
          },
        },
      },
    },
  });
});
