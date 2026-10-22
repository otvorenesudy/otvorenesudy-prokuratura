# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Offices::Parser do
  def parse(page)
    described_class.parse(fixture("genpro_gov_sk/offices/#{page}.html").read)
  end

  def expected(page)
    JSON.parse(fixture("genpro_gov_sk/offices/#{page}.json").read, symbolize_names: true)
  end

  # The parts of an office's data a saved page is checked for.
  def summary(data, fields:, registry:, employees:, employee_fields:)
    {
      **data.slice(:name, :address, :zipcode, :city, *fields),
      type: data[:type].to_sym,
      registry: data[:registry].slice(*registry),
      employees: data[:employees].values_at(*employees).map { |employee| employee.slice(*employee_fields) },
      staffed: data[:employees].any?
    }
  end

  describe '.parse' do
    {
      'the General Prosecutor\'s Office' => [
        'general',
        { fields: %i[phone email electronic_registry], registry: %i[note phone hours], employees: [0, 1, 2, -1],
          employee_fields: %i[name position phone] }
      ],
      'a regional office (Bratislava)' => [
        'krajsk_prokuratra_v_bratislave',
        { fields: %i[phone email], registry: %i[note phone hours], employees: [0],
          employee_fields: %i[name position phone] }
      ],
      'a regional office (Košice)' => [
        'krajsk_prokuratra_v_koiciach',
        { fields: [], registry: %i[note hours], employees: [0], employee_fields: %i[name position] }
      ],
      'a district office (Banská Bystrica)' => [
        'okresn_prokuratra_bansk_bystrica',
        { fields: [], registry: %i[note hours], employees: [0], employee_fields: %i[name position] }
      ],
      'a district office (Košice I)' => [
        'okresn_prokuratra_koice_i',
        { fields: [], registry: %i[note hours], employees: [0], employee_fields: %i[name position] }
      ],
      'a district office (Trnava)' => [
        'okresn_prokuratra_trnava',
        { fields: [], registry: %i[note hours], employees: [0], employee_fields: %i[name position] }
      ]
    }.each do |office, (page, parts)|
      it "reads the contacts, the registry and the staff of #{office}" do
        expect(summary(parse(page), **parts)).to eq(summary(expected(page), **parts))
      end
    end

    context 'with a page lacking the address and the registry\'s phones' do
      def page(name)
        days = %w[Pondelok Utorok Streda Štvrtok Piatok].map do |day|
          "<tr><td>#{day}</td><td>8.00</td><td>15.00</td></tr>"
        end

        <<~HTML
          <div class="tx-tempest-contacts"><h1>#{name}</h1>
            <div class="table-responsive"><table class="gp-table">
              <tr><td></td><td>tel.: 02/111</td></tr><tr><td>Podateľňa</td></tr>#{days.join}
            </table></div>
          </div>
        HTML
      end

      it 'leaves them out, and the type of an office it does not know' do
        special = described_class.parse(page('Úrad špeciálnej prokuratúry'))

        expect(special).to include(
          type: :specialized, address: nil, zipcode: nil, city: nil, phone: '02/111', employees: [],
          registry: include(phone: nil, hours: include(monday: '8:00 – 15:00', friday: '8:00 – 15:00'))
        )
        expect(described_class.parse(page('Eurojust'))[:type]).to be_nil
      end
    end

    context 'with names and positions in one cell' do
      it 'tells the prosecutors\' names from their positions' do
        data = parse('bratislava')

        expect(data.slice(:name, :type)).to eq(name: 'Okresná prokuratúra Bratislava I', type: :district)
        expect(data[:employees].first(3).map { |employee| employee.slice(:name, :position, :phone) }).to eq(
          [
            { name: 'JUDr. Katarína Kuljačková', position: 'okresná prokurátorka', phone: '02/208 36 611' },
            { name: 'JUDr. Hana Štaffenová', position: 'námestníčka okresnej prokurátorky', phone: '02/208 36 611' },
            { name: 'JUDr. Norbert Fecko', position: 'námestník okresnej prokurátorky', phone: '02/208 36 611' }
          ]
        )
      end
    end
  end
end
