class Background
  class Frequencies
    include ActiveModel::Model
    attr_accessor :a,:c,:g,:t
    def frequencies
      [a, c, g, t].map(&:to_f)
    end
    def frequencies=(value)
      @a, @c, @g, @t = value
    end
  end

  include ActiveModel::Model
  attr_reader :background, :gc_content, :mode
  extend Enumerize
  enumerize :mode, in: [:wordwise, :gc_content, :frequencies]

  def frequencies
    @frequencies ||= Frequencies.new
  end

  def frequencies_attributes=(value)
    case value
    when Frequencies
      @frequencies = value
    when Array
      @frequencies = Frequencies.new.tap{|obj| obj.frequencies = value }
    when Hash
      @frequencies = Frequencies.new(a: value[:a], c: value[:c], g: value[:g], t: value[:t])
    else
      raise "Can't convert #{value} to Frequencies"
    end
  end

  def gc_content=(value)
    @gc_content = value.to_f
  end

  def mode=(value)
    @mode = value.to_sym
  end

  def background
    case mode
    when :wordwise
      [1,1,1,1]
    when :gc_content
      c_frequency = g_frequency = gc_content / 2.0
      a_frequency = t_frequency = (1.0 - gc_content) / 2.0
      [a_frequency, c_frequency, g_frequency, t_frequency]
    when :frequencies
      frequencies.frequencies
    else
      raise 'Unknown mode'
    end
  end
end
