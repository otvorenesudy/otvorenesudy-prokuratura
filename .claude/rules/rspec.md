---
paths:
  - "spec/**/*"
---

# RSpec

The process is the `acceptance-first` skill: scenarios first, an end-to-end spec per scenario that fails on its
assertion, then the code. This is how to write those specs here, on **rspec-rails 8, FactoryBot, shoulda-matchers,
Capybara (rack_test and headless Chrome through Selenium), WebMock and VCR**, against the real PostgreSQL. Run them
with `bin/test <spec>`: it lints, prepares the test database and runs outside the Claude Code sandbox, which plain
`bundle exec rspec` can't (the database login is in `.env.test`, and Rails keeps the test environment's secret in
`tmp/local_secret.txt`, both hidden from the sandbox).

## Which Spec

| Behavior | Spec | Directory |
| --- | --- | --- |
| A page: listings, facets, detail, charts, the map | System spec; rack_test by default, `:js` (headless Chrome) when it needs JavaScript | `spec/system/` |
| An endpoint: suggestions, the CSV export, a chart's picture, an error page | Request spec | `spec/requests/` |
| An import from saved pages and documents | The importer's entry point (`GenproGovSk::Offices.import`), with WebMock answering from `spec/fixtures/`; assert the records | `spec/lib/genpro_gov_sk/`, `spec/lib/minv_sk/` |
| A job | The job, run with `perform_enqueued_jobs` or `perform_now`; assert the outcome | `spec/jobs/` |
| A rake task: the sitemap, the cache, the criminality map | The task; `type: :task` | `spec/tasks/` |
| The live sources still parsing as expected | Feature spec replaying the recorded answers (VCR), compared with the expected JSON | `spec/features/` |
| Logic with many branches: parsers, filters, validations | Parser, service or model spec | `spec/lib/`, `spec/services/`, `spec/models/` |

Don't add a model or service spec that repeats what an end-to-end spec already proves.

## Fakes

- Real models, the real database, real jobs, FactoryBot factories.
- Fake only what we don't own, at the edge:
  - genpro.gov.sk, minv.sk and Google: `stub_request` (WebMock), answering with a saved page from `spec/fixtures/`
    (`stub_source`, `fixture`). No spec reaches the network.
  - The live sources in `spec/features/`: VCR replays `spec/fixtures/vcr/live_sources/<spec>` and never records.
    `RECORD_LIVE_SOURCES=1 bundle exec rspec spec/features` records them anew from the live sites: an opt-in check
    the user runs, never part of `bin/test` or CI.
  - Geocoding: Geocoder's test lookup, for every example (`spec/support/geocoder.rb`); pass
    `geocoder: { latitude:, longitude: }` metadata for specific coordinates.
  - unoconv: `:unoconv` puts a fake on the PATH (`spec/support/bin/unoconv`) that reads RTF the way unoconv would.
  - The clock: `travel_to` / `freeze_time`.
  - Jobs: run them with `perform_enqueued_jobs` and assert the outcome; `have_enqueued_job` only when enqueueing is the
    behavior.
- Never `allow_any_instance_of`, and never doubles or stubs of this app's own classes. A double of something we don't
  own is verified (`instance_double`, `class_double`), and a message expectation is a spy: `allow(...)`, then
  `expect(...).to have_received(...)`. RuboCop enforces both.

## Writing Them

RuboCop runs the RSpec, FactoryBot and Capybara cops on every spec; these rules match them.

- `require 'rails_helper'`. `RSpec.describe ClassName` for a class, with `described_class` inside; a string for a page
  or flow (`RSpec.describe 'Offices'`). The directory sets the type.
- `describe` names a method (`'.import'`, `'#full_address'`) or a part of the page (`'the listing'`); `context` names a
  situation and starts with `when`, `with` or `without`. At most three levels of nesting.
- Example names state the outcome in the present tense, after the scenario:
  `it 'lists the active offices, 15 a page'`, never `it 'should ...'`.
- A subject the examples refer to is named: `subject(:office) { build(:office) }`. At most five `let`s in a group;
  `let!` only for a record that must exist before the example runs.
- Factories with parentheses: `create(:prosecutor)`, `create(:decree, office:)`. They live in `spec/factories/`,
  minimal and realistic.
- Every example starts with the offices of `spec/fixtures/offices.json` and the seeds (`spec/support/seeds.rb`); use
  them (`Office.find_by!(name: 'Okresná prokuratúra Žilina')`) rather than creating offices.
- A request or other spec checks a small cluster of outcomes of one behavior (at most 5 expectations, 15 lines). A
  system spec walks one scenario through the UI and has no such limit.
- Examples run in a transaction. The listings search materialized views: call `refresh_search_views` after creating
  the records a search should find.
- Specs run in English (`config/application.rb`), so assert the English text; the site itself defaults to Slovak.
- Specs need no credentials: the code reads them with `dig` and does without.
- No `sleep`, no dependence on order or on the time of day.

## System Specs

- rack_test by default; `:js` for headless Chrome when the flow needs JavaScript, `width: 390` for a phone.
  `bounds(element)` returns where the browser drew an element, for scenarios about the layout.
- Drive the page like a visitor: `visit`, `fill_in`, `click_on`, `select`, by the visible label or text. Assert what
  they see with Capybara's waiting matchers (`have_text`, `have_css`, `have_current_path`). After a click that loads
  another page, wait for something only the new page shows before reading it.
- Headings are uppercase on screen (CSS), so the browser reads them uppercase: match them case-insensitively.
- A Stimulus controller connects after the page shows: hover with `hover_when_connected(element, 'tooltip')`. A chart
  is drawn when its canvas has `data-chart-drawn`.
- `:error_pages` shows the error pages instead of raising.
- A `:js` example that fails prints the browser's console: read it before guessing.

## Live Sources

When a spec in `spec/features/` fails after its cassette was recorded again, check the new values on the live page
before updating the expected JSON, and update only the entries that changed. If the page's structure changed instead,
it's a parser bug: save the new page as a fixture and fix the parser first.

## Never

- Skip, delete or loosen a failing spec to get green. If a spec is wrong, say which scenario it contradicts.
- Filter application code out of coverage. A full `bin/test` fails below 95% of lines or 90% of branches, and
  undercover reports every changed method no spec runs: cover them with specs.
