require 'yaml'
require 'bioinform'
require 'shellwords'
require 'fileutils'
require_relative '../../app/models/background_form'

JVM_MEMORY_LIMIT = '1G'

task_params = YAML.load_file('task_params.yaml')
background = BackgroundForm.new(task_params[:background]).background

opts_similarity_cutoff = ['--similarity-cutoff', task_params[:similarity_cutoff]]  if task_params[:similarity_cutoff]
opts_precise_recalc_cutoff = ['--precise', task_params[:precise_recalc_cutoff]]  if task_params[:precise_recalc_cutoff]
opts_background = ['--background', background]  if task_params[:background]
opts_pvalue = ['--pvalue', task_params[:pvalue]]  if task_params[:pvalue]
opts_pvalue_boundary = ['--boundary', task_params[:pvalue_boundary]]  if task_params[:pvalue_boundary]

# # Don't use precalc because it can't be used with different backgrounds.
command = [ 'java',
            "-Xmx#{JVM_MEMORY_LIMIT}", '-cp', 'ape.jar',
            'ru.autosome.macroape.ScanCollection',
            'query.pwm', 'collection',
            *opts_pvalue, *opts_background, *opts_similarity_cutoff,
            *opts_precise_recalc_cutoff, *opts_pvalue_boundary,
          ].map(&:to_s).shelljoin

# $ticket is defined in a wrapper (so on scene it's defined in a script)
if File.exist?('query.pcm')
  # `sequence_logo` generate output file with name depending from input, so we create some temporary files
  FileUtils.ln_s('query.pcm', 'query_small.pcm')
  FileUtils.ln_s('query.pcm', 'query_medium.pcm')
  FileUtils.ln_s('query.pcm', 'query_large.pcm')
  SMBSMCore.soloist('sequence_logo query_small.pcm --x-unit 20 --y-unit 40 --no-threshold-lines --bg-fill transparent', $ticket)
  SMBSMCore.soloist('sequence_logo query_medium.pcm --x-unit 45 --y-unit 90 --no-threshold-lines --bg-fill transparent', $ticket)
  SMBSMCore.soloist('sequence_logo query_large.pcm --x-unit 100 --y-unit 200 --no-threshold-lines --bg-fill transparent', $ticket)
  FileUtils.ln_s('query_small.png', 'query.png')
  FileUtils.rm ['query_small.pcm', 'query_medium.pcm', 'query_large.pcm']
end

File.write('task_result.txt', SMBSMCore.soloist(command, $ticket))
