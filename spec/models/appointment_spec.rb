require 'rails_helper'

RSpec.describe Appointment, type: :model do
  it { is_expected.to belong_to(:genpro_gov_sk_prosecutors_list) }
  it { is_expected.to belong_to(:prosecutor) }
  it { is_expected.to belong_to(:office) }
  it { is_expected.to validate_presence_of(:started_at) }
  it { is_expected.to define_enum_for(:type).with_values(%i[fixed temporary]) }
end
