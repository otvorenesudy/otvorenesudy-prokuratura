# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Decrees::Parser do
  def parse(page)
    described_class.parse(fixture("genpro_gov_sk/decrees/#{page}.html").read, url: 'https://www.genpro.gov.sk/')
  end

  # The listing writes some of the texts with non-breaking spaces.
  def squish(decree, *keys)
    decree.merge(decree.slice(*keys).transform_values { |value| value.gsub(/[ \s]+/, ' ') })
  end

  def a_decree(type)
    match(
      url: start_with('https://www.genpro.gov.sk/').and(match(/\.#{type}\z/)),
      number: match(%r{^[A-Z]+/\d+/\d+/\d+/\d+$}),
      effective_on: a_kind_of(Date),
      published_on: a_kind_of(Date),
      file_number: a_string_matching(/\S/),
      resolution: a_string_matching(/\S/),
      means_of_resolution: a_string_matching(/\S/),
      file_type: match(/\A#{type}\z/)
    )
  end

  describe '.parse' do
    it 'skips a row without a link to a decree' do
      html = <<~HTML
        <div class="tx-tempest-applications"><table class="govuk-table"><tbody>
          <tr><td colspan="6">Nenašli sa žiadne záznamy.</td></tr>
        </tbody></table></div>
      HTML

      expect(described_class.parse(html, url: 'https://www.genpro.gov.sk/')).to eq([])
    end

    context 'with a page of decrees in PDF' do
      it 'reads the first page, its first decree in full' do
        decrees = parse('page_1')

        expect(decrees).to be_an(Array).and(have_attributes(size: 20)).and(all(a_decree('(pdf|rtf)')))
        expect(decrees.first).to eq(
          url: 'https://www.genpro.gov.sk//download/uznesenie/2025/11/za_5511_997_11_2025_a_2fc7888a717949c39beaa8e2f743f2b8.pdf',
          number: 'ZA/5511/997/11/2025',
          effective_on: Date.new(2025, 11, 19),
          published_on: Date.new(2025, 11, 19),
          file_number: '1 Pv 53/25/5511',
          resolution: 'Uznesenie o schválení zmieru',
          means_of_resolution:
            'zmier schválený a zastavenie trestného stíhania - § 220 s poukazom na § 215/ 1g Tr.por.',
          file_type: 'pdf'
        )
      end

      it 'reads page 50, its first decree in full' do
        decrees = parse('page_50')

        expect(decrees).to have_attributes(size: 20).and(all(a_decree('pdf')))
        expect(squish(decrees.first, :resolution, :means_of_resolution)).to eq(
          url: 'https://www.genpro.gov.sk//download/uznesenie/2025/06/bb_6608_164_05_2025_a_1d0aae4901.pdf',
          number: 'BB/6608/164/05/2025',
          effective_on: Date.new(2025, 5, 30),
          published_on: Date.new(2025, 6, 4),
          file_number: '2 Pv 243/23/6608',
          resolution: 'Uznesenie prokurátora o osvedčení sa v skúšobnej dobe',
          means_of_resolution: 'podmienečné zastavenie trestného stíhania, osvedčil sa - § 217/1 (§ 308/3) Tr.por.',
          file_type: 'pdf'
        )
      end

      it 'reads page 100' do
        expect(parse('page_100')).to have_attributes(size: 20).and(all(a_decree('pdf')))
      end
    end

    context 'with a page of decrees in RTF' do
      it 'reads page 2000, its first decree in full' do
        decrees = parse('page_2000')

        expect(decrees).to have_attributes(size: 20)
        expect(squish(decrees.first, :resolution)).to eq(
          url: 'https://www.genpro.gov.sk//download/uznesenie/2015/03/NR_4401_24_03_2015_a.rtf',
          number: 'NR/4401/24/03/2015',
          effective_on: Date.new(2015, 3, 11),
          published_on: Date.new(2015, 3, 17),
          file_number: '1 Pv 645/13/4401',
          resolution: 'Uznesenie prokurátora o osvedčení sa v skúšobnej dobe',
          means_of_resolution: 'podmienečné zastavenie trestného stíhania, osvedčil sa - § 217/1 (§ 308/3) Tr.por.',
          file_type: 'rtf'
        )
      end

      it 'reads page 2100, its first decree in full' do
        decrees = parse('page_2100')

        expect(decrees).to have_attributes(size: 20).and(all(a_decree('rtf')))
        expect(squish(decrees.first, :resolution, :means_of_resolution)).to eq(
          url: 'https://www.genpro.gov.sk//download/uznesenie/2014/10/ZA_5505_407_10_2014_a.rtf',
          number: 'ZA/5505/407/10/2014',
          effective_on: Date.new(2014, 10, 14),
          published_on: Date.new(2014, 10, 29),
          file_number: '2 Pv 554/13/5505',
          resolution: 'Uznesenie o schválení zmieru',
          means_of_resolution:
            'zmier schválený a zastavenie trestného stíhania - § 220 s poukazom na § 215/ 1g Tr.por.',
          file_type: 'rtf'
        )
      end
    end

    context 'with a page of decrees in both' do
      it 'tells the RTFs from the PDF' do
        expect(%w[page_1950 page_2050].map { |page| parse(page).map { |decree| decree[:file_type] }.tally })
          .to eq([{ 'rtf' => 19, 'pdf' => 1 }, { 'rtf' => 19, 'pdf' => 1 }])
      end
    end

    it 'reads every decree of every saved page' do
      pages = Rails.root.glob('spec/fixtures/genpro_gov_sk/decrees/page_*.html').map { |path| path.basename('.html') }
      decrees = pages.map { |page| parse(page) }

      expect(pages.size).to eq(10)
      expect(decrees).to all(be_present)
      expect(decrees.flatten).to all(a_decree('(pdf|rtf)'))
    end
  end
end
