---
paths:
  - "app/javascript/**"
  - "app/assets/**"
  - "config/webpack/**"
  - "*.js"
  - "package.json"
---

# JavaScript and Styles

Webpacker 6 (`config/webpack/`, release candidate) bundles one pack, `app/javascript/application.js`, with Babel.
Behavior is Stimulus controllers in `app/javascript/src/controllers/`, with Turbo and Rails UJS; charts are Highcharts,
maps Leaflet (with markercluster and snogylop), sortable tables tablesorter, all on jQuery and Bootstrap 4's
JavaScript. `config/webpack/custom.js` provides `$` and `jQuery` to every module. Styles are SCSS on Bootstrap 4 in
`app/assets/stylesheets/` (`components/` and `utilities/`), compiled by Sprockets.

## Formatting

The PostToolUse hook runs `bin/lint --fix`, which formats `*.js`, `*.scss` and `*.css` with Prettier (`.prettierrc`: 120
columns, single quotes, and Prettier 2's defaults otherwise: semicolons, trailing commas where ES5 allows them,
parentheses around arrow parameters). Most files predate it, so many still use double quotes; a file you touch comes
out in single quotes. ESLint (`.eslintrc.js`) doesn't run in `bin/lint`.

## Stimulus Controllers

- The app runs **Stimulus 1.1**: it imports `stimulus`, not `@hotwired/stimulus` (in `package.json` too, but unused).
  Follow the existing controllers, and don't use what came in Stimulus 2 and 3: no `static values` or
  `static classes`, no outlets.
- One controller per behavior in `app/javascript/src/controllers/<behavior>_controller.js`, as
  `export default class extends Controller`. `index.js` loads every file there (`definitionsFromContext`), so there is
  nothing to register; `suggest_controller.js` is `data-controller="suggest"`.
- Wire controllers with `data-controller`, `data-action` and targets (`static targets = ['query']`, then
  `this.queryTarget`). No inline scripts, `on*` attributes or inline styles in the views.
- Data comes from the page: the view renders JSON into a data attribute (`data-json`) and options into others
  (`data-comparison`, `data-animation`), read with `this.element.getAttribute(...)`. A chart doesn't fetch its data.
- A chart controller extends `ChartController` (`chart_controller.js`) for the shared colors, resizing and watermark,
  and builds its Highcharts options in methods (`barChartOptions`, `lineChartOptions`). The export views
  (`crimes/export.html.erb`, `statistics/export.html.erb`) turn the animation off with `data-animation="false"`.
- Undo in `disconnect()` what the controller set up: handlers on `window`, timers, maps and charts. Turbo restores pages
  from its cache, so a controller connects more than once.
- HTML built from data goes through `sanitize-html` before it reaches the page (`map_controller.js`).

## JavaScript

- `const` by default, `let` when reassigned, never `var`; `===` and `!==` only (some old code uses `==`; fix it in what
  you touch).
- Optional chaining and `??` over manual null checks; destructuring, spread and template literals; arrow functions for
  callbacks.
- `async`/`await` over `.then()` chains, and check `response.ok` before reading a response. Never swallow an error.
- Guard clauses and early returns; short methods named after what they do.
- Code that runs on every visit listens to `turbo:load`, not `DOMContentLoaded` (`src/fixes.js`).
- jQuery is there for Bootstrap 4's components and tablesorter; plain DOM APIs for everything else.
- Use the libraries already in `package.json` (lodash's `debounce`, `sanitize-html`) before adding one; add with
  `yarn add` so `yarn.lock` changes with it.

## Tests

There are no JavaScript unit tests. A flow that needs JavaScript is a system spec on headless Chrome that asserts what
the visitor sees (the `rspec` rule).
