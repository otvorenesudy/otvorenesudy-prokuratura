require 'rails_helper'

RSpec.describe GenproGovSk::Offices, webmock: :enabled do
  describe '.import' do
    it 'fetches all 63 office URLs and parses them' do
      main_html = File.read(Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'offices', 'general.html'))

      stub_request(:get, 'https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/')
        .to_return(status: 200, body: generate_list_html)

      63.times do |i|
        url_pattern = %r{https://www\.genpro\.gov\.sk/kontakty-a-uradne-hodiny/detail/\d+/\?cHash=[a-f0-9]+}
        stub_request(:get, url_pattern).to_return(status: 200, body: main_html)
      end

      allow(GenproGovSk::Offices::Parser).to receive(:parse).and_return(
        name: 'Test Office',
        type: :district,
        employees: [],
        address: 'Test Street',
        zipcode: '123 45',
        city: 'Test City',
        phone: '123456',
        email: 'test@test.sk',
        electronic_registry: 'http://test',
        registry: {
          note: 'Test note',
          phone: '123456',
          hours: {
            'pondelok' => '8:00 – 15:00',
            'utorok' => '8:00 – 15:00',
            'streda' => '8:00 – 15:00',
            'štvrtok' => '8:00 – 15:00',
            'piatok' => '8:00 – 15:00'
          }
        }
      )

      allow(GenproGovSk::Office).to receive(:import_from)

      described_class.import

      expect(GenproGovSk::Offices::Parser).to have_received(:parse).exactly(63).times
      expect(GenproGovSk::Office).to have_received(:import_from).exactly(63).times
    end
  end

  def generate_list_html
    offices = (1..63).map do |i|
      name = "Prokuratúra #{i}"
      hash = Digest::MD5.hexdigest(name)[0..31]
      "<tr class=\"govuk-table__row\"><td><a href=\"/kontakty-a-uradne-hodiny/detail/#{i}/?cHash=#{hash}\">#{name}</a></td></tr>"
    end.join

    <<~HTML
      <html>
      <body>
      <div class="tx-tempest-contacts">
        <table>
          #{offices}
        </table>
      </div>
      </body>
      </html>
    HTML
  end
end
