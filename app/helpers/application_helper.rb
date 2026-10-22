# frozen_string_literal: true

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
    safe_join([*values, default_title], ' · ')
  end

  def canonical_url
    "https://#{request.host}#{request.fullpath}"
  end

  def donation_url
    'https://transparency.darujme.sk/prokuratura/?donation=40&periodicity=periodical'
  end

  def organisation_url(path = nil)
    "https://github.com/otvorenesudy/#{path}".delete_suffix('/')
  end

  def repository_url(path = nil)
    organisation_url "otvorenesudy-prokuratura/#{path}".delete_suffix('/')
  end
end
