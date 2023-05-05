require 'p_d_f_extractor'
require 'r_t_f_extractor'

class ReconcileDecreeJob < ApplicationJob
  queue_as :default

  def perform(decree)
    offices = Office.all
    preamble = decree.preamble
    signature = decree.signature

    office = offices.find do |office|
      preamble.gsub(/Košice-okolie/i, 'Košice - okolie').match(/#{office.name}/i)
    end

    decree.update(office: office)

    prosecutors = [
      *Prosecutor.joins(:offices).merge(Office.where(id: office)).distinct.pluck(:id, :name_parts),
      *Prosecutor.joins(:offices).merge(Office.where.not(id: office)).distinct.pluck(:id, :name_parts)
    ].map do |(id, name)|
      [id, [name['first'], name['middle'], name['last']].compact]
    end

    prosecutor = prosecutors.find do |(id, name)|
      name.permutation(name.size).any? { |e| signature.match(/#{e.join(' ').squeeze(' ')}/i) }
    end

    decree.update(prosecutor_id: prosecutor[0]) if prosecutor
  end
end