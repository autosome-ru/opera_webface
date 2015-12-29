require 'virtus'
require 'active_model'
require 'bioinform'

class Perfectosape::ScanForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true) # , strict: true
  include TaskForm

  # attribute :snp_list, SNPListInput
  attribute :snp_list, TextOrFileForm
  attribute :collection, Symbol
  attribute :pvalue_cutoff, Float
  attribute :fold_change_cutoff, Float

  alias_method :snp_list_attributes=, :snp_list=

  SNP_PATTERN = /\A[ACGTN]*\[[ACGTN]\/[ACGTN]\][ACGTN]+\z/i
  COLLECTION_VARIANTS = [:hocomoco_10_human, :hocomoco_10_mouse, :hocomoco, :jaspar, :selex, :swissregulon, :homer]

  validates :collection,  inclusion: {in: COLLECTION_VARIANTS, message: 'Unknown collection `%{value}`'}
  validates :pvalue_cutoff, presence: true, numericality: {less_than_or_equal_to: 1, greater_than_or_equal_to: 0}
  validates :fold_change_cutoff, presence: true, numericality: {greater_than: 0}
  validate do |task|
    task.errors.add(:snp_list, 'SNP sequences are in wrong format')  unless valid_snp_list?(task.snp_list.value)
  end

  def self.valid_snp_format?(line)
    seq = line.strip.split(/[[:space:]]+/, 2)[1] || ''
    seq.gsub(/[[:space:]]/, '').match(SNP_PATTERN)
  end
  def self.valid_snp_list?(text)
    text.lines.all?{|line|
      valid_snp_format?(line)
    } && !text.lines.empty?
  end

  def self.task_type; 'SnpScan'; end
end
