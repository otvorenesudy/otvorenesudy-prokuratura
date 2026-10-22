# frozen_string_literal: true

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
      genpro_gov_sk_office = find_by(digest:)

      return if genpro_gov_sk_office && data.as_json == genpro_gov_sk_office.data

      genpro_gov_sk_office ||= new(digest:, file:)

      ActiveRecord::Base.transaction do
        genpro_gov_sk_office.lock!
        genpro_gov_sk_office.update!(data:)

        office = ::Office.find_or_initialize_by(name: data[:name])

        office.lock!
        office.update!(data.except(:employees).merge(genpro_gov_sk_office:))

        import_employees(office, data[:employees])
      end

      # TODO: Soft-destroy all offices that are not imported

      ::Office.refresh_search_view
    end

    # The office's staff as its page lists it; whoever the page no longer lists has left.
    def self.import_employees(office, staff)
      office.employees.lock!

      employees = staff.map do |params|
        office.employees.active.find_or_initialize_by(params.slice(:name, :position)).tap { |e| e.update!(params) }
      end

      # rubocop:disable-next Rails/SkipsModelValidations -- marks who left, in bulk
      office.employees.where.not(id: employees).update_all(disabled_at: Time.zone.now)
    end
    private_class_method :import_employees
  end
end
