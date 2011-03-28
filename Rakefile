#!/usr/bin/ruby

require 'src/schema'
require 'rake/clean'

CLEAN.include('my.db')

desc "Run the app locally"
task :run do
    sh "shotgun --server=thin --port=3000 config.ru"
end

desc "Pull up an IRB session with everything loaded"
task :console do
    sh "irb -r 'src/fandombot'"
end

namespace :db do
    desc "Load the schema into the database"
    task :up do
        FandomSchema.up
        puts "Schema loaded!"
    end

    desc "Empty out the database"
    task :down do
        if ENV['RACK_ENV'] == :production
            FandomSchema.down
        else
            Rake::Task['clean'].invoke
        end

        puts "Schema dropped!"
    end

    desc "Reload the database schema"
    task :reload => [:down, :up]
end

task :default => :run
