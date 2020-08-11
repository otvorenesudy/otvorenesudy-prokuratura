require 'rails_helper'

RSpec.describe GenproGovSk::Criminality do
  describe '.import_structures' do
    it 'correctly parses filters' do
      data = described_class.import_structures
      keys = described_class::STRUCTURES_MAP.values

      # TODO
    end
  end
end
