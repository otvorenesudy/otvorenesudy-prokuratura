require 'roo'

module GenproGovSk
  module Criminality
    class ParagraphsParser
      def self.parse(path)
        xls = Roo::Spreadsheet.open(path)
        sheet = xls.sheet(0)
        data = {}

        sheet.each do |row|
          data[:office] = row[0].match(/\d{4}/).to_a if row[0]&.match(/Prokuratúry/)

          if row[0]&.match(/Prehľad za.* ((OP|KP).+)$/) && data[:office].nil?
            _, value = *row[0]&.match(/Prehľad za.* ((OP|KP).+)$/)

            next if row[0].match(/Prehľad za OP Šaľa/)

            data[:office] =
              begin
                ::Office.find_by!(name: normalize_office_name(value))
              rescue StandardError
                binding.pry
              end
          end

          data[:year] = row[0].match(/\d{4}/)[0].to_i if row[0]&.match(/obdobie/i)
        end

        data
      end

      def self.normalize_office_name(value)
        value.gsub(/OP/, 'Okresná prokuratúra').gsub(/KP/, 'Krajská prokuratúra').gsub(/-/, ' - ').gsub(/1/, 'I').gsub(
          /2/,
          'II'
        ).gsub(/3/, 'III').gsub(/4/, 'IV').gsub(/5/, 'V').gsub(%r{n\/}, 'nad ')
      end
    end
  end
end
