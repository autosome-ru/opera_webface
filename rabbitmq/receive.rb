# #!/usr/bin/env ruby
# require 'bunny'

# # class ExampleConsumer < Bunny::Consumer
# #   def cancelled?
# #     @cancelled
# #   end

# #   def handle_cancellation(_)
# #     @cancelled = true
# #   end
# # end

# connection = Bunny.new(automatically_recover: false)
# connection.start

# channel = connection.create_channel
# queue = channel.queue('hello', no_declare: true)
# channel.prefetch(1)

# begin
#   puts ' [*] Waiting for messages. To exit press CTRL+C'
#   queue.subscribe(manual_ack: true) do |delivery_info, _properties, body|
#     sleep 0.25
#     puts " [x] Received #{body}"
#     channel.ack(delivery_info.delivery_tag)
#   end
#   loop{ sleep 5 }
# rescue Interrupt => _
#   connection.close

#   exit(0)
# end

require 'bunny'

class HelloConsumer < Bunny::Consumer
end

conn = Bunny.new
conn.start

ch = conn.channel
x = ch.direct('hello-exchange', :durable => true)
q = ch.queue('hello-queue', :durable => true)
q.bind(x, :routing_key => 'hola')

consumer = HelloConsumer.new(ch, q, 'hello-consumer')

consumer.on_delivery do |delivery_info, properties, payload|
  if payload == 'quit'
    ch.work_pool.shutdown
  else
    puts payload
  end
end

q.subscribe_with(consumer, :block => true)