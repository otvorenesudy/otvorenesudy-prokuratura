# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'https://prokuratura.otvorenesudy.sk'

SitemapGenerator::Sitemap.create do
  %i[en sk].each do |l|
    add "/?l=#{l}"

    add "/about?l=#{l}"
    add "/contact?l=#{l}"
    add "/copyright?l=#{l}"
    add "/faq?l=#{l}"
    add "/feedback?l=#{l}"
    add "/privacy?l=#{l}"
    add "/tos?l=#{l}"

    Prosecutor.pluck(:id).each { |id| add prosecutor_path(id, l: l), changefreq: 'daily', priority: 0.8 }
    Office.pluck(:id).each { |id| add office_path(id, l: l), changefreq: 'daily', priority: 0.8 }

    add statistics_path(l: l), changefreq: 'monthly', priority: 0.6
    add crimes_path(l: l), changefreq: 'monthly', priority: 0.6
  end
end
