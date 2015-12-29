require 'virtus'
require 'active_model'
require 'bioinform'

class Macroape::ScanForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true) # , strict: true
  include TaskForm

  attribute :collection, Symbol
  attribute :query, DataModelForm
  attribute :background, BackgroundForm
  attribute :pvalue, Float
  attribute :pvalue_boundary, Symbol
  attribute :similarity_cutoff, Float
  attribute :precise_recalc_cutoff, Float

  alias_method :query_attributes=, :query=
  alias_method :background_attributes=, :background=

  PVALUE_BOUNDARY_VARIANTS = [:lower, :upper]
  COLLECTION_VARIANTS = [:hocomoco_10_human, :hocomoco_10_mouse, :hocomoco, :jaspar, :selex, :swissregulon, :homer]

  validates :collection,  inclusion: {in: COLLECTION_VARIANTS, message: 'Unknown collection `%{value}`'}
  validates :pvalue, presence: true, numericality: {less_than_or_equal_to: 0.001, greater_than: 0}
  validates :pvalue_boundary,  inclusion: {in: PVALUE_BOUNDARY_VARIANTS, message: 'Unknown P-value boundary `%{value}`'}
  validates :similarity_cutoff, presence: true, numericality: {less_than_or_equal_to: 1, greater_than_or_equal_to: 0}
  validates :precise_recalc_cutoff, presence: true, numericality: {less_than_or_equal_to: 1, greater_than_or_equal_to: 0}

  def self.task_type; 'ScanCollection'; end
end
