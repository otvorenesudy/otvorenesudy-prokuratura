# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MinvSk::Criminality::Parser do
  describe '.parse' do
    context 'with 2002 CSV file' do
      let(:csv) { File.read('spec/fixtures/minv_sk/criminality/2002.csv') }
      let(:data) { described_class.parse(csv) }

      it 'parses crime_discovered for § 118 [old]' do
        expect(data.find { |d| d[:paragraph] == '§ 118 [old]' && d[:metric] == :crime_discovered }[:count]).to eq(52)
      end

      it 'parses crime_solved for § 118 [old]' do
        expect(data.find { |d| d[:paragraph] == '§ 118 [old]' && d[:metric] == :crime_solved }[:count]).to eq(26)
      end

      it 'parses crime_denominated_damage for § 118 [old]' do
        expect(
          data.find { |d| d[:paragraph] == '§ 118 [old]' && d[:metric] == :crime_denominated_damage }[:count]
        ).to eq(8796.32)
      end

      it 'parses persons_all for § 118 [old]' do
        expect(data.find { |d| d[:paragraph] == '§ 118 [old]' && d[:metric] == :persons_all }[:count]).to eq(17)
      end

      it 'parses persons_alcohol_abuse for § 118 [old]' do
        expect(data.find { |d| d[:paragraph] == '§ 118 [old]' && d[:metric] == :persons_alcohol_abuse }[:count]).to eq(
          0
        )
      end
    end

    context 'with 2008 CSV file' do
      let(:csv) { File.read('spec/fixtures/minv_sk/criminality/2008.csv') }
      let(:data) { described_class.parse(csv) }

      it 'parses crime_discovered for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :crime_discovered }[:count]).to eq(13)
      end

      it 'parses crime_solved for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :crime_solved }[:count]).to eq(3)
      end

      it 'parses crime_denominated_damage for § 144 [new]' do
        expect(
          data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :crime_denominated_damage }[:count]
        ).to eq(2356.77)
      end

      it 'parses persons_all for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :persons_all }[:count]).to eq(7)
      end

      it 'parses persons_alcohol_abuse for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :persons_alcohol_abuse }[:count]).to eq(
          0
        )
      end
    end

    context 'with 2012 CSV file' do
      let(:csv) { File.read('spec/fixtures/minv_sk/criminality/2012.csv') }
      let(:data) { described_class.parse(csv) }

      it 'parses crime_discovered for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :crime_discovered }[:count]).to eq(20)
      end

      it 'parses crime_solved for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :crime_solved }[:count]).to eq(8)
      end

      it 'parses crime_denominated_damage for § 144 [new]' do
        expect(
          data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :crime_denominated_damage }[:count]
        ).to eq(0)
      end

      it 'parses persons_all for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :persons_all }[:count]).to eq(12)
      end

      it 'parses persons_alcohol_abuse for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :persons_alcohol_abuse }[:count]).to eq(
          0
        )
      end
    end

    context 'with 2020 CSV file' do
      let(:csv) { File.read('spec/fixtures/minv_sk/criminality/2020.csv') }
      let(:data) { described_class.parse(csv) }

      it 'parses crime_discovered for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :crime_discovered }[:count]).to eq(12)
      end

      it 'parses crime_solved for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :crime_solved }[:count]).to eq(3)
      end

      it 'parses crime_denominated_damage for § 144 [new]' do
        expect(
          data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :crime_denominated_damage }[:count]
        ).to eq(0)
      end

      it 'parses persons_all for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :persons_all }[:count]).to eq(4)
      end

      it 'parses persons_alcohol_abuse for § 144 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 144 [new]' && d[:metric] == :persons_alcohol_abuse }[:count]).to eq(
          0
        )
      end
    end

    context 'with 2024 CSV file' do
      let(:csv) { File.read('spec/fixtures/minv_sk/criminality/2024.csv') }
      let(:data) { described_class.parse(csv) }

      it 'parses crime_discovered for § 145 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 145 [new]' && d[:metric] == :crime_discovered }[:count]).to eq(17)
      end

      it 'parses crime_solved for § 145 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 145 [new]' && d[:metric] == :crime_solved }[:count]).to eq(10)
      end

      it 'parses crime_denominated_damage for § 145 [new]' do
        expect(
          data.find { |d| d[:paragraph] == '§ 145 [new]' && d[:metric] == :crime_denominated_damage }[:count]
        ).to eq(0)
      end

      it 'parses persons_all for § 145 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 145 [new]' && d[:metric] == :persons_all }[:count]).to eq(13)
      end

      it 'parses persons_alcohol_abuse for § 145 [new]' do
        expect(data.find { |d| d[:paragraph] == '§ 145 [new]' && d[:metric] == :persons_alcohol_abuse }[:count]).to eq(
          5
        )
      end
    end

    it 'refuses a table with a breakdown it does not know' do
      rows = CSV.parse(fixture('minv_sk/criminality/2002.csv').binread.force_encoding('Windows-1250').encode('UTF-8'))
      rows[6][1] = 'Neznáme'
      csv = CSV.generate { |output| rows.each { |row| output << row } }.encode('Windows-1250')

      expect { described_class.parse(csv) }.to raise_error(RuntimeError, 'Unknown breakdown: Neznáme')
    end
  end
end
