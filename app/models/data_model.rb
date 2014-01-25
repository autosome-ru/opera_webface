class DataModel
  include ActiveModel::Model
  extend Enumerize
  enumerize :data_model, in: [:PCM, :PWM, :PPM]

  attr_accessor :matrix, :background
  attr_reader :data_model, :effective_count, :pseudocount

  def attributes
    result = {matrix: matrix, data_model: data_model, effective_count: effective_count, pseudocount: pseudocount, background: background.attributes}
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
      value.blank? ? nil : value.to_f
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
end
