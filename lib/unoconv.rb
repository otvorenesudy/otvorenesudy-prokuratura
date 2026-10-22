# frozen_string_literal: true

class Unoconv
  def self.convert(path)
    text = `timeout 10s unoconv -p 2002 -n --stdout -f text #{path}`

    status = Process.last_status.exitstatus

    raise ArgumentError, "Unoconv failed with [#{status}] status for [#{path}]" unless status.zero?

    text
  end
end
