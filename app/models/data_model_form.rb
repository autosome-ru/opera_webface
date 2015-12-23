require 'active_model'
require 'enumerize'
require 'bioinform'
require_relative 'background'
require_relative 'model_creation'

class DataModelForm
  include ActiveModel::Model
  extend Enumerize
  enumerize :data_model, in: [:PCM, :PWM, :PPM]

# matrix - is text(!) representation of matrix
  attr_accessor :matrix, :background
  attr_reader :data_model, :effective_count, :pseudocount

  def to_hash
    result = {matrix: matrix, data_model: data_model, effective_count: effective_count, pseudocount: pseudocount, background: background.to_hash}
    case data_model
    when :PWM
      result.merge(pwm: pwm.to_s)
    else
      result.merge(pwm: pwm.to_s, pcm: pcm.to_s, ppm: ppm.to_s)
    end
  end

  def data_model=(value)
    @data_model = value.to_s.upcase.to_sym
  end

  def effective_count=(value)
    @effective_count = value.to_f
  end

  def pseudocount=(value)
    @pseudocount = case value
    when String
      value.blank? ? :log : value.to_f
    else
      value
    end
  end

  def pwm
    Bioinform.get_pwm(data_model, matrix, background.background, pseudocount, effective_count)
  end

  def pcm
    case data_model
    when :PCM, :PPM
      Bioinform.get_pcm(data_model, matrix, effective_count)
    else
      nil
    end
  end

  def ppm
    case data_model
    when :PCM, :PPM
      Bioinform.get_ppm(data_model, matrix)
    else
      nil
    end
  end

  def data_model_object
    case data_model
    when :PWM
      pwm
    when :PCM
      pcm
    when :PPM
      ppm
    end
  end

  validates :effective_count, presence: true, numericality: {greater_than: 0}, :if => ->(model){ model.data_model == :PPM }
  validates :pseudocount, numericality: {greater_than_or_equal_to: 0}, :if => ->(model){ [:PPM, :PCM].include?(model.data_model) && model.pseudocount && model.pseudocount !=  :log }

  validate do |record|
    record.errors.add(:data_model, "Unknown data model #{record.data_model}")  unless [:PWM, :PCM, :PPM].include? record.data_model
    # Don't check model unless background is valid: it will throw an exception
    # because model evaluation with broken background is impossible
    if !record.background.valid?
      record.errors.add(:base, "is invalid because it depends on invalid background value")
    else
      parser = Bioinform::MatrixParser.new
      if parser.valid?(record.matrix)
        matrix_infos = parser.parse!(record.matrix)
        validator = Bioinform.get_model_class(record.data_model).const_get(:VALIDATOR)
        validation_results = validator.validate_params(matrix_infos[:matrix], Bioinform::NucleotideAlphabet)
        record.errors.add(:matrix, validation_results.to_s)  unless validation_results.valid?
      else
        record.errors.add(:matrix, "Can't parse matrix")
      end
    end
  end
end
