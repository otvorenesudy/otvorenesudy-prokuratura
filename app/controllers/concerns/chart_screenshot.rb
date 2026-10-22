# frozen_string_literal: true

# The criminality charts as pictures: headless Chrome opens the page's export (the chart without the facets), waits for
# the chart to be drawn and takes a screenshot of the whole page, at twice the resolution.
module ChartScreenshot
  extend ActiveSupport::Concern

  WIDTH = 1400

  CHROME_ARGUMENTS = %W[
    --headless --window-size=#{WIDTH},760 --force-device-scale-factor=2 --enable-font-antialiasing
    --disable-dev-shm-usage --no-sandbox --disable-extensions --disable-gpu --disable-setuid-sandbox
  ].freeze

  # True once every chart on the page is drawn (charts.js marks the canvas), or when there's none.
  CHARTS_DRAWN = "return document.querySelector('.chart canvas:not([data-chart-drawn])') === null"

  private

  def send_chart_screenshot(url, filename:)
    driver = Selenium::WebDriver.for(:chrome, options: Selenium::WebDriver::Chrome::Options.new(args: CHROME_ARGUMENTS))

    begin
      driver.get(url)
      Selenium::WebDriver::Wait.new(timeout: 10).until { driver.execute_script(CHARTS_DRAWN) }
      driver.manage.window.resize_to(WIDTH, driver.execute_script('return document.body.scrollHeight') + 25)

      send_data driver.screenshot_as(:png), type: 'image/png', filename:
    ensure
      driver.quit
    end
  end
end
