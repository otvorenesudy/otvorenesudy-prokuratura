# frozen_string_literal: true

module Bootstrap
  # The navigation bar's links, marked active on the pages they lead to.
  module BarHelper
    def bar_link_to(title, path, options = {})
      classes = Array.wrap(options[:class]).unshift 'nav-item nav-link'
      classes << 'active' if current_path?(path)

      link_to title, path, options.merge(class: classes)
    end

    # A menu in the bar: its title, active on any page under `path`, opens the links ({ title:, path: }).
    def dropdown_bar_link_to(title, path, links, options = {})
      id = "#{path.parameterize}-dropdown"
      classes = Array.wrap(options[:class]).unshift 'nav-item dropdown'

      tag.div(class: classes) do
        toggle = link_to title, '#', id:, class: ['nav-link ms-0 dropdown-toggle', ('active' if current_path?(path))],
                                     data: { bs_toggle: 'dropdown' }, role: 'button', aria: { expanded: false }
        items = links.map do |link|
          link_to link[:title], link[:path], class: ['dropdown-item', ('active' if current_path?(link[:path]))]
        end

        toggle + tag.div(safe_join(items), class: 'dropdown-menu mt-2', aria: { labelledby: id })
      end
    end

    private

    def current_path?(path)
      path.present? && request.fullpath.start_with?(path.sub(/\?.*\z/, ''))
    end
  end
end
