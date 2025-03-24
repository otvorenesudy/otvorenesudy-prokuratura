# == Schema Information
#
# Table name: prosecutors
#
#  id                                :bigint           not null, primary key
#  declarations                      :jsonb
#  decrees_count                     :bigint           default(0)
#  name                              :string           not null
#  name_parts                        :jsonb            not null
#  news                              :jsonb
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  genpro_gov_sk_prosecutors_list_id :bigint
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

  belongs_to :genpro_gov_sk_prosecutors_list, class_name: :'GenproGovSk::ProsecutorsList', optional: true

  has_many :all_appointments, -> { order(id: :asc) }, dependent: :destroy, class_name: :Appointment
  has_many :all_offices, through: :all_appointments, source: :office

  has_many :past_appointments, -> { past.order(id: :asc) }, dependent: :destroy, class_name: :Appointment
  has_many :past_offices, through: :past_appointments, source: :office

  has_many :appointments, -> { current.order(id: :asc) }, dependent: :destroy
  has_many :offices, through: :appointments

  has_many :employments, class_name: :Employee, dependent: :nullify

  has_many :decrees, -> { order(id: :asc) }, dependent: :nullify

  validates :name, presence: true

  validate :validate_declarations, if: :declarations?

  def to_news_query
    name_parts.values_at('first', 'middle', 'last').compact.join(' ')
  end

  def past_appointments_excluding_current
    all_appointments.past.where.not(office: offices).order(id: :asc)
  end

  def merge_with(prosecutor)
    return if prosecutor == self

    ActiveRecord::Base.transaction do
      prosecutor.appointments.update_all(prosecutor_id: id)
      prosecutor.employments.update_all(prosecutor_id: id)
      prosecutor.decrees.update_all(prosecutor_id: id)
    end

    prosecutor.reload.destroy!
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

    joins(:offices)
      .reorder(id: :asc)
      .pluck(Arel.sql(attributes.join(', ')))
      .map do |values|
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

  def self.find_by_fuzzy_name(name, office: nil)
    # TODO: index?
    relation =
      self.where(
        "
        ARRAY_REMOVE(
          ARRAY[
            LOWER(UNACCENT(name_parts ->> 'prefix')),
            LOWER(UNACCENT(name_parts ->> 'first')),
            LOWER(UNACCENT(name_parts ->> 'middle')),
            LOWER(UNACCENT(name_parts ->> 'last')),
            LOWER(UNACCENT(name_parts ->> 'suffix'))
          ],
          NULL
        ) @> ARRAY[:name]
      ",
        name: name.squeeze(' ').strip.split(' ').map { |e| I18n.transliterate(e).downcase }
      )

    if office
      relation =
        relation.joins(:all_offices).order(
          Arel.sql("CASE WHEN offices.id = #{ActiveRecord::Base.connection.quote(office.id)} THEN 0 ELSE 1 END ASC")
        )
    else
      relation = relation.order(Arel.sql('LENGTH(name) DESC'))
    end

    relation.first
  end

  private

  def validate_declarations
    schema = {
      type: :array,
      items: {
        type: :object,
        required: %i[genpro_gov_sk_declaration_id name year lists incomes statements],
        properties: {
          genpro_gov_sk_declaration_id: {
            type: :bigint
          },
          name: {
            type: :string
          },
          office: {
            type: %i[string null]
          },
          office_id: {
            type: %i[bigint null]
          },
          url: {
            type: :string
          },
          year: {
            type: :number
          },
          lists: {
            type: :array,
            items: {
              type: :object,
              required: %i[category items],
              properties: {
                category: {
                  type: :string
                },
                items: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      description: {
                        type: %i[string null]
                      },
                      acquisition_date: {
                        type: %i[string null]
                      },
                      acquisition_reason: {
                        type: %i[string null]
                      },
                      procurement_price: {
                        type: %i[string null]
                      },
                      price: {
                        type: %i[string null]
                      }
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
              properties: {
                description: {
                  type: :string
                },
                value: {
                  type: %i[string null]
                }
              }
            }
          },
          statements: {
            type: :array,
            iterm: {
              type: :string
            }
          }
        }
      }
    }

    return if JSON::Validator.validate(schema, declarations)

    errors.add(:declarations, :invalid)
  end
end
