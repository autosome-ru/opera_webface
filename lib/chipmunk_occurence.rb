module ChIPMunk
  Occurence = Struct.new(:sequence_index, :position, :sequence, :score, :strand, :weight) do
    def self.headers
      ['Sequence-index', 'Position', 'Sequence', 'Score', 'Strand', 'Weight']
    end
    def self.from_string(str)
      sequence_index, position, sequence, score, strand, weight = str.chomp.split("\t")
      self.new(sequence_index.to_i, position.to_i, sequence, score.to_f, strand.to_sym, weight.to_f)
    end

    def to_s
      values.join("\t")
    end

    def length
      sequence.length
    end
  end
end
