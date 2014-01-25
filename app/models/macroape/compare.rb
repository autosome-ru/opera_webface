require 'bioinform'

class Macroape::Compare < ::Task
  add_background_task_param :background

  add_data_model_task_param :first_motif, :background
  add_data_model_task_param :second_motif, :background

  add_task_params :pvalue, :discretization, &:to_f
  add_task_params :pvalue_boundary


  extend Enumerize
  enumerize :pvalue_boundary, in: [:lower, :upper]

  def self.task_type
    'EvaluateSimilarity'
  end
end
