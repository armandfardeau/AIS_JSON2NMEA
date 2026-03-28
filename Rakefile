# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: :spec

RuboCop::RakeTask.new(:lint)
RuboCop::RakeTask.new(:'lint:fix') do |task|
  task.options = ['-A']
end

desc 'No-op in pure Ruby mode (kept for backward compatibility)'
task :compile do
  puts 'Pure Ruby mode: nothing to compile'
end

# RSpec tests
RSpec::Core::RakeTask.new(:spec)
