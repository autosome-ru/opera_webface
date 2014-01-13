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
    pm_first = Bioinform.const_get(data_model_first).new(matrix_first).set_parameters(background: background)
    pm_first.set_parameters(pseudocount: pseudocount_first)  if pseudocount_first && ! pseudocount_first.blank? && [:PCM,:PPM].include?(data_model_first.to_sym)
    pm_first.set_parameters(effective_count: effective_count_first)  if effective_count_first && [:PPM].include?(data_model_first.to_sym)
    self.pwm_first = pm_first.to_pwm.tap{|pwm| pwm.name = pm_first.name}.to_s

    pm_second = Bioinform.const_get(data_model_second).new(matrix_second).set_parameters(background: background)
    pm_second.set_parameters(pseudocount: pseudocount_second)  if pseudocount_second && ! pseudocount_second.blank? && [:PCM,:PPM].include?(data_model_second.to_sym)
    pm_second.set_parameters(effective_count: effective_count_second)  if effective_count_second && [:PPM].include?(data_model_second.to_sym)
    self.pwm_second = pm_second.to_pwm.tap{|pwm| pwm.name = pm_second.name}.to_s
  end
end
