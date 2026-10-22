# otvorenesudy-prokuratura: Agent Instructions

Otvorená prokuratúra (prokuratura.otvorenesudy.sk), part of the Open Courts project: it makes public data about Slovak
prosecutors more accessible — the offices, the prosecutors and their assignments, their property declarations,
prosecution decrees, and yearly criminality statistics. It imports from the General Prosecutor's Office
(genpro.gov.sk) and the Ministry of the Interior (minv.sk) and serves faceted search over them. Rails 7.1, Ruby 3.3,
PostgreSQL, Sidekiq, Webpacker with Stimulus, Highcharts and Leaflet.

| Repository | What It Is | How It Relates |
| --- | --- | --- |
| otvorenesudy | The courts website | Sibling app on the same server |
| otvorenesudy-api | Court data importers and API | Sibling app; linked from the footer |
| otvorenesudy-server | Ansible provisioning of the production server | Runs this app: nginx, Passenger, PostgreSQL, Redis |

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
| Pages: listings, facets, detail, charts | System specs driving the page like a user | `spec/system/` |
| Endpoints (suggest, JSON, redirects) | Request specs | `spec/requests/` |
| Imports | The importer's entry point with saved pages and documents, records asserted | `spec/lib/genpro_gov_sk/`, `spec/lib/minv_sk/` |
| The live sources still parsing as expected | Feature specs against the live site, compared with expected JSON | `spec/features/` |

Use real collaborators: our code, Rails, the database. Fake only HTTP (VCR, WebMock), geocoding (stubbed for every
spec) and the clock. Never skip, delete or loosen a failing spec to get green; if a spec is wrong, say which scenario
it contradicts.

## Commands

```bash
bin/test                     # lint, then every spec (several minutes: the live-site specs); must be green
bin/test spec/models/office_spec.rb:12   # lint, then those specs
bin/lint                     # syntax_tree, RuboCop and Prettier on the files this branch changed
bin/lint --fix <file>        # format and autocorrect a file (the edit hook does this for you)
bin/rails server             # the app on localhost:3000
```

`bin/test` needs PostgreSQL on localhost. It rebuilds the test database from `db/schema.rb`, holds a machine-wide lock
shared with the other otvorenesudy apps, bypasses Spring, and runs outside the Claude Code sandbox because the
database login is in Rails credentials. Run specs through it rather than `bundle exec rspec`, which the sandbox can't
boot.

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
  | `*.rb`, `*.rake`, `Gemfile` | syntax_tree, then RuboCop's Lint and Security cops | `.streerc`, `.rubocop.yml` (120 columns, single quotes) |
  | `*.js`, `*.scss`, `*.css` | Prettier | `.prettierrc` |

  Most code predates the formatters, so `bin/lint` checks the files a branch changes. RuboCop's older offenses are
  listed in `.rubocop_todo.yml`.
- **Translations**: user-facing text goes through I18n, with every key in both `config/locales/sk.yml` and `en.yml`.
  The site defaults to Slovak, but specs run in English (`config/application.rb`), so assert English text in specs.
- **Dependencies**: gems with `bundle add` (commit `Gemfile.lock`), JavaScript with `yarn add` (commit `yarn.lock`).

## Secrets

These files hold credentials. Never read, print, copy or decrypt them, and don't ask to; when a change needs a
secret, ask the user to add it.

| File | What |
| --- | --- |
| `config/credentials.yml.enc`, `config/master.key` | Rails credentials and their key |
| `config/credentials/*.yml.enc`, `config/credentials/*.key` | Per-environment credentials (database login, Google, Geoapify, Sentry, Sidekiq, storage) and their keys, including CI's committed `test.ci.yml.enc` and `test.ci.key` |

Claude Code denies them to its file tools (`permissions.deny`) and to sandboxed commands
(`sandbox.filesystem.denyRead`), and a hook blocks shell commands that name them. `config/database.yml`,
`config/storage.yml` and `config/skylight.yml` only refer to credentials and ENV, and are fine to read.

## Commits, Branches and Pull Requests

**A push to `main` deploys to production** (`.github/workflows/main.yml`). Changes reach `main` only through a
reviewed pull request; never push to `main`.

1. **One worktree per change**, off the latest `main`, on a branch named with the `branch-naming` skill:

   ```bash
   git fetch origin
   git worktree add -b <type>/<short-description> .claude/worktrees/<short-description> origin/main
   ```

   In Claude Code, switch the session into it with `EnterWorktree`. Run `bundle install` and `yarn install` there.
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
| Hooks | `.claude/hooks/block-sensitive-files.sh` (before shell commands), `.claude/hooks/format.sh` (after edits) |

The settings deny the secrets above, allow `bin/lint` and `bin/test` without asking, ask before `cap` and pushes to
`main`, keep the sandbox's network to package registries, GitHub, genpro.gov.sk and minv.sk, and run only `bin/test`
outside the sandbox. No test covers the agent setup: when you change it, try it in a session.
