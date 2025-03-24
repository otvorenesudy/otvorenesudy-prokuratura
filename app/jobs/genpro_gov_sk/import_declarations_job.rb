module GenproGovSk
  class ImportDeclarationsJob < ApplicationJob
    queue_as :default

    OFFICES_MAP = {
      'OPBN' => 'Okresná prokuratúra Bánovce nad Bebravou',
      'OPVK' => 'Okresná prokuratúra Veľký Krtíš',
      'OPBJ' => 'Okresná prokuratúra Bardejov',
      'OPNM' => 'Okresná prokuratúra Nové Mesto nad Váhom',
      'OPRV' => 'Okresná prokuratúra Rožňava',
      'OPBB' => 'Okresná prokuratúra Banská Bystrica',
      'OPLM' => 'Okresná prokuratúra Liptovský Mikuláš',
      'OPRK' => 'Okresná prokuratúra Ružomberok',
      'OPNO' => 'Okresná prokuratúra Námestovo',
      'OPPN' => 'Okresná prokuratúra Piešťany',
      'OKO' => 'Okresná Organizácia',
      'GP' => 'Generálna prokuratúra Slovenskej republiky',
      'OPBA4' => 'Okresná prokuratúra Bratislava IV',
      'OPBR' => 'Okresná prokuratúra Brezno',
      'OPPP' => 'Okresná prokuratúra Poprad',
      'KPKE' => 'Krajská prokuratúra v Košiciach',
      'OPKE2' => 'Okresná prokuratúra Košice II',
      'KPTN' => 'Krajská prokuratúra v Trenčíne',
      'OPTO' => 'Okresná prokuratúra Topoľčany',
      'OPBA3' => 'Okresná prokuratúra Bratislava III',
      'KPPO' => 'Krajská prokuratúra v Prešove',
      'OPSI' => 'Okresná prokuratúra Skalica',
      'OPTN' => 'Okresná prokuratúra Trenčín',
      'OPPD' => 'Okresná prokuratúra Prievidza',
      'OPRA' => 'Okresná prokuratúra Revúca',
      'OPRS' => 'Okresná prokuratúra Rimavská Sobota',
      'OPKN' => 'Okresná prokuratúra Komárno',
      'OPBA2' => 'Okresná prokuratúra Bratislava II',
      'OPNR' => 'Okresná prokuratúra Nitra',
      'OPZV' => 'Okresná prokuratúra Zvolen',
      'OPDK' => 'Okresná prokuratúra Dolný Kubín',
      'OPMT' => 'Okresná prokuratúra Martin',
      'KPBB' => 'Krajská prokuratúra v Banskej Bystrici',
      'OPZH' => 'Okresná prokuratúra Žiar nad Hronom',
      'OPSN' => 'Okresná prokuratúra Spišská Nová Ves',
      'OPSK' => 'Okresná prokuratúra Svidník',
      'OPPK' => 'Okresná prokuratúra Pezinok',
      'OPPO' => 'Okresná prokuratúra Prešov',
      'OPDS' => 'Okresná prokuratúra Dunajská Streda',
      'OPTT' => 'Okresná prokuratúra Trnava',
      'KPTT' => 'Krajská prokuratúra v Trnave',
      'OPMI' => 'Okresná prokuratúra Michalovce',
      'OPNZ' => 'Okresná prokuratúra Nové Zámky',
      'OPGA' => 'Okresná prokuratúra Galanta',
      'OPLV' => 'Okresná prokuratúra Levice',
      'OPCA' => 'Okresná prokuratúra Čadca',
      'OPZA' => 'Okresná prokuratúra Žilina',
      'OPHN' => 'Okresná prokuratúra Humenné',
      'OPKK' => 'Okresná prokuratúra Kežmarok',
      'KPNR' => 'Krajská prokuratúra v Nitre',
      'OPTV' => 'Okresná prokuratúra Trebišov',
      'OPKE1' => 'Okresná prokuratúra Košice I',
      'USPGP' => 'Úrad špeciálnej prokuratúry',
      'OPMA' => 'Okresná prokuratúra Malacky',
      'OPPE' => 'Okresná prokuratúra Partizánske',
      'OPBA1' => 'Okresná prokuratúra Bratislava I',
      'KPBA' => 'Krajská prokuratúra v Bratislave',
      'OPSE' => 'Okresná prokuratúra Senica',
      'OPKS' => 'Okresná prokuratúra Košice - okolie',
      'OPBA5' => 'Okresná prokuratúra Bratislava V',
      'KPZA' => 'Krajská prokuratúra v Žiline',
      'OPSL' => 'Okresná prokuratúra Stará Ľubovňa',
      'OPPB' => 'Okresná prokuratúra Považská Bystrica',
      'OPVT' => 'Okresná prokuratúra Vranov nad Topľou',
      'OPLC' => 'Okresná prokuratúra Lučenec',
      'EPPO' => 'Úrad Európskej prokuratúry',
      'MOGP' => 'MOGP'
    }.freeze

    def perform(url)
      content = Nokogiri.HTML(Curl.get(url).body_str)

      content.css('.govuk-table__row')[1..-1].each do |row|
        name =
          "#{row.css('td')[1].text.strip} #{row.css('td')[0].text.strip}"
            .gsub(/[;]/, '')
            .gsub(/[[:space:]]+/, ' ')
            .titleize

        office = OFFICES_MAP[row.css('td')[2].text.strip] || OFFICES_MAP[row.css('td')[3].text.strip]
        url = "https://www.genpro.gov.sk/#{row.css('td')[0].css('a')[0]['href']}"
        html = Curl.get(url).body_str

        declaration = GenproGovSk::Declarations::Parser.parse(html)

        GenproGovSk::Declaration.import_from(
          data: declaration.merge(name: name, office: office.presence, url: url),
          file: html
        )
      end
    end
  end
end
