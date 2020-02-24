require 'bunny'
require 'json'
require 'yaml'
require 'bioinform'
require 'shellwords'
require_relative '../app/models/background_form'
require_relative '../config/initializers/amqp'


##########################################
require 'digest/md5'
require 'bunny'
require 'json'
require 'securerandom'
conn = Bunny.new
conn.start

channel = conn.create_channel
channel.confirm_select

coordination_queue = channel.queue('lock_coordination') # no_declare: true
channel.queue('glue_logos')

lock_id = SecureRandom.uuid
to_be_triggered = [
  {'routing_key' => 'glue_logos', 'msg' => {'cmd' => 'logo_1 logo_2 > logo_all'}.to_json},
]
msg = {'type' => 'declare', 'lock_id' => lock_id, 'jobs_to_wait' => ['logo_1', 'logo_2'], 'on_completion' => to_be_triggered}
channel.default_exchange.publish(msg.to_json, routing_key: coordination_queue.name, persistent: true, content_type: 'application/json')
channel.wait_for_confirms

channel.default_exchange.publish({type: 'complete', lock_id: lock_id, job: 'logo_1'}.to_json, routing_key: coordination_queue.name, persistent: true, content_type: 'application/json')
##########################################


class EvaluateSimilarityWorker
  JVM_MEMORY_LIMIT = '1G'
  attr_reader :task_params, :ticket
  def initialize(config)
    @task_params = config['task']
    @ticket = config['ticket']
    # @task_params = YAML.load_file('task_params.yaml')
  end

  def declare_lock(lock_id:, jobs_to_wait:, on_completion: [], on_failure: [])
    msg = {type: 'declare', lock_id: lock_id, jobs_to_wait: lock_id, on_completion: on_completion, on_failure: on_failure}
    AMQPManager.publish_to_default_exchange(msg.to_json, routing_key: 'lock_coordination', persistent: true, content_type: 'application/json')
  end

  def perform
    scene_folder = File.join('/home/ilya/iogen/tools/opera_webface', 'scene_2', ticket)
    
    declare_lock(lock_id: "#{ticket}:logo:small", jobs_to_wait: ['alignment', 'logo_first', 'logo_second'], on_completion: [
      {routing_key: 'glue_logos', msg: 
        {ticket: ticket, cmd: "alignment_small.png alignment.txt --x-unit 20 --y-unit 40 --bg-fill transparent --no-threshold-lines"}
      }
    ])

    Dir.chdir(scene_folder) do
      ['first', 'second'].each do |pcm_filename|
        if File.exist?("#{pcm_filename}.pcm")
          # `sequence_logo` generate output file with name depending from input, so we create some temporary files
          FileUtils.ln_s "#{pcm_filename}.pcm", "#{pcm_filename}_small.pcm"
          FileUtils.ln_s "#{pcm_filename}.pcm", "#{pcm_filename}_medium.pcm"
          FileUtils.ln_s "#{pcm_filename}.pcm", "#{pcm_filename}_large.pcm"
          
          [ {cmd: "#{pcm_filename}_medium.pcm --x-unit 45 --y-unit 90  --orientation both --no-threshold-lines --bg-fill transparent"},
            {cmd: "#{pcm_filename}_large.pcm --x-unit 100 --y-unit 200  --orientation both --no-threshold-lines --bg-fill transparent"},
          ]

          msg = {
            ticket: ticket,
            task: {cmd: "#{pcm_filename}_small.pcm --x-unit 20 --y-unit 40 --orientation both --no-threshold-lines --bg-fill transparent"},
            lock: {lock_id: "#{ticket}:logo:small", job: "logo_#{pcm_filename}"}
          }
          AMQPManager.publish_to_default_exchange(msg.to_json, routing_key: 'sequence_logo', persistent: true, content_type: 'application/json')
          # FileUtils.ln_s "#{pcm_filename}_small_direct.png", "#{pcm_filename}_direct.png"
          # FileUtils.ln_s "#{pcm_filename}_small_revcomp.png", "#{pcm_filename}_revcomp.png"
          # FileUtils.rm ["#{pcm_filename}_small.pcm", "#{pcm_filename}_medium.pcm", "#{pcm_filename}_large.pcm"]
        end
      end

      background = BackgroundForm.new(task_params['background']).background

      opts_pvalue = ['--pvalue', task_params['pvalue']]  if task_params['pvalue']
      opts_pvalue_boundary = ['--boundary', task_params['pvalue_boundary']]  if task_params['pvalue_boundary']
      opts_background = ['--background', background]  if task_params['background']
      opts_discretization = ['--discretization', task_params['discretization']]  if task_params['discretization']

      # Don't use precalc because it can't be used with different backgrounds.
      command = [ 'java',
                  "-Xmx#{JVM_MEMORY_LIMIT}", '-cp', '/home/ilya/iogen/tools/opera_webface/public/ape-3.0.2.jar',
                  'ru.autosome.macroape.EvalSimilarity',
                  'first.pwm', 'second.pwm',
                  *opts_pvalue, *opts_pvalue_boundary, *opts_background, *opts_discretization,
                ].shelljoin + " > task_result.txt"

      exit_code = system(command)
      success = exit_code


      # pwm_first = Bioinform::MotifModel::PWM.from_file('first.pwm')
      # pwm_second = Bioinform::MotifModel::PWM.from_file('second.pwm')

      # result_infos = results_text.lines.reject{|line|
      #   line.start_with?('#')
      # }.map{|line|
      #   line.chomp.split("\t")
      # }.to_h

      # shift = result_infos['SH'].to_i
      # orientation = result_infos['OR'].to_sym

      # both_logos_exist = ['first.pcm', 'second.pcm'].all?{|pcm_filename| File.exist?(pcm_filename) }
      # if both_logos_exist
      #   File.open('alignment.txt', 'w') do |fw|
      #     fw.puts "first.pcm\t0\tdirect\t#{pwm_first.name}"
      #     fw.puts "second.pcm\t#{shift}\t#{orientation}\t#{pwm_second.name}"
      #   end
      #   SMBSMCore.soloist("glue_logos alignment_small.png alignment.txt --x-unit 20 --y-unit 40 --bg-fill transparent --no-threshold-lines", $ticket)
      #   SMBSMCore.soloist("glue_logos alignment_medium.png alignment.txt --x-unit 45 --y-unit 90 --bg-fill transparent --no-threshold-lines", $ticket)
      #   SMBSMCore.soloist("glue_logos alignment_large.png alignment.txt --x-unit 100 --y-unit 200 --bg-fill transparent --no-threshold-lines", $ticket)
      #   FileUtils.ln_s "alignment_small_direct.png", "alignment_direct.png"
      #   FileUtils.ln_s "alignment_small_revcomp.png", "alignment_revcomp.png"
      # end
      success
    end
  end
end

AMQPManager.start
AMQPManager.channel.prefetch(1)
queue = AMQPManager.channel.queue('EvaluateSimilarity', no_declare: true)

begin
  puts ' [*] Waiting for messages. To exit press CTRL+C'
  queue.subscribe(manual_ack: true) do |delivery_info, _properties, body|
    config = JSON.parse(body)

    puts "Started processing #{config}"
    success = EvaluateSimilarityWorker.new(config).perform
    puts "Finished processing with status #{success}"
    
    AMQPManager.channel.ack(delivery_info.delivery_tag)  if success
  end
  loop{ sleep 5 }
rescue Interrupt => _
  AMQPManager.stop
  exit(0)
end
