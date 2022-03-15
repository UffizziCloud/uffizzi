# frozen_string_literal: true

HealthCheck.setup do |config|
  config.uri = 'health_check'
  config.success = 'success'
  config.http_status_for_error_text = 500
  config.http_status_for_error_object = 500
  config.standard_checks = ['database', 'migrations']
  config.full_checks = ['database', 'migrations']
end
