require 'virtus'
require 'active_model'
require 'bioinform'

class Macroape::CompareForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true) # , strict: true
  include TaskForm

  attribute :first_motif, DataModelForm
  attribute :second_motif, DataModelForm
  attribute :background, BackgroundForm
  attribute :pvalue, Float
  attribute :pvalue_boundary, Symbol
  attribute :discretization, Float

  alias_method :first_motif_attributes=, :first_motif=
  alias_method :second_motif_attributes=, :second_motif=
  alias_method :background_attributes=, :background=

  PVALUE_BOUNDARY_VARIANTS = [:lower, :upper]

  validates :pvalue, presence: true, numericality: {less_than_or_equal_to: 0.001, greater_than: 0}
  validates :pvalue_boundary,  inclusion: {in: PVALUE_BOUNDARY_VARIANTS, message: 'Unknown P-value boundary `%{value}`'}
  validates :discretization, presence: true, numericality: {less_than_or_equal_to: 10, greater_than: 0}

  def self.task_type; 'EvaluateSimilarity'; end
end
