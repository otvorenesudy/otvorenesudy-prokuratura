# == Schema Information
#
# Table name: prosecutors
#
#  id                                :bigint           not null, primary key
#  declarations                      :jsonb
#  name                              :string           not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint           not null
#
# Indexes
#
#  index_prosecutors_on_genpro_gov_sk_prosecutors_list_id  (genpro_gov_sk_prosecutors_list_id)
#  index_prosecutors_on_name                               (name)
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_prosecutors_list_id => genpro_gov_sk_prosecutors_lists.id)
#
class Prosecutor < ApplicationRecord
  include Searchable

  belongs_to :genpro_gov_sk_prosecutors_list, class_name: :'GenproGovSk::ProsecutorsList'

  has_many :appointments, -> { current }, dependent: :destroy
  has_many :offices, through: :appointments

  validates :name, presence: true

  def self.as_map_json
    attributes = %w[
      prosecutors.id
      prosecutors.name
      offices.address
      offices.additional_address
      offices.zipcode
      offices.city
      offices.latitude
      offices.longitude
    ]

    joins(:offices).pluck(attributes).map do |values|
      {
        url: Rails.application.routes.url_helpers.prosecutor_path(values[0]),
        name: values[1],
        coordinates: values[6..7],
        address: <<-TEXT
          #{values[3] ? "#{values[2]} (#{values[3]})" : values[2]},
          #{values[4]} #{values[5]}
        TEXT
      }
    end
  end
end
