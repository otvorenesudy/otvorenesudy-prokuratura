# frozen_string_literal: true

# Every prosecutor's property declarations as CSV: a row for each item, income and statement, with the prosecutor's
# current and temporary office.
class DeclarationsExport
  HEADER = [
    'ID', 'Name', 'Current Office', 'Temporary Office', 'Declaration Year', 'Declaration Category', 'Description',
    'Acquisition Date', 'Aquisition Reason', 'Price/Value', 'Procurement Price/Value'
  ].freeze

  ITEM_COLUMNS = %w[description acquisition_date acquisition_reason price procurement_price].freeze

  def self.to_csv
    CSV.generate do |csv|
      csv << HEADER

      Prosecutor.find_each { |prosecutor| rows_of(prosecutor).each { |row| csv << row } }
    end
  end

  class << self
    private

    def rows_of(prosecutor)
      columns = [
        prosecutor.id,
        prosecutor.name,
        prosecutor.appointments.fixed.first&.office&.name,
        prosecutor.appointments.temporary.first&.office&.name
      ]

      Array(prosecutor.declarations).flat_map do |declaration|
        rows_of_declaration(declaration).map { |row| [*columns, declaration['year'], *row] }
      end
    end

    def rows_of_declaration(declaration)
      items = declaration['lists'].flat_map do |list|
        list['items'].map { |item| [list['category'], *item.values_at(*ITEM_COLUMNS)] }
      end
      incomes = Array(declaration['incomes']).map do |income|
        ['Príjmy', income['description'], nil, nil, nil, income['value'], nil]
      end
      statements = declaration['statements'].map { |statement| ['Vyhlásenia', statement, nil, nil, nil, nil, nil] }

      items + incomes + statements
    end
  end
end
