class StatisticsController < ApplicationController
  def index
    @search = StatisticSearch.new(index_params)
    @time = Benchmark.realtime { @data = @search.data } * 1000
    @count = Rails.cache.fetch('statistics_count', expires_in: 1.day) { Statistic.count }
  end

  def suggest
    return head 404 unless suggest_params[:facet].in?(%w[office paragraph])

    @search = StatisticSearch.new(index_params)

    render(
      json: {
        html:
          render_to_string(
            partial: "#{suggest_params[:facet]}_results",
            locals: {
              values: @search.facets_for(suggest_params[:facet], suggest: suggest_params[:suggest]),
              params: @search.params.merge("#{suggest_params[:facet]}_suggest" => suggest_params[:suggest])
            }
          )
      }
    )
  end

  def png
    path = Rails.root.join('tmp', "statistics-export-#{SecureRandom.hex}.png")
    url = export_statistics_url(index_params)

    options = Selenium::WebDriver::Chrome::Options.new(args: %w[headless])
    options.add_argument('--window-size=1400,760')
    options.add_argument('--enable-font-antialiasing')
    options.add_argument('--force-device-scale-factor=2')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-extensions')
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-setuid-sandbox')
    options.add_option(:detach, false)
    driver = Selenium::WebDriver.for(:chrome, options: options)

    begin
      driver.get(url)
      driver.manage.window.resize_to(1400, driver.execute_script('return document.body.scrollHeight') + 25)
      driver.save_screenshot(path)

      File.open(path, 'rb') do |file|
        send_data(file.read, type: 'image/png', filename: 'otvorena-prokuratura-export.png')
      end
    rescue Exception => e
      raise e
    ensure
      driver.quit
      File.delete(path)
    end
  end

  def export
    response.headers['X-FRAME-OPTIONS'] = 'ALLOWALL'

    index

    render layout: 'export'
  end

  def embed
    index
  end

  private

  helper_method :index_params

  def index_params
    params.permit(
      :comparison,
      :paragraph_suggest,
      :show_default_paragraphs,
      year: [],
      office: [],
      metric: [],
      office_type: [],
      paragraph: []
    )
  end

  def suggest_params
    params.permit(:facet, :suggest)
  end
end
