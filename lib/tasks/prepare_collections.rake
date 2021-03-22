require 'rake'
require 'shellwords'

def generate_thresholds(pwm_folder:, output_folder:)
  sh 'java', '-cp', 'public/ape.jar', 'ru.autosome.ape.PrecalculateThresholds', pwm_folder, output_folder, '--silent'
end

def generate_logos(pcm_folder:, output_folder:, sequence_logo_options: '--orientation both --x-unit 20 --y-unit 40 --no-threshold-lines --bg-fill transparent')
  pcm_filenames = Dir.glob(File.join(pcm_folder, '*.pcm'))
  command = "sequence_logo #{sequence_logo_options} --logo-folder #{output_folder} --from-stdin"
  $stderr.puts "Run #{command} (motifs are passed via stdin, line-by-line)"
  $stderr.puts "Stdin (joined into single line):"
  $stderr.puts pcm_filenames.map(&:shellescape).join(" ")
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
  mkdir_p 'public/motif_collection/logo_small/'
  mkdir_p 'public/motif_collection/logo_medium/'
  mkdir_p 'public/motif_collection/logo_large/'
  Dir.glob('public/motif_collection/pcm/*') do |pcm_folder|
    $stderr.puts("generate_logos for #{pcm_folder} (logo_small)")
    generate_logos(
      pcm_folder: pcm_folder,
      output_folder: File.join('public/motif_collection/logo_small/', File.basename(pcm_folder)),
      sequence_logo_options: '--orientation both --x-unit 20 --y-unit 40 --no-threshold-lines --bg-fill transparent'
    )

    $stderr.puts("generate_logos for #{pcm_folder} (logo_medium)")
    generate_logos(
      pcm_folder: pcm_folder,
      output_folder: File.join('public/motif_collection/logo_medium/', File.basename(pcm_folder)),
      sequence_logo_options: '--orientation both --x-unit 45 --y-unit 90 --no-threshold-lines --bg-fill transparent'
    )

    $stderr.puts("generate_logos for #{pcm_folder} (logo_large)")
    generate_logos(
      pcm_folder: pcm_folder,
      output_folder: File.join('public/motif_collection/logo_large/', File.basename(pcm_folder)),
      sequence_logo_options: '--orientation both --x-unit 100 --y-unit 200 --no-threshold-lines --bg-fill transparent'
    )
  end
  ln_sf 'logo_small/', 'public/motif_collection/logo' # logo is a link to relative path logo_small
end

task :generate_thresholds do
  mkdir_p 'public/motif_collection/thresholds'
  Dir.glob('public/motif_collection/pwm/*') do |pwm_folder|
    $stderr.puts "generate_thresholds for #{pwm_folder}"
    generate_thresholds(
      pwm_folder: pwm_folder,
      output_folder: File.join('public/motif_collection/thresholds', File.basename(pwm_folder))
    )
  end
end
