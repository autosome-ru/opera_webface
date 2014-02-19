require 'bioinform'

class Macroape::Scan < ::Task
  add_background_task_param :query_background
  add_data_model_task_param :query, :query_background
  add_task_params :pvalue, &:to_f
  add_task_params :pvalue_boundary, &:to_sym
  add_task_params :similarity_cutoff
  add_task_params :precise_recalc_cutoff
  add_task_params :collection

  validates :pvalue, presence: true, numericality: {less_than_or_equal_to: 0.001, greater_than: 0}

  extend Enumerize
  enumerize :pvalue_boundary, in: [:lower, :upper]
  enumerize :collection, in: [:hocomoco, :jaspar, :selex, :swissregulon, :homer]

  def self.task_type
    'ScanCollection'
  end
end
