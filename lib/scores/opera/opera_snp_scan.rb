require 'yaml'
require 'shellwords'

JVM_MEMORY_LIMIT = '512m'

task_params = YAML.load_file('task_params.yaml')

min_affinity_change = task_params[:fold_change_cutoff]
max_relevant_pvalue = task_params[:pvalue_cutoff]

command = ['java', "-Xmx#{JVM_MEMORY_LIMIT}", '-cp', 'ape.jar', 'ru.autosome.perfectosape.SNPScan', 'collection', 'snp_list.txt', '--precalc', 'collection_precalc',
            '--pvalue-cutoff', max_relevant_pvalue,
            '--fold-change-cutoff', min_affinity_change,
            '-b', 'wordwise',
          ].shelljoin

puts command

File.write('task_result.txt', SMBSMCore.soloist(command, $ticket))
