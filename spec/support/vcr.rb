# frozen_string_literal: true

# Recorded responses of genpro.gov.sk and minv.sk (spec/fixtures/vcr), replayed through WebMock:
# `vcr: { cassette_name: '...' }`. A request without a cassette or a stub fails, like any other request leaving the
# machine. The specs in spec/features replay compressed snapshots of the live sources (live_sources/), and never
# record: to check the live sites again, run them with RECORD_LIVE_SOURCES=1, which records the snapshots anew. That
# reaches the network, so it is never part of bin/test or CI.
VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false
  config.preserve_exact_body_bytes { |message| !message.body.valid_encoding? || message.body.encoding == Encoding::BINARY }
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/features/}) do |metadata|
    name = metadata[:file_path].delete_prefix('./spec/features/').delete_suffix('_spec.rb')
    record = ENV['RECORD_LIVE_SOURCES'] ? :all : :none

    metadata[:vcr] = { cassette_name: "live_sources/#{name}", serialize_with: :compressed, record: }
  end
end
