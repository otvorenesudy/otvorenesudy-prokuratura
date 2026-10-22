# frozen_string_literal: true

require 'rails_helper'
require 'net/http'

RSpec.describe 'Criminality by the prosecutors' do
  let(:kosice) { Office.find_by!(name: 'Krajská prokuratúra v Košiciach') }
  let(:zilina) { Office.find_by!(name: 'Okresná prokuratúra Žilina') }

  before do
    { kosice => [3, 5, 4], zilina => [1, 2, 6] }.each do |office, counts|
      counts.each.with_index(2018) do |count, year|
        create(:statistic, office:, year:, metric: 'sentence_financial', paragraph: '§ 328 [new]', count:)
      end
    end

    create(:statistic, office: kosice, year: 2019, metric: 'accused_all', count: 50)
  end

  def chart_series(controller)
    page.evaluate_script(<<~JS, find("[data-controller=\"#{controller}\"] canvas[data-chart-drawn]"))
      window.Stimulus.getControllerForElementAndIdentifier(arguments[0].parentElement, '#{controller}')
        .chart.data.datasets.map((dataset) => dataset.label)
    JS
  end

  def table_rows
    all('.table-scrollable tbody tr').map { |row| row.all('th, td').map(&:text) }
  end

  it 'charts the sentences for corruption in all of Slovakia by year, and lists them by office', :js do
    visit statistics_path

    expect(page).to have_css('h1', text: /overview by corruption prosecution/i)
    expect(chart_series('statistics-chart')).to eq(['All of SR'])
    expect(table_rows).to eq([['All of SR', '4', '7', '10'], ['KP v Košiciach', '3', '5', '4'],
                              ['OP Žilina', '1', '2', '6']])
  end

  it 'compares the offices in the chart', :js do
    visit statistics_path

    click_on 'Compare In Chart'
    click_on 'By Office'

    expect(page).to have_current_path(/comparison=office/)
    expect(chart_series('statistics-chart')).to contain_exactly('Krajská prokuratúra v Košiciach',
                                                                'Okresná prokuratúra Žilina')
  end

  it 'sorts the offices by a year\'s counts', :js do
    visit statistics_path

    find('th', text: '2020').click
    expect(table_rows.map(&:first)).to eq(['KP v Košiciach', 'OP Žilina', 'All of SR'])

    find('th', text: '2020').click
    expect(table_rows.map(&:first)).to eq(['All of SR', 'OP Žilina', 'KP v Košiciach'])
  end

  it 'folds the facets away to widen the chart, and back', :js do
    visit statistics_path

    click_on 'Shrink'

    expect(page).to have_no_css('#facets', visible: :visible)
    expect(page).to have_css('[data-facets-target="results"].col-lg-12')

    click_on 'Enlarge'

    expect(page).to have_css('#facets', visible: :visible)
    expect(page).to have_no_css('[data-facets-target="results"].col-lg-12')
  end

  it 'narrows the statistics to a year, a type of office and an office' do
    visit statistics_path

    within('#statistic-year-content') { click_on '2019' }

    expect(table_rows).to eq([['All of SR', '7'], ['KP v Košiciach', '5'], ['OP Žilina', '2']])

    within('#statistic-office-type-content') { click_on 'District' }

    # All of Slovakia stays the whole country's sum.
    expect(table_rows).to eq([['All of SR', '7'], ['OP Žilina', '2']])

    visit statistics_path
    within('#statistic-office-content') { click_on 'KP v Košiciach' }

    expect(table_rows).to eq([['All of SR', '4', '7', '10'], ['KP v Košiciach', '3', '5', '4']])
  end

  it 'shows another metric, and says when there is no data for it' do
    create(:statistic, office: Office.find_by!(name: 'Generálna prokuratúra Slovenskej republiky'), year: 2019,
                       metric: 'accused_all', count: 10)
    # An office's total wins over the sum of its paragraphs.
    create(:statistic, office: kosice, year: 2019, metric: 'accused_all', paragraph: '§ 212 [new]', count: 7)

    visit statistics_path

    within('#statistic-accused-content') { click_on 'All', exact: true }

    expect(page).to have_text('Metric – All Accused People')
    expect(table_rows).to eq([['All of SR', '60'], ['KP v Košiciach', '50'], ['GP SR', '10']])

    visit statistics_path(metric: ['accused_men'])

    expect(page).to have_text('No statitics found for the given criteria')

    visit statistics_path(metric: ['judged_all'])

    expect(page).to have_css('h1', text: 'Metric – Judged persons')
  end

  it 'lists the corruption paragraphs behind the overview, marking those of the criminal code of 1961' do
    visit statistics_path

    click_on 'Show Paragraphs'

    within('h1 .paragraphs-list') do
      expect(find('li', text: /\A§ 328 – Prijímanie úplatku/)).to have_no_text("CC '61")
      expect(find('li', text: /\A§ 160 – Prijímanie úplatku a inej nenáležitej výhody/)).to have_text("CC '61")
    end
  end

  it 'narrows the sentences to paragraphs, compares them in the chart and drops one', :js do
    create(:statistic, office: kosice, year: 2019, metric: 'sentence_financial', paragraph: '§ 160 [old]', count: 2)

    visit statistics_path
    within('#statistic-paragraph-content') { click_on '§ 328 – Prijímanie' }

    expect(page).to have_css('h1 .paragraphs-list li', text: /§ 328/i)

    within('#statistic-paragraph-content') { click_on '§ 160 – Prijímanie' }

    expect(page).to have_css('h1 .paragraphs-list li', text: /§ 160/i)
    expect(page).to have_css('h1', text: /metric – all sentences – by paragraphs/i)
    expect(table_rows).to eq([['All of SR', '4', '9', '10'], ['KP v Košiciach', '3', '7', '4'],
                              ['OP Žilina', '1', '2', '6']])

    click_on 'Compare In Chart'
    click_on 'By Paragraphs'

    expect(page).to have_css('.dropdown-item.active', text: 'By Paragraphs', visible: :all)
    expect(chart_series('statistics-chart')).to contain_exactly(
      '§ 328 – Prijímanie úplatku', "§ 160 – Prijímanie úplatku a inej nenáležitej výhody [CC '61]"
    )

    within('h1 .paragraphs-list li', text: /§ 328/) { click_on '×' }

    expect(page).to have_no_css('h1 .paragraphs-list li', text: /§ 328/)
    expect(page).to have_css('.table-scrollable tbody tr', count: 2)
    expect(table_rows).to eq([['All of SR', '2'], ['KP v Košiciach', '2']])
  end

  it 'takes all the paragraphs together, and compares them as a sum when there are none to compare' do
    visit statistics_path

    within('#statistic-paragraph-content') { click_on 'All Paragraphs' }

    expect(page).to have_css('h1', text: 'Metric – All Sentences')
    expect(page).to have_no_css('h1 .paragraphs-list')
    expect(table_rows).to eq([['All of SR', '4', '7', '10'], ['KP v Košiciach', '3', '5', '4'],
                              ['OP Žilina', '1', '2', '6']])

    visit statistics_path(metric: ['accused_all'], comparison: 'paragraph')

    expect(page).to have_css('[data-controller="statistics-chart"][data-statistics-chart-comparison-value="global"]')
  end

  it 'suggests the paragraphs as the visitor types', :js do
    visit statistics_path

    within('#statistic-paragraph-content') do
      fill_in placeholder: 'Paragraph Name', with: 'uplat'

      expect(page).to have_link(text: /§ 328 – Prijímanie/)
      expect(page).to have_no_link(text: /§ 212/)
    end
  end

  it 'exports the chart for embedding, without the facets' do
    visit embed_statistics_path

    expect(page).to have_css("iframe[src*='#{export_statistics_path}']")
    expect(find('textarea#embed', visible: :all).value).to include(export_statistics_path)

    visit export_statistics_path(embedded: true)

    expect(page).to have_css('[data-controller="statistics-chart"][data-statistics-chart-animated-value="false"]')
    expect(page).to have_no_css('#facets')
    expect(page).to have_link('Open in the Application Otvorená Prokuratúra')
  end

  it 'takes a picture of the chart', :js do
    visit statistics_path

    response = Net::HTTP.get_response(URI.join(page.current_url, png_statistics_path))

    expect(response['Content-Type']).to eq('image/png')
    expect(response.body.byteslice(0, 8)).to eq("\x89PNG\r\n\x1A\n".b)
  end
end
