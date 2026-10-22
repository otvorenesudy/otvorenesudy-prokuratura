# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Offices do
  describe '.import' do
    let(:bratislava) { Office.find_by!(name: 'Krajská prokuratúra v Bratislave') }

    before do
      stub_source('https://www.genpro.gov.sk/kontakty-a-uradne-hodiny/', 'genpro_gov_sk/offices/listing.html')
      stub_request(:get, %r{/kontakty-a-uradne-hodiny/detail/\d+})
        .to_return(body: fixture('genpro_gov_sk/offices/okresn_prokuratra_bansk_bystrica.html').read)
      stub_source(%r{/kontakty-a-uradne-hodiny/detail/1\?}, 'genpro_gov_sk/offices/general.html')
      stub_source(%r{/kontakty-a-uradne-hodiny/detail/6\?}, 'genpro_gov_sk/offices/krajsk_prokuratra_v_bratislave.html')
    end

    it 'reads all 63 offices and imports each, with its leading employees' do
      described_class.import

      expect(a_request(:get, %r{/kontakty-a-uradne-hodiny/detail/\d+})).to have_been_made.times(63)
      expect(GenproGovSk::Office.count).to eq(3)
      expect(bratislava.address).to eq('Vajnorská 47')
      expect(bratislava.employees.active.count).to eq(12)
      expect(bratislava.attorney_general.name).to eq('JUDr. Rastislav Remeta, PhD.')
    end

    it 'leaves an office unchanged on its page, and retires the employees a changed page no longer lists' do
      described_class.import
      retired = create(:employee, office: bratislava, name: 'JUDr. Bývalý Zamestnanec')

      expect { described_class.import }.not_to(change { bratislava.reload.updated_at })
      expect(retired.reload.disabled_at).to be_nil

      changed = fixture('genpro_gov_sk/offices/krajsk_prokuratra_v_bratislave.html').read.sub('</body>',
                                                                                              '<p>Zmena</p></body>')
      stub_request(:get, %r{/kontakty-a-uradne-hodiny/detail/6\?}).to_return(body: changed)
      described_class.import

      expect(retired.reload.disabled_at).to be_present
    end
  end
end
