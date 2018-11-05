begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

Bundler::GemHelper.install_tasks

namespace :ci do
  desc "Check security aspects"
  task :check_security do
    sh "bundle exec bundle-audit check --update"
  end
end

task :ci => [:spec, "ci:check_security"]
