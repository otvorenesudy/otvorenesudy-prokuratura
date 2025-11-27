require 'rails_helper'

RSpec.describe 'GenproGovSk::Criminality', type: :feature do
  it 'correctly imports and parses data', webmock: :disabled do
    GenproGovSk::Offices.import

    structure_urls = %w[
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

    structures_data = GenproGovSk::Criminality.parse_structures(structure_urls)
    structure_validations = []

    structures_data
      .group_by { |s| s[:year] }
      .each do |year, entries|
        all_stats =
          entries.flat_map do |entry|
            entry[:statistics]
              .select { |s| s[:count].present? && s[:count] > 0 }
              .map { |s| s.merge(office: entry[:office], year: entry[:year].to_i) }
          end

        structure_validations.concat(all_stats.sample(2, random: Random.new(year.to_i)))
      end

    paragraphs_path = Rails.root.join('data', 'genpro_gov_sk', 'criminality', 'paragraphs', '*.xls*')
    all_paragraph_files = Dir.glob(paragraphs_path).to_a.reject { |e| e.match(/obvod/) }
    selected_paragraph_files = all_paragraph_files.sample(10, random: Random.new(42))

    paragraphs_data = GenproGovSk::Criminality.parse_paragraphs(selected_paragraph_files)
    paragraph_validations = []

    paragraphs_data.compact.each do |entry|
      stats_with_count =
        entry[:statistics]
          .select { |s| s[:count].present? && s[:count] > 0 }
          .map { |s| s.merge(office: entry[:office], year: entry[:year].to_i) }

      paragraph_validations.concat(stats_with_count.sample(2, random: Random.new(entry[:year].to_i)))
    end

    GenproGovSk::Criminality.import(structure_urls: structure_urls, paragraph_paths: selected_paragraph_files)

    structure_validations.each do |attributes|
      office = Office.find_by(name: attributes[:office])

      expect(
        Statistic.find_by(
          year: attributes[:year],
          office_id: office.id,
          metric: attributes[:metric].to_s,
          count: attributes[:count]
        )
      ).to be_present,
      "Structure validation failed for: #{attributes.inspect}"
    end

    paragraph_validations.each do |attributes|
      office = Office.find_by(name: attributes[:office])

      expect(
        Statistic.find_by(
          year: attributes[:year],
          office_id: office.id,
          metric: attributes[:metric].to_s,
          paragraph: attributes[:paragraph],
          count: attributes[:count]
        )
      ).to be_present,
      "Paragraph validation failed for: #{attributes.inspect}"
    end
  end
end
