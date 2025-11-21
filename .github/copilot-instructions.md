# Otvorená Prokuratúra – Copilot Instructions

## Repository Overview

Public data app for Slovak prosecution data: prosecutors, offices, decrees, and criminality stats. Query logic is encapsulated in service objects with composable search filters; fuzzy search uses PostgreSQL materialized views with trigram/unaccent.

Tech Stack: Ruby 3.3.x, Rails 7.1, PostgreSQL 16, Redis (Sidekiq), Node ≥ 20.10 (Webpacker 6 / Webpack 5), Stimulus/Turbo, Bootstrap 4.

## Requirements

- PostgreSQL 16 with `pg_trgm` and `unaccent` extensions
- Redis server for Sidekiq
- Node.js version 20.10 or higher
- Yarn package manager

## Setup Instructions

2. Install and prepare DB: `bin/setup` (bundler + `db:prepare`).
3. JavaScript: `yarn install` (Webpacker 6 rc).
4. Optional data: import via Rails console (see Data Importers).

## Development Guidelines

- Keep controllers thin; move business/query logic to `app/services`.
- Use the Search pattern: `Search.new(relation, params:, filters:)` with filter classes exposing `filter` and optionally `facets` (see `app/services/*_search.rb`).
- Text search via `QueryFilter` runs against `<table>_search` materialized views. If you change view columns/joins, update the migration and call `Model.refresh_search_view` (from `Searchable`).
- When adding filters, align controller strong params with filter keys (e.g., `params.permit(..., city: [], paragraph: [])`).
- Background jobs: Sidekiq queues are env-scoped (see `config/sidekiq-*.yml`); schedules live in `config/schedule.rb` and are wrapped with `ExceptionHandler` to send errors to Sentry.

Always follow these instructions when making code changes.

**IMPORTANT**: Follow these rules strictly.

1. Keep controllers thin; move business/query logic to `app/services`.

2. Use the Search pattern: `Search.new(relation, params:, filters:)` with filter classes exposing `filter` and optionally `facets` (see `app/services/*_search.rb`).

3. Text search via `QueryFilter` runs against `<table>_search` materialized views. If you change view columns/joins, update the migration and call `Model.refresh_search_view` (from `Searchable`).

4. When adding filters, align controller strong params with filter keys (e.g., `params.permit(..., city: [], paragraph: [])`).

5. Background jobs: Sidekiq queues are env-scoped (see `config/sidekiq-*.yml`); schedules live in `config/schedule.rb` and are wrapped with `ExceptionHandler` to send errors to Sentry.

6. Do not put comments or documentation in code. Follow existing patterns. Only in case the logic is very complex or there is a non-obvious reason for something or TODO comments for edge cases.

7. Follow existing code style as defined in `.streerc`. Always format your code via `syntax_tree` by running

   ```bash
   bundle exec syntax_tree format --write <files or directories>
   ```

   Format only the files you changed and fetch them via `git diff --name-only HEAD~1` or similar command.

8. Always write tests for new functionality and bug fixes. Follow existing RSpec patterns in `spec/` directory. Put tests in the same module structure as the code you're testing. Run tests via `bundle exec rspec` and make sure all tests pass before committing. In case of failures, investigate the output logs of RSpec to identify the issues and fix them.

9. When writing specs, make sure to follow existing patterns. Use `let` to define variables, `before` blocks for setup, and `describe`/`context` blocks to organize tests. Use mocks and stubs where necessary to isolate the unit under test. Follow guidelines as set by betterspecs.org.

   9.1. Use `FactoryBot` for creating test data. Define factories in `spec/factories/` and use them in your tests to create instances of models with default attributes. This helps keep tests clean and focused on behavior rather than setup.

   9.2. When testing search functionality, ensure to cover various filter combinations and edge cases. Use database cleaning strategies to maintain a consistent state between tests.

   9.3. When testing background jobs, use `sidekiq/testing` to control job execution. Test that jobs are enqueued with correct arguments and that they perform the expected actions when executed. Mock external services and dependencies to isolate job behavior.

   9.4. Use `shoulda-matchers` for concise model and controller tests. Leverage its built-in matchers for validations, associations, and controller responses to keep tests clean and readable.

   9.5. When testing API endpoints, use `rspec-rails` request specs to simulate HTTP requests and verify responses. Test various scenarios including success, failure, and edge cases to ensure robust API behavior.

   9.6. When testing views, use `capybara` for integration tests that simulate user interactions. Verify that the UI behaves as expected and that important elements are present on the page.

   9.7. When making external API calls in tests, use `webmock` or `vcr` to stub requests and responses. This ensures tests are deterministic and do not rely on external services.

   9.8. Always run the full test suite before committing changes to ensure that new code does not introduce regressions or break existing functionality.

10. When adding new dependencies, follow these steps:

    10.1. For Ruby gems, add to `Gemfile`, run `bundle install`, and commit both `Gemfile` and `Gemfile.lock`.

    10.2. For Node packages, run `yarn add <package>`, and commit both `package.json` and `yarn.lock`.

11. When creating new libraries or modules, ensure they are placed in the appropriate directory under `lib/`. Follow existing naming conventions and structure for consistency.

## Running Application

```bash
bin/rails s            # Rails server
bin/webpack-dev-server # Webpacker dev server (port 3035)
```

## Running Tests

```bash
bin/rspec
```

## Project Structure

- `app/services/search.rb`, `app/services/query_filter.rb` — search composition and fuzzy query helper
- `app/services/{office,prosecutor,crime}_search.rb` — domain searches + facets
- `app/models/concerns/` — `Searchable`, `Newsable`, `Offices::Indicators` (charts from CSVs in `data/`)
- `lib/genpro_gov_sk`, `lib/minv_sk` — importers/parsers required from `config/application.rb`
- `config/webpacker.yml` — dev server (3035), packs to `public/packs`
- `.github/workflows/main.yml` — CI (Postgres 16 service + RSpec) and Capistrano deploy on main

## Data Importers

From Rails console (typical order):

- `GenproGovSk::Offices.import`
- `GenproGovSk::Prosecutors.import`
- `GenproGovSk::Declarations.import`
- `GenproGovSk::Decrees.import`
- `GenproGovSk::Criminality.import` (parallelized)
- `MinvSk::Criminality.import`

## Common Issues & Solutions

- Missing pg_trgm/unaccent: ensure migration `20200504104808_add_trigram_to_postgres.rb` has run on your DB.
- Odd search ordering after data changes: refresh materialized views via `Model.refresh_search_view`.
- Packs not loading in dev: start `bin/webpack-dev-server` (3035) and run `yarn install`.
- Sidekiq not processing: ensure Redis is running and queues match `config/sidekiq-*.yml`; UI is mounted at `/sidekiq` (basic auth in prod).
- Google news empty/failing: verify credentials `[:google][:api][:search][:id]` and `[:key]` exist.

## Build & Deployment

- CI runs RSpec on push; deploy job (Capistrano) triggers on `main` and runs `cap production deploy` (see `.github/workflows/main.yml` and `config/deploy.rb`).
- Pre-deploy sanity: run tests (`bin/rspec`) and ensure migrations are up to date.

## Quick Reference

```bash
bin/setup                   # Install gems, prepare DB
bin/rails db:migrate        # Migrate
bin/rails s                 # Server
bin/webpack-dev-server      # Assets (3035)
bin/rspec                   # Tests
rails c                     # Console (run importers listed above)
bundle exec rake cache:clear
```
