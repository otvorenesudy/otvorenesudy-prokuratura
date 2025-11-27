require 'rails_helper'

RSpec.describe GenproGovSk::Criminality::ParagraphsParser do
  describe '.parse' do
    let(:test_files) do
      [
        'data/genpro_gov_sk/criminality/paragraphs/2010_12_Z1003_6610_TZ_od_2006_Odsúdené osoby pre prečiny, zločiny-Prehľad za OP Veľký Krtíš.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2010_12_Z1002_2206_TZ_do_2005_Prehľad o stíhaných a obžalovaných osobách-Prehľad za OP Skalica.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2010_12_Z1002_6611_TZ_od_2006_Prehľad o stíhaných a obžalovaných osobách-Prehľad za OP Zvolen.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2011_12_Z1002_2202_TZ_od_2006_Prehľad o stíhaných a obžalovaných osobách-Prehľad za OP Galanta.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2011_12_Z1003_4400_TZ_od_2006_Odsúdené osoby pre prečiny, zločiny-Prehľad za KP Nitra.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2011_12_Z1002_7703_TZ_do_2005_Prehľad o stíhaných a obžalovaných osobách-Prehľad za OP Kežmarok.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2012_12_Z1003_2200_TZ_do_2005_Odsúdené osoby za trestné činy-Prehľad za KP Trnava.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2012_12_Z1003_7703_TZ_od_2006_Odsúdené osoby pre prečiny, zločiny-Prehľad za OP Kežmarok.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2012_12_Z1003_7707_TZ_od_2006_Odsúdené osoby pre prečiny, zločiny-Prehľad za OP Prešov.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2013_12_Z1003_6613_TZ_do_2005_Odsúdené osoby za trestné činy-Prehľad za OP Žiar nad Hronom.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2013_12_Z1003_4406_TZ_do_2005_Odsúdené osoby za trestné činy-Prehľad za OP Topoľčany.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2013_12_Z1003_5506_TZ_do_2005_Odsúdené osoby za trestné činy-Prehľad za OP Martin.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2014_12_Z1003_3309_TZ_do_2005_Odsúdené osoby za trestné činy-Prehľad za OP Trenčín.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2014_12_Z1002_8808_TZ_do_2005_Prehľad o stíhaných a obžalovaných osobách-Prehľad za OP Rožňava.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2014_12_Z1002_8807_TZ_do_2005_Prehľad o stíhaných a obžalovaných osobách-Prehľad za OP Michalovce.xls',
        'data/genpro_gov_sk/criminality/paragraphs/2015_12_Z1003_6609_TZ_do_2005_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2015_12_Z1003_7712_TZ_od_2006_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2015_12_Z1003_8802_TZ_do_2005_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2016_12_Z1002_8810_TZ_do_2005_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2016_12_Z1003_1107_TZ_do_2005_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2016_12_Z1003_2207_TZ_od_2006_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2017_12_Z1002_6601_TZ_do_2005_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2017_12_Z1003_6611_TZ_do_2005_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2017_12_Z1002_5511_TZ_do_2005_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2018_12_Z1003_6603_TZ_do_2005_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2018_12_Z1002_2201_TZ_do_2005_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2018_12_Z1002_6601_TZ_do_2005_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2019_12_Z1002_3301_TZ_od_2006_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2019_12_Z1002_5507_TZ_do_2005_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2019_12_Z1002_8802_TZ_do_2005_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2020_12_Z1002_2204_TZ_do_2005_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2020_12_Z1003_3304_TZ_do_2005_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2020_12_Z1002_3304_TZ_do_2005_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2021_12_Z1002_3309_TZ_od_2006_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2021_12_Z1003_2204_TZ_od_2006_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2021_12_Z1003_3307_TZ_do_2005_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2022_12_Z1002_8811_TZ_od_2006_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2022_12_Z1003_3307_TZ_od_2006_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2022_12_Z1003_2200_TZ_od_2006_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2023_12_Z1002_2207_TZ_od_2006_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2023_12_Z1002_5507_TZ_od_2006_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2023_12_Z1003_8806_TZ_od_2006_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2024_12_Z1003_6610_TZ_od_2006_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2024_12_Z1002_8808_TZ_od_2006_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx',
        'data/genpro_gov_sk/criminality/paragraphs/2024_12_Z1003_3301_TZ_od_2006_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx'
      ]
    end

    it 'parses all test files without errors' do
      test_files.each do |file|
        path = Rails.root.join(file).to_s

        next unless File.exist?(path)

        result = described_class.parse(path)

        if result.nil?
          # puts "File returned nil (no paragraphs): #{File.basename(file)}"
          next
        end

        expect(result).to be_a(Hash), "Expected Hash for #{File.basename(file)}"
        expect(result[:year]).to be_present, "Expected year for #{File.basename(file)}"
        expect(result[:office]).to be_present, "Expected office for #{File.basename(file)}"
        expect(result[:type]).to be_in(%i[old new]), "Expected type for #{File.basename(file)}"
        expect(result[:statistics]).to be_an(Array), "Expected statistics array for #{File.basename(file)}"
        expect(result[:unknown]).to be_an(Array), "Expected unknown array for #{File.basename(file)}"
      end
    end

    it 'parses statistics with valid structure' do
      test_files
        .sample(5)
        .each do |file|
          path = Rails.root.join(file).to_s

          next unless File.exist?(path)

          result = described_class.parse(path)

          next if result.nil? || result[:statistics].empty?

          result[:statistics].each do |stat|
            expect(stat).to have_key(:metric)
            expect(stat).to have_key(:paragraph)
            expect(stat).to have_key(:count)
          end
        end
    end

    it 'reports minimal unknown attributes for recent years' do
      recent_files = test_files.select { |f| f.match?(/202[3-4]/) }

      recent_files.each do |file|
        path = Rails.root.join(file).to_s

        next unless File.exist?(path)

        result = described_class.parse(path)

        next if result.nil?

        if result[:unknown].any?
          # puts "Unknown attributes in #{File.basename(file)}:"
          # result[:unknown].uniq.each { |attr| puts "  - #{attr}" }
        end

        expect(result[:unknown].uniq.length).to be <= 5,
        "Too many unknown attributes in #{File.basename(file)}: #{result[:unknown].uniq.join(', ')}"
      end
    end

    context '2024 files with new format' do
      let(:file_2024_accused) do
        'data/genpro_gov_sk/criminality/paragraphs/2024_12_Z1002_8808_TZ_od_2006_6-1002_Prehlad_o_stihanych_a_obzalovanych_osobach_podla_paragrafov.xlsx'
      end

      let(:file_2024_convicted) do
        'data/genpro_gov_sk/criminality/paragraphs/2024_12_Z1003_6610_TZ_od_2006_6-1003_Prehlad_o_osobach_odsudenych_pre_trestne_ciny.xlsx'
      end

      it 'parses 2024 accused file with new metrics' do
        path = Rails.root.join(file_2024_accused).to_s

        skip "File does not exist: #{file_2024_accused}" unless File.exist?(path)

        result = described_class.parse(path)

        expect(result).not_to be_nil
        expect(result[:year]).to eq(2024)
        expect(result[:statistics]).not_to be_empty

        metrics = result[:statistics].map { |s| s[:metric] }.uniq

        has_legal_entities = metrics.include?(:prosecuted_legal_entities)
        has_natural_persons = metrics.include?(:prosecuted_natural_persons)
        has_adults = metrics.include?(:prosecuted_adults_all)

        expect(has_legal_entities || has_natural_persons || has_adults).to be(true),
        'Expected to find at least one of the new 2024 metrics'
      end

      it 'parses 2024 convicted file with new metrics' do
        path = Rails.root.join(file_2024_convicted).to_s

        skip "File does not exist: #{file_2024_convicted}" unless File.exist?(path)

        result = described_class.parse(path)

        expect(result).not_to be_nil
        expect(result[:year]).to eq(2024)
        expect(result[:statistics]).not_to be_empty

        metrics = result[:statistics].map { |s| s[:metric] }.uniq

        has_legal_entities = metrics.include?(:convicted_legal_entities)
        has_natural_persons = metrics.include?(:convicted_natural_persons)
        has_foreigners = metrics.include?(:convicted_foreigners)

        expect(has_legal_entities || has_natural_persons || has_foreigners).to be(true),
        'Expected to find at least one of the new 2024 metrics'
      end
    end
  end
end
