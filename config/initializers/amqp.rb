require 'bunny'

module AMQPManager
  def self.connection; @connection; end
  def self.channel; @channel; end

  def self.start
    @connection = Bunny.new
    @connection.start
    @channel = @connection.create_channel
    @channel.confirm_select
    declare_queues!
  end
  def self.stop
    @connection.close
  end

  def self.publish_to_default_exchange(*args)
    @channel.default_exchange.publish(*args)
    @channel.wait_for_confirms
  end

  # create queues if they don't exist
  def self.declare_queues!
    ['SnpScan', 'MotifDiscovery', 'MotifDiscoveryDi', 'ScanCollection', 'EvaluateSimilarity', 'sequence_logo'].each do |queue_name|
      @channel.queue(queue_name, durable: true)
    end
  end
end

# unicorn runs this in each worker separately
AMQPManager.start  unless ENV["UNICORN"]
