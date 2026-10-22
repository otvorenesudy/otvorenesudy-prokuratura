# frozen_string_literal: true

# == Schema Information
#
# Table name: statistics
#
#  id         :bigint           not null, primary key
#  count      :integer          not null
#  metric     :string           not null
#  paragraph  :string
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  office_id  :bigint           not null
#
# Indexes
#
#  index_statistics_on_metric                                       (metric)
#  index_statistics_on_office_id                                    (office_id)
#  index_statistics_on_paragraph                                    (paragraph)
#  index_statistics_on_paragraph_and_metric                         (paragraph,metric)
#  index_statistics_on_present_paragraph                            (paragraph) WHERE (paragraph IS NOT NULL)
#  index_statistics_on_year                                         (year)
#  index_statistics_on_year_and_office_id_and_metric_and_paragraph  (year,office_id,metric,paragraph) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#

require 'rails_helper'

RSpec.describe Statistic do
  describe 'Validations' do
    it 'accepts the years from 2010, the first of the sources, through the current one' do
      travel_to Time.zone.local(2026, 10, 22) do
        expect(build(:statistic, year: 2010)).to be_valid
        expect(build(:statistic, year: 2024)).to be_valid
        expect(build(:statistic, year: 2026)).to be_valid
        expect(build(:statistic, year: 2009)).not_to be_valid
        expect(build(:statistic, year: 2027)).not_to be_valid
      end
    end
  end
end
