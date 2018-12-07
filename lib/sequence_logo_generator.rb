module SequenceLogoGenerator
  def self.run_dinucleotide(ticket:, pcm_file:, output_filename: nil, orientation: 'direct', x_unit: 30, y_unit: 60)
    if orientation == 'both'
      basename = output_filename.sub(/.png$/i, '')
      run_dinucleotide(ticket: ticket, pcm_file: pcm_file, output_filename: basename + '_direct.png', orientation: 'direct', x_unit: x_unit, y_unit: y_unit)
      run_dinucleotide(ticket: ticket, pcm_file: pcm_file, output_filename: basename + '_revcomp.png', orientation: 'revcomp', x_unit: x_unit, y_unit: y_unit)
    else
      output_filename ||= File.basename(pcm_file, File.extname(pcm_file)) + '.png'
      opts = [x_unit.to_s, y_unit.to_s]
      opts << '--revcomp'  if orientation == 'revcomp'
      command = ['ruby', File.absolute_path('pmflogo/dpmflogo3.rb', __dir__), pcm_file, output_filename, *opts]
      SMBSMCore.soloist(command, ticket)
    end
  end
end
