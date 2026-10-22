# frozen_string_literal: true

# RTF decrees are converted to text by unoconv (LibreOffice), which CI doesn't have: `unoconv: true` puts the stand-in
# in spec/support/bin first on the PATH.
RSpec.configure do |config|
  config.around(unoconv: true) do |example|
    path = ENV.fetch('PATH')
    ENV['PATH'] = "#{Rails.root.join('spec/support/bin')}:#{path}"
    example.run
  ensure
    ENV['PATH'] = path
  end
end
