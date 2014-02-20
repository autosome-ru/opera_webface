require 'macroape'
require 'yaml'

params = YAML.load_file('task_params.yaml')

first_background = params[:background]
second_background = params[:background]

discretization = params[:discretization]
pvalue = params[:pvalue]

max_hash_size = 10000000
max_pair_hash_size = 10000
pvalue_boundary = :upper

pwm_first = Bioinform::PWM.new(params[:first_motif][:pwm]).set_parameters(background: first_background, max_hash_size: max_hash_size).discrete!(discretization)
pwm_second = Bioinform::PWM.new(params[:second_motif][:pwm]).set_parameters(background: second_background, max_hash_size: max_hash_size).discrete!(discretization)
cmp = Macroape::PWMCompare.new(pwm_first, pwm_second).set_parameters(max_pair_hash_size: max_pair_hash_size)


if pvalue_boundary.to_sym == :lower
  threshold_first = pwm_first.threshold(pvalue)
  threshold_second = pwm_second.threshold(pvalue)
else
  threshold_first = pwm_first.weak_threshold(pvalue)
  threshold_second = pwm_second.weak_threshold(pvalue)
end

info = cmp.jaccard(threshold_first, threshold_second)
info.merge!(threshold_first: threshold_first.to_f / discretization,
            threshold_second: threshold_second.to_f / discretization,
            discretization: discretization,
            first_background: first_background,
            second_background: second_background,
            requested_pvalue: pvalue,
            pvalue_boundary: pvalue_boundary)
File.write 'result.txt', Macroape::CLI::Helper.similarity_info_string(info)
File.write 'task_results.yaml', info.to_yaml
['pcm_first.pcm', 'pcm_second.pcm'].each do |pcm_filename|
  if File.exist?(pcm_filename)
    SMBSMCore.soloist("sequence_logo #{pcm_filename}", $ticket) # $ticket is defined in a wrapper (so on scene it's defined in a script)
  end
end

shift = info[:shift]
orientation = info[:orientation]
if ['pcm_first.pcm', 'pcm_second.pcm'].all?{|pcm_filename| File.exist?(pcm_filename) }
  File.open('alignment.txt', 'w') do |fw|
    fw.puts "pcm_first.pcm\t0\tdirect\t#{pwm_first.name}"
    fw.puts "pcm_second.pcm\t#{shift}\t#{orientation}\t#{pwm_second.name}"
  end
  SMBSMCore.soloist("glue_logos alignment.png alignment.txt", $ticket)
end
