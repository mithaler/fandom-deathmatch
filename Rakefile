#!/usr/bin/ruby

require 'src/schema'

task :run do
    sh "thin -R config.ru start"
end

task :console do
    sh "irb -r 'src/fandombot'"
end

namespace :db do
    task :up do
        FandomSchema.up
        puts "Schema loaded!"
    end

    task :down do
        FandomSchema.down
        puts "Schema dropped!"
    end

    task :reload => [:down, :up]
end

task :default => :run
