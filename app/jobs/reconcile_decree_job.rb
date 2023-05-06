require 'p_d_f_extractor'
require 'r_t_f_extractor'

class ReconcileDecreeJob < ApplicationJob
  queue_as :default

  def perform(decree)
    offices = Office.all
    preamble = decree.preamble
    signature = decree.signature

    office =
      offices.find do |office|
        preamble
          .gsub(/Košice-okolie/i, 'Košice - okolie')
          .gsub(/Krajskej prokuratúry/i, 'Krajská prokuratúra')
          .gsub(
            /Ú\s*r\s*a\s*d\s*š\s*p\s*e\s*c\s*i\s*á\s*l\s*n\s*e\s*j\s*p\s*r\s*o\s*k\s*u\s*r\s*a\s*t\s*ú\s*r\s*y/i,
            'Úrad špeciálnej prokuratúry'
          )
          .match(/#{office.name}/i)
      end

    decree.update(office: office)
    Office.reset_counters(office.id, :decrees) if office

    prosecutors =
      [
        *Prosecutor.joins(:offices).merge(Office.where(id: office)).distinct.pluck(:id, :name_parts),
        *Prosecutor.joins(:offices).merge(Office.where.not(id: office)).distinct.pluck(:id, :name_parts)
      ].map { |(id, name)| [id, [name['first'], name['middle'], name['last']].compact] }

    prosecutor =
      prosecutors.find do |(id, name)|
        name.permutation(name.size).any? { |e| signature.match(/#{e.join(' ').squeeze(' ')}/i) }
      end

    if prosecutor
      decree.update(prosecutor_id: prosecutor[0])

      Prosecutor.reset_counters(prosecutor[0], :decrees)
    end
  end
end
