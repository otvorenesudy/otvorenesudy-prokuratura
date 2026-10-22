# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Declarations::Parser do
  def parse(declaration)
    described_class.parse(fixture("genpro_gov_sk/declarations/#{declaration}/data.html").read)
  end

  # What a declaration's saved data is checked for: the year, the statements, and each list's items.
  def summary(data)
    data = data.deep_stringify_keys
    lists = data['lists'].map do |list|
      [list['category'], list['items'].map { |item| item.values_at('description', 'acquisition_date') }]
    end

    { year: data['year'], statements: data['statements'], lists: }
  end

  def list(result, category)
    result[:lists].find { |list| list[:category] == category }
  end

  describe '.parse' do
    Rails.root.glob('spec/fixtures/genpro_gov_sk/declarations/*').each do |directory|
      context "with the declaration #{directory.basename}" do
        it 'reads the year, the statements and the items of each list' do
          expected = JSON.parse(directory.join('data.json').read)

          expect(summary(parse(directory.basename))).to eq(summary(expected))
        end
      end
    end

    describe 'a table of rights' do
      let(:document) { Nokogiri::HTML(fixture('genpro_gov_sk/declarations/Andrea-Jancova-OPZA-2024/data.html').read) }
      let(:rights) do
        document.css('h3').find { |heading| heading.text.strip == 'Majetkové práva a iné majetkové hodnoty' }
                .xpath('following-sibling::table[1]').first
      end

      def items(document)
        list(described_class.parse(document.to_html), 'Majetkové práva a iné majetkové hodnoty')[:items]
      end

      it 'reads the procurement price of a table without the usual price' do
        rights.css('tr').each { |row| row.css('th, td')[3].remove }

        expect(items(document)).to eq(
          [{ description: 'úspory', acquisition_reason: 'príjem z výkonu funkcie prokurátora, dôchodok',
             acquisition_date: 'do 31.12.2024', procurement_price: '26000' }]
        )
      end

      it 'refuses a table whose columns it does not know' do
        rights.at_css('th').content = 'popis nároku'

        expect { items(document) }.to raise_error(ArgumentError, /No parser for \["popis nároku"/)
      end
    end

    it 'reads the year and the statements of a declaration of 2019' do
      result = parse('Maroš-Žilinka-USPGP-2019')

      expect(result[:year]).to eq(2019)
      expect(result[:statements]).to match([include('Vyhlasujem'), be_present])
    end

    it 'reads the lists of a declaration of 2024, the shares of real estate and the obligations' do
      result = parse('Andrej-Morkes-OPZH-2024')

      expect(result[:lists].pluck(:category))
        .to include('Zoznam nehnuteľností', 'Hnuteľné veci', 'Majetkové práva a iné majetkové hodnoty')
      expect(list(result, 'Zoznam nehnuteľností')[:items].pluck(:share_size)).to include(be_present)
      expect(list(result, 'Záväzkové vzťahy prokurátora')[:items]).to be_present
    end

    it 'reads a declaration of the older form, of 2011' do
      expect(parse('Maros-Zilinka-GP-2011')).to include(year: 2011, lists: be_present)
    end
  end
end
