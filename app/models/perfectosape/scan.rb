class Perfectosape::Scan < ::Task
  add_task_params :snp_list
  add_task_params :collection
  add_task_params :pvalue_cutoff, :fold_change_cutoff, &:to_f
  #add_task_params :discretization
  add_background_task_params :background

  extend Enumerize
  enumerize :collection, in: [:hocomoco, :jaspar, :selex, :swissregulon, :homer]

  def self.task_type
    'SnpScan'
  end
end
