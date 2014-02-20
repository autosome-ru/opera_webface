class Perfectosape::Scan < ::Task
  add_task_params :snp_list
  add_task_params :collection, &:to_sym
  add_task_params :pvalue_cutoff, &:to_f
  add_task_params :fold_change_cutoff, &:to_f
  add_background_task_param :background

  extend Enumerize
  enumerize :collection, in: [:hocomoco, :jaspar, :selex, :swissregulon, :homer]

  add_task_permitted_param(:snp_list_file)

  validates :pvalue_cutoff, presence: true, numericality: {less_than_or_equal_to: 1, greater_than_or_equal_to: 0}
  validates :fold_change_cutoff, presence: true, numericality: {greater_than: 0}
  validate do |task|
    unless task.snp_list.each_line.all?{|line| valid_SNP_line?(line, minimal_flank_size: 12) }
      task.errors.add(:snp_list, 'SNP sequences are in wrong format')
    end
  end

  def valid_SNP_line?(line, minimal_flank_size: 25)
    line.strip.match(/\A\w+\s.*[ACGT]{#{minimal_flank_size},}\[[ACGT]\/[ACGT]\][ACGT]{#{minimal_flank_size},}\z/i)
  end

  def snp_list_file=(value)
    self.snp_list = value.read
  end

  def self.task_type
    'SnpScan'
  end
end
