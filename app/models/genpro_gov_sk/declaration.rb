# == Schema Information
#
# Table name: genpro_gov_sk_declarations
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
#  index_genpro_gov_sk_declarations_on_digest  (digest) UNIQUE
#
module GenproGovSk
  class Declaration < ApplicationRecord
    validates :data, presence: true
    validates :file, presence: true
    validates :digest, presence: true, uniqueness: true

    def self.import_from(data:, file:)
      digest = Digest::MD5.hexdigest(file)
      genpro_gov_sk_declaration = find_by(digest: digest)

      if genpro_gov_sk_declaration && data.deep_stringify_keys == genpro_gov_sk_declaration.data.deep_stringify_keys
        return
      end

      genpro_gov_sk_declaration ||= new(digest: digest, file: file)

      ActiveRecord::Base.transaction do
        genpro_gov_sk_declaration.lock!
        genpro_gov_sk_declaration.update!(data: data)
      end
    end

    def self.reconcile!
      find_each do |genpro_gov_sk_declaration|
        data = genpro_gov_sk_declaration.data.deep_symbolize_keys

        office = ::Office.find_by(name: data[:office])
        prosecutor = ::Prosecutor.find_by_fuzzy_name(data[:name], office: office)

        started_at = Time.parse("#{data[:year]}-01-01")
        ended_at = Time.parse("#{data[:year]}-12-31")

        unless prosecutor
          prosecutor = ::Prosecutor.lock.find_or_initialize_by(name: data[:name])

          prosecutor.name_parts = []
          prosecutor.save!
        end

        place = office ? nil : data[:office]

        if office.present? || place.present?
          prosecutor.appointments.find_or_create_by!(
            office: office,
            place: place,
            started_at: started_at,
            ended_at: ended_at,
            type: :fixed
          )
        end

        prosecutor.declarations = (prosecutor.declarations || []).reject { |value| value['year'] == data[:year] }
        prosecutor.declarations << data.merge(genpro_gov_sk_declaration_id: genpro_gov_sk_declaration.id)

        prosecutor.save!
      end

      Prosecutor.refresh_search_view
    end
  end
end
