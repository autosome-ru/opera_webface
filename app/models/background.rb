require 'active_model'
require 'enumerize'

module OperaWebface
  class Frequencies
    include ActiveModel::Model
    attr_reader :a,:c,:g,:t
    def a=(value); @a = value.to_f; end
    def c=(value); @c = value.to_f; end
    def g=(value); @g = value.to_f; end
    def t=(value); @t = value.to_f; end
    def to_hash
      {a: a, c: c, g: g, t: t}
    end
    def self.from_hash(value)
      Frequencies.new(a: value[:a].to_f, c: value[:c].to_f, g: value[:g].to_f, t: value[:t].to_f)
    end
    def self.from_array(value)
      Frequencies.new(a: value[0].to_f, c: value[1].to_f, g: value[2].to_f, t: value[3].to_f)
    end
  end
  class Background
    include ActiveModel::Model
    extend Enumerize
    attr_reader :gc_content, :mode, :frequencies
    MODES = [:wordwise, :gc_content, :frequencies]
    enumerize :mode, in: MODES

    def gc_content=(value)
      @gc_content = value.to_f
    end

    def mode=(value)
      @mode = value.to_sym
      raise "Unknown background mode #{record.mode}"  unless MODES.include?(@mode)
    end

    def frequencies_attributes=(value)
      case value
      when Hash
        @frequencies = Frequencies.from_hash(value)
      when Array
        @frequencies = Frequencies.from_array(value)
      else
        raise "Unknown frequencies type"
      end
    end

    def to_hash
      {mode: mode, gc_content: gc_content, frequencies_attributes: frequencies.to_hash}
    end

    def value
      case mode
      when :wordwise
        Bioinform::Background.wordwise
      when :gc_content
        Bioinform::Background.from_gc_content(gc_content)
      when :frequencies
        Bioinform::Background.from_frequencies([:a,:c,:g,:t].map{|letter| value[letter] })
      end
    end

    validate do |record|
      begin
        record.value
      rescue => e
        record.errors.add(:base, e.message)
      end
    end
  end
end
