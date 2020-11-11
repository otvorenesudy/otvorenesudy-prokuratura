require 'active_support'
require 'legacy'

module GenproGovSk
  module Prosecutors
    module Parser
      OFFICE_MAP = { 'Generálna prokuratúra SR' => 'Generálna prokuratúra Slovenskej republiky' }

      FIXED_OFFICES_BY_PROSECUTOR_NAME = {
        'JUDr. Alexander Bíró' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Milan Cisarik' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Bohdan Čeľovský' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Ján Hrivnák' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Rastislav Hruška, PhD.' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Oliver Janíček' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Peter Jenčík' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Vladimír Kuruc' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Peter Kysel' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Miroslav Ľalík' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Martin Nociar' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Renáta Ontkovičová' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Jaroslav Palkovič, PhD.' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Aurel Pardubský' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Ondrej Repa, PhD.' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Valéria Simonová' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Marek Sivák' => 'Úrad špeciálnej prokuratúry',
        'Mgr. Michal Stanislav' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Ján Šanta, MBA PhD.' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Vasiľ Špirko' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Michal Šúrek' => 'Úrad špeciálnej prokuratúry',
        'Mgr. Martin Tamaškovič' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Mária Trstenská' => 'Úrad špeciálnej prokuratúry',
        'Mgr. Vladimír Turan' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Marián Varga' => 'Úrad špeciálnej prokuratúry',
        'Dr. JUDr. Maroš Žilinka, PhD.' => 'Úrad špeciálnej prokuratúry'
      }

      def self.parse(text)
        text = cleanup(text)
        lines = text.split("\n").map(&:strip).select(&:present?)

        lines.each.with_object([]) { |line, array| array << parse_line(line) }
      end

      class << self
        private

        def cleanup(text)
          text.gsub!(%r{Priezvisko meno, titul\/-y}, '')
          text.gsub!(/Pravidelné miesto výkonu funkcie/, '')
          text.gsub!(/Dočasné pridelenie/, '')

          text
        end

        def parse_line(line)
          _, number = *line.match(/\A(\d+)/)

          line.gsub!(/\A\d+/, '')

          parts = line.split(/\s{3,}/)

          name_parts = parse_name(parts[0])
          office = parts[1].strip
          temporary_office = parts[2]&.strip

          name = name_parts[:value]
          office = FIXED_OFFICES_BY_PROSECUTOR_NAME[name] || OFFICE_MAP[office] || office
          temporary_office = OFFICE_MAP[temporary_office] || temporary_office

          {
            number: number,
            name: name,
            name_parts: name_parts.except(:value),
            office: office,
            temporary_office: temporary_office
          }
        end

        def parse_name(value)
          ::Legacy::Normalizer.partition_person_name(value, reverse: true)
        end
      end
    end
  end
end
