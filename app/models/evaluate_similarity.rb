class EvaluateSimilarity < Task
  add_task_params :matrix_first, :matrix_second, :pwm_first, :pwm_second
  add_task_params :background, :first_background, :second_background do |x| decode_background(x); end
  add_task_params :pvalue, :discretization, &:to_f
  add_task_params :pvalue_boundary

  extend Enumerize
  enumerize :pvalue_boundary, in: [:lower, :upper]

  def initialize(*)
    super
    self.pwm_first = matrix_first
    self.pwm_second = matrix_second
    self.first_background ||= background
    self.second_background ||= background
  end

  def self.decode_background(str)
    case str
    when Array
      str.map(&:to_f)
    when String
      str.tr('[]','  ').gsub(/\s/,'').split(',').map(&:to_f)
    end
  end

end
