# == Schema Information
#
# Table name: genpro_gov_sk_offices
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
#  index_genpro_gov_sk_offices_on_digest  (digest) UNIQUE
#
module GenproGovSk
  class Office < ApplicationRecord
    validates :data, presence: true
    validates :file, presence: true
    validates :digest, presence: true, uniqueness: true

    def self.import_from(data:, file:)
      digest = Digest::MD5.hexdigest(file)
      genpro_gov_sk_office = find_by(digest: digest)

      return if genpro_gov_sk_office && data.deep_stringify_keys == genpro_gov_sk_office.data.deep_stringify_keys

      genpro_gov_sk_office ||= new(digest: digest, file: file)

      ActiveRecord::Base.transaction do
        genpro_gov_sk_office.lock!

        genpro_gov_sk_office.update!(data: data)

        office = ::Office.find_or_initialize_by(genpro_gov_sk_office: genpro_gov_sk_office)

        office.lock!
        office.update!(data.except(:employees))

        office.employees.lock!

        employees =
          data[:employees].map do |params|
            employee = office.employees.active.find_or_initialize_by(params.slice(:identifiable_name, :position))

            employee.update!(params)

            employee
          end

        office.employees.where.not(id: employees).update_all(disabled_at: Time.zone.now)
      end

      ::Office.refresh_search_view
    end
  end
end
