require 'bioinform'

class Macroape::Compare < ::Task
  add_background_task_param :background

  add_data_model_task_param :first_motif, :background
  add_data_model_task_param :second_motif, :background

  add_task_params :pvalue, &:to_f
  add_task_params :discretization, &:to_f
  add_task_params :pvalue_boundary

  validates :pvalue, presence: true, numericality: {less_than_or_equal_to: 0.001, greater_than: 0}
  validates :discretization, presence: true, numericality: {less_than_or_equal_to: 10, greater_than: 0}

  extend Enumerize
  enumerize :pvalue_boundary, in: [:lower, :upper]

  def self.task_type
    'EvaluateSimilarity'
  end
end
