# frozen_string_literal: true

# The pages and documents of genpro.gov.sk and minv.sk the importers read, saved in spec/fixtures, served with WebMock.
module FixtureHelpers
  def fixture(path)
    Rails.root.join('spec/fixtures', path)
  end

  def stub_source(url, path)
    stub_request(:get, url).to_return(status: 200, body: fixture(path).binread)
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers
end
