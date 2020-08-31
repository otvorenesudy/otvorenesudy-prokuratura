# == Schema Information
#
# Table name: paragraphs
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  type       :integer          not null
#  value      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_paragraphs_on_value  (value) UNIQUE
#
class Paragraph < ApplicationRecord
  include Searchable

  self.inheritance_column = :_sti_disabled

  enum type: %i[old new], _prefix: true

  validates :name, presence: true
  validates :value, presence: true, uniqueness: true

  def self.value_of(name)
    by_name[name]
  end

  def self.name_of(value)
    by_value[value]
  end

  def self.by_name
    @paragraphs_by_name ||= Paragraph.pluck(:name, :value).to_h
  end

  def self.by_value
    @paragraphs_by_value ||= by_name.map(&:reverse).to_h
  end
end
