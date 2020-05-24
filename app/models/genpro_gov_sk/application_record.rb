module GenproGovSk
  class ApplicationRecord < ::ApplicationRecord
    self.abstract_class = true

    def self.table_name_prefix
      'genpro_gov_sk_'
    end
  end
end
