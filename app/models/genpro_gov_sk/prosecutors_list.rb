# == Schema Information
#
# Table name: genpro_gov_sk_prosecutors_lists
#
#  id         :bigint           not null, primary key
#  data       :json             not null
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
          office = Office.find_by(name: value[:office])

          prosecutor =
            Prosecutor.joins(:appointments).find_by(
              name: value[:name], appointments: { type: :fixed, office_id: office.id, ended_at: nil }
            )

          prosecutor = Prosecutor.create!(name: value[:name], genpro_gov_sk_prosecutors_list: list) unless prosecutor

          appointment = prosecutor.appointments.current.fixed.find_or_initialize_by(office: office)
          appointment.update!(genpro_gov_sk_prosecutors_list: list, started_at: time) if appointment.new_record?
          prosecutor.appointments.current.fixed.where.not(id: appointment.id).update_all(ended_at: time)

          if value[:temporary_office] # TODO: handle string only if office does not exist
            office = Office.find_by(name: value[:temporary_office])

            appointment = prosecutor.appointments.current.temporary.find_or_initialize_by(office: office)
            appointment.update!(genpro_gov_sk_prosecutors_list: list, started_at: time) if appointment.new_record?
            prosecutor.appointments.current.temporary.where.not(id: appointment.id).update_all(ended_at: time)
          end
        end
      end
    end
  end
end
