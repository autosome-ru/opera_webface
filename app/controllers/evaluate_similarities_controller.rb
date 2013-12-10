class EvaluateSimilaritiesController < TasksController

protected
  def permitted_params
    params.permit(:task => model_class.task_param_names)
  end

  def default_params
    { background: [1,1,1,1],
      first_background: [1,1,1,1],
      second_background: [1,1,1,1],
      pvalue: 0.0005,
      discretization: 10,
      matrix_first: File.read(Rails.root.join('public','KLF4_f2.pwm')),
      matrix_second: File.read(Rails.root.join('public','SP1_f1.pwm')),
      pvalue_boundary: :upper
    }
  end
end
