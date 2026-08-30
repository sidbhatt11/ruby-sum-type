# frozen_string_literal: true

source 'https://rubygems.org'

# Deliberately not the full `rails` gem. This app needs exactly two things:
# railties for the boot + eager-load machinery, and activemodel for in-memory
# models. ActiveRecord and ActionPack would be noise.
gem 'activemodel'
gem 'railties'

gem 'rake'

group :development, :test do
  gem 'minitest' # arrives via railties anyway; declared so it is not accidental
  gem 'rubocop', require: false
end
