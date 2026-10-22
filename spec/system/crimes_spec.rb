# frozen_string_literal: true

require 'rails_helper'
require 'net/http'

RSpec.describe 'Criminality by the police' do
  before do
    {
      'crime_discovered' => [40, 30],
      'crime_solved' => [20, 25],
      'persons_all' => [15, 18],
      'crime_denominated_damage' => [125_000, 2_500_000]
    }.each do |metric, counts|
      counts.each.with_index(2019) do |count, year|
        create(:crime, year:, metric:, paragraph: '§ 328 [new]', count:)
        create(:crime, year:, metric:, paragraph: '§ 212 [new]', count: count * 10)
      end
    end
  end

  def chart_series
    page.evaluate_script(<<~JS, find('[data-controller="crimes-chart"] canvas[data-chart-drawn]'))
      window.Stimulus.getControllerForElementAndIdentifier(arguments[0].parentElement, 'crimes-chart')
        .chart.data.datasets.map((dataset) => [dataset.label, dataset.type || 'line', dataset.yAxisID || 'y'])
    JS
  end

  def table_rows(group)
    find('.table-scrollable', text: /#{group}/i).all('tbody tr').map { |row| row.all('th, td').map(&:text) }
  end

  it 'charts the corruption crimes and their perpetrators by year, and lists them', :js do
    visit crimes_path

    expect(page).to have_css('h1', text: /overview by corruption criminality/i)
    expect(chart_series).to contain_exactly(['Crimes – Discovered', 'line', 'y'], ['Crimes – Solved', 'line', 'y'],
                                            ['Perpetrators – All Persons', 'line', 'y'])
    expect(table_rows('Crimes')).to eq([%w[Discovered 40 30], %w[Solved 20 25]])
    expect(table_rows('Perpetrators')).to eq([['All Persons', '15', '18']])
  end

  it 'charts the damages in euros on an axis of their own, the full amount in a tooltip', :js do
    visit crimes_path(paragraph: ['§ 328 [new]'])

    expect(chart_series).to include(['Crimes – Denominated Damage', 'bar', 'damages'],
                                    ['Crimes – Discovered', 'line', 'y'])

    damage = find('tfoot td span[data-controller="tooltip"]', text: '2.5M')
    scroll_to damage
    hover_when_connected(damage, 'tooltip')

    expect(page).to have_css('.tooltip', text: '€2,500,000')
  end

  it 'sorts the crimes by a year\'s counts', :js do
    visit crimes_path

    year = find('.table-scrollable', text: /crimes/i).find('th', text: '2020')

    year.click
    expect(table_rows('Crimes').map(&:first)).to eq(%w[Solved Discovered])

    year.click
    expect(table_rows('Crimes').map(&:first)).to eq(%w[Discovered Solved])
  end

  it 'narrows the statistics to a year, a metric and a paragraph' do
    visit crimes_path

    within('#crimes-year-content') { click_on '2020' }

    expect(table_rows('Crimes')).to eq([%w[Discovered 30], %w[Solved 25]])

    visit crimes_path(paragraph: ['§ 212 [new]'])

    expect(page).to have_text('§ 212 – Krádež')
    expect(table_rows('Crimes')).to eq([%w[Discovered 400 300], %w[Solved 200 250]])

    # The paragraph's overview selects its metrics; a selected one comes off.
    within('#crimes-crimes-content') { click_on 'Discovered' }

    expect(table_rows('Crimes')).to eq([%w[Solved 200 250]])
  end

  it 'shows the damages alone, under their own title' do
    visit crimes_path(metric: ['crime_denominated_damage'])

    expect(page).to have_css('h1', text: 'Material Damages')
    expect(page).to have_no_css('h1 .paragraphs-list')
  end

  it 'shows the corruption paragraphs of the overview on request' do
    visit crimes_path

    click_on 'Show Paragraphs'

    expect(page).to have_text('§ 328 – Prijímanie úplatku')
  end

  it 'exports the chart for embedding, without the facets' do
    visit embed_crimes_path

    expect(page).to have_css("iframe[src*='#{export_crimes_path}']")

    visit export_crimes_path(embedded: true)

    expect(page).to have_css('[data-controller="crimes-chart"][data-crimes-chart-animated-value="false"]')
    expect(page).to have_no_css('#facets')
    expect(page).to have_link('Open in the Application Otvorená Prokuratúra', href: /#{crimes_path}/)
  end

  it 'takes a picture of the chart', :js do
    visit crimes_path

    response = Net::HTTP.get_response(URI.join(page.current_url, png_crimes_path))

    expect(response['Content-Type']).to eq('image/png')
    expect(response.body.byteslice(0, 8)).to eq("\x89PNG\r\n\x1A\n".b)
  end
end
