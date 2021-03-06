module Bootstrap
  module BarHelper
    def bar_link_to(title, path, options = {})
      classes = Array.wrap(options[:class]).unshift 'nav-item nav-link'
      classes << 'active' if path.present? && request.fullpath.start_with?(path.gsub(/\?.*\z/, ''))
      link_to title, path, options.merge(class: classes)
    end
  end
end
