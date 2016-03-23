# Accepts `wrapped_attribute` option to get value from it.
# Validation errors are assigned to a wrapper, not to wrapped attribute
#
# Use-case:
#   class SnpListValidator
#     attribute :sequence_list, String
#     validates :sequence_list, recursive_valid: true, sequence_list: true
#   end
#
#   # Can be rewritten to use custom input (not a string but string or file, for example):
#   # In an example we obtain value to validate from `TextOrFileForm#value`
#   # according to `wrapped_attribute` option
#   class SnpListValidator
#     prepend WrappingValidator
#     attribute :sequence_list, TextOrFileForm
#     validates :sequence_list, recursive_valid: true, sequence_list: {wrapped_attribute: :value}
#   end
#
module WrappingValidator
  # called from a validator constructor
  def check_validity!
    if options[:wrapped_attribute]
      case options[:wrapped_attribute]
      when Symbol, String
        # pass
      when Proc
        # pass
      else
        raise ArgumentError, 'Wrong `wrapped_attribute` option. Should be Symbol/String/Proc.'
      end
    end

    super
  end

  def unwrapped_attribute_value(record, attribute, value)
    if options[:wrapped_attribute]
      case options[:wrapped_attribute]
      when Symbol, String
        value.send(options[:wrapped_attribute])
      when Proc
        options[:wrapped_attribute].call(record, attribute, value)
      end
    else
      value
    end
  end

  def validate_each(record, attribute, value)
    super(record, attribute, unwrapped_attribute_value(record, attribute, value))
  end
end
