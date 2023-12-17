module Bootstrap
  module BarHelper
    def bar_link_to(title, path, options = {})
      classes = Array.wrap(options[:class]).unshift 'nav-item nav-link'
      classes << 'active' if path.present? && request.fullpath.start_with?(path.gsub(/\?.*\z/, ''))
      link_to title, path, options.merge(class: classes)
    end

    def dropdown_bar_link_to(title, path, links, options = {})
      classes = Array.wrap(options[:class]).unshift 'nav-item dropdown'
      active = path.present? && request.fullpath.start_with?(path.gsub(/\?.*\z/, ''))

      content_tag(:li, class: classes) do
        content_tag(
          :a,
          title,
          class: "nav-link ml-0 dropdown-toggle #{'active' if active}",
          href: '#',
          data: {
            toggle: 'dropdown'
          }
        ) +
          content_tag(:div, class: 'dropdown-menu mt-2') do
            links
              .map do |attributes|
                title, path = attributes.values_at(:title, :path)
                options = attributes[:options] || {}

                classes = Array.wrap(options[:classes]).unshift 'dropdown-item'
                classes << 'active' if path.present? && request.fullpath.start_with?(path.gsub(/\?.*\z/, ''))

                link_to(title, path, (options || {}).merge(class: classes))
              end
              .join
              .html_safe
          end
      end
    end
  end
end
