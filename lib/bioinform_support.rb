module Bioinform 
  class PWM
    def round(n)
      PWM.new(matrix.map{|pos| pos.map{|x| x.round(n) } }).tap{|pwm| pwm.name = name}
    end
  end
end
