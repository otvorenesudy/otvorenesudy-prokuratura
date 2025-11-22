require 'active_support'
require 'legacy'

module GenproGovSk
  module Prosecutors
    module Parser
      OFFICES_MAP = {
        'Generálna prokuratúra SR' => 'Generálna prokuratúra Slovenskej republiky',
        'Úrad špeciálnej prokuratúry' => 'Úrad špeciálnej prokuratúry',
        'Krajská prokuratúra Bratislava' => 'Krajská prokuratúra v Bratislave',
        'Krajská prokuratúra v Bratislave' => 'Krajská prokuratúra v Bratislave',
        'Okresná prokuratúra Bratislava I' => 'Okresná prokuratúra Bratislava I',
        'Okresná prokuratúra Bratislava II' => 'Okresná prokuratúra Bratislava II',
        'Okresná prokuratúra Bratislava III' => 'Okresná prokuratúra Bratislava III',
        'Okresná prokuratúra Bratislava IV' => 'Okresná prokuratúra Bratislava IV',
        'Okresná prokuratúra Bratislava V' => 'Okresná prokuratúra Bratislava V',
        'Okresná prokuratúra Pezinok' => 'Okresná prokuratúra Pezinok',
        'Okresná prokuratúra Malacky' => 'Okresná prokuratúra Malacky',
        'Krajská prokuratúra Trnava' => 'Krajská prokuratúra v Trnave',
        'Krajská prokuratúra v Trnave' => 'Krajská prokuratúra v Trnave',
        'Okresná prokuratúra Trnava' => 'Okresná prokuratúra Trnava',
        'Okresná prokuratúra Galanta' => 'Okresná prokuratúra Galanta',
        'Okresná prokuratúra Dunajská Streda' => 'Okresná prokuratúra Dunajská Streda',
        'Okresná prokuratúra Senica' => 'Okresná prokuratúra Senica',
        'Okresná prokuratúra Skalica' => 'Okresná prokuratúra Skalica',
        'Okresná prokuratúra Piešťany' => 'Okresná prokuratúra Piešťany',
        'Krajská prokuratúra Trenčín' => 'Krajská prokuratúra v Trenčíne',
        'Krajská prokuratúra v Trenčíne' => 'Krajská prokuratúra v Trenčíne',
        'Okresná prokuratúra Trenčín' => 'Okresná prokuratúra Trenčín',
        'Okresná prokuratúra Považská Bystrica' => 'Okresná prokuratúra Považská Bystrica',
        'Okresná prokuratúra Prievidza' => 'Okresná prokuratúra Prievidza',
        'Okresná prokuratúra Nové Mesto nad Váhom' => 'Okresná prokuratúra Nové Mesto nad Váhom',
        'Okresná prokuratúra Bánovce nad Bebravou' => 'Okresná prokuratúra Bánovce nad Bebravou',
        'Okresná prokuratúra Partizánske' => 'Okresná prokuratúra Partizánske',
        'Krajská prokuratúra Nitra' => 'Krajská prokuratúra v Nitre',
        'Krajská prokuratúra v Nitre' => 'Krajská prokuratúra v Nitre',
        'Okresná prokuratúra Nitra' => 'Okresná prokuratúra Nitra',
        'Okresná prokuratúra Komárno' => 'Okresná prokuratúra Komárno',
        'Okresná prokuratúra Levice' => 'Okresná prokuratúra Levice',
        'Okresná prokuratúra Nové Zámky' => 'Okresná prokuratúra Nové Zámky',
        'Okresná prokuratúra Topoľčany' => 'Okresná prokuratúra Topoľčany',
        'Krajská prokuratúra Žilina' => 'Krajská prokuratúra v Žiline',
        'Krajská prokuratúra v Žiline' => 'Krajská prokuratúra v Žiline',
        'Okresná prokuratúra Žilina' => 'Okresná prokuratúra Žilina',
        'Okresná prokuratúra Čadca' => 'Okresná prokuratúra Čadca',
        'Okresná prokuratúra Dolný Kubín' => 'Okresná prokuratúra Dolný Kubín',
        'Okresná prokuratúra Liptovský Mikuláš' => 'Okresná prokuratúra Liptovský Mikuláš',
        'Okresná prokuratúra Martin' => 'Okresná prokuratúra Martin',
        'Okresná prokuratúra Ružomberok' => 'Okresná prokuratúra Ružomberok',
        'Okresná prokuratúra Námestovo' => 'Okresná prokuratúra Námestovo',
        'Krajská prokuratúra Banská Bystrica' => 'Krajská prokuratúra v Banskej Bystrici',
        'Krajská prokuratúra v Banskej Bystrici' => 'Krajská prokuratúra v Banskej Bystrici',
        'Okresná prokuratúra Banská Bystrica' => 'Okresná prokuratúra Banská Bystrica',
        'Okresná prokuratúra Brezno' => 'Okresná prokuratúra Brezno',
        'Okresná prokuratúra Lučenec' => 'Okresná prokuratúra Lučenec',
        'Okresná prokuratúra Revúca' => 'Okresná prokuratúra Revúca',
        'Okresná prokuratúra Rimavská Sobota' => 'Okresná prokuratúra Rimavská Sobota',
        'Okresná prokuratúra Veľký Krtíš' => 'Okresná prokuratúra Veľký Krtíš',
        'Okresná prokuratúra Zvolen' => 'Okresná prokuratúra Zvolen',
        'Okresná prokuratúra Žiar nad Hronom' => 'Okresná prokuratúra Žiar nad Hronom',
        'Krajská prokuratúra Prešov' => 'Krajská prokuratúra v Prešove',
        'Krajská prokuratúra v Prešove' => 'Krajská prokuratúra v Prešove',
        'Okresná prokuratúra Prešov' => 'Okresná prokuratúra Prešov',
        'Okresná prokuratúra Bardejov' => 'Okresná prokuratúra Bardejov',
        'Okresná prokuratúra Humenné' => 'Okresná prokuratúra Humenné',
        'Okresná prokuratúra Kežmarok' => 'Okresná prokuratúra Kežmarok',
        'Okresná prokuratúra Poprad' => 'Okresná prokuratúra Poprad',
        'Okresná prokuratúra Stará Ľubovňa' => 'Okresná prokuratúra Stará Ľubovňa',
        'Okresná prokuratúra Svidník' => 'Okresná prokuratúra Svidník',
        'Okresná prokuratúra Vranov nad Topľou' => 'Okresná prokuratúra Vranov nad Topľou',
        'Krajská prokuratúra Košice' => 'Krajská prokuratúra v Košiciach',
        'Krajská prokuratúra v Košiciach' => 'Krajská prokuratúra v Košiciach',
        'Krajská prokuratúra Košice II' => 'Krajská prokuratúra v Košiciach',
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

      def self.parse(rows)
        rows.map.with_index { |row, i| parse_row(row) }
      end

      class << self
        private

        def parse_row(row)
          source_name, source_office, source_temporary_office = row

          office = parse_office_or_place(source_office)
          temporary_office = parse_office_or_place(source_temporary_office)
          office = OFFICES_MAP[office]

          if office.blank?
            office = OFFICES_MAP.keys.find { |name| row[0].match?(/#{name}/i) }

            raise "Office not found for #{row[0]}" if office.blank?

            source_name = source_name.gsub(/#{office}/i, '').strip
            office = OFFICES_MAP[office]
          end

          name_parts = parse_name(source_name)
          name = name_parts.delete(:value)

          temporary_office = OFFICES_MAP[temporary_office]

          { name: name, name_parts: name_parts, office: office.presence, temporary_office: temporary_office.presence }
        end

        def parse_name(value)
          value = 'Sofia Svitnič Martina, Mgr.' if value.strip.squeeze(' ') == 'Svitnič Martina Sofia, Mgr.'
          value = value.gsub('doc. et doc.', 'doc.')

          ::Legacy::Normalizer.partition_person_name(value, reverse: true)
        end

        def parse_office_or_place(value)
          value.gsub(/–|—/, '-').strip
        end
      end
    end
  end
end
