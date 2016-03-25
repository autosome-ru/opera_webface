require 'yaml'
require 'shellwords'
require 'fileutils'
require 'bioinform'

module ChIPMunk
  def self.ops_mode_option(value)
    case value
    when :oops
      'oops'
    when :zoops_flexible
      '1.0'
    when :zoops_strict
      '0.0'
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

  def self.chipmunk_command(params)
    ops_mode = ops_mode_option(params[:occurences_per_sequence])
    sequence_weighting_mode = sequence_weighting_mode_option(params[:sequence_weighting_mode])

    command_params = [
      params[:min_motif_length], params[:max_motif_length],
      'yes', # verbose
      ops_mode,
      "#{sequence_weighting_mode}:sequences.mfa",
      params[:try_limit], params[:step_limit], params[:iteration_limit],
      1, # thread count
      'random', # seeds set
      params[:gc_content],
      params[:motif_shape_prior]
    ]

    ['java', '-Xms64m', '-Xmx128m', '-cp', 'chipmunk.jar', 'ru.autosome.ChIPMunk', *command_params].shelljoin
  end

  def self.parse_chipmunk_results(chipmunk_results)
    infos = Hash.new{|hsh,k| hsh[k] = [] }
    chipmunk_results.each{|line|
      key, value = line.chomp.split('|')
      infos[key] << value
    }
    infos.map{|k,v|
      [k, v.size != 1 ? v : v.first]
    }.to_h
  end

  def self.extract_pcm(infos)
    matrix = ['A', 'C', 'G', 'T'].map{|letter|
      infos[letter].split.map(&:to_f)
    }.transpose
    Bioinform::MotifModel::PCM.new(matrix).in_prefered_orientation
  end


  def self.extract_chipmunk_section(full_results)
    full_results.drop_while{|line| line.strip != 'OUTC|ru.autosome.ChIPMunk' }
  end
end


class Bioinform::MotifModel::PCM
  # ln(x!)
  def log_fact(x)
    Math.lgamma(x + 1).first
  end

  # choose orientation such that total Cytosines are not greater than  total Guanines
  def in_prefered_orientation
    total_c = self.each_position.map{|pos| pos[1] }.inject(0.0, &:+)
    total_g = self.each_position.map{|pos| pos[2] }.inject(0.0, &:+)
    (total_c <= total_g) ? self : revcomp
  end
end

task_params = YAML.load_file('task_params.yaml')
command = ChIPMunk.chipmunk_command(task_params)
full_results = SMBSMCore.soloist(command, $ticket).lines.map(&:strip)
File.write('task_result.txt', full_results.join("\n"))

chipmunk_results = ChIPMunk.extract_chipmunk_section(full_results)
infos = ChIPMunk.parse_chipmunk_results(chipmunk_results)

File.write('words.txt', infos['WORD'].join("\n"))

# может ли N отличаться от суммы A+C+G+T?
# words_count = infos['N'].to_f
File.write('diagnosis.txt', infos['DIAG'])
pcm = ChIPMunk.extract_pcm(infos)
ppm = Bioinform::ConversionAlgorithms::PCM2PPMConverter.new.convert(pcm)
pwm = Bioinform::ConversionAlgorithms::PCM2PWMConverter.new(pseudocount: :log).convert(pcm)

File.write('motif.pcm', pcm)
File.write('motif.pwm', pwm)
File.write('motif.ppm', ppm)

# File.write('motif_rounded.pcm', pcm.rounded(precision: 3))
# File.write('motif_rounded.pwm', pwm.rounded(precision: 3))
# File.write('motif_rounded.ppm', ppm.rounded(precision: 3))


FileUtils.cp 'motif.pcm', 'motif_small.pcm' # Hack to make logos with different name
# FileUtils.mkdir_p 'logo'
# FileUtils.mkdir_p 'logo_small'
SMBSMCore.soloist("sequence_logo motif.pcm --x-unit 45 --y-unit 90 --icd-mode discrete --no-threshold-lines --orientation both --logo-folder ./", $ticket)
SMBSMCore.soloist("sequence_logo motif_small.pcm --x-unit 20 --y-unit 40 --icd-mode discrete --no-threshold-lines --orientation both --logo-folder ./", $ticket)



# bismark = Bismark.new
# bismark.root.add_element("motif", {"id" => "#{motif_name.to_id}.MTF", "name" => "#{motif_name}"})
# infocod = ppm.infocod
# bismark.elements["//motif"].add_element("comment", {"name" => "discrete information content by position"}).add_text(infocod.inspect.to_s)
# total_infocod = infocod.inject(0) { |ttl, icd| ttl += icd }
# bismark.elements["//motif"].add_element("comment", {"name" => "discrete information content"}).add_text(total_infocod.to_s)
# $ppm.to_bismark(bismark.elements["//motif"])

# pseudoc = Math.log(pm.words_count > 1 ? pm.words_count : 2)
# ($pwm = pm.get_pwm(nil, Randoom::DEF_PROBS, pseudoc)).to_bismark(bismark.elements["//motif"])

# File.open(out_bismark, "w") { |f| f << bismark.getXML }

# return words_count
