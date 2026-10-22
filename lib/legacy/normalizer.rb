# The name of a person, from genpro.gov.sk's lists, declarations and decrees, split into its parts: academic titles
# before and after it, first, middle and last names, and flags (born as, junior or senior). Kept from the courts' importer
# (JusticeGovSk::Helper::Normalizer) so that names stay as they were stored.
module Legacy
  module Normalizer
    extend self

    using Legacy::String

    def partition_person_name(value, options = {})
      copy = value.clone
      value = value.dup

      prefixes = []
      suffixes = []
      additions = []
      uppercase = []
      mixedcase = []
      flags = []

      _, representantive = *value.match(/((\,\s+)?hovorca)?\s+KS\s+(v\s+)?(?<municipality>.+)\z/i)

      unless representantive.nil?
        flags << :representantive
        value.sub!(/((\,\s+)?hovorca\s+)?KS\s+(v\s+)?.+\z/i, '')
      end

      value.strip!
      value.gsub!(/[\,\;\(\)]/, '')
      value.gsub!(/(\.+\s*)+/, '. ')
      value.gsub!(/\s*\-\s*/, '-')

      value
        .split(/\s+/)
        .each do |part|
          key = person_name_map_key(part)

          if prefix = person_name_prefix_map[key]
            prefixes << prefix
          elsif suffix = person_name_suffix_map[key]
            suffixes << suffix
          else
            part = part.strip

            if part =~ /\./
              if part =~ /rod\./i
                flags << :born
              elsif part =~ /(ml|st)\./
                flags << :relative
                additions << part
              end
            else
              if part.upcase == part
                uppercase << part.split(/\-/).map(&:titlecase).join(' - ')
              else
                mixedcase << part.split(/\-/).map(&:titlecase).join(' - ')
              end
            end
          end
        end

      prefixes.uniq!
      suffixes.uniq!

      names = mixedcase + uppercase

      if options[:reverse]
        if names.size >= 3
          names[0], names[1..-1] = names[-1], names[0..-2]
        else
          names.reverse!
        end
      end

      if flags.include? :born
        names << names.last
        names[-2] = 'rod.'
      end

      value = nil
      value = names.join(' ') unless names.empty?
      value = prefixes.join(' ') + ' ' + value unless prefixes.empty?
      value = value + ' ' + additions.join(' ') unless additions.empty?
      value = value + ', ' + suffixes.join(' ') unless suffixes.empty?

      if flags.include? :representantive
        municipality ||= 'Trenčíne' unless representantive.match(/(TN|Trenčín(e)?)/).nil?
        municipality ||= 'Trnave' unless representantive.match(/(TT|Trnav(a|e){1})/).nil?

        role = "Hovorca krajského súdu v #{municipality}"
        value = value.blank? ? role : "#{value}, #{role.downcase_first}"
      end

      {
        unprocessed: copy.strip,
        value: value.to_s,
        prefix: prefixes.empty? ? nil : prefixes.join(' '),
        first: names.count >= 2 ? names.first.to_s : nil,
        middle: names.count >= 3 ? names[1..-2].join(' ') : nil,
        last: names.last.to_s,
        suffix: suffixes.empty? ? nil : suffixes.join(' '),
        addition: additions.empty? ? nil : additions.join(' '),
        flags: flags,
        role: role
      }
    end

    private

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
      values.inject({}) do |m, v|
        m[person_name_map_key(v)] = v
        m
      end
    end

    def person_name_map_key(value)
      value.to_s.ascii.downcase.gsub(/[\s\.\,\;\-\(\)]/, '').to_sym
    end

    public
  end
end
