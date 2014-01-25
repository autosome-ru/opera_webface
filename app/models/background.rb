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
    validate do |record|
      record.errors.add(:base, 'Must give 1 being summed')  unless (record.frequencies.inject(0.0, &:+) - 1.0).abs < 0.001
    end
  end

  include ActiveModel::Model
  attr_reader :background, :gc_content, :mode
  extend Enumerize
  enumerize :mode, in: [:wordwise, :gc_content, :frequencies]

  def attributes
    result = {mode: mode}
    case mode
    when :wordwise
      # do nothing
    when :gc_content
      result.merge!(gc_content: gc_content)
    when :frequencies
      result.merge!(frequencies: frequencies.frequencies)
    end
    result.merge(background: background)
  end

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

  validate do |record|
    case record.mode
    when :gc_content
      record.errors.add(:gc_content, 'Must be in 0 to 1')  unless (0..1).include?(record.gc_content)
    when :frequencies
      record.errors.add(:frequencies)  unless frequencies.valid?
    end
  end
end
