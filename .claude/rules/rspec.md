---
paths:
  - "spec/**/*.rb"
---

# RSpec

The process is the `acceptance-first` skill: scenarios first, an end-to-end spec per scenario that fails on its
assertion, then the code. This is how to write those specs here, on **rspec-rails, shoulda-matchers, FactoryBot, VCR
with WebMock, Capybara and DatabaseCleaner**, against the real test database. Run them with `bin/test <spec>`: it
lints, prepares the test database and runs outside the Claude Code sandbox, which plain `bundle exec rspec` can't (the
database login is in `.env.test` or Rails credentials, both hidden from the sandbox).

## Which Spec

| Behavior | Spec | Directory |
| --- | --- | --- |
| A page: listing, filtering, facets, detail, charts, with or without JavaScript | System spec (`type: :system`) | `spec/system/` (new) |
| An endpoint's status, redirect or JSON (`suggest`) | Request spec | `spec/requests/` (new) |
| An import from a saved page or document | Spec of the importer through `import_from`, asserting the records | `spec/lib/genpro_gov_sk/`, `spec/lib/minv_sk/` |
| An import from the live site, compared with expected data | Feature spec, on the network on purpose | `spec/features/` |
| Parsing with many cases, validations, model logic | Parser and model specs | `spec/lib/`, `spec/models/` |

Don't add a unit spec that repeats what an end-to-end spec proves. There are no system or request specs yet: the first
one sets up its driver with `driven_by :rack_test`, or `driven_by :selenium, using: :headless_chrome` when the flow
needs JavaScript.

## Fakes

- Real models, the real test database, factories, the real Rails stack.
- Nothing blocks the network: VCR lets a request without a cassette through
  (`allow_http_connections_when_no_cassette`). So a spec outside `spec/features/` fakes every request it makes, with a
  VCR cassette (`vcr: { cassette_name: '...' }` metadata, recorded in `spec/fixtures/vcr/`) or WebMock `stub_request`.
  `webmock: :disabled` only labels a spec that reaches the live site; nothing reads it.
- Geocoding is stubbed for every example (`spec/support/geocoder.rb`); pass
  `geocoder: { latitude:, longitude: }` metadata for specific coordinates.
- Time: `travel_to` / `freeze_time`, once `rails_helper.rb` includes `ActiveSupport::Testing::TimeHelpers` (it doesn't
  yet; the first spec that needs the clock adds it). Jobs: run them and assert the outcome.
- Never `allow_any_instance_of`, and never doubles of this app's own classes in system or request specs.

## Writing Them

- `require 'rails_helper'`. `RSpec.describe Office, type: :model` for a class, with `described_class` inside;
  `RSpec.describe 'Searching offices', type: :system` for a flow.
- `describe '.class_method'` / `describe '#instance_method'`; `context 'when ...'` / `'with ...'` / `'without ...'` for
  a situation; no more than three levels of nesting.
- Example names state the outcome in the present tense, after the scenario: `it 'lists offices ordered by name'`,
  never `it 'should ...'`.
- `let` for setup with descriptive names; a subject the examples refer to is named (`subject(:office) { build(:office) }`).
- FactoryBot with parentheses (`create(:office)`, `build(:prosecutor)`), factories in `spec/factories/`, minimal and
  realistic.
- Validations and associations through shoulda-matchers, grouped in `describe 'Validations'`:
  `it { is_expected.to validate_presence_of(:name) }`. Custom validators (the JSONB `registry`) get one example per
  case, with the error message.
- `:seeds` metadata loads `db/seeds.rb` before the example. DatabaseCleaner wraps every example in a transaction; there
  are no transactional fixtures.
- Specs run in English (`config/application.rb`), so assert the English text; the site itself defaults to Slovak.
- In a system spec, drive the page like a visitor (`visit`, `fill_in`, `click_on`, `select`, by visible label) and
  assert what they see with Capybara's waiting matchers.
- No `sleep`, no order dependence: the suite runs in random order.

## Live-Site Specs

When a spec in `spec/features/` fails because genpro.gov.sk or minv.sk changed, check the new values on the live page
before updating the expected JSON, and update only the entries that changed. If the page's structure changed instead,
it's a parser bug: save the new page as a fixture and fix the parser first.

## Never

Skip, delete or loosen a failing spec to get green. If a spec is wrong, say which scenario it contradicts.
