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

  attribute :snp_list_text, String
  attribute :snp_list_file, IO, default: nil

  attribute :collection, Symbol
  attribute :pvalue_cutoff, Float
  attribute :fold_change_cutoff, Float

  def snp_list
    @snp_list ||= snp_list_file ? snp_list_file.read : snp_list_text
  end

  def task_attributes
    result = attributes.reject{|attr_name, attr_value|
      [:snp_list_text, :snp_list_file].include?(attr_name)
    }.merge(snp_list: snp_list)
  end

  private def validate_snp_list(attribute_name, attribute_value)
    errors.add(attribute_name, 'No SNP sequences provided')  if attribute_value.blank?
    errors.add(attribute_name, 'SNP sequences are in wrong format') unless SnpListValidator.new.valid?(attribute_value)
  end

  private def validate_snp_list_text_or_file
    if snp_list_file
      validate_snp_list(:snp_list_file, snp_list)
    else
      validate_snp_list(:snp_list_text, snp_list)
    end
  end

  validate :validate_snp_list_text_or_file

  validates :collection, motif_collection: true
  validates :pvalue_cutoff, presence: true, numericality: {less_than_or_equal_to: 1, greater_than_or_equal_to: 0}
  validates :fold_change_cutoff, presence: true, numericality: {greater_than: 0}

  def self.task_type; 'SnpScan'; end
end
