require 'bioinform'
require_relative 'chipmunk_occurence'

DiPM = Struct.new(:matrix, :name) do
  def named(new_name)
    DiPM.new(matrix, new_name)
  end

  def to_s
    header = (name && !name.strip.empty?) ? "> #{name}" : nil
    [header, *matrix.map{|row| row.join("\t") }].compact.join("\n")
  end

  def revcomp
    revcomp_matrix = Array.new(matrix.length){ Array.new(16) }
    matrix.each_with_index do |pos, index|
      4.times{|first_letter_index|
        4.times{|second_letter_index|
          revcomp_matrix[index][4*first_letter_index + second_letter_index] = matrix[matrix.length - 1 - index][4 * second_letter_index + first_letter_index]
        }
      }
    end
    DiPM.new(revcomp_matrix, name)
  end

  def length
    matrix.length + 1
  end
end

module ChIPMunk
  module Di
    Result = Struct.new(
        :pcm, :pwm,
        :threshold, :weight, :kdic,
        :background, :occurences,
        :iupac_sequence, :diagnosis)

    class Result
      Dinucleotides = ['A', 'C', 'G', 'T'].product(['A','C','G','T']).map(&:join).sort

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
        matrix = Dinucleotides.map{|letter|
          infos[letter].split.map(&:to_f)
        }.transpose
        DiPM.new(matrix)
      end

      def self.extract_pwm(infos)
        matrix = Dinucleotides.map{|letter|
          infos["PW#{letter}"].split.map(&:to_f)
        }.transpose
        DiPM.new(matrix)
      end

      def self.from_chipmunk_output(chipmunk_output)
        infos = parse_chipmunk_output(chipmunk_output)
        pcm = extract_pcm(infos)
        pwm = extract_pwm(infos)
        background = infos['BACK'].split.map(&:to_f)
        occurences = infos['WORD'].map{|occurence|
          ChIPMunk::Occurence.from_string(occurence)
        }
        self.from_hash({
          pcm: pcm, pwm: pwm,
          threshold: infos['THRE'].to_f,
          kdic: infos['KDDC'].to_f,
          weight: infos['NN'].to_f,
          iupac_sequence: infos['IUPA'],
          diagnosis: infos['DIAG'],
          background: background,
          occurences: occurences,
        })
      end

      def ppm
        matrix = pcm.matrix.map do |pos|
          count = pos.inject(0.0, &:+)
          pos.map {|el| el / count }
        end
        DiPM.new(matrix, pcm.name)
      end

      def length
        pcm.length
      end
    end
  end
end
