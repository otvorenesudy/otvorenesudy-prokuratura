# frozen_string_literal: true

# == Schema Information
#
# Table name: decrees
#
#  id                      :bigint           not null, primary key
#  effective_on            :date             not null
#  file_info               :string           not null
#  file_number             :string           not null
#  file_type               :integer          not null
#  means_of_resolution     :string
#  number                  :string           not null
#  paragraph_section       :string
#  published_on            :date             not null
#  resolution              :string           not null
#  text                    :text             not null
#  url                     :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  genpro_gov_sk_decree_id :bigint           not null
#  office_id               :bigint
#  paragraph_id            :bigint
#  prosecutor_id           :bigint
#
# Indexes
#
#  index_decrees_on_effective_on             (effective_on)
#  index_decrees_on_genpro_gov_sk_decree_id  (genpro_gov_sk_decree_id)
#  index_decrees_on_office_id                (office_id)
#  index_decrees_on_prosecutor_id            (prosecutor_id)
#  index_decrees_on_published_on             (published_on)
#  index_decrees_on_url                      (url)
#
# Foreign Keys
#
#  fk_rails_...  (genpro_gov_sk_decree_id => genpro_gov_sk_decrees.id)
#  fk_rails_...  (office_id => offices.id)
#  fk_rails_...  (prosecutor_id => prosecutors.id)
#
class Decree < ApplicationRecord
  belongs_to :prosecutor, optional: true, counter_cache: true
  belongs_to :office, optional: true, counter_cache: true
  belongs_to :genpro_gov_sk_decree, class_name: :'GenproGovSk::Decree', optional: false
  belongs_to :paragraph, optional: true

  enum :file_type, { pdf: 0, rtf: 1 }

  validates :url, presence: true, uniqueness: true
  validates :number, presence: true
  validates :file_info, presence: true
  validates :file_type, presence: true
  validates :effective_on, presence: true
  validates :published_on, presence: true
  validates :file_number, presence: true
  validates :resolution, presence: true

  def formatted_text
    text.gsub(/(?>\r\n|\n|\f|\r|\u2028|\u2029)/, "\n")
  end

  def normalized_text
    formatted_text.gsub(/[[:space:]]+/, ' ').strip
  end

  def preamble
    normalized_text.first(100)
  end

  def signature
    normalized_text.last(100)
  end
end
