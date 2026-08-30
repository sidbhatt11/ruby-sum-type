# frozen_string_literal: true

Rails.application.configure do
  config.eager_load = true
  config.secret_key_base = 'demo_app_not_a_real_secret'
end
