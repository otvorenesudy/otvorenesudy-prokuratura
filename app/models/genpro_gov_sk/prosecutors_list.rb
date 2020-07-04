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

    def self.import_from(data:, file:)
      digest = Digest::MD5.hexdigest(file)

      return if exists?(digest: digest)

      ActiveRecord::Base.transaction do
        ::Prosecutor.lock
        ::Office.lock
        ::Appointment.lock
        ::Employee.lock

        time = Time.zone.now
        list = create!(digest: digest, file: file, data: data)

        namesakes =
          data.each.with_object(Hash.new(0)) { |value, hash| hash[value[:name]] += 0 }.select do |_, value|
            value > 1
          end.keys

        data.each { |value| value[:namesake] = true if value[:name].in?(namesakes) }

        data.each do |value|
          offices = [::Office.find_by(name: value[:office])]

          prosecutor =
            ::Prosecutor.joins(:appointments).find_by(
              name: value[:name], appointments: { type: :fixed, office_id: offices[0].id, ended_at: nil }
            )

          prosecutor = ::Prosecutor.create!(name: value[:name], genpro_gov_sk_prosecutors_list: list) unless prosecutor

          appointment = prosecutor.appointments.current.fixed.find_or_initialize_by(office: offices[0])
          appointment.update!(genpro_gov_sk_prosecutors_list: list, started_at: time) if appointment.new_record?
          prosecutor.appointments.current.fixed.where.not(id: appointment.id).update_all(ended_at: time)

          if value[:temporary_office] # TODO: handle string only if office does not exist
            office = ::Office.find_by(name: value[:temporary_office])

            appointment =
              prosecutor.appointments.current.temporary.find_or_initialize_by(
                office ? { office: office } : { place: value[:temporary_office] }
              )

            appointment.update!(genpro_gov_sk_prosecutors_list: list, started_at: time) if appointment.new_record?
            prosecutor.appointments.current.temporary.where.not(id: appointment.id).update_all(ended_at: time)

            offices << office if office
          end

          if value[:namesake]
            Employee.where(name: prosecutor.name, office: offices).update_all(prosecutor_id: prosecutor.id)
          else
            Employee.where(name: prosecutor.name).update_all(prosecutor_id: prosecutor.id)
          end
        end

        ::Office.refresh_search_view
        ::Prosecutor.refresh_search_view
      end
    end
  end
end
