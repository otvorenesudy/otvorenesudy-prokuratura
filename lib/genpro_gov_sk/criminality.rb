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
          Parser.parse(File.read(path, encoding: 'Windows-1250').force_encoding('UTF-8'))
        end
      end.flatten
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
      'V trestných registroch Pv/Kv/Gv napadlo spisov' => :incoming_cases,
      'V trestných registroch Pv/Kv/Gv bolo vybavených spisov' => :closed_cases,
      'Počet známych odstíhaných osôb (na prokuratúre skončené)' => :known_closed_prosecuted_people,
      'Počet stíhaných známych osôb (na prokuratúre skončené)' => :known_closed_prosecuted_people,
      'Počet obžalovaných osôb' => :prosecuted_people,
      'Obžalovaní recidivisti' => :prosecuted_recidivists,
      'Skladba odstíhaných osôb muži' => :men,
      'Skladba odstíhaných osôb ženy' => :women,
      'Skladba odstíhaných osôb mladiství' => :young,
      'Skladba odstíhaných osôb cudzinci' => :foreigners,
      'Skladba odstíhaných osôb vplyv alkoholu' => :alcohol_abuse,
      'Skladba odstíhaných osôb vplyv inej návykovej látky' => :substance_abuse,
      'Skladba stíhaných osôb muži' => :men,
      'Skladba stíhaných osôb ženy' => :women,
      'Skladba stíhaných osôb mladiství' => :young,
      'Skladba stíhaných osôb cudzinci' => :foreigners,
      'Skladba stíhaných osôb vplyv alkoholu' => :alcohol_abuse,
      'Skladba stíhaných osôb vplyv inej návykovej látky' => :substance_abuse,
      'Podmienečné zastavenie TS prokurátorom - spolu z toho obvineného' =>
        :conditional_cessation_of_accused_by_prosecutor,
      'Podmienečné zastavenie TS prokurátorom - spolu z toho spolupracujúceho obvineného' =>
        :conditional_cessation_of_cooperating_accused_by_prosecutor,
      'Podmienečné zastavenie TS - osvedčil sa - spolu z toho osvedčil sa obvinený' =>
        :conditional_cessation_of_accused,
      'Podmienečné zastavenie TS - osvedčil sa - spolu z toho osvedčil sa spolupracujúci obvinený' =>
        :conditional_cessation_of_cooperating_accused,
      'Schválenie zmieru' => :reconciliation_approval,
      'Dohoda o vine a treste odoslaná na súd' => :guilt_and_punishment_aggreement,
      'Dohoda o vine a treste' => :guilt_and_punishment_aggreement,
      'Zastavenie trestného stíhania' => :cessation_of_prosecution,
      'Zastavené trestné stíhanie' => :cessation_of_prosecution,
      'Prerušenie trestného stíhania' => :suspension_of_prosecution,
      'Prerušené trestné stíhanie' => :suspension_of_prosecution,
      'Prerušenie trestného stíhania spolupracujúceho obvineného' => :suspension_of_prosecution_of_cooperating_accused,
      'Postúpené trestné stíhanie' => :assignation_of_prosuction,
      'Postúpenie trestného stíhania' => :assignation_of_prosuction,
      'Právoplatné rozhodnutia súdu – spolu o odsúdení osôb' => :valid_court_decision_on_conviction_of_people,
      'Právoplatné rozhodnutia súdu – spolu z odsúdených len schválenie dohody o vine a treste' =>
        :valid_court_decision_only_convicted_with_guilt_and_punishment_aggreement,
      'Právoplatné rozhodnutia súdu – spolu schválenie zmieru' => :valid_court_decision_on_reconciliation_approval,
      'Počet oznámení súdu o odsúdení osôb' => :valid_court_decision_on_conviction_of_people,
      'Počet oznámení súdu o schválení dohody o vine a treste' =>
        :valid_court_decision_only_convicted_with_guilt_and_punishment_aggreement,
      'Počet oznámení súdu o schválení zmieru' => :valid_court_decision_on_reconciliation_approval,
      'Právoplatné rozhodnutia súdu – spolu zastavenie TS' => :valid_court_decision_on_cessation_of_prosecution,
      'Právoplatné rozhodnutia súdu – spolu postúpenie TS' => :valid_court_decision_on_assignation_of_prosecution,
      'Právoplatné rozhodnutia súdu – spolu oslobodenie' => :valid_court_decision_on_exemption,
      'Právoplatné rozhodnutia súdu – spolu upustenie od potrestania' => :valid_court_decision_on_waiver_of_punishment,
      'Právoplatné rozhodnutia súdu – spolu rozhodnutie "inak"' => :valid_other_court_decision,
      'Počet trestných stíhaní ukončených na polícii – neznámi páchatelia zastavením' =>
        :prosecution_of_unknown_offender_ended_by_police_by_cessation,
      'Počet trestných stíhaní ukončených na polícii – neznámi páchatelia prerušením' =>
        :prosecution_of_unknown_offender_ended_by_police_by_suspension,
      'Počet trestných stíhaní ukončených na polícii – neznámi páchatelia postúpením' =>
        :prosecution_of_unknown_offender_ended_by_police_by_assignation,
      'Počet trestných stíhaní ukončených na polícii – neznámi páchatelia inak' =>
        :prosecution_of_unknown_offender_ended_by_police_by_other_mean
    }
  end
end
