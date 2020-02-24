require 'virtus'
require 'active_model'
require 'bioinform'
require_relative '../model_creation'
require_relative '../task_form'
require_relative '../data_model_form'
require_relative '../background_form'
require_relative '../../validators/recursive_valid_validator'
require_relative '../../validators/motif_collection_validator'
require_relative '../../validators/pvalue_boundary_validator'

class Macroape::ScanForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)
  include TaskForm

  attribute :collection, Symbol
  attribute :query, DataModelForm
  attribute :background, BackgroundForm
  attribute :pvalue, Float
  attribute :pvalue_boundary, Symbol
  attribute :similarity_cutoff, Float
  attribute :precise_recalc_cutoff, Float

  validates :collection, motif_collection: true
  validates :query, recursive_valid: true
  validates :background, recursive_valid: true
  validates :pvalue, presence: true, numericality: {less_than_or_equal_to: 0.001, greater_than: 0}
  validates :pvalue_boundary, pvalue_boundary: true
  validates :similarity_cutoff, presence: true, numericality: {less_than_or_equal_to: 1, greater_than_or_equal_to: 0}
  validates :precise_recalc_cutoff, presence: true, numericality: {less_than_or_equal_to: 1, greater_than_or_equal_to: 0}

  def self.task_type; 'ScanCollection'; end
  def store_input_data(folder)
    Dir.chdir(folder) do
      File.write('task_params.yaml', task_params.to_yaml)

      background = BackgroundForm.new(task_params[:background]).background
      save_motif_in_different_types(task_params[:query], background: background, basename: 'query')
    end
  end
end
