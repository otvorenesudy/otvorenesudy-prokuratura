# frozen_string_literal: true

module Bootstrap
  # Tabs whose links sit in a list with data-controller="tabs" (the URL's hash opens a tab).
  module TabHelper
    def tab_link_tag(title, tab, options = {})
      classes = Array.wrap(options[:class]).unshift('nav-link')
      active = classes.include?('active')
      data = { bs_toggle: 'tab', action: 'shown.bs.tab->tabs#shown' }
      aria = { selected: active, controls: tab }

      tag.li(class: 'nav-item', role: 'presentation') do
        link_to title, "##{tab}", options.deep_merge(class: classes, data:, aria:, role: 'tab',
                                                     tabindex: (-1 unless active))
      end
    end

    def tab_content_tag(tab, options = {}, &)
      classes = Array.wrap(options[:class]).unshift('tab-pane')

      tag.div(**options, id: tab, class: classes, role: 'tabpanel', &)
    end

    # A tab's pane with the partial in it, named after the partial unless the tab is given.
    def render_tab(partial:, tab: partial.split('/').last, locals: {}, **options)
      tab_content_tag(tab, class: options[:class]) { render(partial, locals) }
    end
  end
end
