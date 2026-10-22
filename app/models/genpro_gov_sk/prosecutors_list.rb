# frozen_string_literal: true

# == Schema Information
#
# Table name: genpro_gov_sk_prosecutors_lists
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
#  index_genpro_gov_sk_prosecutors_lists_on_digest  (digest) UNIQUE
#
module GenproGovSk
  class ProsecutorsList < ApplicationRecord
    validates :data, presence: true
    validates :file, presence: true
    validates :digest, presence: true, uniqueness: true

    def self.import_from(data:, file:, force: false)
      digest = Digest::MD5.hexdigest(file)

      return if exists?(digest:) && !force

      ActiveRecord::Base.transaction do
        ::Prosecutor.lock
        ::Office.lock
        ::Appointment.lock
        ::Employee.lock

        time = Time.zone.now
        list = find_or_initialize_by(digest:)

        list.update!(file:, data:)
        mark_namesakes(data)

        prosecutors = data.map { |value| import_prosecutor(value, list:, time:) }

        # rubocop:disable-next Rails/SkipsModelValidations -- ends whoever the list no longer has, in bulk
        Appointment.current.where.not(prosecutor: prosecutors).update_all(ended_at: time)
      end

      ::Office.refresh_search_view
      ::Prosecutor.refresh_search_view
    end

    class << self
      private

      # Prosecutors of the same name are told apart by their office.
      def mark_namesakes(data)
        namesakes = data.map { |value| value[:name] }.tally.select { |_, count| count > 1 }.keys

        data.each { |value| value[:namesake] = true if value[:name].in?(namesakes) }
      end

      def import_prosecutor(value, list:, time:)
        office = ::Office.find_by!(name: value[:office])
        prosecutor = find_prosecutor(value, office) || ::Prosecutor.create!(
          name: value[:name], genpro_gov_sk_prosecutors_list: list, name_parts: value[:name_parts]
        )

        prosecutor.update!(name_parts: value[:name_parts])

        appoint(prosecutor.appointments.current.fixed, { office: }, list:, time:)
        temporary_office = appoint_temporarily(prosecutor, value[:temporary_office], list:, time:)
        link_employees(prosecutor, namesake: value[:namesake], offices: [office, temporary_office].compact)

        prosecutor
      end

      def find_prosecutor(value, office)
        return ::Prosecutor.find_by(name: value[:name]) unless value[:namesake]

        ::Prosecutor.joins(:appointments).find_by(
          name: value[:name], appointments: { type: :fixed, office_id: office.id, ended_at: nil }
        )
      end

      # The current appointment of its kind (fixed or temporary) where the list puts the prosecutor; the others of that
      # kind end.
      def appoint(appointments, attributes, list:, time:)
        appointment = appointments.find_or_initialize_by(attributes)
        appointment.update!(genpro_gov_sk_prosecutors_list: list, started_at: time) if appointment.new_record?

        # rubocop:disable-next Rails/SkipsModelValidations -- ends the earlier appointments in bulk
        appointments.where.not(id: appointment.id).update_all(ended_at: time)
      end

      # The office of the prosecutor's temporary appointment, or nil for one at a place outside the offices.
      def appoint_temporarily(prosecutor, name, list:, time:)
        return unless name

        office = ::Office.find_by(name:)
        appoint(prosecutor.appointments.current.temporary, office ? { office: } : { place: name }, list:, time:)

        office
      end

      # The employees of the offices' staff lists who are this prosecutor; a namesake only at the prosecutor's offices.
      def link_employees(prosecutor, namesake:, offices:)
        employees = ::Employee.where(name: prosecutor.name)
        employees = employees.where(office: offices) if namesake

        employees.update_all(prosecutor_id: prosecutor.id) # rubocop:disable Rails/SkipsModelValidations -- in bulk
      end
    end
  end
end
