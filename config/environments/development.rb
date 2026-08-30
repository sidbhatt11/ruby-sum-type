# frozen_string_literal: true

Rails.application.configure do
  # Rails ships this as false in development. It is true here on purpose:
  # eager loading is what turns the construction-time check into a boot check.
  # Production and CI already do this by default.
  config.eager_load = true
end
