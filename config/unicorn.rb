# Minimal sample configuration file for Unicorn (not Rack) when used
# with daemonization (unicorn -D) started in your working directory.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
# See also http://unicorn.bogomips.org/examples/unicorn.conf.rb for
# a more verbose configuration using more features.
# See also https://habr.com/ru/post/120368/

rails_root  = File.absolute_path('../', __dir__)

# SIMPLE
# listen 3000 # by default Unicorn listens on port 8080
# worker_processes 3 # this should be >= nr_cpus
# pid "#{rails_root}/tmp/pids/unicorn.pid"
# stderr_path "#{rails_root}/log/unicorn.log"
# stdout_path "#{rails_root}/log/unicorn.log"

# ZERO-DOWNTIME
app_name   = 'opera_webface'
pid_file   = "/run/unicorn/#{app_name}.pid"
socket_file= "/run/unicorn/#{app_name}.sock"
log_file   = "/var/log/unicorn/#{app_name}.log"
err_log    = "/var/log/unicorn/#{app_name}.error.log"
old_pid    = pid_file + '.oldbin'

timeout 30
worker_processes 4
listen socket_file, :backlog => 1024
pid pid_file
stderr_path err_log
stdout_path log_file

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory rails_root # available in 0.94.0+

# combine Ruby 2.0.0+ with "preload_app true" for memory savings
preload_app true # Master preloads an app before spawning workers

# Enable this flag to have unicorn test client connections by writing the
# beginning of the HTTP headers before calling the application.  This
# prevents calling the application for connections that have disconnected
# while queued.  This is only guaranteed to detect clients on the same
# host unicorn runs on, and unlikely to detect disconnects even on a
# fast LAN.
check_client_connection false

GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{rails_root}/Gemfile"
end

# local variable to guard against running a hook multiple times
run_once = true

before_fork do |server, worker|
  # Disconnect from DB before creating the first worker
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!

  # Occasionally, it may be necessary to run non-idempotent code in the master before forking.
  if run_once
    # do_something_once_here ...
    run_once = false # prevent from firing again
  end


  # Zero-downtime deploy magic
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # After worker is on, it connects to a DB
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis. TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
