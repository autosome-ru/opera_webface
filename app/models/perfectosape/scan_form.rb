require 'virtus'
require 'active_model'
require 'bioinform'
require_relative '../task_form'
require_relative '../text_or_file_form'
require_relative '../../validators/recursive_valid_validator'
require_relative '../../validators/motif_collection_validator'
require_relative '../../validators/snp_list_validator'

class Perfectosape::ScanForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)
  include TaskForm

  attribute :snp_list, TextOrFileForm
  attribute :collection, Symbol
  attribute :pvalue_cutoff, Float
  attribute :fold_change_cutoff, Float

  validates :snp_list, recursive_valid: true, snp_list: {wrapped_attribute: :value}
  validates :collection, motif_collection: true
  validates :pvalue_cutoff, presence: true, numericality: {less_than_or_equal_to: 1, greater_than_or_equal_to: 0}
  validates :fold_change_cutoff, presence: true, numericality: {greater_than: 0}

  def self.task_type; 'SnpScan'; end
end
