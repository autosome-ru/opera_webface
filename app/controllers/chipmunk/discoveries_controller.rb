class Chipmunk::DiscoveriesController < ::TasksController
  def description
    redirect_to controller: '/welcome', action: 'chipmunk'
  end

  protected

  def default_params
    common_options = {
      gc_content: 0.5,
      motif_shape_prior: :flat,
      try_limit: 100,
      step_limit: 10,
      iteration_limit: 1,
    }

    case (params[:example] || :simple).to_sym
    when :simple
      simple_sequences = File.read( Rails.root.join('public/chipmunk_sequences_simple.txt') )
      specific_options = {
        sequence_list: TextOrFileForm.new(text: simple_sequences),
        max_motif_length: 15,
        min_motif_length: 6,
        sequence_weighting_mode: :simple,
        occurences_per_sequence: :oops,
      }
    when :weighted
      weighted_sequences = File.read( Rails.root.join('public/chipmunk_sequences_weighted.txt') )
      specific_options = {
        sequence_list: TextOrFileForm.new(text: weighted_sequences),
        max_motif_length: 10,
        min_motif_length: 10,
        sequence_weighting_mode: :weighted,
        occurences_per_sequence: :oops,
      }
    when :peak
      peak_sequences = File.read( Rails.root.join('public/chipmunk_sequences_peak.txt') )
      specific_options = {
        sequence_list: TextOrFileForm.new(text: peak_sequences),
        max_motif_length: 10,
        min_motif_length: 10,
        sequence_weighting_mode: :peak,
        occurences_per_sequence: :zoops_flexible,
      }
    end

    common_options.merge(specific_options)
  end

  def task_results(ticket)
    SMBSMCore.get_content(ticket, 'task_result.txt')  if SMBSMCore.check_content(ticket, 'task_result.txt')
  end

  def task_logo
    'chipmunk_logo.png'
  end

  def self.model_class
    Chipmunk::MotifDiscoveryForm
  end
end
