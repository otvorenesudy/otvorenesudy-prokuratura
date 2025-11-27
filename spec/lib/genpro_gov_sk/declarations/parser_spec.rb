require 'rails_helper'

RSpec.describe GenproGovSk::Declarations::Parser do
  FIXTURES_PATH = Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'declarations')

  describe '.parse' do
    Dir
      .glob(FIXTURES_PATH.join('*'))
      .each do |dir|
        dir_name = File.basename(dir)

        context "with #{dir_name} declaration" do
          let(:html) { File.read(File.join(dir, 'data.html')) }
          let(:expected_json) { JSON.parse(File.read(File.join(dir, 'data.json'))) }

          it 'correctly parses the declaration' do
            result = described_class.parse(html)

            expect(result[:year]).to eq(expected_json['year'])
            expect(result[:lists].length).to eq(expected_json['lists'].length)
            expect(result[:statements]).to eq(expected_json['statements'])

            result[:lists].each_with_index do |list, index|
              expected_list = expected_json['lists'][index]

              expect(list[:category]).to eq(expected_list['category'])
              expect(list[:items].length).to eq(expected_list['items'].length)

              list[:items].each_with_index do |item, item_index|
                expected_item = expected_list['items'][item_index]

                expect(item[:description]).to eq(expected_item['description'])
                expect(item[:acquisition_date]).to eq(expected_item['acquisition_date'])
              end
            end
          end
        end
      end

    it 'extracts the year correctly' do
      html = File.read(FIXTURES_PATH.join('Maroš-Žilinka-USPGP-2019', 'data.html'))
      result = described_class.parse(html)
      expect(result[:year]).to eq(2019)
    end

    it 'extracts lists categories' do
      html = File.read(FIXTURES_PATH.join('Andrej-Morkes-OPZH-2024', 'data.html'))
      result = described_class.parse(html)

      categories = result[:lists].map { |list| list[:category] }
      expect(categories).to include('Zoznam nehnuteľností')
      expect(categories).to include('Hnuteľné veci')
      expect(categories).to include('Majetkové práva a iné majetkové hodnoty')
    end

    it 'extracts statements' do
      html = File.read(FIXTURES_PATH.join('Maroš-Žilinka-USPGP-2019', 'data.html'))
      result = described_class.parse(html)

      expect(result[:statements].length).to eq(2)
      expect(result[:statements].first).to include('Vyhlasujem')
    end

    it 'handles declarations with share_size field' do
      html = File.read(FIXTURES_PATH.join('Andrej-Morkes-OPZH-2024', 'data.html'))
      result = described_class.parse(html)

      real_estate_items = result[:lists].find { |l| l[:category] == 'Zoznam nehnuteľností' }[:items]
      items_with_share = real_estate_items.select { |i| i[:share_size].present? }

      expect(items_with_share).not_to be_empty
    end

    it 'handles declarations with záväzkové vzťahy (obligations)' do
      html = File.read(FIXTURES_PATH.join('Andrej-Morkes-OPZH-2024', 'data.html'))
      result = described_class.parse(html)

      obligations = result[:lists].find { |l| l[:category] == 'Záväzkové vzťahy prokurátora' }
      expect(obligations).not_to be_nil
      expect(obligations[:items].length).to be > 0
    end

    it 'parses older declaration format correctly' do
      html = File.read(FIXTURES_PATH.join('Maros-Zilinka-GP-2011', 'data.html'))
      result = described_class.parse(html)

      expect(result[:year]).to eq(2011)
      expect(result[:lists]).not_to be_empty
    end
  end
end
