class ProsecutorReconciler
  attr_accessor :data

  def initialize(data, list)
    @data = data
    @list = list
  end

  def reconcile!; end
end
