module Bootstrap
  module BarHelper
    def bar_link_to(title, path, options = {})
      path.gsub!(/\?.+\z/, '')

      classes = Array.wrap(options[:class]).unshift 'nav-item nav-link'
      classes << 'active' if path.present? && request.fullpath.start_with?(path)
      link_to title, path, options.merge(class: classes)
    end
  end
end
