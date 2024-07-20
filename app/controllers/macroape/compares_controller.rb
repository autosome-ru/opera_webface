class Macroape::ComparesController < ::TasksController
  def description
    redirect_to controller: '/welcome', action: 'macroape'
  end

protected
  def first_matrix_examples
    {
      PWM: Bioinform::MotifModel::PWM.from_file( Rails.root.join('public','motif_1.pwm') ),
      PCM: Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_1.pcm') ).rounded(precision: 0),
      PPM: Bioinform::MotifModel::PPM.from_file( Rails.root.join('public','motif_1.ppm') )
    }.map{|k,v| [k, v.to_s] }.to_h
  end
  def second_matrix_examples
    {
      PWM: Bioinform::MotifModel::PWM.from_file( Rails.root.join('public','motif_2.pwm') ),
      PCM: Bioinform::MotifModel::PCM.from_file( Rails.root.join('public','motif_2.pcm') ),
      PPM: Bioinform::MotifModel::PPM.from_file( Rails.root.join('public','motif_2.ppm') )
    }.map{|k,v| [k, v.to_s] }.to_h
  end
  def default_params
    common_options = { background: BackgroundForm.uniform,
      pvalue: 0.0005,
      discretization: 10,
      pvalue_boundary: :upper,
      first_motif: {
        effective_count: 100, pseudocount: nil,
      },
      second_motif: {
        effective_count: 100, pseudocount: nil,
      }
    }

    case (params[:example] || :PCM).to_sym
    when :PCM, :PWM, :PPM
      data_model = (params[:example] || :PCM).to_sym
      specific_options = {
        first_motif: { data_model: data_model,  matrix: first_matrix_examples[ data_model ] },
        second_motif: { data_model: data_model,  matrix: second_matrix_examples[ data_model ] },
      }
    when :mixed
      specific_options = {
        first_motif: { data_model: :PCM,  matrix: first_matrix_examples[:PCM] },
        second_motif: { data_model: :PWM,  matrix: second_matrix_examples[:PWM] },
      }
    end

    common_options.deep_merge(specific_options)
  end

  def task_results(ticket)
    results_text = SMBSMCore.get_content(ticket, 'task_result.txt').force_encoding('UTF-8')  if SMBSMCore.check_content(ticket, 'task_result.txt')
    
    infos = results_text.lines.reject{|line|
      line.start_with?('#')
    }.map{|line|
      line.chomp.split("\t")
    }.to_h

    OpenStruct.new({
      similarity: infos['S'].to_f,
      distance: infos['D'].to_f,
      alignment_length: infos['L'].to_f,
      shift: infos['SH'].to_i,
      orientation: infos['OR'].to_sym,
      alignment_first: infos['A1'],
      alignment_second: infos['A2'],
      words_common: infos['W'],
      words_first: infos['W1'],
      words_second: infos['W2'],
      pvalue_first: infos['P1'],
      pvalue_second: infos['P2'],
      threshold_first: infos['T1'],
      threshold_second: infos['T2'],
      first_pwm: Bioinform::MotifModel::PWM.from_string(SMBSMCore.get_content(ticket, 'first.pwm').force_encoding('UTF-8')),
      second_pwm: Bioinform::MotifModel::PWM.from_string(SMBSMCore.get_content(ticket, 'second.pwm').force_encoding('UTF-8')),
    })
  end

  def task_logo
    'macroape_logo.png'
  end

  def self.model_class
    Macroape::CompareForm
  end
end
