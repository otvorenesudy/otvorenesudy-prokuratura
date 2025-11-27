RSpec.configure do |config|
  config.before(:each) do |example|
    options = example.metadata

    if options[:geocoder]
      latitude, longitude =
        if options[:geocoder].is_a?(Hash)
          [options[:geocoder][:latitude] || 48.1486, options[:geocoder][:longitude] || 17.1077]
        else
          [48.1486, 17.1077]
        end

      location_stub = Struct.new(:latitude, :longitude).new(latitude, longitude)
      allow(Geocoder).to receive(:search).and_return([location_stub])
    end
  end
end
