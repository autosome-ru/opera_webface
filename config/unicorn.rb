# Minimal sample configuration file for Unicorn (not Rack) when used
# with daemonization (unicorn -D) started in your working directory.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
# See also http://unicorn.bogomips.org/examples/unicorn.conf.rb for
# a more verbose configuration using more features.

# SIMPLE

# listen 3000 # by default Unicorn listens on port 8080
# worker_processes 3 # this should be >= nr_cpus
# pid "/home/ilya/opera_webface/shared/pids/unicorn.pid"
# stderr_path "/home/ilya/opera_webface/log/unicorn.log"
# stdout_path "/home/ilya/opera_webface/log/unicorn.log"


# ZERO-DOWNTIME
# deploy_to  = "/srv/myapp"
# rails_root = "#{deploy_to}/current"
# pid_file   = "#{deploy_to}/shared/pids/unicorn.pid"
# socket_file= "#{deploy_to}/shared/unicorn.sock"
# log_file   = "#{rails_root}/log/unicorn.log"
# err_log    = "#{rails_root}/log/unicorn_error.log"
# old_pid    = pid_file + '.oldbin'

ENV["UNICORN"] = "true" # notify app that we it's running via unicorn

deploy_to  = ENV.fetch("DEPLOY_PATH", "/home/ilya/opera_webface")
rails_root = "#{deploy_to}"
pid_file   = "#{rails_root}/tmp/pids/unicorn.pid"
socket_file= "#{rails_root}/tmp/sockets/unicorn.sock"
log_file   = "#{rails_root}/log/unicorn.log"
err_log    = "#{rails_root}/log/unicorn_error.log"
old_pid    = pid_file + '.oldbin'

timeout 30
worker_processes 4 # Здесь тоже в зависимости от нагрузки, погодных условий и текущей фазы луны
#listen socket_file, :backlog => 1024
listen "0.0.0.0:3000"
pid pid_file
stderr_path err_log
stdout_path log_file

preload_app true # Мастер процесс загружает приложение, перед тем, как плодить рабочие процессы.

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=) # Решительно не уверен, что значит эта строка, но я решил ее оставить.

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{rails_root}/Gemfile"
end

before_fork do |server, worker|
  # Перед тем, как создать первый рабочий процесс, мастер отсоединяется от базы.
  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.connection.disconnect!

  # Ниже идет магия, связанная с 0 downtime deploy.
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # После того как рабочий процесс создан, он устанавливает соединение с базой.
  defined?(ActiveRecord::Base) and
  ActiveRecord::Base.establish_connection

  AMQPManager.start
end

