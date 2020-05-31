module GenproGovSk
  class ProsecutorsList < ApplicationRecord
    validates :data, presence: true
    validates :file, presence: true
    validates :digest, presence: true, uniqueness: true

    def self.import_from(data:, file:)
      digest = Digest::MD5.hexdigest(file)

      return if exists?(digest: digest)

      ActiveRecord::Base.transaction do
        Prosecutor.lock
        Office.lock
        Appointment.lock

        time = Time.zone.now
        list = create!(digest: digest, file: file, data: data)

        data.each do |value|
          prosecutor = Prosecutor.find_or_initialize_by(name: value[:name])
          prosecutor.update!(genpro_gov_sk_prosecutors_list: list) if prosecutor.new_record?

          office = Office.find_or_initialize_by(name: value[:office])
          office.update!(genpro_gov_sk_prosecutors_list: list) if office.new_record?

          appointment = prosecutor.appointments.current.fixed.find_or_initialize_by(office: office)
          appointment.update!(genpro_gov_sk_prosecutors_list: list, started_at: time) if appointment.new_record?
          prosecutor.appointments.current.fixed.where.not(id: appointment.id).update_all(ended_at: time)

          if value[:termporary_office]
            appointment = prosecutor.appointments.current.temporary.find_or_initialize_by(office: office)
            appointment.update!(genpro_gov_sk_prosecutors_list: list, started_at: time) if appointment.new_record?
            prosecutor.appointments.current.temporary.where.not(id: appointment.id).update_all(ended_at: time)
          end
        end
      end
    end
  end
end
