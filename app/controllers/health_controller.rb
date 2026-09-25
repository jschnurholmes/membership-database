# Bypasses ApplicationController deliberately, same as Rails' own health
# controller, so this never depends on app-level filters (auth, CSRF, etc.)
class HealthController < ActionController::Base
  def db
    ActiveRecord::Base.connection.execute("SELECT 1")
    head :ok
  rescue StandardError
    head :service_unavailable
  end
end
