require 'bioinform'

class ScanCollection < Task
  add_task_params :query_matrix, :query_pwm
  add_background_task_params :query_background
  add_task_params :pvalue, &:to_f
  add_task_params :pvalue_boundary
  add_task_params :similarity_cutoff
  add_task_params :precise_recalc_cutoff
  add_task_params :collection
  add_task_params :query_data_model
  add_task_params :query_effective_count, :query_pseudocount, &->(x){ (x && !x.blank?) ? x.to_f : nil}


  extend Enumerize
  enumerize :pvalue_boundary, in: [:lower, :upper]
  enumerize :collection, in: [:hocomoco, :jaspar, :selex, :swissregulon, :homer]
  enumerize :query_data_model, in: [:PCM, :PPM, :PWM]

  def initialize(*)
    super
    self.query_pwm = Bioinform.get_pwm(query_data_model, query_matrix, query_background, query_pseudocount, query_effective_count).to_s
  end
end
