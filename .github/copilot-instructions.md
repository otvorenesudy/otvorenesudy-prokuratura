# Otvorená Prokuratúra – Copilot Instructions

## Repository Overview

Public data app for Slovak prosecution data: prosecutors, offices, decrees, and criminality stats. Query logic is encapsulated in service objects with composable search filters; fuzzy search uses PostgreSQL materialized views with trigram/unaccent.

**Tech Stack**: Ruby 3.3.x, Rails 7.1, PostgreSQL 16 (with `pg_trgm` and `unaccent`), Redis (Sidekiq), Node ≥ 20.10 (Webpacker 6 / Webpack 5), Stimulus/Turbo, Bootstrap 4.

> Language- and framework-specific conventions (Ruby/Rails style, RSpec, JavaScript) live in `.github/instructions/` and are auto-applied via `applyTo` globs. Do not duplicate them here.

## Setup

1. `bin/setup` — installs gems and runs `db:prepare`.
2. `yarn install` — installs JS dependencies.
3. Optional: import data via Rails console (see Data Importers below).

## Running

```bash
bin/rails s             # Rails server
bin/webpack-dev-server  # Webpacker dev server (port 3035)
bin/rspec               # Tests
```

## Repo-Specific Conventions

These are project rules not covered by the language instruction files:

1. **Thin controllers** — move query/business logic into `app/services`.
2. **Search pattern** — use `Search.new(relation, params:, filters:)` with filter classes exposing `filter` and optionally `facets`. See `app/services/{office,prosecutor,crime}_search.rb`.
3. **Fuzzy text search** — `QueryFilter` runs against `<table>_search` materialized views. If you change view columns/joins, update the migration and call `Model.refresh_search_view` (from `Searchable`).
4. **Strong params must align with filter keys**, e.g. `params.permit(..., city: [], paragraph: [])`.
5. **Background jobs** — Sidekiq queues are env-scoped (`config/sidekiq-*.yml`); schedules live in `config/schedule.rb` and are wrapped with `ExceptionHandler` to send errors to Sentry.
6. **Importers / parsers** — place under `lib/genpro_gov_sk` or `lib/minv_sk`; they are autoloaded from `config/application.rb`.
7. **Dependency management** — Ruby gems: edit `Gemfile`, run `bundle install`, commit `Gemfile` + `Gemfile.lock`. JS: `yarn add <pkg>`, commit `package.json` + `yarn.lock`.

## Project Structure

- `app/services/search.rb`, `app/services/query_filter.rb` — search composition and fuzzy query helper
- `app/services/{office,prosecutor,crime}_search.rb` — domain searches + facets
- `app/models/concerns/` — `Searchable`, `Newsable`, `Offices::Indicators` (charts from CSVs in `data/`)
- `lib/genpro_gov_sk`, `lib/minv_sk` — importers/parsers
- `config/webpacker.yml` — dev server (3035), packs to `public/packs`
- `.github/workflows/main.yml` — CI (Postgres 16 service + RSpec) and Capistrano deploy on `main`

## Data Importers

Run from Rails console in this order:

```ruby
GenproGovSk::Offices.import
GenproGovSk::Prosecutors.import
GenproGovSk::Declarations.import
GenproGovSk::Decrees.import
GenproGovSk::Criminality.import   # parallelized
MinvSk::Criminality.import
```

## Protected Files

**CRITICAL — never modify, delete, or commit changes to:**

- `config/credentials/test.ci.key`
- `config/credentials/test.ci.yml.enc`
- `config/credentials/test.yml.enc`

These are required for CI/CD. Exclude them from any commit.

## Common Issues

- **Missing `pg_trgm`/`unaccent`**: ensure migration `20200504104808_add_trigram_to_postgres.rb` has run.
- **Stale search ordering**: refresh materialized views via `Model.refresh_search_view`.
- **Packs not loading in dev**: start `bin/webpack-dev-server` (3035) and run `yarn install`.
- **Sidekiq not processing**: ensure Redis is running and queues match `config/sidekiq-*.yml`. UI mounted at `/sidekiq` (basic auth in prod).
- **Google news empty/failing**: verify credentials `[:google][:api][:search][:id]` and `[:key]`.

## Build & Deployment

CI runs RSpec on push. Deploy job (Capistrano) triggers on `main` and runs `cap production deploy` (see `.github/workflows/main.yml` and `config/deploy.rb`). Before deploying, ensure tests pass and migrations are up to date.

## Agent Customization Layout

- `.github/instructions/` — auto-applied rules via `applyTo` globs:
  - `ruby.instructions.md` — Ruby/Rails style, controllers, services, models, logging, testing.
  - `rspec.instructions.md` — RSpec patterns (FactoryBot, shoulda-matchers, request/feature specs).
  - `javascript.instructions.md` — modern JS conventions.
  - `instructions.instructions.md`, `prompt.instructions.md`, `agent-skills.instructions.md` — authoring guidance for instruction/prompt/skill files.
- `.github/skills/` — invokable skills: `api-design`, `autoresearch`, `conventional-commit`, `engineering`, `naming`.
- `.github/agents/` — subagents: `autofix`, `fix-tests`, `plan`, `workflow`, `maintain-agentfiles`.
- `.github/hooks/` — post-tool hooks that auto-format Ruby (`stree` with `.streerc`) and JS/TS (`prettier`) after edits, so manual formatting commands are not required.
- `.github/workflows/` — GitHub Actions for CI and deploy.

## Quick Reference

```bash
bin/setup                   # Install gems, prepare DB
bin/rails db:migrate        # Migrate
bin/rails s                 # Server
bin/webpack-dev-server      # Assets (3035)
bin/rspec                   # Tests
rails c                     # Console (run importers above)
bundle exec rake cache:clear
```
