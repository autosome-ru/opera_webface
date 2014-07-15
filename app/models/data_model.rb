require 'active_model'
require 'enumerize'
require 'bioinform'
require_relative 'background'

class DataModel
  include ActiveModel::Model
  extend Enumerize
  enumerize :data_model, in: [:PCM, :PWM, :PPM]

# matrix - is text(!) representation of matrix
  attr_accessor :matrix, :background
  attr_reader :data_model, :effective_count, :pseudocount

  # def self.get_model(data_model, matrix, name)
  #   Bioinform::MotifModel.const_get(data_model).new(matrix).named(name)
  # end

  # def self.get_model_from_string(data_model, matrix_string)
  #   motif_infos = Bioinform::MatrixParser.new.parse(matrix_string)
  #   get_model(data_model, motif_infos[:matrix], motif_infos[:name])
  # end

  def to_hash
    result = {matrix: matrix, data_model: data_model, effective_count: effective_count, pseudocount: pseudocount, background: background.to_hash}
    # case data_model
    # when :PWM
    #   result.merge(pwm: pwm.to_s)
    # else
    #   result.merge(pwm: pwm.to_s, pcm: pcm.to_s, ppm: ppm.to_s)
    # end#.tap{|x|p x}
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
      value.blank? ? nil : value.to_f
    else
      value
    end
  end

  def motif
    Bioinform::MotifModel.const_get(data_model).from_string(matrix)
  end

  def pwm
    # OperaWebface::DataModelPresenter.get_pwm(data_model, matrix, background, pseudocount, effective_count)
    background = background.value
    # input_model = self.class.get_model_from_string(data_model, matrix)
    input_model = motif
    if Bioinform::MotifModel.acts_as_ppm?(input_model)
      ppm2pcm_converter = Bioinform::ConversionAlgorithms::PPM2PCMConverter.new(count: effective_count)
      pcm2pwm_converter = Bioinform::ConversionAlgorithms::PCM2PWMConverter.new(background: background, pseudocount: pseudocount || :log)
      pcm2pwm_converter.convert(ppm2pcm_converter.convert(input_model))
    elsif Bioinform::MotifModel.acts_as_pcm?(input_model)
      pcm2pwm_converter = Bioinform::ConversionAlgorithms::PCM2PWMConverter.new(background: background, pseudocount: pseudocount || :log)
      pcm2pwm_converter.convert(input_model)
    elsif Bioinform::MotifModel.acts_as_pwm?(input_model)
      input_model
    else
      raise Bioinform::Error, "Unknown input `#{input_model}`"
    end
  rescue => e
    raise Bioinform::Error, "PWM creation failed (#{e})"
  end

  def pcm
    # input_model = self.class.get_model_from_string(data_model, matrix)
    input_model = motif
    if Bioinform::MotifModel.acts_as_ppm?(input_model)
      ppm2pcm_converter = Bioinform::ConversionAlgorithms::PPM2PCMConverter.new(count: effective_count)
      ppm2pcm_converter.convert(input_model)
    elsif Bioinform::MotifModel.acts_as_pcm?(input_model)
      input_model
    elsif Bioinform::MotifModel.acts_as_pwm?(input_model)
      raise Bioinform::Error, 'Conversion PWM-->PCM not yet implemented'
    else
      raise Bioinform::Error, "Unknown input `#{input_model}`"
    end
  rescue => e
    raise Bioinform::Error, "PCM creation failed (#{e})"
  end

  def ppm
    # input_model = self.class.get_model_from_string(data_model, matrix)
    input_model = motif
    if Bioinform::MotifModel.acts_as_ppm?(input_model)
      input_model
    elsif Bioinform::MotifModel.acts_as_pcm?(input_model)
      pcm2ppm_converter = Bioinform::ConversionAlgorithms::PCM2PPMConverter.new
      pcm2ppm_converter.convert(input_model)
    elsif Bioinform::MotifModel.acts_as_pwm?(input_model)
      raise Bioinform::Error, 'Conversion PWM-->PPM not yet implemented'
    else
      raise Bioinform::Error, "Unknown input `#{input_model}`"
    end
  rescue => e
    raise Bioinform::Error, "PPM creation failed (#{e})"
  end

  validates :effective_count, presence: true, numericality: {greater_than: 0}, :if => ->(model){ model.data_model == :PPM }
  validates :pseudocount, numericality: {greater_than_or_equal_to: 0}, :if => ->(model){ [:PPM, :PCM].include?(model.data_model) && model.pseudocount }

  validate do |record|
    # record.errors.add(:data_model, "Unknown data model #{record.data_model}")  unless [:PWM, :PCM, :PPM].include? record.data_model
    # # Don't check model unless background is valid: it will throw an exception
    # # because model evaluation with broken background is impossible
    if record.background.valid?
      begin
        record.errors.add(:matrix, record.motif.validation_errors.join(";\n"))  unless record.motif #.valid?
      rescue
        record.errors.add(:matrix, 'is invalid')
      end
    else
      record.errors.add(:base, "is invalid because it depends on invalid background value")
    end
  end
end

# module Bioinform
#   class PM
#     def matrix_rounded(n)
#       matrix.map{|pos| pos.map{|x| x.round(n) } }
#     end
#   end
# end
