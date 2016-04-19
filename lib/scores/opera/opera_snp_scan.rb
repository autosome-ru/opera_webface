require 'yaml'
require 'shellwords'

task_params = YAML.load_file('task_params.yaml')

min_affinity_change = task_params[:fold_change_cutoff]
max_relevant_pvalue = task_params[:pvalue_cutoff]

command = ['java', '-cp', 'ape.jar', 'ru.autosome.perfectosape.SNPScan', 'collection', 'snp_list.txt', '--precalc', 'collection_precalc',
            '--pvalue-cutoff', max_relevant_pvalue,
            '--fold-change-cutoff', min_affinity_change,
            '-b', 'wordwise',
          ].shelljoin

puts command

File.write('task_result.txt', SMBSMCore.soloist(command, $ticket))
