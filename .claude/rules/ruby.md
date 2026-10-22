---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "**/*.erb"
  - "Gemfile"
---

# Ruby 4.0 and Rails 8.1

The app runs **Ruby 4.0 and Rails 8.1** (`.ruby-version`, `Gemfile.lock`). Write current Ruby and Rails, and match the
surrounding code before anything here.

## Formatting and Lint

RuboCop formats and checks every Ruby file (`.rubocop.yml`): the community Ruby and Rails style guides, with the Rails,
RSpec, FactoryBot, Capybara and Performance cops on their defaults. The PostToolUse hook runs `bin/lint --fix` on each
file you write and sends back what it couldn't fix; fix that, don't hand-format. What the configuration settles:

- `# frozen_string_literal: true` opens every Ruby file (`bin/lint --fix` adds it).
- Single quotes, inside interpolation too; lines up to 120 columns.
- Methods up to 20 lines, classes and modules up to 200, ABC size 30, cyclomatic and perceived complexity 10. A method
  over them splits into private methods named after their steps; don't raise a limit or disable the cop.
- Numbers in names are separated by an underscore (`structure_2023`).
- No documentation comment is required above a class. A comment says what the code can't: a source's quirk, a
  constraint, an order that matters (a quirk of genpro.gov.sk's pages). Never one that restates the code.
- A `rubocop:disable` carries its reason after `--` on the same line.

## Ruby

- Use what the versions give: shorthand hash and keyword values (`{ office:, prosecutor: }`), endless ranges,
  anonymous block forwarding (`&`), `filter_map`, `sum`, `compact_blank`, and `Data.define` for small value objects.
- Guard clauses and early returns over nested conditionals (`return relation if params[:city].blank?`); a blank line
  between logical blocks; `unless` only without `else`.
- `present?`, `blank?`, `presence` and safe navigation (`&.`) over manual nil and empty checks.
- Enumerable over loops that fill an accumulator: `map`, `filter_map`, `each_with_object`, `uniq { }`, `group_by`,
  `sum`.
- Stateless code is module or class methods, with the helpers private under `class << self` (the parsers in
  `lib/genpro_gov_sk/*/parser.rb`).
- Static mappings are frozen constants.
- Names follow the `naming` skill: short in small scopes, descriptive for methods, parameters and anything public.

## Controllers and Search

Controllers are thin. Parameters come through `params.permit` or `params.expect` in private methods, exposed to the
views with `helper_method` when the views build links from them, and every listing goes through a search object:

```ruby
class OfficesController < ApplicationController
  def index
    @search = OfficeSearch.new(index_params)
  end

  private

  helper_method :index_params

  def index_params
    params.permit(:page, :sort, :order, :q, type: [], city: [], prosecutors_count: [], decrees_count: [], paragraph: [])
  end
end
```

A search object (`app/services/*_search.rb`) builds a `Search` from a relation and its filters. A filter is a class
with `self.filter(relation, params)`, which returns the relation unchanged when its param is blank, and
`self.facets(relation, suggest:)` for the counts its facet shows; filters shared by several listings live in
`app/services/search/`. A new facet is a new filter, not a condition in the controller.

## Rails

- Models keep the schema annotation at the top (`bin/rails annotate_models`, annotaterb), validate with
  `validates :name, presence: true`, and use enums with explicit values
  (`enum :type, { general: 0, specialized: 1, regional: 2, district: 3 }`).
- The schema lives in `db/structure.sql`, with the materialized views the listings search (`offices_search`,
  `prosecutors_search`, `paragraphs_search`), which `schema.rb` can't hold.
- Importing is two steps. `lib/genpro_gov_sk/` and `lib/minv_sk/` fetch and parse a source's pages and documents.
  `import_from` on a model in `app/models/genpro_gov_sk/` stores the raw page with its parsed data and writes the
  domain records (Office, Prosecutor, Appointment, Employee, Decree, Crime, Statistic, Paragraph). It does nothing for
  a page it has already seen unchanged, and writes everything else in one transaction with the records locked
  (`GenproGovSk::Office.import_from`); an import you add works the same way.
- Jobs are ActiveJob on Sidekiq (`config/sidekiq-1.yml`, `config/sidekiq-2.yml`). They take ids or serializable
  values, keep `perform` short and are safe to run twice.
- Iterate with `find_each` / `in_batches` over large tables; `includes` against N+1 queries.
- Errors you rescue and still want to hear about go to Sentry (`Sentry.capture_exception`). Rescue the errors you
  expect, not `Exception`.
- User-facing text goes through I18n, with every key in both `config/locales/sk.yml` and `en.yml`; missing
  translations raise in development and tests.
- Secrets come from Rails credentials (`Rails.application.credentials.dig(...)`, nil outside production unless you made
  your own), never from code. You can't read the credentials; ask the user when a change needs a new one, and list it
  in `config/initializers/production_boot_check.rb`.
- Settings that differ by machine (the database login) come from ENV, with a default in the code
  (`ENV.fetch('REDIS_URL', ...)`). dotenv-rails loads them in development and test from `.env` and `.env.test`, whose
  templates are the committed `.env.example` and `.env.test.example`; CI's are in `.env.ci`. You can't open dotenv
  files, so ask the user to add a new setting there.
- Log through `Rails.logger`, prefixed with the class, values in brackets:
  `Rails.logger.info "Downloader # Retry [#{attempt}/#{retries}] for [#{url}] after [#{backoff_time}s]: [#{e.class}]"`.
  Rake tasks may `puts` their progress; nothing else does.

## Views

- ERB, which no formatter checks: keep the indentation of the surrounding markup.
- Build HTML with helpers: `tag`, `link_to`, `safe_join`, `to_sentence`. `html_safe` and `raw` only on markup we wrote,
  with a reason.
- Behavior is a Stimulus controller wired with `data-*` attributes (the `javascript` rule); no inline scripts or styles.

## Where Code Goes

| Code | Place |
| --- | --- |
| Fetching and parsing genpro.gov.sk and minv.sk | `lib/genpro_gov_sk/`, `lib/minv_sk/` |
| Raw imported pages and their parsed data | `app/models/genpro_gov_sk/` |
| Domain records | `app/models/` |
| Faceted search and filters | `app/services/*_search.rb`, `app/services/search/` |
| Background work | `app/jobs/` |
| PDF and RTF text | `lib/p_d_f_extractor.rb`, `lib/r_t_f_extractor.rb`, `lib/unoconv.rb` |
| Front-end behavior | Stimulus controllers in `app/javascript/controllers/` (the `javascript` rule) |
