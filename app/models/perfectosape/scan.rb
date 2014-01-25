class Perfectosape::Scan < ::Task
  add_task_params :snp_list
  add_task_params :collection
  add_task_params :pvalue_cutoff, :fold_change_cutoff, &:to_f
  add_background_task_param :background

  extend Enumerize
  enumerize :collection, in: [:hocomoco, :jaspar, :selex, :swissregulon, :homer]

  add_task_permitted_param(:snp_list_file)

  def snp_list_file=(value)
    self.snp_list = value.read
  end

  def self.task_type
    'SnpScan'
  end
end
