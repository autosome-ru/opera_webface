class Chipmunk::DiscoveryController < ::TasksController
  def description
    redirect_to controller: '/welcome', action: 'chipmunk'
  end

  protected

  def reload_page_time
    10
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
      specific_options = {
        sequence_weighting_mode: :simple,
        sequence_list_text: File.read( Rails.root.join('public/chipmunk_sequences_simple.txt') ),
        gc_content: :auto,
      }
    when :weighted
      specific_options = {
        sequence_weighting_mode: :weighted,
        sequence_list_text: File.read( Rails.root.join('public/chipmunk_sequences_weighted.txt') ),
        gc_content: :auto,
      }
    when :peak
      specific_options = {
        sequence_weighting_mode: :peak,
        sequence_list_text: File.read( Rails.root.join('public/chipmunk_sequences_peak.txt') ),
        gc_content: :uniform,
      }
    end

    common_options.deep_merge(specific_options)
  end

  def chipmunk_infos
    @chipmunk_infos ||= ChipmunkResultsDecorator.decorate(task_results(@ticket))
  end

  def chipmunk_task_params
    @chipmunk_task_params ||= task_params(@ticket)
  end

  def single_stranded?
    chipmunk_task_params.sequence_weighting_mode == :simple_single_stranded
  end

  helper_method :chipmunk_infos, :chipmunk_task_params, :single_stranded?
end
