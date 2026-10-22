# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages' do
  describe 'the error pages' do
    it 'answers with the page of the status, or of a server error for any other', :error_pages do
      { '/400' => [400, 'Bad request'], '/503' => [500, 'Internal server error'] }.each do |path, (status, title)|
        get path

        expect(response).to have_http_status(status)
        expect(response.body).to include(title)
      end
    end

    it 'answers a record that does not exist with the not found page', :error_pages do
      get office_path(0)

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include('Page not found')
    end
  end

  describe 'an office\'s decrees' do
    it 'answers with the table alone, for the office page\'s frame' do
      office = Office.find_by!(name: 'Okresná prokuratúra Žilina')
      theft = Paragraph.find_by!(value: '§ 212 [new]')
      create(:decree, office:, number: '1 Pv 1/24', paragraph: theft)
      create(:decree, office:, number: '1 Pv 2/24')

      get decrees_office_path(office, paragraph: [theft.value])

      expect(response.body).to include('turbo-frame', '1 Pv 1/24', 'Filtered by')
      expect(response.body).not_to include('1 Pv 2/24')
      expect(response.body).not_to include('<html')
    end
  end
end
