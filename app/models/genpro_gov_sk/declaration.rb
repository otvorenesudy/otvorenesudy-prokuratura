# frozen_string_literal: true

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

      return if genpro_gov_sk_declaration && data.as_json == genpro_gov_sk_declaration.data

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
        prosecutor = ::Prosecutor.fuzzy_find(data[:name], office:) || create_prosecutor(data[:name])

        appoint(prosecutor, office:, place: (data[:office] unless office), year: data[:year])

        prosecutor.declarations = (prosecutor.declarations || []).reject { |value| value['year'] == data[:year] }
        prosecutor.declarations << data.merge(genpro_gov_sk_declaration_id: genpro_gov_sk_declaration.id)

        prosecutor.save!
      end

      Prosecutor.refresh_search_view
    end

    class << self
      private

      def create_prosecutor(name)
        ::Prosecutor.lock.find_or_initialize_by(name:).tap do |prosecutor|
          prosecutor.name_parts = ::Legacy::Normalizer.partition_person_name(name)
          prosecutor.save!
        end
      end

      # The declaration's year at its office, or at a place outside the offices; nothing when it names neither.
      def appoint(prosecutor, office:, place:, year:)
        return if office.blank? && place.blank?

        prosecutor.appointments.find_or_create_by!(
          office:,
          place:,
          started_at: Time.zone.parse("#{year}-01-01"),
          ended_at: Time.zone.parse("#{year}-12-31"),
          type: :fixed
        )
      end
    end
  end
end
