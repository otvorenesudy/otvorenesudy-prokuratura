# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Offices' do
  let(:bratislava) { Office.find_by!(name: 'Krajská prokuratúra v Bratislave') }
  let(:kosice) { Office.find_by!(name: 'Krajská prokuratúra v Košiciach') }

  def appoint(office, *names)
    names.map do |name|
      last, first = name.split
      prosecutor = create(:prosecutor, name: "JUDr. #{first} #{last}", name_parts: { first:, last: })
      create(:appointment, office:, prosecutor:, type: :fixed)

      prosecutor
    end
  end

  describe 'the listing' do
    it 'lists the active offices, 15 a page' do
      visit offices_path

      expect(page).to have_css('h1', text: "Prosecutors' Offices")
      expect(page).to have_css('.search-result-title a', count: 15)
      expect(page).to have_link('Generálna prokuratúra Slovenskej republiky')
      expect(page).to have_text('1 – 15 out of 63 attorney general offices')

      click_on 'Next'

      expect(page).to have_text('16 – 30 out of 63 attorney general offices')
    end

    it 'finds the offices of a city typed without diacritics' do
      visit offices_path
      fill_in 'q', with: 'kosice'
      click_on 'Name of the office or name of the prosecutor'

      expect(page).to have_link('Krajská prokuratúra v Košiciach')
      expect(page).to have_link('Okresná prokuratúra Košice I')
      expect(page).to have_no_link('Krajská prokuratúra v Bratislave')
    end

    it 'says when no office matches' do
      visit offices_path(q: 'zzzzzz')

      expect(page).to have_text("No prosecutors' offices found for given search filters.")
    end

    it 'narrows the offices to a type' do
      visit offices_path

      within('#office-type-content') { click_on 'Regional' }

      expect(page).to have_css('.search-result-title a', count: 8)
      expect(page).to have_link('Krajská prokuratúra v Košiciach')
      expect(page).to have_no_link('Okresná prokuratúra Košice I')

      click_on 'Cancel all filters'

      expect(page).to have_text('1 – 15 out of 63 attorney general offices')
    end

    it 'narrows the offices to those with a number of prosecutors' do
      appoint(kosice, 'Novák Ján', 'Horváth Peter')

      visit offices_path
      within('#office-prosecutors-count-content') { find('a', text: /\A1 up to 5 prosecutors/).click }

      expect(page).to have_css('.search-result-title a', count: 1)
      expect(page).to have_link('Krajská prokuratúra v Košiciach')
      expect(page).to have_text('At the prosecutor\'s office we register 2 prosecutors')
    end

    it 'narrows the offices to those with decrees, and to a paragraph of them' do
      theft = Paragraph.find_by!(value: '§ 212 [new]')
      create_list(:decree, 2, office: kosice, paragraph: theft)
      create(:decree, office: bratislava)

      visit offices_path
      within('#office-decrees-count-content') { find('a', text: /\A1 up to 50 decrees/).click }

      expect(page).to have_css('.search-result-title a', count: 2)

      within('#office-paragraph-content') { click_on theft.name.first(20) }

      expect(page).to have_css('.search-result-title a', count: 1)
      expect(page).to have_link('Krajská prokuratúra v Košiciach')
    end

    it 'sorts the offices by name, either way' do
      visit offices_path

      within('#office-sort-content') { click_on 'By Name' }
      click_on 'Descending'

      # Letters before accents: Zvolen comes after Žilina.
      expect(page.first('.search-result-title a')).to have_text('Okresná prokuratúra Zvolen')

      click_on 'Ascending'

      expect(page.first('.search-result-title a')).to have_text('Generálna prokuratúra Slovenskej republiky')
    end

    it 'sorts the offices by type, either way' do
      visit offices_path

      within('#office-sort-content') { click_on 'By Type' }

      expect(page.first('.search-result-title a')).to have_text('Okresná prokuratúra')

      click_on 'Descending'

      expect(page.first('.search-result-title a')).to have_text('Generálna prokuratúra Slovenskej republiky')
    end

    it 'keeps the default order for a sort it does not know, or by relevancy without a query' do
      visit offices_path(sort: 'name', order: 'sideways')

      expect(page.first('.search-result-title a')).to have_text('Generálna prokuratúra Slovenskej republiky')

      visit offices_path(sort: 'relevancy')

      expect(find('#office-sort-content .dropdown-toggle')).to have_text('Default')
    end

    it 'opens an office\'s decrees of the paragraph it narrowed the offices to', :js do
      theft = Paragraph.find_by!(value: '§ 212 [new]')
      create(:decree, office: kosice, paragraph: theft, number: '1 Pv 1/24')
      create(:decree, office: kosice, number: '1 Pv 2/24')

      visit offices_path(paragraph: [theft.value])
      click_on 'Krajská prokuratúra v Košiciach'
      scroll_to find_by_id('decrees')

      within('#decrees') do
        expect(page).to have_text('Filtered by § 212 – Krádež')
        expect(page).to have_link('1 Pv 1/24')
        expect(page).to have_no_link('1 Pv 2/24')
      end
    end

    it 'suggests the cities as the visitor types', :js do
      visit offices_path

      within('#office-city-content') do
        fill_in placeholder: 'Name of the city', with: 'zili'

        expect(page).to have_link('Žilina')
        expect(page).to have_no_link('Bratislava')

        click_on 'Žilina'
      end

      expect(page).to have_link('Krajská prokuratúra v Žiline')
      expect(page).to have_link('Okresná prokuratúra Žilina')
      expect(page).to have_css('.search-result-title a', count: 2)
    end

    it 'shows the offices on the map, clustered where close, each linking to its page', :js do
      visit offices_path(type: ['regional'])

      expect(page).to have_css('.leaflet-marker-icon[title="Krajská prokuratúra v Žiline"]')
      expect(page).to have_no_css('.leaflet-marker-icon[title="Krajská prokuratúra v Košiciach"]')

      find('.marker-cluster', text: '2').click
      find('.leaflet-marker-icon[title="Krajská prokuratúra v Košiciach"]').hover

      within('.leaflet-popup') { click_on 'Krajská prokuratúra v Košiciach' }

      expect(page).to have_css('h1', text: /krajská prokuratúra v košiciach/i)
    end
  end

  describe 'an office' do
    it 'shows its contact and its registry' do
      visit office_path(kosice)

      expect(page).to have_css('h1', text: 'Krajská prokuratúra v Košiciach')
      expect(page).to have_text(kosice.full_address)
      expect(page).to have_link(kosice.email)
      expect(page).to have_text('Business Hours')
      expect(page).to have_text(kosice.registry.dig('hours', 'monday'))
    end

    it 'answers an office that does not exist with the not found page', :error_pages do
      visit office_path(0)

      expect(page).to have_text('404').or(have_text('not found'))
    end

    it 'sorts its prosecutors by name, either way', :js do
      appoint(kosice, 'Zelený Peter', 'Čierny Adam', 'Biely Ján')

      visit office_path(kosice)
      within('.nav-tabs') { click_on 'Prosecutors' }

      within('#prosecutors') do
        expect(names_in_table).to eq(['JUDr. Peter Zelený', 'JUDr. Adam Čierny', 'JUDr. Ján Biely'])

        find('th', text: /name of the prosecutor/i).click
        expect(names_in_table).to eq(['JUDr. Ján Biely', 'JUDr. Adam Čierny', 'JUDr. Peter Zelený'])

        find('th', text: /name of the prosecutor/i).click
        expect(names_in_table).to eq(['JUDr. Peter Zelený', 'JUDr. Adam Čierny', 'JUDr. Ján Biely'])
      end
    end

    it 'explains the prosecutors\' activity in a tooltip', :js do
      appoint(kosice, 'Zelený Peter')
      biely = create(:prosecutor, name: 'JUDr. Ján Biely', name_parts: { first: 'Ján', last: 'Biely' })
      create(:appointment, office: kosice, prosecutor: biely, type: :temporary)

      visit office_path(kosice)
      within('.nav-tabs') { click_on 'Prosecutors' }

      hover_when_connected(find('#prosecutors tr', text: 'Zelený').find('a[data-controller="tooltip"]'), 'tooltip')

      expect(page).to have_css('.tooltip', text: 'Active prosecutor')

      hover_when_connected(find('#prosecutors tr', text: 'Biely').find('a[data-controller="tooltip"]'), 'tooltip')

      expect(page).to have_css('.tooltip', text: 'Temporarily appointed prosecutor')
    end

    it 'loads its decrees, newest first, and filters them as the visitor types', :js do
      cierny, = appoint(kosice, 'Čierny Adam')
      create(:decree, office: kosice, prosecutor: cierny, number: '1 Pv 100/24', effective_on: Date.new(2024, 1, 10))
      create(:decree, office: kosice, number: '1 Pv 200/24', effective_on: Date.new(2024, 5, 20),
                      resolution: 'Uznesenie o postúpení veci')

      visit office_path(kosice, tab: 'decrees')
      scroll_to find_by_id('decrees')

      within('#decrees') do
        expect(page).to have_link('1 Pv 100/24')
        expect(page.all('tbody tr td:nth-child(2)').map(&:text)).to eq(['1 Pv 200/24', '1 Pv 100/24'])

        fill_in placeholder: 'Search in Decrees', with: 'cierny'

        expect(page).to have_css('tbody tr:not([hidden])', count: 1)
        expect(page).to have_link('JUDr. Adam Čierny')
        expect(page).to have_text('List of Decrees (1)')

        fill_in placeholder: 'Search in Decrees', with: 'zzz'

        expect(page).to have_text('No decrees found')

        click_on 'Clear the search'

        expect(page).to have_css('tbody tr:not([hidden])', count: 2)
      end
    end

    it 'counts its convicted people a year, beside the average of its type' do
      zilina = Office.find_by!(name: 'Okresná prokuratúra Žilina')
      { 2019 => 3, 2020 => 5 }.each do |year, count|
        create(:statistic, office: zilina, year:, metric: 'convicted_all', paragraph: '§ 212 [new]', count:)
      end

      visit office_path(zilina)

      expect(page).to have_text('We register 4.0 convited people per year on avarage.')
      expect(page).to have_text("District yearly average is #{(4.0 / Office.district.count).round(2)}.")
    end

    it 'draws its indicators by year beside the average of its type', :js do
      visit office_path(bratislava)

      canvas = find('canvas[data-chart-drawn]')
      labels = page.evaluate_script(<<~JS, canvas)
        window.Stimulus.getControllerForElementAndIdentifier(arguments[0].parentElement, 'indicators-chart')
          .chart.data.datasets.map((dataset) => dataset.label)
      JS

      expect(labels).to include(I18n.t('active_record.models.prosecutor.indicators.incoming_cases.office'))
    end
  end

  def names_in_table
    all('tbody tr td:nth-child(2) a').map(&:text)
  end
end
