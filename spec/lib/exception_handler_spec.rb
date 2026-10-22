# frozen_string_literal: true

require 'rails_helper'

# The scheduled imports (config/schedule.rb) run inside it: a failure goes to Sentry and the next import still runs.
RSpec.describe ExceptionHandler do
  describe '.run' do
    it 'reports an error to Sentry instead of raising it' do
      allow(Sentry).to receive(:capture_exception)
      error = RuntimeError.new('genpro.gov.sk is down')

      expect { described_class.run { raise error } }.not_to raise_error
      expect(Sentry).to have_received(:capture_exception).with(error)
    end

    it 'returns what the block returns' do
      expect(described_class.run { 42 }).to eq(42)
    end
  end
end
