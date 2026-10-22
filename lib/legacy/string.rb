# frozen_string_literal: true

# The name normalizer's String extension: the text with its letters stripped of diacritics and anything outside ASCII
# dropped, to compare titles and names regardless of how they're written.
module Legacy
  module String
    refine ::String do
      def ascii
        return self if ascii_only?

        unicode_normalize(:nfkd).bytes.map { |byte| (0x00..0x7F).cover?(byte) ? byte.chr : '' }.join
      end
    end
  end
end
