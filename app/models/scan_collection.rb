require 'bioinform'

class ScanCollection < Task
  add_task_params :query_matrix, :query_pwm
  add_background_task_params :query_background
  add_task_params :pvalue, &:to_f
  add_task_params :pvalue_boundary
  add_task_params :similarity_cutoff
  add_task_params :precise_recalc_cutoff
  add_task_params :collection_background
  add_task_params :query_data_model
  add_task_params :query_effective_count, :query_pseudocount, &->(x){ (x && !x.blank?) ? x.to_f : nil}


  extend Enumerize
  enumerize :pvalue_boundary, in: [:lower, :upper]
  enumerize :collection_background, in: [:uniform, :hg19]
  enumerize :query_data_model, in: [:PCM, :PPM, :PWM]

  def initialize(*)
    super
    self.query_pwm = Bioinform.const_get(query_data_model).new(query_matrix).set_parameters(background: query_background).to_pwm.to_s
  end
end
