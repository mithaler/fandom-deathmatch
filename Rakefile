#!/usr/bin/ruby

require 'src/schema'

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
