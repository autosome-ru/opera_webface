# Accepts `wrapped_attribute` option to get value from it.
# Validation errors are assigned to a wrapper, not to wrapped attribute
#
# Use-case:
#   attribute :snp_list, String
#   validates :snp_list, recursive_valid: true, snp_list: true
#
#   attribute :snp_list, TextOrFileForm
#   validates :snp_list, recursive_valid: true, snp_list: {wrapped_attribute: :value}
#
class SnpListValidator < ActiveModel::EachValidator
  SNP_PATTERN = /\A[ACGTN]*\[[ACGTN]\/[ACGTN]\][ACGTN]+\z/i

  def valid_snp_format?(line)
    seq = line.strip.split(/[[:space:]]+/, 2)[1] || ''
    seq.gsub(/[[:space:]]/, '').match(SNP_PATTERN)
  end

  def valid_snp_list?(text)
    text.lines.all?{|line|
      valid_snp_format?(line)
    } && !text.lines.empty?
  end

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
    unless valid_snp_list?( unwrapped_attribute_value(record, attribute, value) )
      record.errors.add(attribute, 'SNP sequences are in wrong format')
    end
  end
end
