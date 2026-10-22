# frozen_string_literal: true

# Every example runs in a transaction on a database holding the seeds (db/seeds.rb: the Criminal Code's paragraphs and
# two offices) and the prosecution offices in spec/fixtures/offices.json, which the offices' indicator datasets
# (data/*.csv) name; all committed once before the suite.
RSpec.configure do |config|
  config.before(:suite) do
    connection = ActiveRecord::Base.connection
    connection.truncate_tables(*(connection.tables - %w[schema_migrations ar_internal_metadata]))

    Rails.application.load_seed

    # Each office geocodes to the coordinates it has on the site.
    JSON.parse(Rails.root.join('spec/fixtures/offices.json').read).each do |office|
      query = "#{office['address']}, #{office['city']}, Slovakia"
      Geocoder::Lookup::Test.add_stub(query, [{ 'coordinates' => office.values_at('latitude', 'longitude') }])

      Office.create!(office)
    end

    [Office, Prosecutor, Paragraph].each(&:refresh_search_view)
  end

  # The paragraphs and the offices' indicators are read once per process; each example reads them again, from its own
  # records.
  config.before do
    Paragraph.reset!
    Office.reset_indicators!
  end
end
