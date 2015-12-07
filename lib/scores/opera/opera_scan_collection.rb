require 'yaml'
task_params = YAML.load_file('task_params.yaml')
pvalue = task_params[:pvalue]
if task_params[:background]
  background_string = (task_params[:background] == [1,1,1,1]) ? "-b wordwise" : "-b #{task_params[:background].join(',')}"
else
  background_string = ''
end
similarity_cutoff = task_params[:similarity_cutoff]
precise_recalc_cutoff = task_params[:precise_recalc_cutoff]
pvalue_boundary = task_params[:pvalue_boundary]

# Don't use precalc because it can't be used with different backgrounds.
command = ["java -cp ape.jar ru.autosome.macroape.ScanCollection query.pwm collection",
            "-p #{pvalue}",
            "-c #{similarity_cutoff}",
            "--boundary #{pvalue_boundary}",
            "--precise #{precise_recalc_cutoff}",
            background_string,
          ].join(' ')

if File.exist?('query.pcm')
  SMBSMCore.soloist('sequence_logo query.pcm --x-unit 20 --y-unit 40 --no-threshold-lines --bg-fill transparent', $ticket) # $ticket is defined in a wrapper (so on scene it's defined in a script)
end

File.write('task_result.txt', SMBSMCore.soloist(command, $ticket))
