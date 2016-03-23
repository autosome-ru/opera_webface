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
require_relative 'wrapping_validator'

class SnpListValidator < ActiveModel::EachValidator
  prepend WrappingValidator

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

  def validate_each(record, attribute, value)
    record.errors.add(attribute, 'SNP sequences are in wrong format')  unless valid_snp_list?(value)
  end
end
