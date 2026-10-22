# frozen_string_literal: true

namespace :criminality do
  desc 'Write the table of the criminality metrics: our names beside genpro.gov.sk\'s (the metrics map CSV in data/)'
  task :metrics_map, [:path] => :environment do |_, arguments|
    path = arguments[:path] || Rails.root.join('data/genpro_gov_sk/criminality/metrics-map.csv')
    sources = {
      'Štruktúry' => GenproGovSk::Criminality::STRUCTURES_MAP,
      'Prehľad o osobách odsúdených pre trestné činy' => GenproGovSk::Criminality::PARAGRAPHS_BY_CONVICTED_MAP,
      'Prehľad o stíhaných a obžalovaných osobách' => GenproGovSk::Criminality::PARAGRAPHS_BY_ACCUSED_AND_PROSECUTED_MAP
    }

    I18n.with_locale(:sk) do
      CSV.open(path, 'w') do |csv|
        csv << ['Symbol nášho atribútu', 'Názov nášho atribútu', 'Názov atribútu z dát Generálnej prokuratúry',
                'Typ súboru']

        sources.values.flat_map(&:values).uniq.sort.each do |metric|
          rows = sources.flat_map do |kind, source|
            source.select { |_, value| value == metric }.map { |name, _| [nil, nil, name, kind] }
          end

          group = Statistic::GROUPS.find { |_, metrics| metric.in?(metrics) }
          title = group ? "#{I18n.t("statistics.index.search.#{group[0]}.title")} - " : ''

          rows[0][0] = metric
          rows[0][1] = title + I18n.t("models.statistic.metrics.#{metric}")

          rows.each { |row| csv << row }
        end
      end
    end
  end
end
