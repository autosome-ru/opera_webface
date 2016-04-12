module ChIPMunk
  module Runner
    def self.ops_mode_option(value)
      case value
      when :oops
        'oops'
      when :zoops
        '1.0'
      else
        raise ArgumentError, "Unknown occurences_per_sequence value `#{params[:occurences_per_sequence]}`"
      end
    end

    def self.sequence_weighting_mode_option(value)
      case value
      when :simple
        's'
      when :weighted
        'w'
      when :peak
        'p'
      else
        raise ArgumentError, "Unknown sequence_weighting_mode value `#{params[:sequence_weighting_mode]}`"
      end
    end

    def self.chipmunk_command(filename, params, mode: :mono)
      ops_mode = ops_mode_option(params[:occurences_per_sequence])
      sequence_weighting_mode = sequence_weighting_mode_option(params[:sequence_weighting_mode])

      command_params = [
        params[:min_motif_length], params[:max_motif_length],
        params[:verbose],
        ops_mode,
        "#{sequence_weighting_mode}:#{filename}",
        params[:try_limit], params[:step_limit], params[:iteration_limit],
        params[:thread_count],
        params[:seeds_set],
        params[:gc_content],
        params[:motif_shape_prior]
      ]
      case mode.downcase.to_sym
      when :mono
        ['java', '-Xms64m', '-Xmx128m', '-cp', 'chipmunk.jar', 'ru.autosome.ChIPMunk', *command_params].shelljoin
      when :di
        ['java', '-Xms64m', '-Xmx128m', '-cp', 'chipmunk.jar', 'ru.autosome.di.ChIPMunk', *command_params].shelljoin
      else
        raise ArgumentError, 'Unknown mode. Should be mono/di'
      end
    end
  end
end
