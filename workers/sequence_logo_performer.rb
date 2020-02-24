require 'bunny'
require 'json'
require 'logger'
require 'shellwords'
require_relative '../config/initializers/amqp'

class SequenceLogoPerformer
  attr_reader :task_params, :ticket
  def initialize(config)
    @task_params = config['task']
    @ticket = config['ticket']
  end
  def perform
    success = false
    scene_folder = File.join('/home/ilya/iogen/tools/opera_webface', 'scene_2', ticket)
    Dir.chdir(scene_folder) do
      pwd = File.absolute_path(Dir.pwd)
      cmd = "docker run -it --rm --mount type=bind,src=#{pwd.shellescape},dst=/data vorontsovie/sequence_logo " + task_params['cmd']
      exit_code = system(cmd)
      success = exit_code.zero?
    end
    success
  end
end

logger = Logger.new($stdout)
AMQPManager.start
AMQPManager.channel.prefetch(1)
AMQPManager.channel.queue('lock_coordination')

queue = AMQPManager.channel.queue('sequence_logo', no_declare: true)

begin
  logger.info ' [*] Waiting for messages. To exit press CTRL+C'
  queue.subscribe(manual_ack: true) do |delivery_info, _properties, body|
    config = JSON.parse(body)
    lock_info = config.delete('lock_coordinator')
    logger.info "Started processing #{config}"

    success = nil
    begin
      success = SequenceLogoPerformer.new(config).perform
      logger.info "Finished processing with status #{success}"
    rescue => err
      logger.error "Processing failed: #{err}"
      success = false
    end

    if lock_info
      event_type = success ? 'complete' : 'failure'
      msg = {type: event_type, lock_id: lock_info['lock_id'], job: lock_info['job']}
      AMQPManager.publish_to_default_exchange(msg.to_json, routing_key: 'lock_coordination', persistent: true, content_type: 'application/json')
      logger.info "Sent message #{msg} to coordinator"
    end

    AMQPManager.channel.ack(delivery_info.delivery_tag) # if success
  end
  loop{ sleep 5 }
rescue Interrupt => _
  AMQPManager.stop
  exit(0)
end
