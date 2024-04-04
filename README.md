# Otvorená Prokuratúra

[![Build Status](https://github.com/otvorenesudy/otvorenesudy-prokuratura/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/otvorenesudy/otvorenesudy-prokuratura/actions?query=branch:main)
[![Code Climate](https://codeclimate.com/github/otvorenesudy/otvorenesudy-prokuratura/badges/gpa.svg)](https://codeclimate.com/github/otvorenesudy/otvorenesudy-prokuratura)
[![Test Coverage](https://codeclimate.com/github/otvorenesudy/otvorenesudy-prokuratura/badges/coverage.svg)](https://codeclimate.com/github/otvorenesudy/otvorenesudy-prokuratura/coverage)

[![View performance data on Skylight](https://badges.skylight.io/status/T4hV7FBx1p8H.svg)](https://oss.skylight.io/app/applications/T4hV7FBx1p8H)
[![View performance data on Skylight](https://badges.skylight.io/rpm/T4hV7FBx1p8H.svg)](https://oss.skylight.io/app/applications/T4hV7FBx1p8H)
[![View performance data on Skylight](https://badges.skylight.io/typical/T4hV7FBx1p8H.svg)](https://oss.skylight.io/app/applications/T4hV7FBx1p8H)
[![View performance data on Skylight](https://badges.skylight.io/problem/T4hV7FBx1p8H.svg)](https://oss.skylight.io/app/applications/T4hV7FBx1p8H)

Public data project aimed at making information about public prosecutors such as their assignations and property declarations, and annual data about criminality from [General Prosecutors Office of the Slovak Republic](https://www.genpro.gov.sk) more publicly available.

## Requirements

- Ruby 3.3.0
- Rails 7.1
- PostgreSQL 16

## Installation

```
git clone git://github.com/otvorenesudy/otvorenesudy-prokuratura
cd otvorenesudy-prokuratura
bin/setup
```

Now import the data

```ruby
GenproGovSk::Offices.import
GenproGovSk::Prosecutors.import
GenproGovSk::Declarations.import

# Runs 12 separate processes to levarage all your cores. Adjust for less if needed.
GenproGovSk::Criminality.import # make sure to run Sidekiq as Declarations are processed in jobs
```

## Contributing

1. Fork it
2. Create your feature branch `git checkout -b new-feature`
3. Commit your changes `git commit -am 'Add some feature'`
4. Push to the branch `git push origin new-feature`
5. Create new Pull Request

## License

[Educational Community License 1.0](http://opensource.org/licenses/ecl1.php)
