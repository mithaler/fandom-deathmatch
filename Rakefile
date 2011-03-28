#!/usr/bin/ruby

require 'src/schema'
require 'rake/clean'

CLEAN.include('my.db')

task :run do
    sh "shotgun --server=thin --port=3000 config.ru"
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
        if ENV['RACK_ENV'] == :production
            FandomSchema.down
        else
            Rake::Task['clean'].invoke
        end

        puts "Schema dropped!"
    end

    task :reload => [:down, :up]
end

task :default => :run
