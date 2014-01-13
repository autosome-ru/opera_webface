# program_path = File.dirname(File.absolute_path __FILE__)
# Dir.chdir(program_path)

require 'macroape'
require 'yaml'

#puts 'opera_macroape.rb started'
params = YAML.load_file('task_params.yaml')

# first_background = params[:first_background]
# second_background = params[:first_background]
first_background = params[:background]
second_background = params[:background]

discretization = params[:discretization]
pvalue = params[:pvalue]

max_hash_size = 10000000
max_pair_hash_size = 10000
pvalue_boundary = :upper

pwm_first = Bioinform::PWM.new(params[:pwm_first]).set_parameters(background: first_background, max_hash_size: max_hash_size).discrete!(discretization)
pwm_second = Bioinform::PWM.new(params[:pwm_second]).set_parameters(background: second_background, max_hash_size: max_hash_size).discrete!(discretization)
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


#pwm_first = Bioinform::PWM.new(File.read('pwm_first.pwm')).set_parameters(background: first_background).discrete(discretization)
#pwm_second = Bioinform::PWM.new(File.read('pwm_second.pwm')).with_background(background).discrete(discretization)
# cmp = PWMCompare::PWMCompare.new(pwm_first, pwm_second)
# first_threshold = pwm_first.thresh(pvalue)
# second_threshold = pwm_second.thresh(pvalue)
# info = cmp.jaccard(first_threshold, second_threshold)
# info[:first_pwm_name] = pwm_first.name
# info[:second_pwm_name] = pwm_second.name

# File.open('results.yaml', 'w') {|f| f.puts info.to_yaml }