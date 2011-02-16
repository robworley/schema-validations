require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |task|
  task.pattern = 'test/schema_validations_test.rb'
  task.warning = false
  task.verbose = true
end
