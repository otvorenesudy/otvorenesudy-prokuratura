class ProsecutorReconciler
  attr_accessor :data

  def initialize(data, list)
    @data = data
    @list = list
  end

  def reconcile!
    prosecutor = Prosecutor.find_or_initialize_by(genpro_gov_sk_name: data[:genpro_gov_sk_name])

    prosecutor.with_lock { prosecutor.update!(name: data[:name], genpro_gov_sk_prosecutors_list: list) }
  end
end
