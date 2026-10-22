# frozen_string_literal: true

require 'rails_helper'

# The facets' suggest boxes (the facet-suggest controller) fetch the facet's values matching what the visitor typed.
RSpec.describe 'Suggesting facet values' do
  let(:zilina) { Office.find_by!(name: 'Okresná prokuratúra Žilina') }
  let(:theft) { Paragraph.find_by!(value: '§ 212 [new]') }

  before do
    prosecutor = create(:prosecutor)
    create(:appointment, prosecutor:, office: zilina)
    create(:decree, prosecutor:, office: zilina, paragraph: theft)
    create(:statistic, office: zilina, metric: 'sentence_financial', paragraph: '§ 212 [new]')
    create(:crime, paragraph: '§ 212 [new]')
  end

  it 'answers with the offices\' cities and paragraphs matching the text, as HTML' do
    get suggest_offices_path(facet: :city, suggest: 'zilin')

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('text/html')
    expect(response.body).to include('Žilina').and(include('href="/offices?city%5B%5D=%C5%BDilina'))

    get suggest_offices_path(facet: :paragraph, suggest: 'kradez')

    expect(response.body).to include('§ 212 – Krádež')
  end

  it 'answers with the prosecutors\' cities, offices and paragraphs matching the text' do
    { city: %w[zilin Žilina], office: ['zilin', 'OP Žilina'], paragraph: ['kradez', '§ 212 – Krádež'] }
      .each do |facet, (text, value)|
        get suggest_prosecutors_path(facet:, suggest: text)

        expect(response.body).to include(value)
      end
  end

  it 'answers with the statistics\' offices and paragraphs, keeping the text in the links' do
    get suggest_statistics_path(facet: :office, suggest: 'zilin')

    expect(response.body).to include('OP Žilina').and(include('office_suggest=zilin'))

    get suggest_statistics_path(facet: :paragraph, suggest: 'kradez')
    expect(response.body).to include('§ 212 – Krádež')

    get suggest_crimes_path(facet: :paragraph, suggest: 'kradez')
    expect(response.body).to include('§ 212 – Krádež').and(include('paragraph_suggest=kradez'))
  end

  it 'answers a facet it does not have with not found' do
    [suggest_offices_path(facet: :office), suggest_prosecutors_path(facet: :type),
     suggest_statistics_path(facet: :year), suggest_crimes_path(facet: :metric)].each do |path|
      get path

      expect(response).to have_http_status(:not_found)
    end
  end
end
