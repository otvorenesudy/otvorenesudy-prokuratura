# frozen_string_literal: true

# The name of a person, from genpro.gov.sk's lists, declarations and decrees, split into its parts: academic titles
# before and after it, first, middle and last names, and flags (born as, junior or senior). Kept from the courts'
# importer (JusticeGovSk::Helper::Normalizer) so that names stay as they were stored.
module Legacy
  module Normalizer
    extend self

    using Legacy::String

    def partition_person_name(value, options = {})
      name = value.dup
      representantive = cut_representantive!(name)
      parts = split_name(normalize_name(name), flags: representantive ? [:representantive] : [])
      names = order_names(parts[:mixedcase] + parts[:uppercase], parts[:flags], reverse: options[:reverse])
      role = "Hovorca krajského súdu v #{municipality_of(representantive)}" if representantive
      text = join_name(names, parts)
      text = text.blank? ? role : "#{text}, #{role.downcase_first}" if role

      {
        unprocessed: value.strip,
        value: text.to_s,
        prefix: parts[:prefixes].join(' ').presence,
        **name_fields(names),
        suffix: parts[:suffixes].join(' ').presence,
        addition: parts[:additions].join(' ').presence,
        flags: parts[:flags],
        role:
      }
    end

    private

    # A spokesperson of a regional court ("hovorca KS v Trnave") is named with the court; the court comes off the name.
    def cut_representantive!(name)
      representantive = name[/(?:(?:,\s+)?hovorca)?\s+KS\s+(?:v\s+)?(?<municipality>.+)\z/i, :municipality]

      name.sub!(/((,\s+)?hovorca\s+)?KS\s+(v\s+)?.+\z/i, '') if representantive

      representantive
    end

    # The court's town as the name gives it, Trenčín's and Trnava's abbreviations and forms written out.
    def municipality_of(representantive)
      return 'Trenčíne' if representantive.match?(/(TN|Trenčín(e)?)/)
      return 'Trnave' if representantive.match?(/(TT|Trnav(a|e){1})/)

      representantive
    end

    def normalize_name(name)
      name.strip.gsub(/[,;()]/, '').gsub(/(\.+\s*)+/, '. ').gsub(/\s*-\s*/, '-')
    end

    # The name's words sorted into titles before and after it, additions (junior, senior) and names, in capitals or not.
    def split_name(name, flags:)
      parts = { prefixes: [], suffixes: [], additions: [], uppercase: [], mixedcase: [], flags: }

      name.split(/\s+/).each { |part| sort_part(part, parts) }

      parts[:prefixes].uniq!
      parts[:suffixes].uniq!
      parts
    end

    def sort_part(part, parts)
      key = person_name_map_key(part)

      if (prefix = person_name_prefix_map[key])
        parts[:prefixes] << prefix
      elsif (suffix = person_name_suffix_map[key])
        parts[:suffixes] << suffix
      elsif part.strip.include?('.')
        sort_abbreviation(part.strip, parts)
      else
        part = part.strip

        (part.upcase == part ? parts[:uppercase] : parts[:mixedcase]) << part.split('-').map(&:titlecase).join(' - ')
      end
    end

    def sort_abbreviation(part, parts)
      if /rod\./i.match?(part)
        parts[:flags] << :born
      elsif /(ml|st)\./.match?(part)
        parts[:flags] << :relative
        parts[:additions] << part
      end
    end

    # The names in order: a list's "last first" turned around, and "rod." (born as) before the maiden name.
    def order_names(names, flags, reverse:)
      names = names.size >= 3 ? names.rotate(-1) : names.reverse if reverse
      names = [*names[0..-2], 'rod.', names.last] if flags.include?(:born)

      names
    end

    def join_name(names, parts)
      text = names.join(' ') unless names.empty?
      text = "#{parts[:prefixes].join(' ')} #{text}" unless parts[:prefixes].empty?
      text = "#{text} #{parts[:additions].join(' ')}" unless parts[:additions].empty?
      text = "#{text}, #{parts[:suffixes].join(' ')}" unless parts[:suffixes].empty?

      text
    end

    def name_fields(names)
      {
        first: names.count >= 2 ? names.first.to_s : nil,
        middle: names.count >= 3 ? names[1..-2].join(' ') : nil,
        last: names.last.to_s
      }
    end

    def person_name_prefix_map
      @person_name_prefix_map ||=
        person_name_map_using [
          'abs. v. š.',
          'akad.',
          'akad. arch.',
          'akad. mal.',
          'akad. soch.',
          'arch.',
          'Bc.',
          'Bc. arch.',
          'BcA.',
          'B.Ed.',
          'B.Sc.',
          'Bw. (VWA)',
          'doc.',
          'Dr.',
          'Dr hab.',
          'Dr inž.',
          'Dr. jur.',
          'Dr.h.c.',
          'Dr.ir.',
          'Dr.phil.',
          'Eng.',
          'ICDr.',
          'Ing.',
          'Ing. arch.',
          'JUC.',
          'JUDr.',
          'Kfm.',
          'Kfm. (FH)',
          'Lic.',
          'Mag',
          'Mag.',
          'Mag. (FH)',
          'Mag. iur',
          'Magistra Artium',
          'Mag.rer.nat.',
          'MDDr.',
          'MgA.',
          'Mgr.',
          'Mgr. art.',
          'mgr inž.',
          'Mgr. phil.',
          'MMag.',
          'Mr.sc.',
          'MSDr.',
          'MUc.',
          'MUDr.',
          'MVc.',
          'MVDr.',
          'PaedDr.',
          'PharmDr.',
          'PhDr.',
          'PhMr.',
          'prof.',
          'prof. mpx. h.c.',
          'prof.h.c.',
          'RCDr.',
          'RNDr.',
          'RSDr.',
          'ThDr.',
          'ThLic.'
        ]
    end

    def person_name_suffix_map
      @person_name_suffix_map ||=
        person_name_map_using [
          'ArtD.',
          'BA',
          'BA (Hons)',
          'BBA',
          'BBS',
          'BBus',
          'BBus (Hons)',
          'BS',
          'BSBA',
          'BSc',
          'Cert Mgmt',
          'CPA',
          'CSc.',
          'DDr.',
          'Dipl. Ing.',
          'Dipl. Kfm.',
          'Dipl.ECEIM',
          'DiS.',
          'DiS.art',
          'Dr.',
          'Dr.h.c.',
          'DrSc.',
          'DSc.',
          'EMBA',
          'E.M.M.',
          'Eqm.',
          'Litt.D.',
          'LL.A.',
          'LL.B.',
          'LL.M.',
          'LL.M',
          'M.A.',
          'MAE',
          'MAS',
          'MBA',
          'MBSc',
          'M.C.L.',
          'MEng.',
          'MIM',
          'MMBA',
          'MPH',
          'M.Phil.',
          'MS',
          'MSc',
          'M.S.Ed.',
          'Ph.D.',
          'PhD.',
          'prom. biol.',
          'prom. ek.',
          'prom. fil.',
          'prom. filol.',
          'prom. fyz.',
          'prom. geog.',
          'prom. geol.',
          'prom. hist.',
          'prom. chem.',
          'prom. knih.',
          'prom. logop.',
          'prom. mat.',
          'prom. nov.',
          'prom. ped.',
          'prom. pharm.',
          'prom. práv.',
          'prom. psych.',
          'prom. vet.',
          'prom. zub.',
          'ThD.'
        ]
    end

    def person_name_map_using(values)
      values.index_by do |v|
        person_name_map_key(v)
      end
    end

    def person_name_map_key(value)
      value.to_s.ascii.downcase.gsub(/[\s.,;\-()]/, '').to_sym
    end
  end
end
