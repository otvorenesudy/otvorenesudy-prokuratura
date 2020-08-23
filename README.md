# Otvorená Prokuratúra

[![Build Status](https://travis-ci.org/otvorenesudy/otvorenesudy-api.svg)](https://travis-ci.org/otvorenesudy/otvorenesudy-api)
[![Code Climate](https://codeclimate.com/github/otvorenesudy/otvorenesudy-api/badges/gpa.svg)](https://codeclimate.com/github/otvorenesudy/otvorenesudy-api)
[![Test Coverage](https://codeclimate.com/github/otvorenesudy/otvorenesudy-api/badges/coverage.svg)](https://codeclimate.com/github/otvorenesudy/otvorenesudy-api/coverage)

RESTful APIs and crawlers for public data of the [Open Courts](https://github.com/otvorenesudy) project

Public data project aimed at making information about public prosecutors such as their assignations and property declarations, and annual data about criminality from [General Prosecutors Office of the Slovak Republic](https://www.genpro.gov.sk) more publicly available.

## Requirements

- Ruby 2.7
- Rails 6
- PostgreSQL 9.4 (minimum)

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
GenproGovSk::Criminality.import # enqueues Sidekiq jobs
```

## Contributing

1. Fork it
2. Create your feature branch `git checkout -b new-feature`
3. Commit your changes `git commit -am 'Add some feature'`
4. Push to the branch `git push origin new-feature`
5. Create new Pull Request

## License

[Educational Community License 1.0](http://opensource.org/licenses/ecl1.php)
