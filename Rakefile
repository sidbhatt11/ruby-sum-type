# frozen_string_literal: true

require 'rake/testtask'

# Present so Rails resolves this directory as the application root.
# It only shells out; requiring the app here would double-activate rake.

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
end

desc 'RuboCop, full config'
task :rubocop do
  sh 'bundle exec rubocop'
end

desc "Boot the app; fails if any matcher doesn't cover its sum"
task :boot_check do
  sh 'bin/boot-check'
end

task default: %i[rubocop test boot_check]
