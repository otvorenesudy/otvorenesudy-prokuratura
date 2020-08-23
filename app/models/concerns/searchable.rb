module Searchable
  extend ActiveSupport::Concern

  included { after_save { self.class.refresh_search_view } }

  class_methods do
    def refresh_search_view
      ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW #{table_name}_search") unless Rails.env.test?
    end
  end
end
