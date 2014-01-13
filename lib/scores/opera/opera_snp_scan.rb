require 'yaml'
require 'ostruct'
task_params = OpenStruct.new(YAML.load_file('task_params.yaml'))

min_affinity_change = task_params.fold_change_cutoff
max_relevant_pvalue = task_params.pvalue_cutoff

command = ["java -jar multi-SNP-scan.jar collection snp_list.txt --precalc collection_precalc",
            "--pvalue-cutoff #{max_relevant_pvalue}",
            "--fold-change-cutoff #{min_affinity_change}",
            "-b #{task_params.background.join(',')}"
          ].join(' ')

puts command

File.write('task_result.txt', SMBSMCore.soloist(command, $ticket))
