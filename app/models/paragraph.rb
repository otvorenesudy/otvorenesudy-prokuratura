# frozen_string_literal: true

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
#  index_paragraphs_on_type   (type)
#  index_paragraphs_on_value  (value) UNIQUE
#
class Paragraph < ApplicationRecord
  include Searchable

  self.inheritance_column = :_sti_disabled

  enum :type, { old: 0, new: 1 }, prefix: true

  validates :name, presence: true
  validates :value, presence: true, uniqueness: true

  def self.name_of(value)
    by_value[value]
  end

  def self.type_of(value)
    by_type[value]
  end

  def self.by_name
    @by_name ||= Paragraph.pluck(:name, :value).to_h
  end

  def self.by_value
    @by_value ||= by_name.invert
  end

  def self.by_type
    @by_type ||= Paragraph.pluck(:value, :type).to_h { |value, type| [value, type.to_sym] }
  end

  # The lookups above are read once per process; this reads them again.
  def self.reset!
    @by_name = @by_value = @by_type = nil
  end
end
