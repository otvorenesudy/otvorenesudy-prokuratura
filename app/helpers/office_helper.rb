module OfficeHelper
  def offices_path(*args, &block)
    path = super(*args, &block)

    args.any? && args[0].any? ? "#{path}#facets" : path
  end

  def minified_office_name(name)
    return 'GP SR' if name == 'Generálna prokuratúra Slovenskej republiky'

    name.gsub('Krajská prokuratúra', 'KP').gsub('Okresná prokuratúra', 'OP')
  end
end
