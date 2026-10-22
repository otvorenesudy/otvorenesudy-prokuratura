# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Importing a decree' do
  let(:zilina) { Office.find_by!(name: 'Okresná prokuratúra Žilina') }

  def decree(number, type)
    { url: "https://www.genpro.gov.sk/download/uznesenie/2024/01/#{number}.#{type}", number:, file_type: type,
      effective_on: Date.new(2024, 1, 10), published_on: Date.new(2024, 1, 17), file_number: "1 Pv #{number}/24",
      resolution: 'Uznesenie o zastavení trestného stíhania', means_of_resolution: 'zastavenie trestného stíhania' }
  end

  def prosecutor(first, last)
    create(:prosecutor, name: "JUDr. #{first} #{last}", name_parts: { first:, last: }).tap do |prosecutor|
      create(:appointment, prosecutor:, office: zilina)
    end
  end

  describe GenproGovSk::ImportPdfDecreeJob do
    let(:data) { decree('100', 'pdf') }

    before { stub_source(data[:url], 'genpro_gov_sk/decrees/decree.pdf') }

    it 'stores the decree\'s text, and finds its office, its prosecutor and its paragraph' do
      novak = prosecutor('Ján', 'Novák')

      perform_enqueued_jobs { described_class.perform_now(data) }

      decree = Decree.find_by!(url: data[:url])

      expect(decree.text).to include('Prečin: krádeže podľa § 212 ods. 2 písm. a) Trestného zákona')
      expect(decree).to have_attributes(office: zilina, prosecutor: novak, paragraph_section: 'ods. 2 písm. a)')
      expect(decree.paragraph.value).to eq('§ 212 [new]')
      expect([zilina.reload.decrees_count, novak.reload.decrees_count]).to eq([1, 1])
    end

    it 'leaves a decree it has already imported as it is' do
      perform_enqueued_jobs { described_class.perform_now(data) }

      expect { described_class.perform_now(data) }.not_to(change { Decree.find_by!(url: data[:url]).updated_at })
    end
  end

  describe GenproGovSk::ImportRtfDecreeJob, :unoconv do
    let(:data) { decree('200', 'rtf') }

    it 'converts the decree to text and finds its prosecutor and its paragraph' do
      horvath = prosecutor('Peter', 'Horváth')
      stub_source(data[:url], 'genpro_gov_sk/decrees/decree.rtf')

      perform_enqueued_jobs { described_class.perform_now(data) }

      decree = Decree.find_by!(url: data[:url])

      expect(decree).to have_attributes(office: zilina, prosecutor: horvath)
      expect(decree.paragraph.value).to eq('§ 221 [new]')
    end

    it 'fails on a document unoconv cannot convert' do
      stub_source(data[:url], 'genpro_gov_sk/decrees/decree.pdf')

      expect { described_class.perform_now(data) }.to raise_error(ArgumentError, /Unoconv failed with \[1\] status/)
    end
  end
end
