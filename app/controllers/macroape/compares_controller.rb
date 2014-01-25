class Macroape::ComparesController < ::TasksController

protected

  def default_params
    { background_attributes: {mode: :wordwise, frequencies_attributes: [0.25, 0.25, 0.25, 0.25], gc_content: 0.5},
      pvalue: 0.0005,
      discretization: 10,
      pvalue_boundary: :upper,
      first_motif_attributes: {
        data_model: :PWM, effective_count: 100, pseudocount: nil,
        matrix: Bioinform::PWM.new( File.read(Rails.root.join('public','KLF4_f2.pwm')) ).round(3)
      },
      second_motif_attributes: {
        data_model: :PWM, effective_count: 100, pseudocount: nil,
        matrix: Bioinform::PWM.new( File.read(Rails.root.join('public','SP1_f1.pwm')) ).round(3)
      }
    }
  end
end
