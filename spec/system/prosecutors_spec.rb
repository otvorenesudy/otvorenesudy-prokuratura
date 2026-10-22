# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Prosecutors' do
  let(:kosice) { Office.find_by!(name: 'Krajská prokuratúra v Košiciach') }
  let(:zilina) { Office.find_by!(name: 'Okresná prokuratúra Žilina') }

  def prosecutor(name, office: nil, **attributes)
    first, last = name.split
    record = create(:prosecutor, name: "JUDr. #{first} #{last}", name_parts: { first:, last: }, **attributes)
    create(:appointment, office:, prosecutor: record, type: :fixed) if office

    record
  end

  def declaration(year, office:)
    {
      genpro_gov_sk_declaration_id: year,
      name: 'JUDr. Ján Novák',
      office: office.name,
      url: "https://www.genpro.gov.sk/majetkove-priznania/#{year}",
      year:,
      lists: [
        {
          category: 'Nehnuteľnosti',
          items: [{ description: "Byt #{year}", acquisition_date: '12.03.2015', acquisition_reason: 'kúpa',
                    procurement_price: nil, price: '120 000 €' }]
        }
      ],
      incomes: [{ description: 'Príjem z funkcie prokurátora', value: "#{year} €" }],
      statements: ["Vyhlásenie za rok #{year}"]
    }
  end

  describe 'the listing' do
    it 'lists the prosecutors with their offices and what we register about them' do
      novak = prosecutor('Ján Novák', office: kosice, declarations: [declaration(2023, office: kosice)])
      create(:decree, prosecutor: novak, office: kosice)
      prosecutor('Peter Horváth')

      visit prosecutors_path

      expect(page).to have_css('h1', text: 'Prosecutors')
      expect(page).to have_text('1 – 2 out of 2 prosecutors')
      expect(page).to have_link('JUDr. Ján Novák')
      expect(page).to have_text('The prosecutor is appointed to Krajská prokuratúra v Košiciach.')
      expect(page).to have_text('We register 1 decree and 1 asset declaration.')
      expect(page).to have_css('a[data-bs-title="Probably an inactive prosecutor"]')
    end

    it 'finds a prosecutor by a name typed without diacritics' do
      prosecutor('Ján Novák', office: kosice)
      prosecutor('Peter Horváth', office: kosice)
      refresh_search_views

      visit prosecutors_path
      fill_in 'q', with: 'horvath'
      click_on 'Name of the prosecutor or prosecutors\' office'

      expect(page).to have_link('JUDr. Peter Horváth')
      expect(page).to have_no_link('JUDr. Ján Novák')
    end

    it 'says when no prosecutor matches' do
      prosecutor('Ján Novák', office: kosice)

      visit prosecutors_path(q: 'zzzzzz')

      expect(page).to have_text('No prosecutors found for given search filters.')
    end

    it 'narrows the prosecutors to a type of office, an office and a city' do
      prosecutor('Ján Novák', office: kosice)
      prosecutor('Peter Horváth', office: zilina)

      visit prosecutors_path
      within('#prosecutor-type-content') { click_on 'District' }

      expect(page).to have_link('JUDr. Peter Horváth')
      expect(page).to have_no_link('JUDr. Ján Novák')

      visit prosecutors_path
      within('#prosecutor-office-content') { click_on 'KP v Košiciach' }

      expect(page).to have_link('JUDr. Ján Novák')
      expect(page).to have_no_link('JUDr. Peter Horváth')

      visit prosecutors_path
      within('#prosecutor-city-content') { click_on 'Žilina' }

      expect(page).to have_link('JUDr. Peter Horváth')
      expect(page).to have_no_link('JUDr. Ján Novák')
    end

    it 'narrows the prosecutors to those with decrees of a paragraph, and opens those decrees' do
      theft = Paragraph.find_by!(value: '§ 212 [new]')
      novak = prosecutor('Ján Novák', office: kosice)
      create(:decree, prosecutor: novak, office: kosice, paragraph: theft, number: '1 Pv 1/24')
      create(:decree, prosecutor: novak, office: kosice, number: '1 Pv 2/24')
      horvath = prosecutor('Peter Horváth', office: zilina)
      create(:decree, prosecutor: horvath, office: zilina)

      visit prosecutors_path
      within('#prosecutor-decrees-count-content') { find('a', text: /\A1 up to 10 decrees/).click }

      expect(page).to have_css('.search-result-title > a[href*="/prosecutors/"]', count: 2)

      within('#prosecutor-paragraph-content') { click_on theft.name.first(20) }

      expect(page).to have_css('.search-result-title > a[href*="/prosecutors/"]', count: 1)

      click_on 'JUDr. Ján Novák'

      within('#decrees') do
        expect(page).to have_text('Filtered by § 212 – Krádež')
        expect(page).to have_text('1 Pv 1/24')
        expect(page).to have_no_text('1 Pv 2/24')
      end
    end

    it 'sorts by relevancy only what the visitor searched for' do
      visit prosecutors_path(sort: 'relevancy')

      expect(find('#prosecutor-sort-content .dropdown-toggle')).to have_text('Default')
    end

    it 'sorts the prosecutors of a list by name' do
      list = create(:genpro_gov_sk_prosecutors_list)
      prosecutor('Ján Novák', office: kosice, genpro_gov_sk_prosecutors_list: list)
      prosecutor('Adam Bielik', office: kosice, genpro_gov_sk_prosecutors_list: list)

      visit prosecutors_path
      within('#prosecutor-sort-content') { click_on 'By Name' }
      click_on 'Descending'

      expect(all('.search-result-title > a[href*="/prosecutors/"]').map(&:text)).to eq(['JUDr. Ján Novák',
                                                                                        'JUDr. Adam Bielik'])

      click_on 'Ascending'

      expect(all('.search-result-title > a[href*="/prosecutors/"]').map(&:text)).to eq(['JUDr. Adam Bielik',
                                                                                        'JUDr. Ján Novák'])
    end

    it 'suggests the offices as the visitor types', :js do
      prosecutor('Ján Novák', office: kosice)
      prosecutor('Peter Horváth', office: zilina)

      visit prosecutors_path

      within('#prosecutor-office-content') do
        fill_in placeholder: 'Name of the office', with: 'zilin'

        expect(page).to have_link('OP Žilina')
        expect(page).to have_no_link('KP v Košiciach')
      end
    end

    it 'leads from a cluster of an office\'s prosecutors on the map to them in the listing', :js do
      prosecutor('Ján Novák', office: kosice)
      prosecutor('Peter Horváth', office: kosice)
      prosecutor('Adam Bielik', office: zilina)

      visit prosecutors_path

      expect(page).to have_css('.leaflet-marker-icon[title="JUDr. Adam Bielik"]')

      find('.marker-cluster', text: '2').click

      expect(page).to have_text('We are redirecting you to the list of prosecutors …')
      expect(page).to have_current_path(/office%5B%5D=Krajsk/, wait: 10)
      expect(page).to have_link('JUDr. Ján Novák')
      expect(page).to have_no_link('JUDr. Adam Bielik')
    end
  end

  describe 'a prosecutor' do
    it 'shows the offices the prosecutor works at, has worked at and leads' do
      novak = prosecutor('Ján Novák', office: kosice)
      create(:appointment, office: zilina, prosecutor: novak, ended_at: 1.year.ago)
      create(:employee, office: kosice, prosecutor: novak, position: 'krajský prokurátor')

      visit prosecutor_path(novak)

      expect(page).to have_css('h1', text: 'JUDr. Ján Novák')
      expect(page).to have_text('The prosecutor is appointed to Krajská prokuratúra v Košiciach.')
      expect(page).to have_link('Okresná prokuratúra Žilina')
      expect(page).to have_text('We register the prosecutor as krajský prokurátor at the prosecutors\' office')
    end

    it 'shows each year\'s estate declaration in its tab', :js do
      novak = prosecutor('Ján Novák', office: kosice,
                                      declarations: [declaration(2022, office: kosice), declaration(2023, office: kosice)])

      visit prosecutor_path(novak)

      within('#declarations') do
        expect(page).to have_text('Byt 2023')
        expect(page).to have_no_text('Byt 2022')

        within('.nav-tabs') { click_on '2022' }

        expect(page).to have_text('Byt 2022')
        expect(page).to have_text('Príjem z funkcie prokurátora')
        expect(page).to have_text('Vyhlásenie za rok 2022')
        expect(page).to have_link('Krajská prokuratúra v Košiciach')
      end
    end

    it 'says when there is no estate declaration' do
      novak = prosecutor('Ján Novák', office: kosice)

      visit prosecutor_path(novak)

      expect(page).to have_text('No estate declarations found.')
    end

    it 'filters and sorts the prosecutor\'s decrees', :js do
      novak = prosecutor('Ján Novák', office: kosice)
      create(:decree, prosecutor: novak, office: kosice, number: '1 Pv 100/24', effective_on: Date.new(2024, 1, 10))
      create(:decree, prosecutor: novak, office: zilina, number: '2 Pv 200/24', effective_on: Date.new(2024, 5, 20))

      visit prosecutor_path(novak)
      within('.nav-tabs') { click_on 'Decrees' }

      within('#decrees') do
        expect(numbers).to eq(['2 Pv 200/24', '1 Pv 100/24'])

        find('th', text: /effective on/i).click
        expect(numbers).to eq(['1 Pv 100/24', '2 Pv 200/24'])

        fill_in placeholder: 'Search in Decrees', with: 'zilina'

        expect(page).to have_css('tbody tr:not([hidden])', count: 1)
        expect(page).to have_text('List of Decrees (1)')
      end
    end

    it 'links the news about the prosecutor, only to web addresses' do
      novak = prosecutor('Ján Novák', office: kosice, news: {
                           'data' => [
                             { 'title' => 'Prokurátor podal obžalobu', 'url' => 'https://dennikn.sk/1', 'source' => 'Denník N',
                               'snippet' => 'Obžaloba' },
                             { 'title' => 'Podvrh', 'url' => 'javascript:alert(1)', 'source' => 'SME',
                               'snippet' => 'Nič' }
                           ]
                         })

      visit prosecutor_path(novak)

      within('#media') do
        expect(page).to have_link('Prokurátor podal obžalobu', href: 'https://dennikn.sk/1')
        expect(page).to have_text('Podvrh')
        expect(page).to have_no_link('Podvrh')
      end
    end

    it 'answers a prosecutor that does not exist with the not found page', :error_pages do
      visit prosecutor_path(0)

      expect(page).to have_text('404').or(have_text('not found'))
    end
  end

  def numbers
    all('tbody tr td:nth-child(2) a').map(&:text)
  end
end
