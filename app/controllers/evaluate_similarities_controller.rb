class EvaluateSimilaritiesController < TasksController

protected

  def default_params
    { background_mode: :wordwise,
      background_frequencies: [0.25, 0.25, 0.25, 0.25],
      background_gc_content: 0.5,
      data_model_first: :PWM, effective_count_first: 100, pseudocount_first: nil,
      data_model_second: :PWM, effective_count_second: 100, pseudocount_second: nil,
      pvalue: 0.0005,
      discretization: 10,
      matrix_first: Bioinform::PWM.new( File.read(Rails.root.join('public','KLF4_f2.pwm')) ).round(3),
      matrix_second: Bioinform::PWM.new( File.read(Rails.root.join('public','SP1_f1.pwm')) ).round(3),
      pvalue_boundary: :upper
    }
  end
end
