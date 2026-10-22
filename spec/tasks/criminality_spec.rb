# frozen_string_literal: true

require 'rails_helper'
require 'rake'

# The table of the criminality metrics, for whoever maps genpro.gov.sk's new columns.
RSpec.describe 'criminality:metrics_map', type: :task do
  let(:path) { Rails.root.join('tmp/spec-metrics-map.csv') }

  before { Rails.application.load_tasks unless Rake::Task.task_defined?('criminality:metrics_map') }

  after { FileUtils.rm_f(path) }

  it 'lists each metric with its name and the names genpro.gov.sk gives it, in Slovak' do
    Rake::Task['criminality:metrics_map'].tap(&:reenable).invoke(path.to_s)

    rows = CSV.read(path)

    expect(rows.first).to eq(['Symbol nášho atribútu', 'Názov nášho atribútu',
                              'Názov atribútu z dát Generálnej prokuratúry', 'Typ súboru'])
    expect(rows).to include(['accused_all', 'Obžalované osoby - Všetci', 'Počet obžalovaných osôb',
                             'Štruktúry'])
  end
end
