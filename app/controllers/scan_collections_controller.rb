class ScanCollectionsController < TasksController

protected

  def default_params
    { collection: :hocomoco,
      query_background_mode: :wordwise,
      query_background_frequencies: [0.25, 0.25, 0.25, 0.25],
      query_background_gc_content: 0.5,
      query_data_model: :PWM, query_effective_count: 100, query_pseudocount: nil,
      pvalue: 0.0005,
      similarity_cutoff: 0.05,
      precise_recalc_cutoff: 0.05,
      query_matrix: Bioinform::PWM.new( File.read(Rails.root.join('public','KLF4_f2.pwm')) ).round(3),
      pvalue_boundary: :upper
    }
  end

  def task_results(ticket)
    SMBSMCore.get_content(ticket, 'task_result.txt')  if SMBSMCore.check_content(ticket, 'task_result.txt')
  end
end
