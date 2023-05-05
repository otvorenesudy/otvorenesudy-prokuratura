# == Schema Information
#
# Table name: genpro_gov_sk_decrees
#
#  id         :bigint           not null, primary key
#  data       :jsonb            not null
#  digest     :string           not null
#  file       :binary           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_genpro_gov_sk_decrees_on_digest  (digest) UNIQUE
#
module GenproGovSk
  class Decree < ApplicationRecord
    validates :data, presence: true
    validates :file, presence: true
    validates :digest, presence: true, uniqueness: true

    def self.import_from(data:, file:)
      digest = Digest::MD5.hexdigest(file)
      genpro_gov_sk_decree = find_by(digest: digest)

      return if genpro_gov_sk_decree && data.deep_stringify_keys == genpro_gov_sk_decree.data.deep_stringify_keys

      genpro_gov_sk_decree ||= new(digest: digest, file: file.force_encoding('ISO-8859-1').encode('UTF-8'))

      ActiveRecord::Base.transaction do
        genpro_gov_sk_decree.lock!
        genpro_gov_sk_decree.update!(data: data)

        decree = ::Decree.find_or_initialize_by(url: data[:url])

        decree.lock!
        decree.update!(data.merge(genpro_gov_sk_decree: genpro_gov_sk_decree))
        
        return decree
      end
    end
  end
end
