module Bioinform
  class Error < StandardError
  end

  def self.round_matrix(n, matrix)
    matrix.map{|pos| pos.map{|x| x.round(n) } }
  end

  class PWM
    def round(n)
      PWM.new(Bioinform::round_matrix(n, matrix)).tap{|pwm| pwm.name = name}
    end

    def consensus
      matrix.map{|pos|
        pos.each_with_index.max_by{|el, letter_index| el}
      }.map{|el, letter_index| letter_index}.map{|letter_index| %w{A C G T}[letter_index] }.join
    end
  end
  class PCM
    make_parameters :pseudocount
    def round(n)
      PCM.new(Bioinform::round_matrix(n, matrix)).tap{|pwm| pwm.name = name}
    end
  end

  class PPM
    make_parameters :effective_count, :pseudocount
    def round(n)
      PPM.new(Bioinform::round_matrix(n, matrix)).tap{|pwm| pwm.name = name}
    end
    def to_pcm
      PCM.new(matrix.map{|pos| pos.map{|el| el * effective_count} }).tap{|pcm| pcm.name = name}
    end
    def to_pwm
      pseudocount ? to_pcm.to_pwm(pseudocount) : to_pcm.to_pwm
    end
  end

  def self.get_pwm(data_model, matrix, background, pseudocount, effective_count)
    pm = Bioinform.const_get(data_model).new(matrix)
    pm.set_parameters(background: background)
    if pseudocount && ! pseudocount.blank? && [:PCM,:PPM].include?(data_model.to_sym)
      pm.set_parameters(pseudocount: pseudocount)
    end
    if effective_count && [:PPM].include?(data_model.to_sym)
      pm.set_parameters(effective_count: effective_count)
    end
    pm.to_pwm
  rescue => e
    raise "PWM creation failed (#{e})"
  end

  def self.get_pcm(data_model, matrix, effective_count)
    pm = Bioinform.const_get(data_model).new(matrix)
    if effective_count && [:PPM].include?(data_model.to_sym)
      pm.set_parameters(effective_count: effective_count)
    end
    pm.to_pcm
  end

  def self.get_ppm(data_model, matrix)
    Bioinform.const_get(data_model).new(matrix).to_ppm
  end
end
