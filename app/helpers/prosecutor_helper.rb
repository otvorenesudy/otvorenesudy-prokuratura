module ProsecutorHelper
  def prosecutors_path(*args, &block)
    path = super(*args, &block)

    args.any? && args[0].any? ? "#{path}#facets" : path
  end
end
