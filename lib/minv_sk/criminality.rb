require 'minv_sk/criminality/parser'

module MinvSk
  module Criminality
    def self.import
      links = %w[
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_1997/statistika_podla_paragrafov_3_31.12.1997.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_1998/3csv_statistika_podla_paragrafov_31.12.1998.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_1999/3csv_statistika_podla_paragrafov_31.12.1999.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_2000/3csv_statistika_podla_paragrafov_31.12.2000.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_2001/3csv_statistika_podla_paragrafov_31.12.2001.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_2002/3csv_statistika_podla_paragrafov_31.12.2002.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_2003/3csv_statistika_podla_paragrafov_31.12.2003.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_2004/3csv_statistika_podla_paragrafov_31.12.2004.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_2005/3csv_statistika_podla_paragrafov_31.12.2005.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_2006/3csv_statistika_podla_paragrafov_31.12.2006.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_2007/3csv_statistika_podla_paragrafov_31.12.2007.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/rok_2008/3csv_statistika_podla_paragrafov_31.12.2008.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/12_12/3csv_statistika_podla_paragrafov_31.12.2012.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/2013/12_december/3_statistika_podla_paragrafov_3_31.12.2013.csv
        https://www.minv.sk/swift_data/source/policia/statistiky/2014/12_december/3csv_statistika_podla_paragrafov_3_31.12.2014.csv
        https://www.minv.sk/swift_data/source/policia/statistiky_2015/december/csv3_statistika_podla_paragrafov_3_31.12.2015.csv
        https://www.minv.sk/swift_data/source/policia/statistiky_2016/12_december/csv3_statistika_podla_paragrafov_3_31.12.2016.csv
        https://www.minv.sk/swift_data/source/policia/statistiky_2017/12_december/csv3_statistika_podla_paragrafov_3_31.12.2017.csv
        https://www.minv.sk/swift_data/source/policia/statistiky_2018/12_december/3_csv_statistika_podla_paragrafov_3_31.12.2018.csv
        https://www.minv.sk/swift_data/source/policia/statistiky_2019/12_december/3csv_statistika_podla_paragrafov_3_31.12.2019.csv
        https://www.minv.sk/swift_data/source/policia/statistiky_2020/12_december/3csv_statistika_podla_paragrafov_3_31.12.2020.csv
        https://www.minv.sk/swift_data/source/policia/statistiky_2021/12_december/3csv_statistika_podla_paragrafov_3_31.12.2021.csv
        https://www.minv.sk/swift_data/source/policia/statistiky_2022/12_december/3csv_statistika_podla_paragrafov_3_31.12.2022.csv
      ]

      statistics =
        links
          .map do |link|
            csv = Curl.get(link).body_str
            data = Parser.parse(csv)

            data.select { |e| e[:count].present? }
          end
          .flatten

      ::Crime.import_from(statistics)
    end

    CRIME_MAP = {
      'Zistené' => :crime_discovered,
      'Objasnené' => :crime_solved,
      'Dodatoč. objasnené' => :crime_additionally_solved,
      'Spôsob. škoda' => :crime_denominated_damage,
      'Vplyv alkoholu' => :crime_alcohol_abuse,
      'Vplyv drog' => :crime_drug_abuse,
      'Maloletý páchateľ' => :crime_underage_offender,
      'Maloletý - alkohol' => :crime_underage_offender_alcohol_abuse,
      'Maloletý - drogy' => :crime_underage_offender_drug_abuse,
      'Mladistvý páchateľ' => :crime_adolescent_offender,
      'Mladistvý - alkohol' => :crime_adolescent_offender_alcohol_abuse,
      'Mladistvý - drogy' => :crime_adolescent_offender_drug_abuse
    }.freeze

    PERSONS_MAP = {
      'Celkom osôb' => :persons_all,
      'Vplyv alkoholu' => :persons_alcohol_abuse,
      'Vplyv drog' => :persons_drug_abuse,
      'Maloletý páchateľ' => :persons_underage_offender,
      'Maloletý - alkohol' => :persons_underage_offender_alcohol_abuse,
      'Maloletý - drogy' => :persons_underage_offender_drug_abuse,
      'Mladistvý páchateľ' => :persons_adolescent_offender,
      'Mladistvý - alkohol' => :persons_adolescent_offender_alcohol_abuse,
      'Mladistvý - drogy' => :persons_adolescent_offender_drug_abuse
    }.freeze
  end
end
