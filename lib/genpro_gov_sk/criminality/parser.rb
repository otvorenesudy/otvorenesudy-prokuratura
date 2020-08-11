require 'csv'

module GenproGovSk
  module Criminality
    class Parser
      def self.parse(text)
        csv = CSV.parse(text, col_sep: ';')
        year = csv[0][0].match(/\d{2}.\d{2}.(\d{4})/)[1]
        offices =
          GenproGovSk::Criminality::OFFICES_MAP.each.with_object({}) do |(key, name), hash|
            hash[name] = csv[0].index(key)
          end

        map = {
          'V trestných registroch Pv/Kv/Gv napadlo spisov' => :incoming_cases,
          'V trestných registroch Pv/Kv/Gv bolo vybavených spisov' => :closed_cases,
          'Počet známych odstíhaných osôb (na prokuratúre skončené)' => :known_closed_prosecuted_people,
          'Počet obžalovaných osôb' => :prosecuted_people,
          'Obžalovaní recidivisti' => :prosecuted_recidivists,
          'Skladba odstíhaných osôb muži' => :men,
          'Skladba odstíhaných osôb ženy' => :women,
          'Skladba odstíhaných osôb mladiství' => :young,
          'Skladba odstíhaných osôb cudzinci' => :foreigners,
          'Skladba odstíhaných osôb vplyv alkoholu' => :alcohol_abuse,
          'Skladba odstíhaných osôb vplyv inej návykovej látky' => :substance_abuse,
          'Dohoda o vine a treste odoslaná na súd' => :guilt_and_punishment_aggreement
        }

        offices.map do |name, index|
          last_title = nil

          statistics =
            csv.map do |row|
              last_title = row[0] if row[0]&.strip.presence

              filter =
                map[Normalizer.normalize_filter(row[0]&.strip.presence ? row[0] : [last_title, row[1]].join(' '))]

              next unless filter

              count = Normalizer.parse_count(row[index])

              next unless count

              { filters: [filter], count: count }
            end

          { name: name, year: year, statistics: statistics.compact }
        end
      end

      class Normalizer
        def self.normalize_filter(value)
          value.to_s.gsub(/[[:space:]]+/, ' ').strip
        end

        def self.parse_count(value)
          count = value.to_s.gsub(/[[:space:]]/, '')

          count.presence ? Integer(count) : nil
        end
      end
    end
  end
end
