---
paths:
  - "app/javascript/**"
  - "app/assets/**"
  - "config/webpack/**"
  - "*.js"
---

# JavaScript and Styles

Webpacker 6 bundles `app/javascript/` (`config/webpack/`). Behavior is Stimulus controllers in
`app/javascript/src/controllers/` with Turbo; charts use Highcharts, maps Leaflet (with markercluster), tables
tablesorter. Styles are SCSS on Bootstrap 4 in `app/assets/stylesheets/` (components and utilities folders).

- The PostToolUse hook runs `bin/lint --fix`, which formats `*.js`, `*.scss` and `*.css` with Prettier
  (`.prettierrc`: 120 columns, single quotes). Most existing files predate it; only files you touch get formatted.
- One Stimulus controller per behavior, in `app/javascript/src/controllers/<thing>_controller.js`; `index.js` loads
  every file there (`definitionsFromContext`), so there is nothing to register. The app imports `stimulus`, not
  `@hotwired/stimulus`; follow the existing controllers. Wire them with `data-controller`, `data-action` and targets.
  No inline scripts or styles.
- Charts take their data from the page (data attributes or JSON the view renders), not from extra requests.
- Use the libraries already in `package.json` before adding one; add with `yarn add` so `yarn.lock` changes with it.
- A flow that needs JavaScript is tested with a system spec on the JavaScript driver; assert what the user sees.
