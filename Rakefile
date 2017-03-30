# frozen_string_literal: true

require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'bundler/gem_tasks'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Default: run tests.'
task default: %i(rubocop test)

desc 'Test the translate_routes plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.warning = false
end

desc 'Generate documentation for the translate_routes plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'RouteTranslator'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
