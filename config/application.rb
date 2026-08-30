# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'

module SumTypeDemo
  # The only configuration of note is eager-loading app/models, which is what
  # turns every matcher's construction-time check into a boot-time check.
  class Application < Rails::Application
    config.load_defaults 8.1
    config.eager_load_paths << root.join('app/models')
  end
end
