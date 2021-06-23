module GenproGovSk
  module Declarations
    OFFICES_MAPPER = {
      'Okresná prokuratúra Bánovce nad Bebravou' => 'OPBN',
      'Okresná prokuratúra Veľký Krtíš' => 'OPVK',
      'Okresná prokuratúra Bardejov' => 'OPBJ',
      'Okresná prokuratúra Nové Mesto nad Váhom' => 'OPNM',
      'Okresná prokuratúra Rožňava' => 'OPRV',
      'Okresná prokuratúra Banská Bystrica' => 'OPBB',
      'Okresná prokuratúra Liptovský Mikuláš' => 'OPLM',
      'Okresná prokuratúra Ružomberok' => 'OPRK',
      'Okresná prokuratúra Námestovo' => 'OPNO',
      'Okresná prokuratúra Piešťany' => 'OPPN',
      'Okresná Organizácia' => 'OKO',
      'Generálna prokuratúra Slovenskej republiky' => 'GP',
      'Okresná prokuratúra Bratislava IV' => 'OPBA4',
      'Okresná prokuratúra Brezno' => 'OPBR',
      'Okresná prokuratúra Poprad' => 'OPPP',
      'Krajská prokuratúra Košice' => 'KPKE',
      'Okresná prokuratúra Košice II' => 'OPKE2',
      'Krajská prokuratúra Trenčín' => 'KPTN',
      'Okresná prokuratúra Topoľčany' => 'OPTO',
      'Okresná prokuratúra Bratislava III' => 'OPBA3',
      'Krajská prokuratúra Prešov' => 'KPPO',
      'Okresná prokuratúra Skalica' => 'OPSI',
      'Okresná prokuratúra Trenčín' => 'OPTN',
      'Okresná prokuratúra Prievidza' => 'OPPD',
      'Okresná prokuratúra Revúca' => 'OPRA',
      'Okresná prokuratúra Rimavská Sobota' => 'OPRS',
      'Okresná prokuratúra Komárno' => 'OPKN',
      'Okresná prokuratúra Bratislava II' => 'OPBA2',
      'Okresná prokuratúra Nitra' => 'OPNR',
      'Okresná prokuratúra Zvolen' => 'OPZV',
      'Okresná prokuratúra Dolný Kubín' => 'OPDK',
      'Okresná prokuratúra Martin' => 'OPMT',
      'Krajská prokuratúra Banská Bystrica' => 'KPBB',
      'Okresná prokuratúra Žiar nad Hronom' => 'OPZH',
      'Okresná prokuratúra Spišská Nová Ves' => 'OPSN',
      'Okresná prokuratúra Svidník' => 'OPSK',
      'Okresná prokuratúra Pezinok' => 'OPPK',
      'Okresná prokuratúra Prešov' => 'OPPO',
      'Okresná prokuratúra Dunajská Streda' => 'OPDS',
      'Okresná prokuratúra Trnava' => 'OPTT',
      'Krajská prokuratúra Trnava' => 'KPTT',
      'Okresná prokuratúra Michalovce' => 'OPMI',
      'Okresná prokuratúra Nové Zámky' => 'OPNZ',
      'Okresná prokuratúra Galanta' => 'OPGA',
      'Okresná prokuratúra Levice' => 'OPLV',
      'Okresná prokuratúra Čadca' => 'OPCA',
      'Okresná prokuratúra Žilina' => 'OPZA',
      'Okresná prokuratúra Humenné' => 'OPHN',
      'Okresná prokuratúra Kežmarok' => 'OPKK',
      'Krajská prokuratúra Nitra' => 'KPNR',
      'Okresná prokuratúra Trebišov' => 'OPTV',
      'Okresná prokuratúra Košice I' => 'OPKE1',
      'Úrad špeciálnej prokuratúry' => 'USPGP',
      'Okresná prokuratúra Malacky' => 'OPMA',
      'Okresná prokuratúra Partizánske' => 'OPPE',
      'Okresná prokuratúra Bratislava I' => 'OPBA1',
      'Krajská prokuratúra Bratislava' => 'KPBA',
      'Okresná prokuratúra Senica' => 'OPSE',
      'Okresná prokuratúra Košice - okolie' => 'OPKS',
      'Okresná prokuratúra Bratislava V' => 'OPBA5',
      'Krajská prokuratúra Žilina' => 'KPZA',
      'Okresná prokuratúra Stará Ľubovňa' => 'OPSL',
      'Okresná prokuratúra Považská Bystrica' => 'OPPB',
      'Okresná prokuratúra Vranov nad Topľou' => 'OPVT',
      'Okresná prokuratúra Lučenec' => 'OPLC'
    }

    class Job < ActiveJob::Base
      def perform(prosecutor)
        name = ::Legacy::Normalizer.partition_person_name(prosecutor.name)
        first_name, last_name = name[:first], name.values_at(:middle, :last).compact.join(' ')
        offices = prosecutor.offices.map { |e| OFFICES_MAPPER[e.name] }
        declarations =
          GenproGovSk::Legacy::PropertyDeclarationsCrawler.crawl_for(
            first_name: first_name, last_name: last_name, offices: offices
          )

        prosecutor.update!(declarations: declarations)
      end
    end

    def self.import
      ::Prosecutor.find_each { |prosecutor| Job.perform_later(prosecutor) }
    end
  end
end
