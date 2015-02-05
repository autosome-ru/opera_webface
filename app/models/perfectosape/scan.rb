class Perfectosape::Scan < ::Task
  add_task_params :snp_list, &->(list){
    list.lines.map(&:strip).reject(&:empty?).map{|l|
      name, seq = l.split(/\s+/, 2)
      seq_w_snp = SequenceWithSNP.from_string(seq.gsub(/[[:space:]]/, ''))
      seq_left = seq_w_snp.left
      seq_right = seq_w_snp.right
      seq_allele_variants = seq_w_snp.allele_variants

      seq_w_snp_elongated = SequenceWithSNP.new('n' * [(25 - seq_left.length), 0].max + seq_left,
                                                seq_allele_variants,
                                                seq_right + 'n' * [(25 - seq_right.length), 0].max)

      "#{name}\t#{seq_w_snp_elongated}"
    }.join("\n")
  }
  add_task_params :collection, &:to_sym
  add_task_params :pvalue_cutoff, &:to_f
  add_task_params :fold_change_cutoff, &:to_f
  # add_background_task_param :background

  extend Enumerize
  enumerize :collection, in: [:hocomoco, :jaspar, :selex, :swissregulon, :homer]

  add_task_permitted_param(:snp_list_file)

  validates :pvalue_cutoff, presence: true, numericality: {less_than_or_equal_to: 1, greater_than_or_equal_to: 0}
  validates :fold_change_cutoff, presence: true, numericality: {greater_than: 0}
  validate do |task|
    unless task.snp_list.each_line.all?{|line| Perfectosape::Scan.valid_SNP_line?(line) }
      task.errors.add(:snp_list, 'SNP sequences are in wrong format')
    end
  end

  def self.valid_SNP_line?(line)
    line.strip.match(/\A\w+\s+[ACGTN]*\[[ACGTN]\/[ACGTN]\][ACGTN]+\z/i)
  end

  def snp_list_file=(value)
    self.snp_list = value.read
  end

  def self.task_type
    'SnpScan'
  end
end
