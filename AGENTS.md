# otvorenesudy-prokuratura: Agent Instructions

Otvorená prokuratúra (prokuratura.otvorenesudy.sk), part of the Open Courts project: it makes public data about Slovak
prosecutors more accessible — the offices, the prosecutors and their assignments, their property declarations,
prosecution decrees, and yearly criminality statistics. It imports from the General Prosecutor's Office
(genpro.gov.sk) and the Ministry of the Interior (minv.sk) and serves faceted search over them. **Rails 8.1 on Ruby
4.0**, PostgreSQL (pg_trgm, unaccent), Sidekiq 8, Memcached, Importmap with Stimulus and Turbo, Bootstrap 5.3 through
Dart Sass, Chart.js and Leaflet, and Sentry for errors.

| Repository | What It Is | How It Relates |
| --- | --- | --- |
| otvorenesudy | The courts website | Sibling app on the same server |
| otvorenesudy-api | Court data importers and API | Sibling app; linked from the footer |
| otvorenesudy-server | Ansible provisioning of the production server | Runs this app: nginx, Passenger, PostgreSQL, Redis, Memcached |

## How We Work: Acceptance First

Every feature, behavior change and bug fix starts as an acceptance test. Use the `acceptance-first` skill before
writing code; this is the summary. Tooling, deployment, configuration and refactors that keep behavior get no new
tests: check them by running them and the suite.

1. **Scenarios first**: each scenario the user gave, verbatim, plus edge cases (no results, one, many; invalid or
   missing params; an unknown office or prosecutor; Slovak diacritics in queries; a page the source changed). A bug
   fix starts with the bug as scenario 1.
2. **An end-to-end spec per scenario, red first.** Run it and watch it fail on its assertion.
3. **Implement outside-in** until it passes. Unit specs only for logic with many branches (parsers, filters).
4. **Done** means every scenario's spec passes and `bin/test` is green, with its output shown.

| Behavior | Tested Through | Where |
| --- | --- | --- |
| Pages: listings, facets, detail, charts, the map | System specs with Capybara: rack_test, or headless Chrome (`:js`) when the page needs JavaScript | `spec/system/` |
| Endpoints: suggestions, exports, pictures of charts, error pages | Request specs | `spec/requests/` |
| Imports | The importer's entry point with saved pages and documents (WebMock), records asserted | `spec/lib/genpro_gov_sk/`, `spec/lib/minv_sk/` |
| Jobs and scheduled tasks | The job or the rake task, with `perform_enqueued_jobs` | `spec/jobs/`, `spec/tasks/` |
| The live sources still parsing as expected | Feature specs replaying recorded answers (VCR), compared with expected JSON | `spec/features/` |
| Parsers, filters, models with many branches | Specs against real objects and the database | `spec/lib/`, `spec/models/`, `spec/services/` |

Use real collaborators: our code, Rails, the database. Fake only what we don't own, at the edge: HTTP (WebMock, VCR),
geocoding (Geocoder's test lookup, for every spec), unoconv (`spec/support/bin/unoconv`, with `:unoconv`) and the
clock. Never skip, delete or loosen a failing spec to get green; if a spec is wrong, say which scenario it
contradicts.

Every spec starts with the offices of `spec/fixtures/offices.json` and the seeds; specs that search the listings call
`refresh_search_views` after creating records. No spec reaches the network: the specs in `spec/features/` replay the
cassettes in `spec/fixtures/vcr/live_sources`. To check the live sites, the user runs
`RECORD_LIVE_SOURCES=1 bundle exec rspec spec/features`, which records them anew; it is opt-in, never part of
`bin/test` or CI. When a source changed its data, update the expected JSON; when it changed its pages, fix the parser.

## Commands

```bash
bin/setup                    # gems, Node packages, the git hooks, .env and .env.test from their examples, the database; then bin/dev
bin/dev                      # the app and Dart Sass in watch mode
bin/test                     # lint, then every spec with coverage, then undercover; must be green before you are done
bin/test spec/system/offices_spec.rb:12   # lint, then those specs
bin/lint                     # RuboCop and Prettier on the files this branch changed
bin/lint --fix <file>        # format and autocorrect a file (the edit hook does this for you)
bin/leaks                    # secrets in the files and the history (the git hooks check each commit and push)
bin/brakeman                 # vulnerabilities in the code
bin/bundler-audit            # gems with known vulnerabilities
bin/vendor                   # copy the browser libraries package.json lists into vendor/ (npm install first)
bundle exec sidekiq -C config/sidekiq-1.yml
```

`bin/test` needs, on localhost:

- **PostgreSQL** with pg_trgm and unaccent. It rebuilds `opencourts_prokuratura_test` from `db/structure.sql`, in
  the en_US.UTF-8 locale whatever the server's default, so text sorts and folds case as in production.
- **Chrome** for the `:js` specs; Selenium Manager fetches the matching chromedriver.

It holds a machine-wide lock shared with the other otvorenesudy apps, and runs outside the Claude Code sandbox,
because the database login is in `.env.test` and Rails keeps the test environment's secret in `tmp/local_secret.txt`,
which the sandbox hides. Run specs through it rather than `bundle exec rspec`, which the sandbox can't boot. Without
`.env.test`, the specs log in to PostgreSQL as your own user.

A full run measures coverage: SimpleCov fails below 95% of lines or 90% of branches, and undercover reports every
method this branch changed that no spec runs. Rake tasks and configuration aren't measured. Cover what undercover
reports with specs; never filter application code out of coverage.

## Code Conventions

- **Engineering**: the `engineering` skill. Small reviewable changes, the simplest thing that works, match the
  surrounding code, production-ready only.
- **Naming**: the `naming` skill. Short names in small scopes; descriptive names for methods, parameters, fields
  and anything public; precise nouns and verbs, no filler words.
- **Names people read** (CI workflows, jobs and steps, headings, table columns, English UI labels): title case, the
  `title-case` skill. "Check Out Repository", not "Checkout repository".
- **Rules** in `.claude/rules/` load when you touch the files they cover: `ruby`, `rspec`, `javascript`. Follow them.
- **Formatting is automatic.** After every edit a hook runs `bin/lint --fix` on the file and sends back what it
  couldn't fix. Fix those; don't hand-format.

  | Files | Tools | Settings |
  | --- | --- | --- |
  | `*.rb`, `*.rake`, `Gemfile`, `Capfile` | RuboCop with the Rails, RSpec, FactoryBot, Capybara and Performance cops | `.rubocop.yml` (120 columns, single quotes) |
  | `app/javascript/**/*.js`, `app/assets/stylesheets/**/*.scss` | Prettier | `.prettierrc.json` |

  ERB has no formatter here.
- **Front end**: behavior lives in Stimulus controllers (`app/javascript/controllers`), wired by `data-*` attributes;
  no inline scripts. Third-party libraries are listed in `package.json` at exact versions and copied into `vendor/`
  by `bin/vendor`, never edited by hand; `config/importmap.rb` pins them. To add or update one, change
  `package.json`, run `npm install` and `bin/vendor`; `bin/test` fails while the files don't match.
- **Translations**: user-facing text goes through I18n, with every key in both `config/locales/sk.yml` and `en.yml`.
  The site defaults to Slovak, but specs run in English (`config/application.rb`), so assert English text in specs.
  Missing translations raise in development and tests.
- **Dependencies**: gems with `bundle add` (commit `Gemfile.lock`); browser libraries and tools in `package.json`
  with `npm install` (commit `package-lock.json`).

## Secrets

These files hold credentials. Never read, print, copy or decrypt them, and don't ask to; when a change needs a
secret, ask the user to add it.

| File | What |
| --- | --- |
| `.env`, `.env.test`, `.env.local`, `.env.*.local` | Each machine's settings, such as the database login (`OPENCOURTS_PROKURATURA_DATABASE_*`), which dotenv-rails loads in development and test; never committed. `bin/setup` creates `.env` and `.env.test` from the committed `.env.example` and `.env.test.example`, and CI copies the committed `.env.ci` to `.env.test`. Those three hold no secrets, but are denied to agents like the rest: ask the user to change them |
| `config/master.key`, `config/credentials/*.key` | Keys of the encrypted credentials; `config/credentials/*.yml.enc` are the encrypted files. Production's hold the other secrets: `secret_key_base`, `sidekiq.*`, `google.*`, `geoapify.key`, `sentry.dsn`, `skylight.token` (`config/initializers/production_boot_check.rb` lists them) |

Development and the specs need no credentials: the code reads them with `credentials.dig(...)` and does without.
Claude Code denies these files to its file tools (`permissions.deny`) and to sandboxed commands
(`sandbox.filesystem.denyRead`), and a hook blocks shell commands that name them. `config/database.yml` and
`config/skylight.yml` only refer to credentials and ENV, and are fine to read.

### Keeping Secrets Out of Git

The history is public, so a secret that reaches it has leaked. `bin/leaks` stops one first: Betterleaks, pinned in
the script and downloaded on first use, for what files say, and a list of names in the script (`config/master.key`,
`config/credentials/*.key`, dotenv files other than the templates and `.env.ci`, private keys, database dumps) for what
they are called.

| Where | When | What It Checks |
| --- | --- | --- |
| `.githooks/pre-commit`, `.githooks/pre-push` | Every commit and push, once `bin/leaks --install` has run (`bin/setup` and every Claude Code session run it) | The staged changes; the commits being pushed |
| `.claude/hooks/scan-for-leaks.sh` | Before every file an agent writes | The new text and the file's name |
| `.github/workflows/security.yml` | Every pull request and push to `main` | The files at HEAD and every commit before it; the ruleset on `main` requires this Secrets check |

When it stops you:

- **A real secret**: take it out, put it in the credentials or a gitignored `.env`, and tell the user, who revokes it if
  it was pushed.
- **Not a secret** (a test password, a placeholder, a value in a recorded page): `betterleaks:allow` in a comment on
  its line, or, where no comment fits, its fingerprint in `.betterleaksignore` with the reason above it.
- **Never skip the hooks.** `--no-verify`, `git commit -n` and changing `core.hooksPath` are blocked for agents, and
  CI scans the whole history anyway.

## Commits, Branches and Pull Requests

**Nothing deploys to production automatically for now**: the deploy job in `.github/workflows/ci.yml` is off until
the server runs the Rails 8 upgrade; deploy by hand with `bundle exec cap production deploy`. Changes reach `main`
only through a reviewed pull request; never push to `main`. CI (`.github/workflows/ci.yml`) runs `bin/test`, and
`.github/workflows/security.yml` runs `bin/leaks`, Brakeman and bundler-audit. The ruleset on `main` requires a pull
request and its Secrets check.

1. **One worktree per change**, off the latest `main`, on a branch named with the `branch-naming` skill:

   ```bash
   git fetch origin
   git worktree add -b <type>/<short-description> .claude/worktrees/<short-description> origin/main
   ```

   In Claude Code, switch the session into it with `EnterWorktree`. Run `bundle install` and `npm install` there.
2. **Commit** with the `conventional-commit` skill, staging files by name.
3. **Push and open a pull request** when the user asks: `git push -u origin <branch>`, then `gh pr create` with a
   summary and the test plan (the commands you ran and their result).

Keep a pull request to one concern. When it's merged, remove the worktree:
`git worktree remove .claude/worktrees/<short-description>`.

## Agent Setup

Claude Code reads `CLAUDE.md`, which imports this file. Other agents read this file directly.

| What | Lives In |
| --- | --- |
| Instructions | `AGENTS.md` |
| Rules, loaded by path | `.claude/rules/*.md` |
| Skills | `.claude/skills/*/SKILL.md` |
| Permissions, sandbox, hooks | `.claude/settings.json`; personal overrides in `.claude/settings.local.json` (not committed) |
| Hooks | `bin/leaks --install` (at session start); `.claude/hooks/block-sensitive-files.sh` and `block-hook-bypass.sh` (before shell commands); `scan-for-leaks.sh` (before edits); `format.sh` (after edits) |

The settings deny the secrets above, allow `bin/leaks`, `bin/lint` and `bin/test` without asking, ask before `cap`
and pushes to `main`, keep the sandbox's network to RubyGems, npm, GitHub, genpro.gov.sk and minv.sk, and run only
`bin/test` outside the sandbox. No test covers the agent setup: when you change it, try it in a session.
