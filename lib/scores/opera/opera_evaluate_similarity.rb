require 'yaml'
require 'bioinform'
require 'shellwords'
require_relative '../../app/models/background_form'

JVM_MEMORY_LIMIT = '1G'

task_params = YAML.load_file('task_params.yaml')
background = BackgroundForm.new(task_params[:background]).background

opts_pvalue = ['--pvalue', task_params[:pvalue]]  if task_params[:pvalue]
opts_pvalue_boundary = ['--boundary', task_params[:pvalue_boundary]]  if task_params[:pvalue_boundary]
opts_background = ['--background', background]  if task_params[:background]
opts_discretization = ['--discretization', task_params[:discretization]]  if task_params[:discretization]

# Don't use precalc because it can't be used with different backgrounds.
command = [ 'java',
            "-Xmx#{JVM_MEMORY_LIMIT}", '-cp', 'ape.jar',
            'ru.autosome.macroape.EvalSimilarity',
            'first.pwm', 'second.pwm',
            *opts_pvalue, *opts_pvalue_boundary, *opts_background, *opts_discretization,
          ].shelljoin

# $ticket is defined in a wrapper (so on scene it's defined in a script)
results_text = SMBSMCore.soloist(command, $ticket)
File.write('task_result.txt', results_text)

['first.pcm', 'second.pcm'].each do |pcm_filename|
  if File.exist?(pcm_filename)
    SMBSMCore.soloist("sequence_logo #{pcm_filename} --orientation both --no-threshold-lines --bg-fill transparent", $ticket)
  end
end

pwm_first = Bioinform::MotifModel::PWM.from_file('first.pwm')
pwm_second = Bioinform::MotifModel::PWM.from_file('second.pwm')

result_infos = results_text.lines.reject{|line|
  line.start_with?('#')
}.map{|line|
  line.chomp.split("\t")
}.to_h

shift = result_infos['SH'].to_i
orientation = result_infos['OR'].to_sym

both_logos_exist = ['first.pcm', 'second.pcm'].all?{|pcm_filename| File.exist?(pcm_filename) }
if both_logos_exist
  File.open('alignment.txt', 'w') do |fw|
    fw.puts "first.pcm\t0\tdirect\t#{pwm_first.name}"
    fw.puts "second.pcm\t#{shift}\t#{orientation}\t#{pwm_second.name}"
  end
  SMBSMCore.soloist("glue_logos alignment.png alignment.txt --bg-fill transparent --no-threshold-lines", $ticket)
end
