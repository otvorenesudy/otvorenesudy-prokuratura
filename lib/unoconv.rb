class Unoconv
  def self.convert(path)
    text = `timeout 10s unoconv -p 2002 -n --stdout -f text #{path}`

    raise ArgumentError, "Unoconv failed with [#{$?.exitstatus}] status for [#{path}]" unless $?.exitstatus.zero?

    text
  end
end
