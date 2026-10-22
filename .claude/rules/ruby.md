---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "Gemfile"
---

# Ruby and Rails

Ruby 3.3 (`.ruby-version`), Rails 7.1. Follow what the surrounding code does before anything here.

## Formatting and Lint

The PostToolUse hook runs `bin/lint --fix` on every Ruby file you write: syntax_tree formats it (`.streerc`: 120
columns, single quotes), then RuboCop's Lint and Security cops check it (`.rubocop.yml`). Fix what it reports; don't
format by hand. Offenses listed in `.rubocop_todo.yml` predate the setup: leave them unless the change is about them.

## Style

- No comments that restate the code. Comment only the non-obvious: a constraint, a workaround, a source quirk.
- Guard clauses and early returns over nested conditionals; a blank line between logical blocks.
- `unless` only without `else`. Safe navigation (`&.`) over chains of nil checks. `present?`, `blank?`, `presence`.
- Enumerable over loops with accumulators: `map`, `filter_map`, `each_with_object`, `uniq { }`, `group_by`, `sum`.
- Stateless code is module or class methods, helpers private under `class << self` (the importers in
  `lib/genpro_gov_sk/` do this).
- Constants for static mappings.
- Names follow the `naming` skill: short in small scopes, descriptive for methods, parameters and anything public.

## Controllers

Thin, with strong parameters grouped in private methods and exposed to views when they need them:

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

Listing pages go through a search object (`app/services/*_search.rb`).

## Where Code Goes

| Code | Place |
| --- | --- |
| Fetching and parsing genpro.gov.sk and minv.sk | `lib/genpro_gov_sk/`, `lib/minv_sk/` |
| Raw imported pages and their parsed data | `app/models/genpro_gov_sk/` |
| Domain records: Office, Prosecutor, Appointment, Employee, Decree, Crime, Statistic, Paragraph | `app/models/` |
| Faceted search and filters | `app/services/*_search.rb`, `app/services/search/` |
| Background work | `app/jobs/` on Sidekiq (`config/sidekiq-1.yml`, `config/sidekiq-2.yml`) |
| PDF and RTF text | `lib/p_d_f_extractor.rb`, `lib/r_t_f_extractor.rb`, `lib/unoconv.rb` |

## Rails

- Models keep the schema annotation at the top (`annotate`); validations with `validates :x, presence: true`.
- Jobs take IDs or serializable values, keep `perform` short, and are safe to run twice.
- `find_each` / `in_batches` over large tables; `includes` against N+1 queries.
- Logging: prefix with the class and put values in brackets,
  `Rails.logger.info "GenproGovSk::Offices # Imported [#{links.size}] offices"`.
- Secrets come from Rails credentials (`Rails.application.credentials.dig(...)`), never from code. You can't read the
  credentials; ask the user when a change needs a new one.
