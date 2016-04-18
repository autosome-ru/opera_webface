require 'bioinform'
require_relative 'chipmunk_occurence'

module ChIPMunk
  Result = Struct.new(
      :pcm, :pwm,
      :threshold, :weight, :kdic,
      :background, :occurences,
      :iupac_sequence, :diagnosis)

  class Result
    Nucleotides = ['A', 'C', 'G', 'T']
    def initialize(*args, &block)
      super
      raise ArgumentError, 'PCM and PWM are inconsistent (have different length)'  unless pcm.length == pwm.length
      raise ArgumentError, 'PCM and occurences are inconsistent (have different length)'  unless occurences.all?{|word| word.length == pcm.length }
    end

    def self.from_hash(hsh)
      self.new(*hsh.values_at(*self.members))
    end

    def self.parse_chipmunk_output(chipmunk_output)
      infos = Hash.new{|hsh,k| hsh[k] = [] }

      chipmunk_output.each_line.map(&:strip).drop_while{|line|
        !line.match(/^OUTC\|ru\.autosome\.(di\.)?ChIPMunk$/)
      }.slice_after(/^DUMP\|/).first.each{|line|
        key, value = line.split('|', 2)
        infos[key] << value
      }

      infos.map{|k,v|
        [k, v.size != 1 ? v : v.first]
      }.to_h
    end
    private_class_method :parse_chipmunk_output

    def self.extract_pcm(infos)
      matrix = Nucleotides.map{|letter|
        infos[letter].split.map(&:to_f)
      }.transpose
      Bioinform::MotifModel::PCM.new(matrix)
    end

    def self.extract_pwm(infos)
      matrix = Nucleotides.map{|letter|
        infos["PWM#{letter}"].split.map(&:to_f)
      }.transpose
      Bioinform::MotifModel::PWM.new(matrix)
    end

    def self.from_chipmunk_output(chipmunk_output)
      infos = parse_chipmunk_output(chipmunk_output)
      pcm = extract_pcm(infos)
      pwm = extract_pwm(infos)
      background = Bioinform::Background.from_frequencies(infos['BACK'].split.map(&:to_f))
      occurences = infos['WORD'].map{|occurence|
        ChIPMunk::Occurence.from_string(occurence)
      }
      self.from_hash({
        pcm: pcm, pwm: pwm,
        threshold: infos['THRE'].to_f,
        kdic: infos['KDIC'].to_f,
        weight: infos['N'].to_f,
        iupac_sequence: infos['IUPA'],
        diagnosis: infos['DIAG'],
        background: background,
        occurences: occurences,
      })
    end

    def ppm
      Bioinform::ConversionAlgorithms::PCM2PPMConverter.new.convert(pcm)
    end

    def length
      pcm.length
    end
  end
end
