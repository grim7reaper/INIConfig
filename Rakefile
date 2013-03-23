require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |test|
    test.libs  = ["lib", "test"]
    test.test_files = FileList['test/ts_INIConfig.rb']
    test.verbose = true
end

