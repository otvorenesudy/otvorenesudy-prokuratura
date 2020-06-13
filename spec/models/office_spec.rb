# == Schema Information
#
# Table name: offices
#
#  id                                :bigint           not null, primary key
#  address                           :string(1024)     not null
#  electronic_registry               :string
#  email                             :string           not null
#  fax                               :string
#  name                              :string           not null
#  phone                             :string           not null
#  registry                          :jsonb            not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint           not null
#
# Indexes
#
#  index_offices_on_genpro_gov_sk_prosecutors_list_id  (genpro_gov_sk_prosecutors_list_id)
#  index_offices_on_name                               (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_prosecutors_list_id => genpro_gov_sk_prosecutors_lists.id)
#
require 'rails_helper'

RSpec.describe Office, type: :model do
  subject { build(:office) }

  it { is_expected.to belong_to(:genpro_gov_sk_prosecutors_list) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
