class Chipmunk::DiscoveryController < ::TasksController
  def description
    redirect_to controller: '/welcome', action: 'chipmunk'
  end

  protected

  def reload_page_time
    30
  end

  def default_params
    common_options = {
      min_motif_length: 7, max_motif_length: 20,
      motif_shape_prior: :flat,
      occurences_per_sequence: :zoops,
      speed_mode: :fast,
    }

    case (params[:example] || :simple).to_sym
    when :simple
      simple_sequences = File.read( Rails.root.join('public/chipmunk_sequences_simple.txt') )
      specific_options = {
        sequence_weighting_mode: :simple,
        sequence_list: TextOrFileForm.new(text: simple_sequences),
        gc_content: :auto,
      }
    when :weighted
      weighted_sequences = File.read( Rails.root.join('public/chipmunk_sequences_weighted.txt') )
      specific_options = {
        sequence_weighting_mode: :weighted,
        sequence_list: TextOrFileForm.new(text: weighted_sequences),
        gc_content: :auto,
      }
    when :peak
      peak_sequences = File.read( Rails.root.join('public/chipmunk_sequences_peak.txt') )
      specific_options = {
        sequence_weighting_mode: :peak,
        sequence_list: TextOrFileForm.new(text: peak_sequences),
        gc_content: :uniform,
      }
    end

    common_options.merge(specific_options)
  end
end
