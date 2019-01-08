require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Metanorma-ietf 2.0 test suite"
RSpec::Core::RakeTask.new(:spec_ietf20) do |task|
  ietf20_dirs = ["spec/asciidoctor/ietf/*_spec.rb"]
  task.pattern = Dir.glob(ietf20_dirs)
end

desc "Run the edge version"
task :spec_edge do
  require "dotenv/load"
  rake_task = ENV["DEV_MODE"] != "true" ? "spec" : "spec_ietf20"

  Rake::Task[rake_task].execute
end

# Run the suitable test suite: temporary
#
# The ietf development version is bit different than our
# current version, and in this development phase we don't wnat
# to break any of thise version for the other one, so we are
# explicity defining a custom task that will determine which
# test suite to run.
#
task default: :spec_edge
