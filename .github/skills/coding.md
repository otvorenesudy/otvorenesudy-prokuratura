---
name: coding
description: Guide for general coding practices. Use this guide when asked to write code in the repository or when reviewing code.
---

# Copilot Skill: Otvorena Prokuratura – Coding Style

Use this skill whenever generating Ruby, Rails, or lib code in this repo. Match the patterns and structure below.

## General Ruby & Formatting

- Ruby 3.3, Rails 7.1, standard OOP style.
- Two-space indentation, no tabs.
- Prefer single quotes for strings unless interpolation or special escaping is required.
- Avoid inline comments in application code. Only use comments in very complex or non-obvious places.
- Keep methods short and focused. Extract private helpers instead of deeply nested conditionals.
- Use newlines to visually and semantically separate part of code

## Controllers

Follow thin-controller pattern; move business logic into services or models.

Example: OfficesController index and strong params

```ruby
class OfficesController < ApplicationController
  layout false, only: [:decrees]

  def index
    @search = OfficeSearch.new(index_params)

    @search.params[:sort] = nil if @search.params[:sort] == 'relevancy' && @search.params[:q].blank?
  end

  def show
    @office = Office.find(params[:id])
    @tab = show_params[:tab]
    @paragraphs = Paragraph.where(value: show_params[:paragraph]) if params[:paragraph].present?
    @decrees = @office.decrees
    @decrees = @decrees.where(paragraph: @paragraphs) if @paragraphs.present?
    @registry = @office.registry.deep_symbolize_keys
  end

  def suggest
    return head 404 unless suggest_params[:facet].in?(%w[city paragraph])

    @search = OfficeSearch.new(index_params)

    render(
      json: {
        html:
          render_to_string(
            partial: "#{suggest_params[:facet]}_results",
            locals: {
              values: @search.facets_for(suggest_params[:facet], suggest: suggest_params[:suggest]),
              params: @search.params
            }
          )
      }
    )
  end

  private

  helper_method :index_params, :show_params

  def index_params
    params.permit(:page, :sort, :order, :q, type: [], city: [], prosecutors_count: [], decrees_count: [], paragraph: [])
  end

  def show_params
    params.permit(:tab, paragraph: [])
  end

  def suggest_params
    params.permit(:facet, :suggest)
  end
end
```

When generating new controllers:

- Inherit from `ApplicationController`.
- Use strong params with `params.permit` grouped in private methods (`index_params`, `show_params`, etc.).
- Use early returns (`return head 404 unless ...`) to simplify branching.
- Keep instance variable setup explicit and ordered.

## ApplicationController & Locale Handling

Use `before_action` with inline block and protected/private methods.

```ruby
class ApplicationController < ActionController::Base
  before_action { set_locale(locale_params[:l] || I18n.default_locale) }

  protected

  def default_url_options
    Rails.application.routes.default_url_options.merge(l: I18n.locale)
  end

  private

  def set_locale(value)
    I18n.locale = value
  rescue I18n::InvalidLocale
    redirect_to :root
  end

  def locale_params
    params.permit(:l)
  end
end
```

## Services and Search Objects

Use plain Ruby objects in `app/services` and the Search pattern in case of faceted-search business logic. 
Use services to provide hide business logic away from the controllers.

Example: OfficeSearch

```ruby
class OfficeSearch
  attr_reader :search

  def initialize(params)
    @search =
      Search.new(
        Office.active.all,
        params: params,
        filters: {
          query: QueryFilter,
          type: TypeFilter,
          city: CityFilter,
          prosecutors_count: ProsecutorsCountFilter,
          paragraph: Search::ParagraphFilter.new(Office),
          decrees_count:
            Search::DecreesCountFilter.new(
              [1..50, 51..200, 201..500, 501..1000, 1001..1500, 1501..2000, 2001..Office.maximum(:decrees_count)]
            ),
          sort: SortFilter
        }
      )
  end

  delegate :all, :paginated, :facets_for, :params, to: :search

  class QueryFilter
    def self.filter(relation, params)
      return relation if params[:q].blank?

      columns = %i[name address city employee]

      ::QueryFilter.filter(relation, params, columns: columns)
    end
  end

  class SortFilter
    def self.filter(relation, params)
      order = params[:order] || 'asc'

      return relation unless order.in?(%w[asc desc])

      return relation.reorder(type: order == 'asc' ? 'desc' : 'asc') if params[:sort] == 'type'
      return relation.reorder(name: order) if params[:sort] == 'name'

      relation.order(id: order)
    end
  end
end
```

## Background Jobs

Pattern:

- Inherit from `ApplicationJob`.
- Use `queue_as :default` unless a specific queue is required.
- Implement `perform` delegating to private helpers.
- Use clear, deterministic string manipulation and ActiveRecord updates.

Example excerpt: ReconcileDecreeJob

```ruby
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
end
```

When generating jobs:

- Keep `perform` short; move complex logic into private methods.
- Prefer `update` on models and use counter caches via `reset_counters` when necessary.

## Lib Modules & Parsers

Lib code is organized into top-level namespaces like `GenproGovSk`, `MinvSk`, etc.

Pattern:

- Use nested modules and plain Ruby classes.
- Use constants for large static mappings.
- Provide single entrypoints like `.parse` returning simple Ruby hashes.
- Use `class << self` with `private` for internal helpers.

Example: GenproGovSk::Prosecutors::Parser

```ruby
module GenproGovSk
  module Prosecutors
    module Parser
      OFFICES_MAP = {
        'Generálna prokuratúra SR' => 'Generálna prokuratúra Slovenskej republiky',
        # ... many mappings ...
      }

      def self.parse(rows)
        rows.map.with_index { |row, i| parse_row(row) }
      end

      class << self
        private

        def parse_row(row)
          source_name, source_office, source_temporary_office = row

          office = parse_office_or_place(source_office)
          temporary_office = parse_office_or_place(source_temporary_office)
          office = OFFICES_MAP[office]

          if office.blank?
            office = OFFICES_MAP.keys.find { |name| row[0].match?(/#{name}/i) }

            raise "Office not found for #{row[0]}" if office.blank?

            source_name = source_name.gsub(/#{office}/i, '').strip
            office = OFFICES_MAP[office]
          end

          name_parts = parse_name(source_name)
          name = name_parts.delete(:value)

          temporary_office = OFFICES_MAP[temporary_office]

          { name: name, name_parts: name_parts, office: office.presence, temporary_office: temporary_office.presence }
        end

        # ...
      end
    end
  end
end
```

When generating lib code:

- Keep public API small (e.g., `.parse`, `.import`).
- Use pure functions and simple data structures (hashes, arrays) where possible.
- Use `presence`, `blank?`, and ActiveSupport helpers idiomatically.

## Logging

When logging in lib or service classes, follow this format:

- Prefix messages with the class/module name.
- Wrap interpolated values in square brackets.

Example pattern:

```ruby
Rails.logger.info "GenproGovSk::Prosecutors::Importer # Importing prosecutors ..."
Rails.logger.info "GenproGovSk::Prosecutors::Importer # Importing prosecutors completed in [#{time_taken_ms} ms]"
```

## ActiveRecord Models

Patterns from existing specs and models:

- Use standard Rails validations (`validate_presence_of`, `validate_uniqueness_of`).
- Use JSONB columns for structured data (e.g., `registry`, `name_parts`).
- Keep complex validation logic inside the model with clear error messages.

Guidance for Copilot when generating models:

- Use `belongs_to` with `.optional(true)` where associations can be nil.
- Validate presence and uniqueness as needed, matching existing patterns.
- Prefer value objects and hashes for flexible JSONB fields, and validate their structure inside custom validators.
