# frozen_string_literal: true

# The records' full-text search reads a materialized view (<table>_search, db/structure.sql), which an import refreshes.
module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def refresh_search_view
      ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{table_name}_search")
    end
  end
end
