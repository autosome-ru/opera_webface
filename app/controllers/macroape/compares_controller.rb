require Rails.root.join('app/models/data_model')

class Macroape::ComparesController < ::TasksController
protected
  def first_matrix_examples
    {
      pwm: Bioinform::MotifModel::PWM.from_file(Rails.root.join('public','motif_1.pwm') ),
      pcm: Bioinform::MotifModel::PCM.from_file(Rails.root.join('public','motif_1.pcm') ),
      ppm: Bioinform::MotifModel::PPM.from_file(Rails.root.join('public','motif_1.ppm') )
    }
  end
  def second_matrix_examples
    {
      pwm: Bioinform::MotifModel::PWM.from_file(Rails.root.join('public','motif_2.pwm') ),
      pcm: Bioinform::MotifModel::PCM.from_file(Rails.root.join('public','motif_2.pcm') ),
      ppm: Bioinform::MotifModel::PPM.from_file(Rails.root.join('public','motif_2.ppm') )
    }
  end
  helper_method :first_matrix_examples
  helper_method :second_matrix_examples
  def default_params
    { background_attributes: {mode: :wordwise, frequencies_attributes: [0.25, 0.25, 0.25, 0.25], gc_content: 0.5},
      pvalue: 0.0005,
      discretization: 10,
      pvalue_boundary: :upper,
      first_motif_attributes: {
        data_model: :PCM, effective_count: 100, pseudocount: nil,
        matrix: first_matrix_examples[:pcm]
      },
      second_motif_attributes: {
        data_model: :PCM, effective_count: 100, pseudocount: nil,
        matrix: second_matrix_examples[:pcm]
      }
    }
  end

  def task_logo
    'macroape_logo.png'
  end

  def first_motif_pwm
    Bioinform::MotifModel::PWM.from_string(task_params(@ticket)[:first_motif][:pwm])
  end
  def second_motif_pwm
    Bioinform::MotifModel::PWM.from_string(task_params(@ticket)[:second_motif][:pwm])
  end
  helper_method :first_motif_pwm
  helper_method :second_motif_pwm
end
