Geocoder.configure(lookup: :bing, api_key: Rails.application.credentials.dig(:bing, :maps, :key))
