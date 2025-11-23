module GenproGovSk
  module Criminality
    def self.import
      unknown_attributes = []
      statistics = [parse_structures, parse_paragraphs].flatten
      records =
        statistics
          .map do |attributes|
            year = attributes[:year]
            office = attributes[:office]

            unknown_attributes += attributes[:unknown] if attributes[:unknown].any?

            attributes[:statistics].map do |statistic|
              next if statistic[:count].blank?

              statistic.slice(:metric, :paragraph, :count).merge(office: office, year: year, file: attributes[:file])
            end
          end
          .flatten
          .compact

      if unknown_attributes.any?
        warn "Unknown attributes: \n#{unknown_attributes.uniq.map { |attr| "- #{attr}" }.join("\n")}"
      end

      ::Statistic.import_from(records)
    end

    def self.parse_structures
      urls = %w[
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2010/2010_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2011/2011_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2012/2012_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2013/2013_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2014/2014_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2015/2015_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2016/2016_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2017/2017_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2018/2018_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2019/Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2020/12_Struktura_kriminality_a_stíhanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2021/12_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2022/12_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2023/12_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
        https://www.genpro.gov.sk/fileadmin/Statistiky_datasety/2024/12_Struktura_kriminality_a_stihanych_a_obzalovanych_osob.csv
      ]

      urls
        .map do |url|
          FileDownloader.download(URI::Parser.new.escape(url)) do |path|
            StructureParser.parse(File.read(path, encoding: 'Windows-1250').force_encoding('UTF-8'))
          end
        end
        .flatten
    end

    def self.parse_paragraphs
      path = Rails.root.join('data', 'genpro_gov_sk', 'criminality', 'paragraphs', '*.xls*')
      files = Dir.glob(path).to_a.reject { |e| e.match(/obvod/) }

      Parallel.map(files, in_processes: 8) { |file| ParagraphsParser.parse(file)&.merge(file: file) }.compact
    end

    def self.paragraphs_map
      @paragraphs_map ||=
        %i[new old]
          .each
          .with_object({ new: {}, old: {} }) do |key, hash|
            csv =
              CSV.open(
                Rails.root.join('data', 'genpro_gov_sk', 'criminality', "paragraph-definitions-#{key}.csv"),
                headers: true
              )

            csv.each do |row|
              hash[key][row[2]] = {
                chapter: row[0],
                chapter_name: row[1]&.downcase&.capitalize,
                paragraph: row[2],
                paragraph_name: row[3].downcase.capitalize
              }
            end
          end
    end

    def self.generate_and_save_metrics_map
      sources = {
        'Štruktúry' => STRUCTURES_MAP,
        'Prehľad o osobách odsúdených pre trestné činy' => PARAGRAPHS_BY_CONVICTED_MAP,
        'Prehľad o stíhaných a obžalovaných osobách' => PARAGRAPHS_BY_ACCUSED_AND_PROSECUTED_MAP
      }

      CSV.open(Rails.root.join('data', 'genpro_gov_sk', 'criminality', 'metrics-map.csv'), 'w') do |csv|
        csv << [
          'Symbol nášho atribútu',
          'Názov nášho atribútu',
          'Názov atribútu z dát Generálnej prokuratúry',
          'Typ súboru'
        ]

        sources
          .values
          .map(&:values)
          .flatten
          .uniq
          .sort
          .each
          .with_object({}) do |metric, hash|
            rows =
              sources
                .each
                .with_object([]) do |(key, source), array|
                  values = source.select { |_, e| e == metric }.map(&:first)

                  values.each { |value| array << [nil, nil, value, key] }
                end
                .sort_by { |e| e[1] }

            rows[0][0] = metric

            title = Statistic::GROUPS.find { |group, values| metric.in?(values) }

            rows[0][1] = (title ? "#{I18n.t("statistics.index.search.#{title[0]}.title")} - " : '') +
              I18n.t("models.statistic.metrics.#{metric}")

            rows.each { |row| csv << row }
          end
      end
    end

    OFFICES_MAP = {
      '1000' => 'Generálna prokuratúra Slovenskej republiky',
      '1100' => 'Krajská prokuratúra v Bratislave',
      '1101' => 'Okresná prokuratúra Bratislava I',
      '1102' => 'Okresná prokuratúra Bratislava II',
      '1103' => 'Okresná prokuratúra Bratislava III',
      '1104' => 'Okresná prokuratúra Bratislava IV',
      '1105' => 'Okresná prokuratúra Bratislava V',
      '1106' => 'Okresná prokuratúra Malacky',
      '1107' => 'Okresná prokuratúra Pezinok',
      'KP BA' => 'Krajská prokuratúra v Bratislave',
      '2200' => 'Krajská prokuratúra v Trnave',
      '2201' => 'Okresná prokuratúra Dunajská Streda',
      '2202' => 'Okresná prokuratúra Galanta',
      '2204' => 'Okresná prokuratúra Piešťany',
      '2205' => 'Okresná prokuratúra Senica',
      '2206' => 'Okresná prokuratúra Skalica',
      '2207' => 'Okresná prokuratúra Trnava',
      'KP TT' => 'Krajská prokuratúra v Trnave',
      '3300' => 'Krajská prokuratúra v Trenčíne',
      '3301' => 'Okresná prokuratúra Bánovce nad Bebravou',
      '3304' => 'Okresná prokuratúra Nové Mesto nad Váhom',
      '3305' => 'Okresná prokuratúra Partizánske',
      '3306' => 'Okresná prokuratúra Považská Bystrica',
      '3307' => 'Okresná prokuratúra Prievidza',
      '3309' => 'Okresná prokuratúra Trenčín',
      'KP TN' => 'Krajská prokuratúra v Trenčíne',
      '4400' => 'Krajská prokuratúra v Nitre',
      '4401' => 'Okresná prokuratúra Komárno',
      '4402' => 'Okresná prokuratúra Levice',
      '4403' => 'Okresná prokuratúra Nitra',
      '4404' => 'Okresná prokuratúra Nové Zámky',
      '4406' => 'Okresná prokuratúra Topoľčany',
      'KP NR' => 'Krajská prokuratúra v Nitre',
      '5500' => 'Krajská prokuratúra v Žiline',
      '5502' => 'Okresná prokuratúra Čadca',
      '5503' => 'Okresná prokuratúra Dolný Kubín',
      '5505' => 'Okresná prokuratúra Liptovský Mikuláš',
      '5506' => 'Okresná prokuratúra Martin',
      '5507' => 'Okresná prokuratúra Námestovo',
      '5508' => 'Okresná prokuratúra Ružomberok',
      '5511' => 'Okresná prokuratúra Žilina',
      'KP ZA' => 'Krajská prokuratúra v Žiline',
      '6600' => 'Krajská prokuratúra v Banskej Bystrici',
      '6601' => 'Okresná prokuratúra Banská Bystrica',
      '6603' => 'Okresná prokuratúra Brezno',
      '6606' => 'Okresná prokuratúra Lučenec',
      '6608' => 'Okresná prokuratúra Revúca',
      '6609' => 'Okresná prokuratúra Rimavská Sobota',
      '6610' => 'Okresná prokuratúra Veľký Krtíš',
      '6611' => 'Okresná prokuratúra Zvolen',
      '6613' => 'Okresná prokuratúra Žiar nad Hronom',
      'KP BB' => 'Krajská prokuratúra v Banskej Bystrici',
      '7700' => 'Krajská prokuratúra v Prešove',
      '7701' => 'Okresná prokuratúra Bardejov',
      '7702' => 'Okresná prokuratúra Humenné',
      '7703' => 'Okresná prokuratúra Kežmarok',
      '7706' => 'Okresná prokuratúra Poprad',
      '7707' => 'Okresná prokuratúra Prešov',
      '7710' => 'Okresná prokuratúra Stará Ľubovňa',
      '7712' => 'Okresná prokuratúra Svidník',
      '7713' => 'Okresná prokuratúra Vranov nad Topľou',
      'KP PO' => 'Krajská prokuratúra v Prešove',
      '8800' => 'Krajská prokuratúra v Košiciach',
      '8802' => 'Okresná prokuratúra Košice I',
      '8803' => 'Okresná prokuratúra Košice II',
      '8806' => 'Okresná prokuratúra Košice - okolie',
      '8807' => 'Okresná prokuratúra Michalovce',
      '8808' => 'Okresná prokuratúra Rožňava',
      '8810' => 'Okresná prokuratúra Spišská Nová Ves',
      '8811' => 'Okresná prokuratúra Trebišov',
      'KP KE' => 'Krajská prokuratúra v Košiciach'
    }

    STRUCTURES_MAP = {
      'Obžalovaní recidivisti' => :accused_recidivists_all,
      'Obžalovaní recidivisti recidivisti' => :accused_recidivists_only,
      'Obžalovaní recidivisti obzvlášť nebezpeční recidivisti' => :accused_recidivists_dangerous,
      'Počet obžalovaných osôb' => :accused_all,
      'Počet obžalovaných osôb - z toho skrátené vyšetrovanie podľa §204 Tr.por.' => :accused_by_paragraph_204,
      'Počet obžalovaných osôb z toho skrátené vyšetrovanie podľa § 204 Tr.por.' => :accused_by_paragraph_204,
      'Postúpenie trestného stíhania' => :assignation_of_prosecution,
      'Postúpené trestné stíhanie' => :assignation_of_prosecution,
      'Zastavené trestné stíhanie' => :cessation_of_prosecution,
      'Zastavenie trestného stíhania' => :cessation_of_prosecution,
      'V trestných registroch Pv/Kv/Gv bolo vybavených spisov' => :closed_cases,
      'Podmienečné zastavenie TS súdom' => :conditional_cessation_by_court,
      'Podmienečné zastavenie TS' => :conditional_cessation,
      # TODO: verify THIS
      'Podmienečné zastavenie TS prokurátorom' => :conditional_cessation_by_prosecutor,
      'Podmienečné zastavenie TS - osvedčil sa - spolu' => :conditional_cessation_of_accused_all,
      'Podmienečné zastavenie TS - osvedčil sa - spolu z toho osvedčil sa obvinený' =>
        :conditional_cessation_of_accused_and_proven,
      'Podmienečné zastavenie TS prokurátorom - osvedčil sa' =>
        :conditional_cessation_of_accused_and_proven_by_prosecutor,
      'Podmienečné zastavenie TS prokurátorom - spolu' => :conditional_cessation_by_prosecutor_all,
      'Podmienečné zastavenie TS prokurátorom - spolu z toho obvineného' =>
        :conditional_cessation_of_accused_by_prosecutor,
      'Podmienečné zastavenie TS - osvedčil sa - spolu z toho osvedčil sa spolupracujúci obvinený' =>
        :conditional_cessation_of_cooperating_accused_and_proven,
      'Podmienečné zastavenie TS prokurátorom - spolu z toho spolupracujúceho obvineného' =>
        :conditional_cessation_of_cooperating_accused_by_prosecutor,
      'Podmienečné zastavenie TS spolupracujúceho obvineného prokurátorom' =>
        :conditional_cessation_of_cooperating_accused_by_prosecutor,
      'Dohoda o vine a treste' => :guilt_and_sentence_agreement,
      'Dohoda o vine a treste odoslaná na súd' => :guilt_and_sentence_agreement,
      'V trestných registroch Pv/Kv/Gv napadlo spisov' => :incoming_cases,
      'Počet stíhaných známych osôb (na prokuratúre skončené)' => :prosecuted_all,
      'Počet známych odstíhaných osôb (na prokuratúre skončené)' => :prosecuted_all,
      'Počet známych stíhaných osôb (na prokuratúre skončené)' => :prosecuted_all,
      'Skladba stíhaných osôb vplyv alkoholu' => :prosecuted_alcohol_abuse,
      'Skladba stíhaných osôb cudzinci' => :prosecuted_foreigners,
      'Skladba stíhaných osôb muži' => :prosecuted_men,
      'Skladba stíhaných osôb vplyv inej návykovej látky' => :prosecuted_substance_abuse,
      'Skladba stíhaných osôb ženy' => :prosecuted_women,
      'Skladba stíhaných osôb mladiství' => :prosecuted_young,
      'Počet trestných stíhaní ukončených na polícii – neznámi páchatelia' =>
        :prosecution_of_unknown_offender_ended_by_police,
      'Počet trestných stíhaní ukončených na polícii – neznámi páchatelia postúpením' =>
        :prosecution_of_unknown_offender_ended_by_police_by_assignation,
      'Počet trestných stíhaní ukončených na polícii – neznámi páchatelia zastavením' =>
        :prosecution_of_unknown_offender_ended_by_police_by_cessation,
      'Počet trestných stíhaní ukončených na polícii – neznámi páchatelia inak' =>
        :prosecution_of_unknown_offender_ended_by_police_by_other_mean,
      'Počet trestných stíhaní ukončených na polícii – neznámi páchatelia prerušením' =>
        :prosecution_of_unknown_offender_ended_by_police_by_suspension,
      'Schválenie zmieru' => :reconciliation_approval,
      'Prerušenie trestného stíhania' => :suspension_of_prosecution,
      'Prerušené trestné stíhanie' => :suspension_of_prosecution,
      'Prerušenie trestného stíhania spolupracujúceho obvineného' => :suspension_of_prosecution_of_cooperating_accused,
      'Právoplatné rozhodnutia súdu – spolu' => :valid_court_decision_all,
      'Právoplatné rozhodnutia súdu – spolu postúpenie TS' => :valid_court_decision_on_assignation_of_prosecution,
      'Právoplatné rozhodnutia súdu – spolu zastavenie TS' => :valid_court_decision_on_cessation_of_prosecution,
      'Právoplatné rozhodnutia súdu – spolu o odsúdení osôb' => :valid_court_decision_on_conviction_of_people,
      'Právoplatné rozhodnutia súdu – spolu prerušenie TS' => :valid_court_decision_on_suspension_of_prosecution,
      'Právoplatné rozhodnutia súdu – spolu podmienečné zastavenie TS spolupracujúceho obvineného' =>
        :valid_court_decision_on_conditional_cessation_of_prosecution_of_cooperating_accused,
      'Právoplatné rozhodnutia súdu – spolu podmienečné zastavenie TS' =>
        :valid_court_decision_on_conditional_cessation_of_prosecution,
      'Počet oznámení súdu' => :valid_court_decision_all,
      'Počet oznámení súdu o odsúdení osôb' => :valid_court_decision_on_conviction_of_people,
      'Počet oznámení o odsúdení osôb' => :valid_court_decision_on_conviction_of_people,
      'Právoplatné rozhodnutia súdu – spolu oslobodenie' => :valid_court_decision_on_exemption,
      'Právoplatné rozhodnutia súdu – spolu schválenie zmieru' => :valid_court_decision_on_reconciliation_approval,
      'Počet oznámení súdu o schválení zmieru' => :valid_court_decision_on_reconciliation_approval,
      'Právoplatné rozhodnutia súdu – spolu upustenie od potrestania' => :valid_court_decision_on_waiver_of_sentence,
      'Počet oznámení súdu o schválení dohody o vine a treste' =>
        :valid_court_decision_only_convicted_with_guilt_and_sentence_agreement,
      'Právoplatné rozhodnutia súdu – spolu z odsúdených len schválenie dohody o vine a treste' =>
        :valid_court_decision_only_convicted_with_guilt_and_sentence_agreement,
      'Počet oznámení o schválení dohody o vine a treste súdom' =>
        :valid_court_decision_only_convicted_with_guilt_and_sentence_agreement,
      "Právoplatné rozhodnutia súdu – spolu rozhodnutie \"inak\"" => :valid_other_court_decision
    }

    PARAGRAPHS_BY_ACCUSED_AND_PROSECUTED_MAP = {
      'Vek 14 - 15' => :accused_age_14_to_15_all,
      'Vek 14 - 15 - dievčatá' => :accused_age_14_to_15_girls,
      'Vek 14 - 15 - chlapci' => :accused_age_14_to_15_boys,
      'Vek 16 - 18' => :accused_age_16_to_18_all,
      'Vek 16 - 18 - dievčatá' => :accused_age_16_to_18_girls,
      'Vek 16 - 18 - chlapci' => :accused_age_16_to_18_boys,
      'Vek 19 - 21' => :accused_age_19_to_21_all,
      'Vek 22 - 30' => :accused_age_22_to_30_all,
      'Vek 31 - 40' => :accused_age_31_to_40_all,
      'Vek 41 - 50' => :accused_age_41_to_50_all,
      'Vek 51 - 60' => :accused_age_51_to_60_all,
      'Vek 61 a viac' => :accused_age_61_and_more_all,
      'Obžalovaných osôb - vek 14 - 15' => :accused_age_14_to_15_all,
      'Obžalovaných osôb - vek 14 - 15 - dievčatá' => :accused_age_14_to_15_girls,
      'Obžalovaných osôb - vek 14 - 15 - chlapci' => :accused_age_14_to_15_boys,
      'Obžalovaných osôb - vek 16 - 18' => :accused_age_16_to_18_all,
      'Obžalovaných osôb - vek 16 - 18 - dievčatá' => :accused_age_16_to_18_girls,
      'Obžalovaných osôb - vek 16 - 18 - chlapci' => :accused_age_16_to_18_boys,
      'Obžalovaných osôb - vek 19 - 21' => :accused_age_19_to_21_all,
      'Obžalovaných osôb - vek 22 - 30' => :accused_age_22_to_30_all,
      'Obžalovaných osôb - vek 31 - 40' => :accused_age_31_to_40_all,
      'Obžalovaných osôb - vek 41 - 50' => :accused_age_41_to_50_all,
      'Obžalovaných osôb - vek 51 - 60' => :accused_age_51_to_60_all,
      'Obžalovaných osôb - vek 61 a viac' => :accused_age_61_and_more_all,
      'Obžalovaných osôb - vplyv alkoholu' => :accused_alcohol_abuse,
      'Obžalovaných osôb - obzvlášť nebezpeční recidivisti' => :accused_recidivists_dangerous,
      'Zvlášť nebezpeční recidivisti' => :accused_recidivists_dangerous,
      'Obzvlášť nebezpeční recidivisti' => :accused_recidivists_dangerous,
      'Obžalovaných osôb - z toho muži' => :accused_men,
      'Obžalovaných osôb' => :accused_all,
      'Obžalovaných osôb za úmyselné tr. činy' => :accused_people_for_intentional_crimes,
      'Obžalovaných osôb - úmyselné tr. činy' => :accused_people_for_intentional_crimes,
      'Úmyselné tr. činy' => :accused_people_for_intentional_crimes,
      'Obžalovaných osôb za úmyselné tr. činy - úmyselné tr. činy rovnakého druhu' =>
        :accused_people_for_intentional_crimes_of_same_nature,
      'Obžalovaných osôb - úmyselné tr. činy rovnakého druhu' => :accused_people_for_intentional_crimes_of_same_nature,
      'Úmyselné tr. činy rovnakého druhu' => :accused_people_for_intentional_crimes_of_same_nature,
      'Obžalovaných osôb - recidivisti' => :accused_recidivists_only,
      'Recidivisti' => :accused_recidivists_only,
      'Obžalovaných osôb - iné návykové látky' => :accused_substance_abuse,
      'Obžalovaných osôb - vplyv inej návykovej látky' => :accused_substance_abuse,
      'Vplyv inej návykovej látky' => :accused_substance_abuse,
      'Obžalovaných osôb - z toho ženy' => :accused_women,
      'Obžalovaných osôb - ženy' => :accused_women,
      'Vplyv alkoholu' => :accused_alcohol_abuse,
      'Podmienečné zastavenie TS' => :conditional_cessation_by_prosecutor,
      'Podmienečné zastavenie tr. stíhania' => :conditional_cessation_by_prosecutor,
      'Podmienečné zastavenie TS - spolupracujúcich osôb' =>
        :conditional_cessation_of_cooperating_accused_by_prosecutor,
      'Podmienečné zastavenie TS - spolupracujúcich obvinených' =>
        :conditional_cessation_of_cooperating_accused_by_prosecutor,
      'Podmienečné zastavenie tr. stíhania - spolupracujúcich osôb' =>
        :conditional_cessation_of_cooperating_accused_by_prosecutor,
      'Dohoda o vine a treste' => :guilt_and_sentence_agreement,
      'Odstíhané známe osoby - vplyv alkoholu' => :prosecuted_alcohol_abuse,
      'Odstíhané známe osoby' => :prosecuted_all,
      'Odstíhané známe osoby - muži' => :prosecuted_men,
      'Odstíhané známe osoby - vplyv inej návykovej látky' => :prosecuted_substance_abuse,
      'Odstíhané známe osoby - ženy' => :prosecuted_women,
      'Odstíhané známe osoby - mladiství' => :prosecuted_young,
      'Rozhodnutie o schválení zmieru a zastavení trestného stíhania' => :reconciliation_approval,
      'Schválenie zmieru' => :reconciliation_approval,
      'Schválenie zmieru a zastavenie TS prokurátorom' => :reconciliation_approval,
      'Oslobodených osôb' => :exemption,
      'Ukončené tr. stíhanie osôb' => :prosecuted_all,
      'Ukončené tr. stíhanie osôb - ženy' => :prosecuted_women,
      'Ukončené tr. stíhanie osôb - mladiství' => :prosecuted_young,
      'Ukončené tr. stíhanie osôb - vplyv alkoholu' => :prosecuted_alcohol_abuse,
      'Ukončené tr. stíhanie osôb - iné návykové látky' => :prosecuted_substance_abuse,
      'Z toho právnické osoby' => :prosecuted_legal_entities,
      'Z toho fyzické osoby' => :prosecuted_natural_persons,
      'Z toho dospelí' => :prosecuted_adults_all,
      '- Dospelí muži' => :prosecuted_adult_men,
      '- Dospelé ženy' => :prosecuted_adult_women,
      'Z toho dospelí - Dospelí muži' => :prosecuted_adult_men,
      'Z toho dospelí - Dospelé ženy' => :prosecuted_adult_women,
      'Z toho mladiství' => :prosecuted_young,
      '- Mladiství chlapci' => :prosecuted_young_boys,
      '- Mladistvé dievčatá' => :prosecuted_young_girls,
      'Z toho mladiství - Mladiství chlapci' => :prosecuted_young_boys,
      'Z toho mladiství - Mladistvé dievčatá' => :prosecuted_young_girls,
      'Cudzinci' => :prosecuted_foreigners,
      'Počet útokov pri tr. činoch' => :prosecuted_attacks_count,
      'Odstíhané známe osoby - počet útokov pri tr. činoch' => :prosecuted_attacks_count,
      'Obžalovaných osôb - počet útokov pri tr. činoch' => :accused_attacks_count,
      'Vek 14' => :accused_age_14_all,
      '- dievčatá' => :accused_age_14_girls,
      'Vek 14 - dievčatá' => :accused_age_14_girls,
      'Vek 15 - 17' => :accused_age_15_to_17_all,
      'Vek 15 - 17 - dievčatá' => :accused_age_15_to_17_girls,
      'Vek 18 - 21' => :accused_age_18_to_21_all
    }

    PARAGRAPHS_BY_CONVICTED_MAP = {
      'Súdených osôb' => :judged_all,
      'Oslobodených osôb' => :exempt_all,
      'Odsúdených osôb' => :convicted_all,
      'Odsúdených osôb - muži' => :convicted_men,
      'Odsúdených osôb - ženy' => :convicted_women,
      'Odsúdených osôb - mladiství' => :convicted_young,
      'Z toho právnické osoby' => :convicted_legal_entities,
      'Z toho fyzické osoby' => :convicted_natural_persons,
      'Z toho dospelí' => :convicted_adults_all,
      '- Dospelí muži' => :convicted_adult_men,
      '- Dospelé ženy' => :convicted_adult_women,
      'Z toho dospelí - Dospelí muži' => :convicted_adult_men,
      'Z toho dospelí - Dospelé ženy' => :convicted_adult_women,
      'Z toho mladiství' => :convicted_young,
      '- Mladiství chlapci' => :convicted_young_boys,
      '- Mladistvé dievčatá' => :convicted_young_girls,
      'Z toho mladiství - Mladiství chlapci' => :convicted_young_boys,
      'Z toho mladiství - Mladistvé dievčatá' => :convicted_young_girls,
      'Cudzinci' => :convicted_foreigners,
      'Tresty OS podľa §47/2 T.z.' => :sentence_by_os_47_2_tz,
      'Trest - Peňažný' => :sentence_financial,
      'Tresty NEPO' => :sentence_nepo,
      'Tresty povinnej práce' => :sentence_of_compulsary_labor,
      'Tresty prepadnutia veci' => :sentence_of_forfeiture_of_possesion,
      'Tresty prepadnutia majetku' => :sentence_of_forfeiture_of_property,
      'Iné tresty' => :sentence_other,
      'Tresty PO' => :sentence_po,
      'Trest - Zákaz pohybu' => :sentence_prohibition_of_movement,
      'Trest - Zákaz činnosti' => :sentence_prohibition_of_practice,
      'Trest - Zákaz pobytu' => :sentence_prohibition_of_stay,
      'Tresty domáceho väzenia' => :sentence_under_home_arrest,
      'Tresty upustené' => :sentence_waived,
      'Tresty vyhostenia' => :sentence_of_deportation,
      'Uložené ochranné opatrenia' => :protective_measures_imposed,
      'Počet schval. dohôd o vine a trest' => :valid_court_decision_only_convicted_with_guilt_and_sentence_agreement,
      'Počet schválených dohôd o vine a treste' =>
        :valid_court_decision_only_convicted_with_guilt_and_sentence_agreement,
      'Počet podmienečne zastavených TS' => :valid_court_decision_on_conditional_cessation_of_prosecution,
      'Počet podmienečne zastavených TS spoluprac. obvineného' =>
        :valid_court_decision_on_conditional_cessation_of_prosecution_of_cooperating_accused,
      'Počet podmienečne zastavených TS -TS spoluprac. obvineného' =>
        :valid_court_decision_on_conditional_cessation_of_prosecution_of_cooperating_accused,
      'Počet schválených zmierov' => :valid_court_decision_on_reconciliation_approval,
      'Počet zastavených TS' => :valid_court_decision_on_cessation_of_prosecution,
      'Počet zastavených' => :valid_court_decision_on_cessation_of_prosecution,
      'Počet prerušených' => :valid_court_decision_on_suspension_of_prosecution,
      'Počet prerušených TS' => :valid_court_decision_on_suspension_of_prosecution,
      'Počet postúpených' => :valid_court_decision_on_assignation_of_prosecution,
      'Počet oslobodených osôb' => :valid_court_decision_on_exemption,
      'Počet upustení od potrestania' => :valid_court_decision_on_waiver_of_sentence,
      'Počet inak skončených' => :valid_other_court_decision
    }
  end
end
