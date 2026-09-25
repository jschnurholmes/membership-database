max_threads = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads max_threads, max_threads

port  ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

worker_count = ENV.fetch("WEB_CONCURRENCY") { 0 }.to_i
workers worker_count

preload_app!

# Forked workers inherit the parent's DB connection, which they can't safely
# share, so each one needs its own. Only relevant in cluster mode (workers > 0).
if worker_count > 0
  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
end

plugin :tmp_restart
