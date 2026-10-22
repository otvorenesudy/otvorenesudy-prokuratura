# frozen_string_literal: true

require 'rails_helper'
require 'rake'
require 'zlib'

# The sitemap search engines read, refreshed nightly (config/schedule.rb).
RSpec.describe 'sitemap:refresh:no_ping', type: :task do
  let(:directory) { Rails.root.join('tmp/spec-sitemap') }

  before do
    Rails.application.load_tasks unless Rake::Task.task_defined?('sitemap:refresh:no_ping')
    FileUtils.rm_rf(directory)
    SitemapGenerator::Sitemap.reset!
    SitemapGenerator::Sitemap.public_path = directory.to_s
    SitemapGenerator::Sitemap.verbose = false
  end

  after { SitemapGenerator::Sitemap.reset! }

  def urls
    %w[sitemap:create sitemap:refresh:no_ping].each { |task| Rake::Task[task].reenable }
    Rake::Task['sitemap:refresh:no_ping'].invoke

    directory.glob('**/*.xml.gz').flat_map do |path|
      Zlib::GzipReader.open(path) { |file| Nokogiri::XML(file.read).remove_namespaces!.xpath('//loc').map(&:text) }
    end
  end

  it 'lists the pages, the prosecutors, the offices and the criminality in both languages' do
    prosecutor = create(:prosecutor)
    office = Office.find_by!(name: 'Okresná prokuratúra Žilina')

    expect(urls).to include(
      'https://prokuratura.otvorenesudy.sk/?l=sk', 'https://prokuratura.otvorenesudy.sk/about?l=en',
      "https://prokuratura.otvorenesudy.sk/prosecutors/#{prosecutor.id}?l=sk",
      "https://prokuratura.otvorenesudy.sk/offices/#{office.id}?l=en",
      'https://prokuratura.otvorenesudy.sk/criminality/prosecutors?l=sk',
      'https://prokuratura.otvorenesudy.sk/criminality/police?l=en'
    )
  end
end
