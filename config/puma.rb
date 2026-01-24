# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.

# Puma starts a configurable number of processes (workers) and each process
# serves each request in a thread from an internal thread pool.
#
# The ideal number of threads per worker depends both on how much time the
# application spends waiting for IO operations and on how much you wish to
# to prioritize throughput over latency.
#
# As a rule of thumb, increasing the number of threads will increase how much
# traffic a given process can handle (throughput), but due to CRuby's
# Global VM Lock (GVL) it has diminishing returns and will degrade the
# response time (latency) of the application.
#
# The default is set to 3 threads as it's deemed a decent compromise between
# throughput and latency for the average Rails application.
#
# Any libraries that use a connection pool or another resource pool should
# be configured to provide at least as many connections as the number of
# threads. This includes Active Record's `pool` parameter in `database.yml`.

# threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
# threads threads_count, threads_count

# # Specify the PID file. Defaults to tmp/pids/server.pid in development.
# # In other environments, only set the PID file if requested.
# pidfile ENV["PIDFILE"] if ENV["PIDFILE"]


app_name = 'opera_webface'
environment ENV.fetch("RAILS_ENV") { "production" }

threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS") { 3 })
threads threads_count, threads_count

# Use one process to save memory (0 means single-mode, not cluster-mode)
# see https://github.com/puma/puma/blob/main/docs/deployment.md#single-vs-cluster-mode
workers Integer(ENV.fetch("WEB_CONCURRENCY") { 0 })

shared_dir = ENV.fetch("APP_SHARED_DIR") { '/run/puma' }
log_dir = ENV.fetch("APP_LOG_DIR") { '/var/log/puma' }

bind ENV.fetch("APP_BIND") {
  # "tcp://0.0.0.0:3000"
  "unix://#{shared_dir}/#{app_name}.sock?umask=0007"
}
# # (or shortcut)
# # Specifies the `port` that Puma will listen on to receive requests; default is 3000.
# port ENV.fetch("PORT", 3000)

pidfile "#{shared_dir}/#{app_name}.pid"
state_path "#{shared_dir}/#{app_name}.state"

stdout_redirect "#{log_dir}/#{app_name}.log", "#{log_dir}/#{app_name}.error.log", true

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
