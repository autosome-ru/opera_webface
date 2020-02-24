require 'virtus'
require 'active_model'
require 'bioinform'
require_relative '../model_creation'
require_relative '../task_form'
require_relative '../data_model_form'
require_relative '../background_form'
require_relative '../../validators/recursive_valid_validator'
require_relative '../../validators/pvalue_boundary_validator'

class Macroape::CompareForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)
  include TaskForm

  attribute :first_motif, DataModelForm
  attribute :second_motif, DataModelForm
  attribute :background, BackgroundForm
  attribute :pvalue, Float
  attribute :pvalue_boundary, Symbol
  attribute :discretization, Float

  validates :first_motif, recursive_valid: true
  validates :second_motif, recursive_valid: true
  validates :background, recursive_valid: true
  validates :pvalue, presence: true, numericality: {less_than_or_equal_to: 0.001, greater_than: 0}
  validates :pvalue_boundary, pvalue_boundary: true
  validates :discretization, presence: true, numericality: {less_than_or_equal_to: 10, greater_than: 0}

  def self.task_type; 'EvaluateSimilarity'; end
  def store_input_data(folder)
    Dir.chdir(folder) do
      File.write('task_params.yaml', task_params.to_yaml)

      background = BackgroundForm.new(task_params[:background]).background
      save_motif_in_different_types(task_params[:first_motif], background: background, basename: 'first')
      save_motif_in_different_types(task_params[:second_motif], background: background, basename: 'second')
    end
  end
end
