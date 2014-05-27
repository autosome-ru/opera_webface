require 'fileutils'
require 'shellwords'

def run(command)
  $stderr.puts(command)
  system(command)
end

def create_dir(folder)
  FileUtils.mkdir_p(folder)  unless Dir.exist?(folder)
end

no_thresholds = ARGV.delete('--no-thresholds')
no_logos = ARGV.delete('--no-logos')

full_archive, result_folder = ARGV.first(2)

unless full_archive && result_folder
  $stderr.puts '------------------------------------------'
  $stderr.puts "Usage: #{$0} <collections> <output folder> [options]"
  $stderr.puts "Example: #{$0} ./all_collections_pack.tar.gz ./motif_collection --no-logos"
  $stderr.puts "Options:"
  $stderr.puts "          --no-logos - don't generate logos for motifs"
  $stderr.puts "          --no-thresholds - don't precalculate thresholds for motifs"
  $stderr.puts
  $stderr.puts "Collections should be either folder or tar/tar.gz archive with collections(e.g. folder with hocomoco.tar.gz and selex.tar.gz) inside."
  $stderr.puts "Don't specify single collection file (like hocomoco.tar.gz) here, put it into a folder and specify a folder"
  $stderr.puts '------------------------------------------'
  exit 1
end


create_dir(result_folder)
if File.directory?(full_archive)
  FileUtils.cp_r(File.join(full_archive, '*.tar.gz'), result_folder)
elsif File.extname(full_archive) == '.tar'
  run("tar -C #{result_folder} -xf #{full_archive}")
elsif File.extname(full_archive) == '.gz' || File.extname(full_archive) == '.tgz'
  run("tar -C #{result_folder} -zxf #{full_archive}")
else
  $stderr.puts "Unknown format of collections argument. Should be either folder or tar/tar.gz archive"
end

['pcm', 'ppm', 'pwm'].each do |data_model|
  data_model_archive = File.join(result_folder, "*_#{data_model}.tar.gz")
  data_model_folder = File.join(result_folder, data_model)
  create_dir(data_model_folder)

  Dir.glob(data_model_archive) do |pm_archive|
    run "tar -C #{data_model_folder} -zxf #{pm_archive}"
    FileUtils.rm(pm_archive)
  end
end

unless no_thresholds
  pwm_folder = File.join(result_folder, 'pwm')
  thresholds_folder = File.join(result_folder, 'thresholds')
  create_dir(thresholds_folder)
  Dir.glob(File.join(pwm_folder, '*')) do |pwm_collection_folder|
    # data_model_folder = File.join(result_folder, 'pwm')
    collection_name = File.basename(pwm_collection_folder)
    output_folder = File.join(thresholds_folder, collection_name)
    run "java -cp macro-perfectos-ape.jar ru.autosome.perfectosape.cli.PrecalculateThresholdLists #{pwm_collection_folder} #{output_folder} --silence"
  end
end

unless no_logos
  logo_folder = File.join(result_folder, 'logo')
  create_dir(logo_folder)
  Dir.glob(File.join(result_folder, 'pcm/*')) do |pcm_collection_folder|
    collection_name = File.basename(pcm_collection_folder)
    pcm_filenames = Dir.glob(File.join(pcm_collection_folder, '*.pcm'))
    output_folder = File.join(logo_folder, collection_name)
    command = "sequence_logo --orientation both --logo-folder #{output_folder}"
    puts "#{pcm_collection_folder} ===> #{command}"
    IO.popen(command, 'w') do |io|
      io.puts(pcm_filenames.map(&:shellescape).join("\n"))
      io.close_write
    end
  end
end
