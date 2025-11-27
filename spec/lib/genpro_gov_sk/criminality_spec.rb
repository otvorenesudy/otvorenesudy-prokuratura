require 'rails_helper'

RSpec.describe GenproGovSk::Criminality do
  describe '.import' do
    it 'raises error when non-empty unknown attributes are found' do
      allow(described_class).to receive(:parse_structures).and_return(
        [{ year: '2024', office: 'Test', statistics: [], unknown: ['Unknown Metric'] }]
      )
      allow(described_class).to receive(:parse_paragraphs).and_return([])

      expect { described_class.import }.to raise_error(RuntimeError, /Unknown attributes.*Unknown Metric/m)
    end

    it 'does not raise error when only empty strings are in unknown attributes' do
      allow(described_class).to receive(:parse_structures).and_return(
        [{ year: '2024', office: 'Test', statistics: [], unknown: ['', '  '] }]
      )
      allow(described_class).to receive(:parse_paragraphs).and_return([])
      allow(Statistic).to receive(:import_from)

      expect { described_class.import }.not_to raise_error
    end

    it 'does not raise error when unknown attributes are empty' do
      allow(described_class).to receive(:parse_structures).and_return(
        [{ year: '2024', office: 'Test', statistics: [], unknown: [] }]
      )
      allow(described_class).to receive(:parse_paragraphs).and_return([])
      allow(Statistic).to receive(:import_from)

      expect { described_class.import }.not_to raise_error
    end
  end
end
