require 'rake'
require 'shellwords'

def generate_thresholds(pwm_folder:, output_folder:)
  sh 'java', '-cp', 'public/macro-perfectos-ape.jar', 'ru.autosome.ape.PrecalculateThresholds', pwm_folder, output_folder, '--silent'
end

def generate_logos(pcm_folder:, output_folder:, sequence_logo_options: '--orientation both --x-unit 20 --y-unit 40 --no-threshold-lines --bg-fill transparent')
  pcm_filenames = Dir.glob(File.join(pcm_folder, '*.pcm'))
  command = "sequence_logo #{sequence_logo_options} --logo-folder #{output_folder}"
  IO.popen(command, 'w') do |io|
    io.puts(pcm_filenames.map(&:shellescape).join("\n"))
    io.close_write
  end
end


desc 'Prepare motif collections from archives of pcm + pwm files lying in public/motif_collection/*.tar.gz '
task :prepare_motif_collections do
  Rake::Task['unpack_motifs'].invoke
  Rake::Task['generate_logos'].invoke
  Rake::Task['generate_thresholds'].invoke
end


task :unpack_motifs do
  ['pcm', 'pwm'].each do |data_model|
    data_model_folder = "public/motif_collection/#{data_model}"
    mkdir_p data_model_folder
    Dir.glob("public/motif_collection/*_#{data_model}.tar.gz") do |pm_archive|
      sh 'tar', '--directory', data_model_folder, '-zxf', pm_archive
    end
  end
end

task :generate_logos do
  mkdir_p 'public/motif_collection/logo/'
  Dir.glob('public/motif_collection/pcm/*') do |pcm_folder|
    generate_logos(
      pcm_folder: pcm_folder,
      output_folder: File.join('public/motif_collection/logo/', File.basename(pcm_folder)),
      sequence_logo_options: '--orientation both --x-unit 20 --y-unit 40 --no-threshold-lines --bg-fill transparent'
    )
  end
end

task :generate_thresholds do
  mkdir_p 'public/motif_collection/thresholds'
  Dir.glob('public/motif_collection/pwm/*') do |pwm_folder|
    generate_thresholds(
      pwm_folder: pwm_folder,
      output_folder: File.join('public/motif_collection/thresholds', File.basename(pwm_folder))
    )
  end
end
