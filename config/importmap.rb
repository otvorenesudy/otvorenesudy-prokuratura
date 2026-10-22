# frozen_string_literal: true

# JavaScript modules, served from app/javascript and vendor/javascript. The libraries come from package.json through
# bin/vendor, which also keeps the version noted on each pin.
pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin '@popperjs/core', to: '@popperjs--core.js' # @2.11.8
pin 'bootstrap' # @5.3.8
pin 'chart.js' # @4.5.1
pin '@kurkle/color', to: '@kurkle--color.js' # @0.3.4
pin 'vanilla-cookieconsent' # @3.1.0
pin 'analytics'
pin 'charts'
pin 'home_charts'
pin 'cookie_consent'
pin 'external_links'
# Leaflet and the plugins that extend its global L, imported by the map controller only, in this order.
pin 'leaflet', preload: false # @1.9.4
pin 'leaflet.markercluster', preload: false # @1.5.3
pin 'leaflet.snogylop', preload: false # @0.4.0
