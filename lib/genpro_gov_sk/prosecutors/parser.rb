require 'active_support'
require 'legacy'

module GenproGovSk
  module Prosecutors
    module Parser
      OFFICES_MAP = {
        'Generálna prokuratúra SR' => 'Generálna prokuratúra Slovenskej republiky',
        'Úrad špeciálnej prokuratúry' => 'Úrad špeciálnej prokuratúry',
        'Krajská prokuratúra Bratislava' => 'Krajská prokuratúra Bratislava',
        'Okresná prokuratúra Bratislava I' => 'Okresná prokuratúra Bratislava I',
        'Okresná prokuratúra Bratislava II' => 'Okresná prokuratúra Bratislava II',
        'Okresná prokuratúra Bratislava III' => 'Okresná prokuratúra Bratislava III',
        'Okresná prokuratúra Bratislava IV' => 'Okresná prokuratúra Bratislava IV',
        'Okresná prokuratúra Bratislava V' => 'Okresná prokuratúra Bratislava V',
        'Okresná prokuratúra Pezinok' => 'Okresná prokuratúra Pezinok',
        'Okresná prokuratúra Malacky' => 'Okresná prokuratúra Malacky',
        'Krajská prokuratúra Trnava' => 'Krajská prokuratúra Trnava',
        'Okresná prokuratúra Trnava' => 'Okresná prokuratúra Trnava',
        'Okresná prokuratúra Galanta' => 'Okresná prokuratúra Galanta',
        'Okresná prokuratúra Dunajská Streda' => 'Okresná prokuratúra Dunajská Streda',
        'Okresná prokuratúra Senica' => 'Okresná prokuratúra Senica',
        'Okresná prokuratúra Skalica' => 'Okresná prokuratúra Skalica',
        'Okresná prokuratúra Piešťany' => 'Okresná prokuratúra Piešťany',
        'Krajská prokuratúra Trenčín' => 'Krajská prokuratúra Trenčín',
        'Okresná prokuratúra Trenčín' => 'Okresná prokuratúra Trenčín',
        'Okresná prokuratúra Považská Bystrica' => 'Okresná prokuratúra Považská Bystrica',
        'Okresná prokuratúra Prievidza' => 'Okresná prokuratúra Prievidza',
        'Okresná prokuratúra Nové Mesto nad Váhom' => 'Okresná prokuratúra Nové Mesto nad Váhom',
        'Okresná prokuratúra Bánovce nad Bebravou' => 'Okresná prokuratúra Bánovce nad Bebravou',
        'Okresná prokuratúra Partizánske' => 'Okresná prokuratúra Partizánske',
        'Krajská prokuratúra Nitra' => 'Krajská prokuratúra Nitra',
        'Okresná prokuratúra Nitra' => 'Okresná prokuratúra Nitra',
        'Okresná prokuratúra Komárno' => 'Okresná prokuratúra Komárno',
        'Okresná prokuratúra Levice' => 'Okresná prokuratúra Levice',
        'Okresná prokuratúra Nové Zámky' => 'Okresná prokuratúra Nové Zámky',
        'Okresná prokuratúra Topoľčany' => 'Okresná prokuratúra Topoľčany',
        'Krajská prokuratúra Žilina' => 'Krajská prokuratúra Žilina',
        'Okresná prokuratúra Žilina' => 'Okresná prokuratúra Žilina',
        'Okresná prokuratúra Čadca' => 'Okresná prokuratúra Čadca',
        'Okresná prokuratúra Dolný Kubín' => 'Okresná prokuratúra Dolný Kubín',
        'Okresná prokuratúra Liptovský Mikuláš' => 'Okresná prokuratúra Liptovský Mikuláš',
        'Okresná prokuratúra Martin' => 'Okresná prokuratúra Martin',
        'Okresná prokuratúra Ružomberok' => 'Okresná prokuratúra Ružomberok',
        'Okresná prokuratúra Námestovo' => 'Okresná prokuratúra Námestovo',
        'Krajská prokuratúra Banská Bystrica' => 'Krajská prokuratúra Banská Bystrica',
        'Okresná prokuratúra Banská Bystrica' => 'Okresná prokuratúra Banská Bystrica',
        'Okresná prokuratúra Brezno' => 'Okresná prokuratúra Brezno',
        'Okresná prokuratúra Lučenec' => 'Okresná prokuratúra Lučenec',
        'Okresná prokuratúra Revúca' => 'Okresná prokuratúra Revúca',
        'Okresná prokuratúra Rimavská Sobota' => 'Okresná prokuratúra Rimavská Sobota',
        'Okresná prokuratúra Veľký Krtíš' => 'Okresná prokuratúra Veľký Krtíš',
        'Okresná prokuratúra Zvolen' => 'Okresná prokuratúra Zvolen',
        'Okresná prokuratúra Žiar nad Hronom' => 'Okresná prokuratúra Žiar nad Hronom',
        'Krajská prokuratúra Prešov' => 'Krajská prokuratúra Prešov',
        'Okresná prokuratúra Prešov' => 'Okresná prokuratúra Prešov',
        'Okresná prokuratúra Bardejov' => 'Okresná prokuratúra Bardejov',
        'Okresná prokuratúra Humenné' => 'Okresná prokuratúra Humenné',
        'Okresná prokuratúra Kežmarok' => 'Okresná prokuratúra Kežmarok',
        'Okresná prokuratúra Poprad' => 'Okresná prokuratúra Poprad',
        'Okresná prokuratúra Stará Ľubovňa' => 'Okresná prokuratúra Stará Ľubovňa',
        'Okresná prokuratúra Svidník' => 'Okresná prokuratúra Svidník',
        'Okresná prokuratúra Vranov nad Topľou' => 'Okresná prokuratúra Vranov nad Topľou',
        'Krajská prokuratúra Košice' => 'Krajská prokuratúra Košice',
        'Krajská prokuratúra Košice II' => 'Krajská prokuratúra Košice',
        'Okresná prokuratúra Košice I' => 'Okresná prokuratúra Košice I',
        'Okresná prokuratúra Košice II' => 'Okresná prokuratúra Košice II',
        'Okresná prokuratúra Košice - okolie' => 'Okresná prokuratúra Košice - okolie',
        'Okresná prokuratúra Michalovce' => 'Okresná prokuratúra Michalovce',
        'Okresná prokuratúra Rožňava' => 'Okresná prokuratúra Rožňava',
        'Okresná prokuratúra Spišská Nová Ves' => 'Okresná prokuratúra Spišská Nová Ves',
        'Okresná prokuratúra Trebišov' => 'Okresná prokuratúra Trebišov',
        'Justičná akadémia SR' => 'Justičná akadémia SR',
        'EUROJUST' => 'EUROJUST'
      }

      FIXED_OFFICES_BY_PROSECUTOR_NAME = {
        'JUDr. Alexander Bíró' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Milan Cisarik' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Bohdan Čeľovský' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Ján Hrivnák' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Tomáš Honz' => 'Úrad špeciálnej prokuratúry',
        'JUDr. Attila Izsák' => 'Úrad špeciálnej prokuratúry',
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
        'JUDr. Marián Varga' => 'Úrad špeciálnej prokuratúry'
      }

      def self.parse(text)
        text = cleanup(text)
        lines = text.split("\n").map(&:strip).select(&:present?)

        lines.each.with_object([]) { |line, array| array << parse_line(line) }.compact
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
          OFFICES_MAP.keys.each { |name| line.gsub!("#{name}", "   #{name}   ") } if (!line.match(/\s{3,}/))

          _, number = *line.match(/\A(\d+)/)

          line.gsub!(/\A\d+/, '')

          parts = line.split(/\s{3,}/)

          return if parts.size <= 1 || parts[0].size <= 5

          name_parts = parse_name(parts[0])
          office = parts[1].strip.gsub(/–/, '-')
          temporary_office = parts[2]&.strip&.gsub(/–/, '-')

          name = name_parts[:value]
          office = FIXED_OFFICES_BY_PROSECUTOR_NAME[name] || OFFICES_MAP[office] || office
          temporary_office = OFFICES_MAP[temporary_office] || temporary_office

          {
            number: number,
            name: name,
            name_parts: name_parts.except(:value),
            office: office,
            temporary_office: temporary_office
          }
        end

        def parse_name(value)
          value = 'Sofia Svitnič Martina, Mgr.' if value.strip.squeeze(' ') == 'Svitnič Martina Sofia, Mgr.'

          ::Legacy::Normalizer.partition_person_name(value, reverse: true)
        end
      end
    end
  end
end
