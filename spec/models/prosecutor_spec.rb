require 'rails_helper'

RSpec.describe Prosecutor, type: :model do
  subject { build(:prosecutor) }

  it { is_expected.to belong_to(:genpro_gov_sk_prosecutors_list) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
