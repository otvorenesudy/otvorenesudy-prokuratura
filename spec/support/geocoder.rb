# frozen_string_literal: true

# Offices are geocoded by Geoapify through the geocoder gem. Its test lookup answers every address with Bratislava's
# coordinates; `geocoder: { latitude:, longitude: }` metadata gives an example others.
Geocoder.configure(lookup: :test)
Geocoder::Lookup::Test.set_default_stub([{ 'coordinates' => [48.1486, 17.1077] }])

RSpec.configure do |config|
  config.before do |example|
    coordinates = { latitude: 48.1486, longitude: 17.1077 }.merge(example.metadata[:geocoder] || {})

    Geocoder::Lookup::Test.set_default_stub([{ 'coordinates' => coordinates.values_at(:latitude, :longitude) }])
  end

  config.after { Geocoder::Lookup::Test.reset }
end
