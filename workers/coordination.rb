require 'logger'
require 'redis'
require 'bunny'
require 'json'

class LockCoordinator
  def initialize(queue_name: 'lock_coordination',redis_options: {}, rabbitmq_options: {})
    @logger = Logger.new($stdout)
    @redis = Redis.new(**redis_options)

    @connection = Bunny.new(**rabbitmq_options)
    @connection.start

    @channel = @connection.create_channel
    @queue  = @channel.queue(queue_name)
    @channel.confirm_select
  end

  def run
    @queue.subscribe(manual_ack: true, exclusive: true) do |delivery_info, properties, payload|
      msg = JSON.parse(payload)
      process_message(msg)      
      @channel.ack(delivery_info.delivery_tag)
    end
    loop{ sleep 5 }
  end

  def stop
    @connection.close
    @redis.close
  end

  # accepts JSON-encoded message and routing key
  def fire_message(msg_info_string, wait_for_confirms: true)
    msg_info = JSON.parse(msg_info_string)
    msg_to_fire = msg_info['msg']
    routing_key = msg_info['routing_key']
    @channel.default_exchange.publish(msg_to_fire.to_json, routing_key: routing_key, persistent: true) #, content_type: 'application/json'
    @channel.wait_for_confirms  if wait_for_confirms
    @logger.info "Sent #{msg_to_fire} to #{routing_key}"
  end

  def fire_message_group(msg_info_strings, wait_for_confirms: true)
    msg_info_strings.each{|msg_info_string|
      fire_message(msg_info_string, wait_for_confirms: false)
    }
    @channel.wait_for_confirms  if wait_for_confirms
  end

  def lock_exist?(lock_id)
    @redis.exists("lock:#{lock_id}:jobs_to_wait")
  end

  def clear_lock(lock_id)
    @redis.del("lock:#{lock_id}:jobs_to_wait", "lock:#{lock_id}:on_completion", "lock:#{lock_id}:on_failure")
    @logger.info "Lock #{lock_id} cleared."
  end

  def can_resolve?(lock_id)
    @redis.scard("lock:#{lock_id}:jobs_to_wait") == 0
  end

  def resolve_lock_completion(lock_id)
    @logger.info "Lock #{lock_id} resolved successfully. Fire completion hook."
    messages_to_fire = @redis.lrange("lock:#{lock_id}:on_completion", 0, -1)
    fire_message_group(messages_to_fire)
    clear_lock(lock_id)
  end

  def resolve_lock_failure(lock_id, job)
    @logger.info "Lock #{lock_id} failed due to job `#{job}`. Fire failure hook."
    messages_to_fire = @redis.lrange("lock:#{lock_id}:on_failure", 0, -1)
    # ToDo: we can further add handling fails in a different way depending on a failed job
    # messages_to_fire += @redis.lrange("lock:#{lock_id}:on_failure:#{job}", 0, -1)
    fire_message_group(messages_to_fire)
    clear_lock(lock_id)
  end

  # Declares a lock which fires a message when all jobs are complete or when any job fails
  # msg: {type: 'declare', lock_id: 'abc123', jobs_to_wait: ['task_1_name', 'task_2_name'], expiration_time: 3600,
  #       on_completion: [{routing_key: 'queue_X', msg: 'some msg probably as JSON-encoded string'}, ...],
  #       on_failure: [{routing_key: 'queue_Y', msg: 'some msg probably as JSON-encoded string'}, ...] }
  # `expiration_time`, `on_completion` and `on_failure` are optional.
  # But `on_complete` is probably the main reason to declare a lock.
  def declare_lock(msg)
    lock_id = msg['lock_id']

    if lock_exist?(lock_id)
      @logger.error "Lock #{lock_id} already exist. Can't redeclare."
      return
    end

    jobs_to_wait = msg['jobs_to_wait']
    if jobs_to_wait.empty?
      @logger.info "Lock #{lock_id} fires immediately"
      fire_message_group(msg.fetch('on_completion', []))
      return
    end

    on_completion = msg.fetch('on_completion', []).map(&:to_json)
    on_failure = msg.fetch('on_failure', []).map(&:to_json)

    expiration_time = msg.fetch('expiration_time', 24*3600)
    @redis.multi do |multi|
      multi.sadd "lock:#{lock_id}:jobs_to_wait", jobs_to_wait
      multi.expire "lock:#{lock_id}:jobs_to_wait", expiration_time
      unless on_completion.empty?
        multi.rpush "lock:#{lock_id}:on_completion", on_completion
        multi.expire "lock:#{lock_id}:on_completion", expiration_time
      end
      unless on_failure.empty?
        multi.rpush "lock:#{lock_id}:on_failure", on_failure
        multi.expire "lock:#{lock_id}:on_failure", expiration_time
      end
    end
    @logger.info "Declared lock #{lock_id} waiting for jobs: #{jobs_to_wait.join(', ')}. Will expire in #{expiration_time} seconds."
  end

  # {type: 'completion', lock_id: 'abc123', job: 'task_1_name'}
  def handle_completion(msg)
    lock_id = msg['lock_id']
    job = msg['job']
    if lock_exist?(lock_id)
      if @redis.sismember("lock:#{lock_id}:jobs_to_wait", job)
        @redis.srem("lock:#{lock_id}:jobs_to_wait", job)
        @logger.info "Completion of job `#{job}` for lock `#{lock_id}`."
      else
        @logger.error "Completion of unknown job `#{job}` for lock `#{lock_id}`."
      end
      resolve_lock_completion(lock_id)  if can_resolve?(lock_id)
    else
      @logger.error "Unknown lock `#{lock_id}`"
    end
  end

  # {type: 'failure', lock_id: 'abc123', job: 'task_1_name'}
  def handle_failure(msg)
    lock_id = msg['lock_id']
    job = msg['job']
    if lock_exist?(lock_id)
      @logger.info "Failure of job `#{job}` for lock `#{lock_id}`."
      resolve_lock_failure(lock_id, job)
    else
      @logger.error "Unknown lock `#{lock_id}`"
    end
  end

  def process_message(msg)
    @logger.info "Got message #{msg}"
    lock_id = msg['lock_id']
    case msg['type']
    when 'declare'
      declare_lock(msg)
    when 'complete'
      handle_completion(msg)
    when 'failure'
      handle_failure(msg)
    else
      @logger.error "Unknown messsage #{msg}"
    end
  end
end

begin
  lock_coordinator = LockCoordinator.new(queue_name: 'lock_coordination') # , rabbitmq_options: {username: 'opera', password: 'opera'}
  lock_coordinator.run
rescue Interrupt
  lock_coordinator.stop
  exit(0)
end
