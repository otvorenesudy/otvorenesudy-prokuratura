# == Schema Information
#
# Table name: prosecutors
#
#  id                                :bigint           not null, primary key
#  declarations                      :jsonb
#  name                              :string           not null
#  name_parts                        :jsonb            not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint           not null
#
# Indexes
#
#  index_prosecutors_on_genpro_gov_sk_prosecutors_list_id  (genpro_gov_sk_prosecutors_list_id)
#  index_prosecutors_on_name                               (name)
#  index_prosecutors_on_name_parts                         (name_parts)
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_prosecutors_list_id => genpro_gov_sk_prosecutors_lists.id)
#
class Prosecutor < ApplicationRecord
  include Searchable
  include Newsable

  belongs_to :genpro_gov_sk_prosecutors_list, class_name: :'GenproGovSk::ProsecutorsList'

  has_many :appointments, -> { order(id: :asc) }, dependent: :destroy
  has_many :offices, through: :appointments

  has_many :employments, class_name: :Employee, dependent: :nullify

  validates :name, presence: true

  validate :validate_declarations, if: :declarations?

  def to_news_query
    "\"#{name_parts.values_at('first', 'middle', 'last').compact.join(' ')}\" prokurátor"
  end

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
      offices.name
    ]

    joins(:offices).pluck(Arel.sql(attributes.join(', '))).map do |values|
      {
        url: Rails.application.routes.url_helpers.prosecutor_path(values[0]),
        name: values[1],
        coordinates: values[6..7],
        office: values[8],
        address: <<-TEXT
          #{values[3] ? "#{values[2]} (#{values[3]})" : values[2]},
          #{values[4]} #{values[5]}
        TEXT
      }
    end
  end

  private

  def validate_declarations
    schema = {
      type: :array,
      items: {
        type: :object,
        required: %i[year lists incomes statements],
        properties: {
          year: { type: :number },
          lists: {
            type: :array,
            items: {
              type: :object,
              required: %i[category items],
              properties: {
                category: { type: :string },
                items: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      description: { type: %i[string null] },
                      acquisition_date: { type: %i[string null] },
                      acquisition_reason: { type: %i[string null] },
                      procurement_price: { type: %i[string null] },
                      price: { type: %i[string null] }
                    }
                  }
                }
              }
            }
          },
          incomes: {
            type: %i[array null],
            items: {
              type: :object,
              required: %i[description value],
              properties: { description: { type: :string }, value: { type: %i[string null] } }
            }
          },
          statements: { type: :array, iterm: { type: :string } }
        }
      }
    }

    return if JSON::Validator.validate(schema, declarations)

    errors.add(:declarations, :invalid)
  end
end
