# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# Run after every deploy (config/deploy.rb), so the pages show the new code's output.
RSpec.describe 'cache:clear', :cache, type: :task do
  before { Rails.application.load_tasks unless Rake::Task.task_defined?('cache:clear') }

  it 'empties the cache' do
    Rails.cache.write('statistics_count', 42)

    Rake::Task['cache:clear'].tap(&:reenable).invoke

    expect(Rails.cache.read('statistics_count')).to be_nil
  end
end
