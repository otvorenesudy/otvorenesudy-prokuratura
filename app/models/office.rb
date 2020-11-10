# == Schema Information
#
# Table name: offices
#
#  id                      :bigint           not null, primary key
#  additional_address      :string(1024)
#  address                 :string(1024)     not null
#  city                    :string           not null
#  destroyed_at            :datetime
#  electronic_registry     :string
#  email                   :string
#  fax                     :string
#  latitude                :float            not null
#  longitude               :float            not null
#  name                    :string           not null
#  news                    :jsonb
#  phone                   :string           not null
#  registry                :jsonb            not null
#  type                    :integer
#  zipcode                 :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  genpro_gov_sk_office_id :bigint
#
# Indexes
#
#  index_offices_on_city                     (city)
#  index_offices_on_destroyed_at             (destroyed_at)
#  index_offices_on_genpro_gov_sk_office_id  (genpro_gov_sk_office_id)
#  index_offices_on_name                     (name) UNIQUE
#  index_offices_on_news                     (news)
#  index_offices_on_type                     (type)
#  index_offices_on_unique_general_type      (type) UNIQUE WHERE (type = 0)
#  index_offices_on_unique_specialized_type  (type) UNIQUE WHERE (type = 1)
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_office_id => genpro_gov_sk_offices.id)
#
class Office < ApplicationRecord
  include Searchable
  include Newsable

  self.inheritance_column = :_type_disabled

  belongs_to :genpro_gov_sk_office, class_name: :'GenproGovSk::Office', optional: true

  has_many :employees, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :active_appointments, -> { current }, class_name: :Appointment, dependent: :destroy
  has_many :prosecutors, through: :active_appointments

  enum type: { general: 0, specialized: 1, regional: 2, district: 3 }

  validates :name, presence: true, uniqueness: true
  validates :address, presence: true
  validates :zipcode, presence: true
  validates :city, presence: true
  validates :phone, presence: true
  validates :registry, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  validate :validate_registry, if: :registry?

  before_validation :geocode, if: -> { address.present? && city.present? && (address_changed? || city_changed?) }

  scope :active, -> { where(destroyed_at: nil) }

  def attorney_general
    employees.active.order(rank: :asc).first
  end

  def full_address
    address = additional_address ? "#{self.address} (#{additional_address})" : self.address

    "#{address}, #{zipcode} #{city}"
  end

  def to_news_query
    general? ? 'Generálna prokuratúra' : name
  end

  def self.as_map_json
    pluck(:id, :name, :address, :additional_address, :zipcode, :city, :latitude, :longitude).map do |values|
      {
        url: Rails.application.routes.url_helpers.office_path(values[0]),
        name: values[1],
        coordinates: values[6..7],
        address: <<-TEXT
          #{values[3] ? "#{values[2]} (#{values[3]})" : values[2]},
          #{values[4]} #{values[5]}
        TEXT
      }
    end
  end

  private

  def validate_registry
    schema = {
      type: :object,
      required: %i[phone hours],
      properties: {
        phone: { type: %i[string null] },
        note: { type: %i[string null] },
        hours: {
          required: %i[monday tuesday wednesday thursday friday],
          properties: {
            monday: { type: :string, minLength: 1 },
            tuesday: { type: :string, minLength: 1 },
            wednesday: { type: :string, minLength: 1 },
            thursday: { type: :string, minLength: 1 },
            friday: { type: :string, minLength: 1 }
          }
        }
      }
    }

    return if JSON::Validator.validate(schema, registry)

    errors.add(:registry, :invalid)
  end

  def geocode
    location = Geocoder.search("#{address}, #{city}, Slovakia").first

    self.latitude = location.latitude
    self.longitude = location.longitude

    self
  end
end
