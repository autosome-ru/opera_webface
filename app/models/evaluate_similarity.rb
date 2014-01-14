require 'bioinform'

class EvaluateSimilarity < Task
  add_task_params :matrix_first, :matrix_second, :pwm_first, :pwm_second
  add_background_task_params :background
  add_task_params :pvalue, :discretization, &:to_f
  add_task_params :pvalue_boundary

  add_task_params :data_model_first
  add_task_params :effective_count_first, :pseudocount_first, &->(x){ (x && !x.blank?) ? x.to_f : nil}


  add_task_params :data_model_second
  add_task_params :effective_count_second, :pseudocount_second, &->(x){ (x && !x.blank?) ? x.to_f : nil}

  extend Enumerize
  enumerize :pvalue_boundary, in: [:lower, :upper]
  enumerize :data_model_first, in: [:PCM, :PWM, :PPM]
  enumerize :data_model_second, in: [:PCM, :PWM, :PPM]

  validates :background, background: true

  def initialize(*)
    super
    self.pwm_first = Bioinform.get_pwm(data_model_first, matrix_first, background, pseudocount_first, effective_count_first).to_s
    self.pwm_second = Bioinform.get_pwm(data_model_second, matrix_second, background, pseudocount_second, effective_count_second).to_s
  end
end
