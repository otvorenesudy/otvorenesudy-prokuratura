# frozen_string_literal: true

# The full-text search reads materialized views (offices_search, prosecutors_search, paragraphs_search), which the
# importers refresh. An example refreshes them after creating its records, with `refresh_search_views`.
module SearchHelpers
  def refresh_search_views
    [Office, Prosecutor, Paragraph].each(&:refresh_search_view)
  end
end

RSpec.configure do |config|
  config.include SearchHelpers
end
