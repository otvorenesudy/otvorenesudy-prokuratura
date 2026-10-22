---
paths:
  - "spec/**/*.rb"
---

# RSpec

The process is the `acceptance-first` skill: scenarios, an end-to-end spec per scenario that fails first, then code.
This is how to write those specs here. Run them with `bin/test <spec>`; it prepares the test database and runs
outside the Claude Code sandbox, which plain `bundle exec rspec` can't (the database login is in Rails credentials).

## Which Spec

| Behavior | Spec | Directory |
| --- | --- | --- |
| A page: listing, filtering, facets, detail, with or without JavaScript | System spec (`type: :system`; `rack_test` unless the flow needs JavaScript) | `spec/system/` (new) |
| An endpoint's status, redirect or JSON | Request spec | `spec/requests/` (new) |
| An import from a saved page or document | Spec of the importer through `import_from`, asserting the records | `spec/lib/genpro_gov_sk/`, `spec/lib/minv_sk/` |
| An import from the live site, compared with expected data | Feature spec, network on purpose | `spec/features/` |
| Parsing with many cases, validations, model logic | Parser and model specs | `spec/lib/`, `spec/models/` |

Don't add a unit spec that repeats what an end-to-end spec proves.

## Fakes

- Real models, the real test database, factories, the real Rails stack.
- HTTP at the wire only: VCR cassettes (`spec/fixtures/vcr`, `vcr:` metadata) or WebMock `stub_request`. Only the
  `spec/features/` live-site specs may reach the network.
- Geocoding is stubbed for every example (`spec/support/geocoder.rb`); pass `geocoder: { latitude:, longitude: }`
  metadata for specific coordinates.
- Time: `travel_to` / `freeze_time`. Jobs: run them and assert the outcome.
- Never `allow_any_instance_of`, and never doubles of this app's own classes in system or request specs.

## Style

- `require 'rails_helper'`, `RSpec.describe Office, type: :model` or `RSpec.describe 'Searching offices', type: :system`.
- `describe '.class_method'` / `describe '#instance_method'`, `context 'when ...'` / `'with ...'`.
- Example names state the outcome in the present tense, after the scenario: `it 'lists offices ordered by name'`,
  never `it 'should ...'`.
- `let` for setup, FactoryBot (`spec/factories`), `described_class`, shoulda-matchers for validations and
  associations (`it { is_expected.to validate_presence_of(:name) }`).
- `:seeds` metadata loads `db/seeds.rb` before the example. DatabaseCleaner wraps every example; no transactional
  fixtures.
- No `sleep`, no order dependence: the suite runs in random order.
- When a live-site spec in `spec/features/` fails because genpro.gov.sk or minv.sk changed, check the new values on
  the live page before updating the expected JSON, and update only the entries that changed. If the page's structure
  changed instead, it's a parser bug: save the new page as a fixture and fix the parser first.
- Never skip, delete or loosen a failing spec to get green. If a spec is wrong, say which scenario it contradicts.
