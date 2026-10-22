# frozen_string_literal: true

module FacetsHelper
  def collapsible_facet_results(facets, selected: [], limit: 5, &renderer)
    visible = facets.to_a[0...limit]
    hidden = facets.to_a[limit..]
    if facets.is_a?(Hash)
      visible = visible.to_h
      hidden = hidden.to_h
    end
    id = "collapsible-facet-values-#{SecureRandom.hex}"

    render(
      partial: 'facets/collapsible_results',
      locals: { id: id, visible: visible, hidden: hidden, renderer: renderer, selected: selected }
    )
  end
end
