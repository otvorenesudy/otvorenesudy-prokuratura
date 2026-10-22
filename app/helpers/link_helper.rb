# frozen_string_literal: true

module LinkHelper
  PATTERN = /[;,]\s+/

  def email_to(emails, separator = ', ')
    safe_join(emails.split(PATTERN).map { |email| mail_to(email) }, separator)
  end

  # A link to an address from imported data (news, declarations, decrees). Only a web address links; anything else
  # (javascript:, data:) shows as the plain text.
  def link_to_source(body, url, options = {})
    return body unless url.to_s.match?(%r{\Ahttps?://}i)

    link_to body, url, options
  end

  # Phone numbers as links, each kept on one line.
  def phone_to(phones, separator = ', ')
    links = phones.split(PATTERN).map do |phone|
      link_to(safe_join(phone.split(/\s+/), "\u00A0"), "tel:#{phone.delete(' ')}")
    end

    safe_join(links, separator)
  end
end
