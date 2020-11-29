module ApplicationHelper
  def default_title
    t 'layouts.application.title'
  end

  def resolve_title(value)
    return default_title if value.blank?
    return title(value) unless value.end_with? default_title
    value
  end

  def title(*values)
    (values << default_title).map { |value| html_escape value }.join(' &middot; ').html_safe
  end

  def canonical_url
    "https://#{request.host}#{request.fullpath}"
  end

  def donation_url
    'https://transparency.darujme.sk/prokuratura/?donation=40&periodicity=periodical'
  end

  def organisation_url(path = nil)
    "https://github.com/otvorenesudy/#{path}".sub(%r{\/\z}, '')
  end

  def repository_url(path = nil)
    organisation_url "otvorenesudy-prokuratura/#{path}".sub(%r{\/\z}, '')
  end
end
