module GenproGovSk
  module Declarations
    def self.import
      ::Prosecutor.find_each do |prosecutor|
        name = ::Legacy::Normalizer.partition_person_name(prosecutor.name)
        first_name, last_name = name[:first], name.values_at(:middle, :last).compact.join(' ')

        declarations =
          GenproGovSk::Legacy::PropertyDeclarationsCrawler.crawl_for(first_name: first_name, last_name: last_name)

        prosecutor.update!(declarations: declarations)
      end
    end
  end
end
