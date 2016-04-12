require 'yaml'
require 'shellwords'
require 'fileutils'
require 'bioinform'

require 'chipmunk_runner'
require 'chipmunk_result'

# choose orientation such that total Cytosines are not greater than total Guanines
def pcm_prefered_orientation(pcm)
  total_c = pcm.each_position.map{|pos| pos[1] }.inject(0.0, &:+)
  total_g = pcm.each_position.map{|pos| pos[2] }.inject(0.0, &:+)
  (total_c <= total_g) ? :direct : :revcomp
end

task_params = YAML.load_file('task_params.yaml')
default_params = { # All params which aren't specified in task params should be defined here
  seeds_set: 'random',
  thread_count: 1,
  verbose: 'yes',
}

speed_mode = task_params.delete(:speed_mode) || :fast
case speed_mode
when :precise
  repetition_limits = {try_limit: 200, step_limit: 20, iteration_limit: 1}
when :fast
  repetition_limits = {try_limit: 100, step_limit: 10, iteration_limit: 1}
end

command = ChIPMunk::Runner.chipmunk_command('sequences.mfa', default_params.merge(repetition_limits).merge(task_params), mode: :mono)
full_results = SMBSMCore.soloist(command, $ticket)
File.write('task_result.txt', full_results.lines.map(&:strip).join("\n"))

infos = ChIPMunk::Result.from_chipmunk_output(full_results)

File.write('occurences.txt', ['#' + ChIPMunk::Occurence.headers.join("\t"), *infos.occurences.map(&:to_s)].join("\n"))

case pcm_prefered_orientation(infos.pcm)
when :direct
  File.write('motif.pcm', infos.pcm.named($ticket))
  File.write('motif.pwm', infos.pwm.named($ticket))
  File.write('motif.ppm', infos.ppm.named($ticket))
when :revcomp
  File.write('motif.pcm', infos.pcm.revcomp.named($ticket))
  File.write('motif.pwm', infos.pwm.revcomp.named($ticket))
  File.write('motif.ppm', infos.ppm.revcomp.named($ticket))
end

FileUtils.cp 'motif.pcm', 'motif_small.pcm' # Hack to make logos with different name
SMBSMCore.soloist("sequence_logo motif.pcm --x-unit 45 --y-unit 90 --icd-mode discrete --no-threshold-lines --orientation both --logo-folder ./", $ticket)
SMBSMCore.soloist("sequence_logo motif_small.pcm --x-unit 20 --y-unit 40 --icd-mode discrete --no-threshold-lines --orientation both --logo-folder ./", $ticket)
