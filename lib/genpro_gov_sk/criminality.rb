module GenproGovSk
  module Criminality
    def self.import
      urls = %w[
        https://www.genpro.gov.sk/extdoc/54953/Struktura%20kriminality%20a%20stihanych%20a%20obzalovanych%20osob
      ]

      urls.map do |url|
        FileDownloader.download(url) do |path|
          Parser.parse(File.read(path, encoding: 'Windows-1250').force_encoding('UTF-8'))
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
  end
end
