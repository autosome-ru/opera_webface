require 'virtus'

class TextOrFileForm
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)

  attribute :text, String
  attribute :file, IO, default: nil # `default` is necessary because otherwise `IO.new` will be invoked (without arguments it raises)

  def value
    @value ||= (file ? file.read : text)
  end
end
