module FacetsHelper
  def collapsible_facet_results(facets, selected: [], limit: 5, &renderer)
    visible, hidden = facets.to_a[0...limit], facets.to_a[limit..-1]
    visible, hidden = visible.to_h, hidden.to_h if facets.is_a?(Hash)
    id = "collapsible-facet-values-#{SecureRandom.hex}"

    render(
      partial: 'facets/collapsible_results',
      locals: { id: id, visible: visible, hidden: hidden, renderer: renderer, selected: selected }
    )
  end
end
