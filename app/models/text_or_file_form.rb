require 'virtus'
require 'active_model'
require_relative 'task_form'

class TextOrFileForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)
  include TaskForm

  attribute :text, String
  attribute :file, IO, default: nil # `default` is necessary because otherwise `IO.new` will be invoked (without arguments it raises)

  validates :value, presence: true

  def value
    @value ||= (file ? file.read : text)
  end

  def task_params
    value
  end
end
