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
FactoryBot.define do
  factory :employee do
    office

    sequence(:name) { |n| "John Smith ##{n}" }
    name_parts { { value: name } }
    sequence(:position) { |n| "a position in the office ##{n}" }
    sequence(:rank) { |n| n }

    trait :with_prosecutor do
      prosecutor
    end
  end
end
