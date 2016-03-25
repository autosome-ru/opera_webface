FastaRecord = Struct.new(:header, :sequence) do
  # first line should be a header (`>` character and spaces at each side will be stripped)
  # other lines represent a multiline sequence (they will be joined)
  def self.from_string_array(record_lines)
    raise ArgumentError, validation_errors(record_lines).join("\n")  unless valid_input?(record_lines)
    header = record_lines.first.sub(/^>[[:space:]]*/, '').strip
    sequence = record_lines.drop(1).map(&:strip).join
    self.new(header, sequence)
  end

  def self.valid_input?(record_lines)
    validation_errors(record_lines).empty?
  end

  def self.validation_errors(record_lines)
    errors = []
    errors << 'Header line should start with >'  unless record_lines.first.start_with?('>')
    errors << 'Sequence lines should not start with >'  unless record_lines.drop(1).none?{|line| line.start_with?('>') }
    errors
  end

  def self.each_input_chunk(stream, &block)
    stream.each_line.slice_before{|line|
      line.start_with?('>')
    }.each(&block)
  end

  def self.all_records_valid?(stream)
    each_input_chunk(stream).all?{|record_lines|
      valid_input?(record_lines)
    }
  end

  def self.each_record(stream, &block)
    each_input_chunk(stream).map{|record_lines|
      from_string_array(record_lines)
    }.each(&block)
  end

  def length
    sequence.length
  end
end
