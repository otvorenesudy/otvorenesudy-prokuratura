# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages' do
  describe 'the home page' do
    it 'leads to the prosecutors, the offices and the crime stats' do
      visit root_path

      expect(page).to have_text('More transparency to the Slovak prosecution offices')
      expect(page).to have_text('Otvorená Prokuratúra brings:')
      expect(page).to have_css('.feature .text-uppercase', text: 'Otvorená Prokuratúra')

      within('.square', text: 'Crime Stats', match: :first) { |square| square.click }

      expect(page).to have_css('h1', text: 'Prosecutors')
      expect(page).to have_current_path(statistics_path(l: :en))
    end

    it 'turns the carousel\'s slides', :js do
      visit root_path

      expect(page).to have_css('.carousel-item.active img[alt="V snahe o lepšie Slovensko vytrváme"]')
      expect(page).to have_css('.carousel-indicators button', count: 8)

      find('.carousel-indicators button[aria-label="Rytieri a bojovníčky Transparency"]').click

      expect(page).to have_css('.carousel-item.active img[alt="Rytieri a bojovníčky Transparency"]')
    end

    it 'charts the offices\' caseload', :js do
      visit root_path

      series = page.evaluate_script(<<~JS)
        Array.from(document.querySelectorAll('[data-controller="home-chart"]'), (element) => {
          const chart = window.Stimulus.getControllerForElementAndIdentifier(element, 'home-chart')?.chart;
          return chart && chart.data.datasets.filter((dataset, index) => chart.isDatasetVisible(index)).map((dataset) => dataset.label);
        })
      JS

      expect(page).to have_css('[data-controller="home-chart"] canvas[data-chart-drawn]', count: 4)
      expect(series).to eq([['2022', 'Priemer 2022'], ['Priemer za okresné prokuratúry', 'Priemer za krajské prokuratúry'],
                            ['Nápad vecí dozoru', 'Prenesené veci z predchádzajúceho obdobia'], %w[Pomer Priemer]])
    end
  end

  describe 'the navigation' do
    it 'opens the crime stats menu', :js do
      visit root_path

      within('header') do
        click_on 'Crime Stats'
        click_on 'Police'
      end

      expect(page).to have_css('h1', text: /police/i)
      expect(page).to have_css('.nav-link.dropdown-toggle.active', text: /crime stats/i)
    end

    it 'folds the menu on a phone', :js, width: 390 do
      visit root_path

      within('header') do
        expect(page).to have_no_link('Prosecutors\' Offices')

        click_on 'Menu', match: :first
        click_on 'Prosecutors\' Offices'
      end

      expect(page).to have_css('h1', text: /prosecutors' offices/i)
    end

    it 'switches the language' do
      visit offices_path

      click_on 'Slovenčina'

      expect(page).to have_css('html[lang="sk"]', visible: :all)
      expect(page).to have_css('h1', text: 'Prokuratúry')

      click_on 'English'

      expect(page).to have_css('h1', text: "Prosecutors' Offices")
    end

    it 'goes home for a language it does not speak' do
      visit offices_path(l: 'de')

      expect(page).to have_current_path(root_path(l: :en))
    end

    it 'opens links to other sites in a new tab', :js do
      visit root_path

      expect(page).to have_css('a[href="https://transparency.sk"][target="_blank"][rel="noopener"]', minimum: 1)
      expect(page).to have_no_css("a[href='#{offices_path(l: :en)}'][target='_blank']")
    end
  end

  describe 'the cookie consent', :js do
    # The banner hides from bots, which a browser driven by Selenium says it is (navigator.webdriver).
    before do
      @script = page.driver.browser.execute_cdp('Page.addScriptToEvaluateOnNewDocument',
                                                source: "Object.defineProperty(navigator, 'webdriver', { get: () => false })")
    end

    after { page.driver.browser.execute_cdp('Page.removeScriptToEvaluateOnNewDocument', identifier: @script['identifier']) }

    it 'asks for consent once, and keeps the answer across pages' do
      visit root_path

      within('#cc-main') { click_on 'Reject All' }

      expect(page).to have_no_css('#cc-main .cm', visible: :visible)

      visit offices_path

      expect(page).to have_link('Krajská prokuratúra v Bratislave')
      expect(page).to have_no_css('#cc-main .cm', visible: :visible)
    end
  end

  describe 'the static pages' do
    it 'shows each of them' do
      { 'about' => 'OTVORENÁ PROKURATÚRA', 'contact' => 'Bajkalská 25', 'copyright' => 'Transparency International',
        'faq' => 'Čo je cieľom projektu?', 'feedback' => 'kontakt', 'privacy' => 'osobných údajov',
        'tos' => 'Prevádzkovatelia' }.each do |slug, text|
        visit static_page_path(slug)

        expect(page).to have_text(text)
      end
    end

    it 'answers a page it does not have with not found' do
      visit static_page_path('unknown')

      expect(page.status_code).to eq(404)
    end
  end

  describe 'the error pages' do
    it 'shows the not found page, with the unicorn', :error_pages do
      visit office_path(0)

      expect(page).to have_css('h1', text: /page not found/i)
      expect(page).to have_css('img[alt="Unicorn"]')
    end
  end
end
