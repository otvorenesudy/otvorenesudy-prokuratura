require 'p_d_f_extractor'
require 'r_t_f_extractor'

class ReconcileDecreeJob < ApplicationJob
  queue_as :default

  def perform(decree)
    office = reconcile_office(decree)
    reconcile_prosecutor(decree, office)
    reconcile_paragraph(decree)
  end

  private

  def reconcile_office(decree)
    offices = Office.all
    preamble = decree.preamble

    office =
      offices.find do |office|
        preamble
          .gsub(/Košice-okolie/i, 'Košice - okolie')
          .gsub(/Krajskej prokuratúry/i, 'Krajská prokuratúra')
          .gsub(
            /Ú\s*r\s*a\s*d\s*š\s*p\s*e\s*c\s*i\s*á\s*l\s*n\s*e\s*j\s*p\s*r\s*o\s*k\s*u\s*r\s*a\s*t\s*ú\s*r\s*y/i,
            'Úrad špeciálnej prokuratúry'
          )
          .match(/(#{[office.name, *office.synonyms].compact.join('|')})/i)
      end

    decree.update(office: office)
    Office.reset_counters(office.id, :decrees) if office

    office
  end

  def reconcile_prosecutor(decree, office)
    signature = decree.signature

    prosecutors =
      [
        *Prosecutor.joins(:offices).merge(Office.where(id: office)).distinct.pluck(:id, :name_parts),
        *Prosecutor.joins(:past_offices).merge(Office.where(id: office)).distinct.pluck(:id, :name_parts),
        *Prosecutor.joins(:all_offices).merge(Office.where.not(id: office)).distinct.pluck(:id, :name_parts)
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

  def reconcile_paragraph(decree)
    matches = decree.normalized_text.match(/(Trestný čin|Prečin|Zločin):.+?(§\s+?\d+)(.{0,200})/i)

    return unless matches && matches[2]

    after_paragraph = matches[3]

    _, _, paragraph_section = *after_paragraph.match(/((.+?)(Trestného zákona|Tr. zák))?/i)
    paragraph_type = after_paragraph.match(/1961/) ? 'old' : 'new'
    paragraph = Paragraph.find_by(type: paragraph_type, value: "#{matches[2]} [#{paragraph_type}]")

    return unless paragraph

    decree.update(paragraph_id: paragraph.id, paragraph_section: paragraph_section&.strip)
  end
end
