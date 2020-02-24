#!/usr/bin/env ruby
require 'bunny'

connection = Bunny.new(automatically_recover: false)
connection.start

channel = connection.create_channel
channel.confirm_select

queue = channel.queue('hello', durable: true)

# exchange = channel.direct('logs')
# exchange.publish(message)

exchange = channel.default_exchange
# (http://www.rabbitmq.com/tutorials/amqp-concepts.html#exchange-default)
# all queues are automatically bound to default exchange with routing keys equal to queue names

exchange.publish('Hello World!', routing_key: queue.name, persistent: true) # , content_type: 'application/json'
puts " [x] Sent 'Hello World!'"

channel.wait_for_confirms

connection.close

# docker run --rm -p 5672:5672 -p 8001:15672 -d --hostname my-rabbit -v /home/ilya/iogen/tools/opera_webface/rabbitmq/rabbit_data:/var/lib/rabbitmq -e RABBITMQ_DEFAULT_USER=user -e RABBITMQ_DEFAULT_PASS=password --name some-rabbit rabbitmq:3.7.8-management
# docker exec some-rabbit rabbitmqctl list_queues


# не очень хорошо, чтобы приложение создавало очередь. Каждый "создатель" очереди должен согласованно передавать параметры --> сложнее согласовать кодовые базы
# стоит ещё настроить логины-пароли у брокера