require 'virtus'
require 'bioinform'
require_relative 'model_creation'

class DataModelForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)
  attribute :matrix, String  # matrix - is text(!) representation of matrix
  attribute :data_model, Symbol
  attribute :effective_count, Float
  attribute :pseudocount, Object, default: :log

  def data_model=(value)
    super(value.to_s.upcase.to_sym)
  end

  def pseudocount=(value)
    if !value || value.blank? || value.to_s.downcase == 'log'
      super(:log)
    else
      super(value.to_f)
    end
  end

  DATA_MODEL_VARIANTS = [:PCM, :PWM, :PPM]

  validates :data_model,  inclusion: {in: DATA_MODEL_VARIANTS, message: 'Unknown data model `%{value}`'}
  validates :effective_count, presence: true, numericality: {greater_than: 0}, :if => ->(model){ model.data_model == :PPM }
  validates :pseudocount, numericality: {greater_than_or_equal_to: 0}, :if => ->(model){
    [:PPM, :PCM].include?(model.data_model) && model.pseudocount && model.pseudocount !=  :log
  }

  validate do |record|
    parser = Bioinform::MatrixParser.new
    if parser.valid?(record.matrix)
      matrix_infos = parser.parse!(record.matrix)
      validator = Bioinform.get_model_class(record.data_model).const_get(:VALIDATOR)
      validation_results = validator.validate_params(matrix_infos[:matrix], Bioinform::NucleotideAlphabet)
      if !validation_results.valid?
        record.errors.add(:matrix, validation_results.to_s)
      end
    else
      record.errors.add(:matrix, "Can't parse matrix")
    end
  end

end
