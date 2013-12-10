module Bioinform 
  class PWM
    def round(n)
      PWM.new(matrix.map{|pos| pos.map{|x| x.round(n) } }).tap{|pwm| pwm.name = name}
    end
  end
end

class EvaluateSimilaritiesController < TasksController

protected
  
  def default_params
    { background: [1,1,1,1],
      first_background: [1,1,1,1],
      second_background: [1,1,1,1],
      data_model_first: :PWM,
      data_model_second: :PWM,
      pvalue: 0.0005,
      discretization: 10,
      matrix_first: Bioinform::PWM.new( File.read(Rails.root.join('public','KLF4_f2.pwm')) ).round(3),
      matrix_second: Bioinform::PWM.new( File.read(Rails.root.join('public','SP1_f1.pwm')) ).round(3),
      pvalue_boundary: :upper
    }
  end
end
