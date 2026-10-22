# Otvorená Prokuratúra

[![CI](https://github.com/otvorenesudy/otvorenesudy-prokuratura/actions/workflows/ci.yml/badge.svg)](https://github.com/otvorenesudy/otvorenesudy-prokuratura/actions/workflows/ci.yml)

[![View performance data on Skylight](https://badges.skylight.io/status/T4hV7FBx1p8H.svg)](https://oss.skylight.io/app/applications/T4hV7FBx1p8H)
[![View performance data on Skylight](https://badges.skylight.io/rpm/T4hV7FBx1p8H.svg)](https://oss.skylight.io/app/applications/T4hV7FBx1p8H)
[![View performance data on Skylight](https://badges.skylight.io/typical/T4hV7FBx1p8H.svg)](https://oss.skylight.io/app/applications/T4hV7FBx1p8H)
[![View performance data on Skylight](https://badges.skylight.io/problem/T4hV7FBx1p8H.svg)](https://oss.skylight.io/app/applications/T4hV7FBx1p8H)

A public data project that makes information about Slovak public prosecutors more accessible: the prosecutors'
offices, the prosecutors and their appointments, their property declarations, prosecution decrees, and yearly
criminality statistics from the [General Prosecutor's Office](https://www.genpro.gov.sk) and the
[Ministry of the Interior](https://www.minv.sk). It runs at
[prokuratura.otvorenesudy.sk](https://prokuratura.otvorenesudy.sk).

## Requirements

- Ruby 4.0 and Node 24 (`.tool-versions`; Node runs Prettier and `bin/vendor`, the app's JavaScript needs no build)
- PostgreSQL 17 with the pg_trgm and unaccent extensions
- Redis (Sidekiq) and Memcached (cache, in production)
- Chrome, for the specs that need JavaScript and for the charts' PNG export
- Ghostscript (the prosecutors' PDF list) and unoconv with LibreOffice (decrees in RTF), for the imports

## Setup

```sh
git clone git@github.com:otvorenesudy/otvorenesudy-prokuratura.git
cd otvorenesudy-prokuratura
bin/setup
```

`bin/setup` installs the gems and the Node packages, creates `.env` and `.env.test` from the committed `.env.example`
and `.env.test.example` (never overwriting them), creates the database from `db/structure.sql` with its seeds, then
starts `bin/dev` (the app on port 3000 and the Dart Sass watcher).

Then import the data:

```ruby
GenproGovSk::Offices.import
GenproGovSk::Prosecutors.import
GenproGovSk::Decrees.import
GenproGovSk::Declarations.import

# Runs a process per core
GenproGovSk::Criminality.import

MinvSk::Criminality.import
```

The imports enqueue Sidekiq jobs (`bundle exec sidekiq -C config/sidekiq-1.yml`, and `config/sidekiq-2.yml` for the
decrees in RTF); `SIDEKIQ_INLINE=true` runs them as they're enqueued instead. On the server, cron
(`config/schedule.rb`) runs the imports nightly and weekly.

## Configuration

Settings come from the environment, with their defaults in the code: the database login
(`OPENCOURTS_PROKURATURA_DATABASE_HOST`, `OPENCOURTS_PROKURATURA_DATABASE_USER`,
`OPENCOURTS_PROKURATURA_DATABASE_PASSWORD`; without them PostgreSQL's defaults apply) and `REDIS_URL`.
[dotenv](https://github.com/bkeepers/dotenv) loads them in development from `.env` and in the specs from `.env.test`;
set your PostgreSQL login there if your own user can't log in. Neither file is committed, nor are `.env.local` and
`.env.*.local`, which override them. CI copies the committed `.env.ci` to `.env.test`, and production reads the same
variables from the server's environment (the deploy user's `~/.env`).

The other secrets live only in Rails' encrypted credentials: `config/credentials/production.yml.enc`, with its key in
`config/credentials/production.key` (on the server, linked by Capistrano; never committed). Production doesn't boot
without them and names the ones missing (`config/initializers/production_boot_check.rb`):

```yaml
secret_key_base: ...          # signs sessions and cookies
sidekiq:                      # the login of the Sidekiq dashboard at /sidekiq
  username: ...
  password: ...
google:
  analytics:
    tracking_id: ...          # Google Analytics, once the visitor allows analytics cookies
  api:
    search:                   # Google Custom Search, for the news about offices and prosecutors
      key: ...
      id: ...
geoapify:
  key: ...                    # geocodes the offices' addresses on import
sentry:
  dsn: ...
  traces_sample_rate: 1.0     # optional
skylight:
  token: ...
```

Edit them with `bin/rails credentials:edit --environment production`. Development and the specs need none of them;
to try one locally, make your own from `config/credentials/development.example` with
`bin/rails credentials:edit --environment development` (git ignores them).

## Browser Libraries

Bootstrap, Popper, Chart.js, Leaflet with its marker clusters and snogylop, and the cookie consent banner are listed
in `package.json` at exact versions, and `bin/vendor` copies them from `node_modules` into `vendor/`, bundling Popper
and Chart.js into one module each with esbuild. importmap serves them without a build step. Don't edit those files: to
update a library, change its version in `package.json` (Dependabot proposes updates weekly), then run `npm install`
and `bin/vendor` and commit what changed. Bootstrap's SCSS comes from the bootstrap gem, which must be the same
version. `bin/test` runs `bin/vendor --check`, which fails when the files aren't what `package.json`'s versions make.

## Testing

```sh
bin/test                                # lint, every spec with coverage, undercover
bin/test spec/system/offices_spec.rb    # lint, then those specs
bin/lint --fix                          # RuboCop and Prettier on what the branch changed
```

`bin/test` needs PostgreSQL running locally and Chrome; CI runs it on every pull request. The specs never reach the
network: the imports read saved pages and documents, and the specs of the live sources replay what genpro.gov.sk and
minv.sk answered when they were recorded (`spec/fixtures/vcr/live_sources`).

To check the live sites, record those answers again: `RECORD_LIVE_SOURCES=1 bundle exec rspec spec/features`. That
reaches genpro.gov.sk and minv.sk, so it is never part of `bin/test` or CI; when the sites changed their data, update
the expected JSON in `spec/fixtures` and commit the new recordings with it.

## Deployment

A maintainer deploys `main` with Capistrano: `bundle exec cap production deploy`. CI's deploy job is off until the
server runs the upgraded stack. The server is provisioned by
[otvorenesudy-server](https://github.com/otvorenesudy/otvorenesudy-server).

## License

[Educational Community License 1.0](http://opensource.org/licenses/ecl1.php)
