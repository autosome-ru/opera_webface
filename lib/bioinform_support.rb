module Bioinform
  class PWM
    def round(n)
      PWM.new(matrix.map{|pos| pos.map{|x| x.round(n) } }).tap{|pwm| pwm.name = name}
    end
  end

  class PPM
    make_parameters :effective_count, :pseudocount
    def to_pcm
      PCM.new(matrix.map{|pos| pos.map{|el| el * effective_count} })
    end
    def to_pwm
      pseudocount ? to_pcm.to_pwm(pseudocount) : to_pcm.to_pwm
    end
  end

end
