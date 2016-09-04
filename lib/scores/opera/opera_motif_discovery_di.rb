require 'yaml'
require 'shellwords'
require 'fileutils'
require 'bioinform'

require 'chipmunk_runner'
require 'chipmunk_dinucleotide_result'
require 'sequence_logo_generator'

# choose orientation such that total Cytosines are not greater than total Guanines
def pcm_prefered_orientation(pcm)
  total_c = pcm.matrix.map{|pos| pos[1] + pos[5] + pos[9] + pos[13] }.inject(0.0, &:+)
  total_g = pcm.matrix.map{|pos| pos[2] + pos[6] + pos[10] + pos[14] }.inject(0.0, &:+)
  (total_c <= total_g) ? :direct : :revcomp
end

task_params = YAML.load_file('task_params.yaml')
default_params = { # All params which aren't specified in task params should be defined here
  seeds_set: 'random',
  thread_count: 2,
  verbose: 'yes',
}

speed_mode = task_params.delete(:speed_mode) || :fast
case speed_mode
when :precise
  repetition_limits = {try_limit: 400, step_limit: 40, iteration_limit: 1}
when :fast
  repetition_limits = {try_limit: 200, step_limit: 20, iteration_limit: 1}
end

command = ChIPMunk::Runner.chipmunk_command('sequences.mfa', default_params.merge(repetition_limits).merge(task_params), mode: :di)
full_results = SMBSMCore.soloist(command, $ticket)
File.write('task_result.txt', full_results.lines.map(&:strip).join("\n"))

infos = ChIPMunk::Di::Result.from_chipmunk_output(full_results)

File.write('occurences.txt', ['#' + ChIPMunk::Occurence.headers.join("\t"), *infos.occurences.map(&:to_s)].join("\n"))

if task_params[:sequence_weighting_mode] == :simple_single_stranded
  # impossible right now
  File.write('motif.dpcm', infos.pcm.named($ticket))
  File.write('motif.dpwm', infos.pwm.named($ticket))
  File.write('motif.dppm', infos.ppm.named($ticket))
else
  case pcm_prefered_orientation(infos.pcm)
  when :direct
    File.write('motif.dpcm', infos.pcm.named($ticket))
    File.write('motif.dpwm', infos.pwm.named($ticket))
    File.write('motif.dppm', infos.ppm.named($ticket))
  when :revcomp
    File.write('motif.dpcm', infos.pcm.revcomp.named($ticket))
    File.write('motif.dpwm', infos.pwm.revcomp.named($ticket))
    File.write('motif.dppm', infos.ppm.revcomp.named($ticket))
  end
end

# Temporary files to make logos of different sizes in files with different names
FileUtils.ln_s 'motif.dpcm', 'motif_small.dpcm'
FileUtils.ln_s 'motif.dpcm', 'motif_medium.dpcm'
FileUtils.ln_s 'motif.dpcm', 'motif_large.dpcm'
SequenceLogoGenerator.run_dinucleotide(ticket: $ticket, pcm_files: ['motif_small.dpcm'], output_folder: '.', orientation: 'both', x_unit: 20, y_unit: 40)
SequenceLogoGenerator.run_dinucleotide(ticket: $ticket, pcm_files: ['motif_medium.dpcm'], output_folder: '.', orientation: 'both', x_unit: 45, y_unit: 90)
SequenceLogoGenerator.run_dinucleotide(ticket: $ticket, pcm_files: ['motif_large.dpcm'], output_folder: '.', orientation: 'both', x_unit: 100, y_unit: 200)
FileUtils.ln_s 'motif_small_direct.png', 'motif_direct.png'
FileUtils.ln_s 'motif_small_revcomp.png', 'motif_revcomp.png'
FileUtils.rm ['motif_small.dpcm', 'motif_medium.dpcm', 'motif_large.dpcm']
