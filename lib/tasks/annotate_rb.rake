# frozen_string_literal: true

# Annotates the models with their schema after migrations in development (annotaterb, .annotaterb.yml); set
# ANNOTATERB_SKIP_ON_DB_TASKS to skip it.
if Rails.env.development? && ENV['ANNOTATERB_SKIP_ON_DB_TASKS'].nil?
  require 'annotate_rb'

  AnnotateRb::Core.load_rake_tasks
end
