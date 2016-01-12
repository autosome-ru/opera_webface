require 'virtus'
require 'active_model'
require 'bioinform'
require_relative 'task_form'
require_relative 'frequencies_form'
require_relative '../validators/recursive_valid_validator'
require_relative '../validators/background_mode_validator'

class BackgroundForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)
  include TaskForm
  attribute :mode, Symbol, default: :wordwise
  attribute :gc_content, Float, default: 0.5
  attribute :frequencies, FrequenciesForm, default: FrequenciesForm.uniform

  MODE_VARIANTS = [:wordwise, :gc_content, :frequencies]
  validates :frequencies, recursive_valid: true
  validates :mode, background_mode: true
  validates :gc_content, inclusion: {in: 0..1, message: 'GC-content must be in [0,1] range'}, if: ->(record){ record.mode == :gc_content }

  def frequencies=(value)
    case value
    when Hash, FrequenciesForm
      super
    when Array
      frequencies = [:a,:c,:g,:t].zip(value).inject({}){|res, (letter, frequency)| res.merge(letter => frequency) }
      super(frequencies)
    end
  end

  def background
    case mode
    when :wordwise
      Bioinform::Background.wordwise
    when :gc_content
      Bioinform::Background.from_gc_content(gc_content)
    when :frequencies
      frequencies.background
    else
      raise 'Unknown background mode'
    end
  end

  def self.uniform
    BackgroundForm.new(mode: :wordwise, gc_content: 0.5, frequencies: FrequenciesForm.uniform)
  end
end
