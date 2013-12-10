class EvaluateSimilarity < Task
  add_task_params :matrix_first, :matrix_second, :pwm_first, :pwm_second
  add_background_task_params :background, :first_background, :second_background
  add_task_params :pvalue, :discretization, &:to_f
  add_task_params :pvalue_boundary
  add_task_params :data_model_first
  add_task_params :data_model_second

  extend Enumerize
  enumerize :pvalue_boundary, in: [:lower, :upper]
  enumerize :data_model_first, in: [:PCM, :PWM]
  enumerize :data_model_second, in: [:PCM, :PWM]


  def initialize(*)
    super
    self.pwm_first = Bioinform.const_get(data_model_first).new(matrix_first).set_parameters(background: first_background).to_pwm.to_s
    self.pwm_second = Bioinform.const_get(data_model_second).new(matrix_second).set_parameters(background: second_background).to_pwm.to_s
    self.first_background ||= background
    self.second_background ||= background
  end
end
