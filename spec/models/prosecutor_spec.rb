# == Schema Information
#
# Table name: prosecutors
#
#  id                                :bigint           not null, primary key
#  declarations                      :jsonb
#  decrees_count                     :bigint           default(0)
#  name                              :string           not null
#  name_parts                        :jsonb            not null
#  news                              :jsonb
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint
#
# Indexes
#
#  index_prosecutors_on_genpro_gov_sk_prosecutors_list_id  (genpro_gov_sk_prosecutors_list_id)
#  index_prosecutors_on_name                               (name)
#  index_prosecutors_on_name_parts                         (name_parts)
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_prosecutors_list_id => genpro_gov_sk_prosecutors_lists.id)
#
require 'rails_helper'

RSpec.describe Prosecutor, type: :model do
  subject { build(:prosecutor) }

  it { is_expected.to belong_to(:genpro_gov_sk_prosecutors_list) }
  it { is_expected.to validate_presence_of(:name) }
end
