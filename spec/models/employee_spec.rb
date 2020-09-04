# == Schema Information
#
# Table name: employees
#
#  id            :bigint           not null, primary key
#  disabled_at   :datetime
#  name          :string           not null
#  name_parts    :jsonb            not null
#  phone         :string
#  position      :string(1024)     not null
#  rank          :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  office_id     :bigint           not null
#  prosecutor_id :bigint
#
# Indexes
#
#  index_employees_on_name                                (name)
#  index_employees_on_name_and_position                   (name,position)
#  index_employees_on_name_parts                          (name_parts)
#  index_employees_on_office_id                           (office_id)
#  index_employees_on_office_id_and_disabled_at_and_rank  (office_id,disabled_at,rank) UNIQUE WHERE (disabled_at IS NULL)
#  index_employees_on_prosecutor_id                       (prosecutor_id)
#  index_employees_on_rank                                (rank)
#
# Foreign Keys
#
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (prosecutor_id => prosecutors.id)
#
require 'rails_helper'

RSpec.describe Employee do
  subject { build(:employee) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:position) }
  it { is_expected.to validate_presence_of(:rank) }
  it { is_expected.to validate_numericality_of(:rank).is_greater_than(0).only_integer }

  context 'when active' do
    subject { build(:employee, disabled_at: nil) }

    it { is_expected.to validate_uniqueness_of(:rank).scoped_to(%i[office_id disabled_at]) }
  end

  context 'when disabled' do
    subject { build(:employee, disabled_at: Time.zone.now) }

    it { is_expected.not_to validate_uniqueness_of(:rank).scoped_to(%i[office_id disabled_at]) }
  end
end
