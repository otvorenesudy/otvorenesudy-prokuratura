# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::ImportRtfDecreeJob, :unoconv do
  let(:zilina) { Office.find_by!(name: 'Okresná prokuratúra Žilina') }
  let(:data) { decree('200', 'rtf') }

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
