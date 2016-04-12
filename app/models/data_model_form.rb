require 'virtus'
require 'active_model'
require 'bioinform'
require_relative 'task_form'

class DataModelForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)
  include TaskForm
  attribute :matrix, String  # matrix - is text(!) representation of matrix
  attribute :data_model, Symbol
  attribute :effective_count, Float
  attribute :pseudocount, Object, default: :log

  def pseudocount=(value)
    if !value || value.blank? || value.to_s.downcase == 'log'
      super(:log)
    else
      val = Float(value) rescue value
      super(val)
    end
  end

  validates :data_model, inclusion: {in: [:PCM, :PWM, :PPM] }
  validates :effective_count, presence: true, numericality: {greater_than: 0}, :if => ->(model){ model.data_model == :PPM }
  validates :pseudocount, numericality: {greater_than_or_equal_to: 0, message: 'should be either non-negative number or `log` string'}, :if => :need_pseudocount?
  validate :check_matrix_valid

  private def need_pseudocount?
    [:PPM, :PCM].include?(data_model) && (pseudocount != :log)
  end

  private def model_class
    Bioinform::MotifModel.const_get(data_model)
  end

  private def check_matrix_valid
    parser = Bioinform::MatrixParser.new
    if parser.valid?(matrix)
      matrix_infos = parser.parse!(matrix)
      validator = model_class.const_get(:VALIDATOR)
      validation_results = validator.validate_params(matrix_infos[:matrix], Bioinform::NucleotideAlphabet)
      if !validation_results.valid?
        errors.add(:matrix, validation_results.to_s)
      end
    else
      errors.add(:matrix, "Can't parse matrix")
    end
  end

end
