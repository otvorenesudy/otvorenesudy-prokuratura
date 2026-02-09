#!/usr/bin/env ruby

require 'bundler/setup'
require_relative '../config/environment'
require 'json'
require 'fileutils'
require 'legacy'

puts "Fetching current prosecutor list from genpro.gov.sk..."

begin
  using ::Legacy::String
  
  # Download and parse the current PDF
  html = Curl.get('https://www.genpro.gov.sk/menny-zoznam-prokuratorov-slovenskej-republiky').body_str
  path = Nokogiri.HTML(html).css('a').find { |e| e.text.ascii =~ /Menny zoznam prokuratorov SR/ }[:href]
  url = "https://www.genpro.gov.sk#{path}"
  
  puts "Downloading PDF from: #{url}"
  
  rows, pdf_content =
    FileDownloader.download(url, extension: 'pdf') do |pdf_path|
      [GenproGovSk::Prosecutors::PDFParser.parse(pdf_path), File.open(pdf_path, 'rb').read]
    end
  
  puts "Parsed #{rows.size} prosecutors from PDF"
  
  # Save the raw PDF
  pdf_fixture_path = Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'prosecutors', 'list.pdf')
  File.write(pdf_fixture_path, pdf_content, mode: 'wb')
  puts "Updated #{pdf_fixture_path}"
  
  # Save the parsed rows (list.json)
  list_json_path = Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'prosecutors', 'list.json')
  File.write(list_json_path, JSON.pretty_generate(rows))
  puts "Updated #{list_json_path}"
  
  # Parse and save the processed prosecutors (all_prosecutors.json)
  parsed_prosecutors = GenproGovSk::Prosecutors::Parser.parse(rows)
  all_prosecutors_path = Rails.root.join('spec', 'fixtures', 'genpro_gov_sk', 'prosecutors', 'all_prosecutors.json')
  File.write(all_prosecutors_path, JSON.pretty_generate(parsed_prosecutors))
  puts "Updated #{all_prosecutors_path} with #{parsed_prosecutors.size} prosecutors"
  
  puts "\n✅ Success! Fixtures updated with current data from genpro.gov.sk"
  puts "   - #{rows.size} prosecutors in list.json"
  puts "   - #{parsed_prosecutors.size} prosecutors in all_prosecutors.json"
  
rescue => e
  puts "\n❌ Error updating fixtures:"
  puts "   #{e.class}: #{e.message}"
  puts "\n#{e.backtrace.first(10).join("\n")}"
  exit 1
end
