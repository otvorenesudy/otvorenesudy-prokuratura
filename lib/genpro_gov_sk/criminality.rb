module GenproGovSk
  module Criminality
    def self.import_structures
      urls = %w[
        https://www.genpro.gov.sk/extdoc/54953/Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
        https://www.genpro.gov.sk/extdoc/54820/Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
        https://www.genpro.gov.sk/extdoc/54483/2018_Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
        https://www.genpro.gov.sk/extdoc/54488/2017_Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
        https://www.genpro.gov.sk/extdoc/54487/2016_Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
        https://www.genpro.gov.sk/extdoc/54486/2015_Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
        https://www.genpro.gov.sk/extdoc/54485/2014_Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
        https://www.genpro.gov.sk/extdoc/54395/2013_Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
        https://www.genpro.gov.sk/extdoc/54394/2012_Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
        https://www.genpro.gov.sk/extdoc/54393/2011_Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
        https://www.genpro.gov.sk/extdoc/54392/2010_Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
      ]

      urls.map do |url|
        FileDownloader.download(url) do |path|
          StructureParser.parse(File.read(path, encoding: 'Windows-1250').force_encoding('UTF-8'))
        end
      end.flatten
    end

    def self.import_paragraphs
      path = Rails.root.join('data', 'genpro_gov_sk', 'criminality', 'paragraphs', '*.xls*')
      files = Dir.glob(path).to_a

      ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS genpro_gov_sk_paragraphs')
      ActiveRecord::Base.connection.execute('CREATE TABLE genpro_gov_sk_paragraphs (data jsonb)')

      Parallel.each(files, in_processes: 12) do |file|
        result = ParagraphsParser.parse(file)

        result[:file] = file

        ActiveRecord::Base.connection.execute("INSERT INTO genpro_gov_sk_paragraphs VALUES ('#{result.to_json}')")
      end

      data =
        ActiveRecord::Base.connection.execute('SELECT data FROM genpro_gov_sk_paragraphs').to_a.map do |e|
          JSON.parse(e['data'])
        end

      ActiveRecord::Base.connection.execute('DROP TABLE genpro_gov_sk_paragraphs')

      data
    end

    def self.paragraphs_map
      @paragraphs_map ||=
        %i[new old].each.with_object({ new: {}, old: {} }) do |key, hash|
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
              paragraph_name:
                (
                  begin
                    row[3].downcase.capitalize
                  rescue StandardError
                    binding.pry
                  end
                )
            }
          end
        end
    end

    OFFICES_MAP = {
      '1000' => 'Generálna prokuratúra Slovenskej republiky',
      '1100' => 'Krajská prokuratúra Bratislava',
      '1101' => 'Okresná prokuratúra Bratislava I',
      '1102' => 'Okresná prokuratúra Bratislava II',
      '1103' => 'Okresná prokuratúra Bratislava III',
      '1104' => 'Okresná prokuratúra Bratislava IV',
      '1105' => 'Okresná prokuratúra Bratislava V',
      '1106' => 'Okresná prokuratúra Malacky',
      '1107' => 'Okresná prokuratúra Pezinok',
      'KP BA' => 'Krajská prokuratúra Bratislava',
      '2200' => 'Krajská prokuratúra Trnava',
      '2201' => 'Okresná prokuratúra Dunajská Streda',
      '2202' => 'Okresná prokuratúra Galanta',
      '2204' => 'Okresná prokuratúra Piešťany',
      '2205' => 'Okresná prokuratúra Senica',
      '2206' => 'Okresná prokuratúra Skalica',
      '2207' => 'Okresná prokuratúra Trnava',
      'KP TT' => 'Krajská prokuratúra Trnava',
      '3300' => 'Krajská prokuratúra Trenčín',
      '3301' => 'Okresná prokuratúra Bánovce nad Bebravou',
      '3304' => 'Okresná prokuratúra Nové Mesto nad Váhom',
      '3305' => 'Okresná prokuratúra Partizánske',
      '3306' => 'Okresná prokuratúra Považská Bystrica',
      '3307' => 'Okresná prokuratúra Prievidza',
      '3309' => 'Okresná prokuratúra Trenčín',
      'KP TN' => 'Krajská prokuratúra Trenčín',
      '4400' => 'Krajská prokuratúra Nitra',
      '4401' => 'Okresná prokuratúra Komárno',
      '4402' => 'Okresná prokuratúra Levice',
      '4403' => 'Okresná prokuratúra Nitra',
      '4404' => 'Okresná prokuratúra Nové Zámky',
      '4406' => 'Okresná prokuratúra Topoľčany',
      'KP NR' => 'Krajská prokuratúra Nitra',
      '5500' => 'Krajská prokuratúra Žilina',
      '5502' => 'Okresná prokuratúra Čadca',
      '5503' => 'Okresná prokuratúra Dolný Kubín',
      '5505' => 'Okresná prokuratúra Liptovský Mikuláš',
      '5506' => 'Okresná prokuratúra Martin',
      '5507' => 'Okresná prokuratúra Námestovo',
      '5508' => 'Okresná prokuratúra Ružomberok',
      '5511' => 'Okresná prokuratúra Žilina',
      'KP ZA' => 'Krajská prokuratúra Žilina',
      '6600' => 'Krajská prokuratúra Banská Bystrica',
      '6601' => 'Okresná prokuratúra Banská Bystrica',
      '6603' => 'Okresná prokuratúra Brezno',
      '6606' => 'Okresná prokuratúra Lučenec',
      '6608' => 'Okresná prokuratúra Revúca',
      '6609' => 'Okresná prokuratúra Rimavská Sobota',
      '6610' => 'Okresná prokuratúra Veľký Krtíš',
      '6611' => 'Okresná prokuratúra Zvolen',
      '6613' => 'Okresná prokuratúra Žiar nad Hronom',
      'KP BB' => 'Krajská prokuratúra Banská Bystrica',
      '7700' => 'Krajská prokuratúra Prešov',
      '7701' => 'Okresná prokuratúra Bardejov',
      '7702' => 'Okresná prokuratúra Humenné',
      '7703' => 'Okresná prokuratúra Kežmarok',
      '7706' => 'Okresná prokuratúra Poprad',
      '7707' => 'Okresná prokuratúra Prešov',
      '7710' => 'Okresná prokuratúra Stará Ľubovňa',
      '7712' => 'Okresná prokuratúra Svidník',
      '7713' => 'Okresná prokuratúra Vranov nad Topľou',
      'KP PO' => 'Krajská prokuratúra Prešov',
      '8800' => 'Krajská prokuratúra Košice',
      '8802' => 'Okresná prokuratúra Košice I',
      '8803' => 'Okresná prokuratúra Košice II',
      '8806' => 'Okresná prokuratúra Košice - okolie',
      '8807' => 'Okresná prokuratúra Michalovce',
      '8808' => 'Okresná prokuratúra Rožňava',
      '8810' => 'Okresná prokuratúra Spišská Nová Ves',
      '8811' => 'Okresná prokuratúra Trebišov',
      'KP KE' => 'Krajská prokuratúra Košice'
    }

    STRUCTURES_MAP = {
      'Obžalovaní recidivisti' => :acccused_recidivists,
      'Počet obžalovaných osôb' => :accused_people,
      'Postúpenie trestného stíhania' => :assignation_of_prosuction,
      'Postúpené trestné stíhanie' => :assignation_of_prosuction,
      'Zastavené trestné stíhanie' => :cessation_of_prosecution,
      'Zastavenie trestného stíhania' => :cessation_of_prosecution,
      'V trestných registroch Pv/Kv/Gv bolo vybavených spisov' => :closed_cases,
      'Podmienečné zastavenie TS súdom' => :conditional_cessation_by_court,
      'Podmienečné zastavenie TS prokurátorom' => :conditional_cessation_by_prosecutor,
      'Podmienečné zastavenie TS - osvedčil sa - spolu z toho osvedčil sa obvinený' =>
        :conditional_cessation_of_accused_and_proven,
      'Podmienečné zastavenie TS prokurátorom - osvedčil sa' =>
        :conditional_cessation_of_accused_and_proven_by_prosecutor,
      'Podmienečné zastavenie TS prokurátorom - spolu z toho obvineného' =>
        :conditional_cessation_of_accused_by_prosecutor,
      'Podmienečné zastavenie TS - osvedčil sa - spolu z toho osvedčil sa spolupracujúci obvinený' =>
        :conditional_cessation_of_cooperating_accused_and_proven,
      'Podmienečné zastavenie TS prokurátorom - spolu z toho spolupracujúceho obvineného' =>
        :conditional_cessation_of_cooperating_accused_by_prosecutor,
      'Podmienečné zastavenie TS spolupracujúceho obvineného prokurátorom' =>
        :conditional_cessation_of_cooperating_accused_by_prosecutor,
      'Dohoda o vine a treste' => :guilt_and_punishment_aggreement,
      'Dohoda o vine a treste odoslaná na súd' => :guilt_and_punishment_aggreement,
      'V trestných registroch Pv/Kv/Gv napadlo spisov' => :incoming_cases,
      'Počet stíhaných známych osôb (na prokuratúre skončené)' => :known_closed_prosecuted_people,
      'Počet známych odstíhaných osôb (na prokuratúre skončené)' => :known_closed_prosecuted_people,
      'Skladba odstíhaných osôb vplyv alkoholu' => :prosecuted_alcohol_abuse,
      'Skladba stíhaných osôb vplyv alkoholu' => :prosecuted_alcohol_abuse,
      'Skladba odstíhaných osôb cudzinci' => :prosecuted_foreigners,
      'Skladba stíhaných osôb cudzinci' => :prosecuted_foreigners,
      'Skladba stíhaných osôb muži' => :prosecuted_men,
      'Skladba odstíhaných osôb muži' => :prosecuted_men,
      'Skladba odstíhaných osôb vplyv inej návykovej látky' => :prosecuted_substance_abuse,
      'Skladba stíhaných osôb vplyv inej návykovej látky' => :prosecuted_substance_abuse,
      'Skladba stíhaných osôb ženy' => :prosecuted_women,
      'Skladba odstíhaných osôb ženy' => :prosecuted_women,
      'Skladba odstíhaných osôb mladiství' => :prosecuted_young,
      'Skladba stíhaných osôb mladiství' => :prosecuted_young,
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
      'Právoplatné rozhodnutia súdu – spolu postúpenie TS' => :valid_court_decision_on_assignation_of_prosecution,
      'Právoplatné rozhodnutia súdu – spolu zastavenie TS' => :valid_court_decision_on_cessation_of_prosecution,
      'Právoplatné rozhodnutia súdu – spolu o odsúdení osôb' => :valid_court_decision_on_conviction_of_people,
      'Počet oznámení súdu o odsúdení osôb' => :valid_court_decision_on_conviction_of_people,
      'Počet oznámení o odsúdení osôb' => :valid_court_decision_on_conviction_of_people,
      'Právoplatné rozhodnutia súdu – spolu oslobodenie' => :valid_court_decision_on_exemption,
      'Právoplatné rozhodnutia súdu – spolu schválenie zmieru' => :valid_court_decision_on_reconciliation_approval,
      'Počet oznámení súdu o schválení zmieru' => :valid_court_decision_on_reconciliation_approval,
      'Právoplatné rozhodnutia súdu – spolu upustenie od potrestania' => :valid_court_decision_on_waiver_of_punishment,
      'Počet oznámení súdu o schválení dohody o vine a treste' =>
        :valid_court_decision_only_convicted_with_guilt_and_punishment_aggreement,
      'Právoplatné rozhodnutia súdu – spolu z odsúdených len schválenie dohody o vine a treste' =>
        :valid_court_decision_only_convicted_with_guilt_and_punishment_aggreement,
      'Počet oznámení o schválení dohody o vine a treste súdom' =>
        :valid_court_decision_only_convicted_with_guilt_and_punishment_aggreement,
      "Právoplatné rozhodnutia súdu – spolu rozhodnutie \"inak\"" => :valid_other_court_decision
    }

    PARAGRAPHS_MAP = {
      'Vek 14 - 15' => :accused_age_14_to_15,
      'Obžalovaných osôb - vek 14 - 15' => :accused_age_14_to_15,
      'Vek 14 - 15 - dievčatá' => :accused_age_14_to_15_girls,
      'Vek 16 - 18' => :accused_age_16_to_18,
      'Obžalovaných osôb - vek 16 - 18' => :accused_age_16_to_18,
      'Vek 16 - 18 - dievčatá' => :accused_age_16_to_18,
      'Obžalovaných osôb - vek 19 - 21' => :accused_age_19_to_21,
      'Vek 19 - 21' => :accused_age_19_to_21,
      'Vek 22 - 30' => :accused_age_22_to_30,
      'Obžalovaných osôb - vek 22 - 30' => :accused_age_22_to_30,
      'Obžalovaných osôb - vek 31 - 40' => :accused_age_31_to_40,
      'Vek 31 - 40' => :accused_age_31_to_40,
      'Obžalovaných osôb - vek 41 - 50' => :accused_age_51_to_60,
      'Vek 41 - 50' => :accused_age_51_to_60,
      'Obžalovaných osôb - vek 61 a viac' => :accused_age_61_and_more,
      'Vek 61 a viac' => :accused_age_61_and_more,
      'Obžalovaných osôb - vplyv alkoholu' => :accused_alcohol_abuse,
      'Obžalovaných osôb - obzvlášť nebezpeční recidivisti' => :accused_dangerous_recidivists,
      'Zvlášť nebezpeční recidivisti' => :accused_dangerous_recidivists,
      'Obžalovaných osôb - dievčatá' => :accused_girls,
      'Obžalovaných osôb - z toho muži' => :accused_men,
      'Obžalovaných osôb' => :accused_people,
      'Obžalovaných osôb - počet útokov pri tr. činoch' => :accused_people_for_attacks_in_crimes,
      'Obžalovaných osôb za úmyselné tr. činy' => :accused_people_for_intentional_crimes,
      'Obžalovaných osôb - úmyselné tr. činy' => :accused_people_for_intentional_crimes,
      'Obžalovaných osôb za úmyselné tr. činy - úmyselné tr. činy rovnakého druhu' =>
        :accused_people_for_intentional_crimes_of_same_nature,
      'Obžalovaných osôb - úmyselné tr. činy rovnakého druhu' => :accused_people_for_intentional_crimes_of_same_nature,
      'Obžalovaných osôb - recidivisti' => :accused_recidivists,
      'Recidivisti' => :accused_recidivists,
      'Obžalovaných osôb - iné návykové látky' => :accused_substance_abuse,
      'Obžalovaných osôb - z toho ženy' => :accused_women,
      'Obžalovaných osôb - ženy' => :accused_women,
      'Počet útokov pri tr. činoch' => :amount_of_attacks_in_crimes,
      'Počet postúpených' => :assignation_of_prosuction,
      'Počet zastavených TS' => :cessation_of_prosecution,
      'Počet zastavených' => :cessation_of_prosecution,
      'Počet podmienečne zastavených TS' => :conditional_cessation_by_court,
      'Podmienečné zastavenie TS' => :conditional_cessation_by_court,
      'Podmienečné zastavenie tr. stíhania' => :conditional_cessation_by_court,
      'Podmienečné zastavenie TS - spolupracujúcich obvinených' =>
        :conditional_cessation_of_cooperating_accused_and_proven,
      'Podmienečné zastavenie TS - spolupracujúcich osôb' => :conditional_cessation_of_cooperating_accused_and_proven,
      'Počet podmienečne zastavených TS spoluprac. obvineného' =>
        :conditional_cessation_of_cooperating_accused_and_proven,
      'Počet podmienečne zastavených TS -TS spoluprac. obvineného' =>
        :conditional_cessation_of_cooperating_accused_and_proven,
      'Počet schválených dohôd o vine a treste' => :guilt_and_punishment_aggreement,
      'Počet schval. dohôd o vine a trest' => :guilt_and_punishment_aggreement,
      'Dohoda o vine a treste' => :guilt_and_punishment_aggreement,
      'Ukončené tr. stíhanie osôb' => :known_closed_prosecuted_people,
      'Odstíhané známe osoby - vplyv alkoholu' => :prosecuted_alcohol_abuse,
      'Odstíhané známe osoby' => :prosecuted_all,
      'Odstíhané známe osoby - muži' => :prosecuted_men,
      'Odstíhané známe osoby - počet útokov pri tr. činoch' => :prosecuted_people_for_attacks_in_crimes,
      'Odstíhané známe osoby - vplyv inej návykovej látky' => :prosecuted_substance_abuse,
      'Odstíhané známe osoby - ženy' => :prosecuted_women,
      'Odstíhané známe osoby - mladiství' => :prosecuted_young,
      'Tresty OS podľa §47/2 T.z.' => :punishment_by_os_47_2_tz,
      'Trest - Peňažný' => :punishment_financial,
      'Tresty NEPO' => :punishment_nepo,
      'Tresty povinnej práce' => :punishment_of_compulsary_labor,
      'Tresty prepadnutia veci' => :punishment_of_forfeiture_of_possesion,
      'Tresty prepadnutia majetku' => :punishment_of_forfeiture_of_property,
      'Iné tresty' => :punishment_other,
      'Tresty PO' => :punishment_po,
      'Trest - Zákaz pohybu' => :punishment_prohibition_of_movement,
      'Trest - Zákaz činnosti' => :punishment_prohibition_of_practice,
      'Trest - Zákaz pobytu' => :punishment_prohibition_of_stay,
      'Tresty domáceho väzenia' => :punishment_under_home_arrest,
      'Tresty upustené' => :punishment_waived,
      'Rozhodnutie o schválení zmieru a zastavení trestného stíhania' => :reconciliation_approval,
      'Schválenie zmieru' => :reconciliation_approval,
      'Počet schválených zmierov' => :reconciliation_approval,
      'Odsúdených osôb' => :sentenced_all,
      'Odsúdených osôb - muži' => :sentenced_men,
      'Odsúdených osôb - ženy' => :sentenced_women,
      'Odsúdených osôb - mladiství' => :sentenced_young,
      'Počet prerušených' => :suspension_of_prosecution,
      'Počet prerušených TS' => :suspension_of_prosecution,
      'Oslobodených osôb' => :valid_court_decision_on_exemption,
      'Počet oslobodených osôb' => :valid_court_decision_on_exemption,
      'Počet upustení od potrestania' => :valid_court_decision_on_waiver_of_punishment,
      'Počet inak skončených' => :valid_other_court_decision
    }
  end
end