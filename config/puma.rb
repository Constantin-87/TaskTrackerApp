
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# bind to localhost (Nginx will redirect here)
bind "tcp://127.0.0.1:4000"

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# Specify the PID file. Defaults to tmp/pids/server.pid in development.
# In other environments, only set the PID file if requested.
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

stdout_redirect "/var/www/tasktracker-backend/log/puma.stdout.log", "/var/www/tasktracker-backend/log/puma.stderr.log", true
