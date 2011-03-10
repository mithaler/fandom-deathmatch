#!/usr/bin/ruby

require 'rubygems'
require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://my.db')

module FandomSchema
    def self.up
        DB.create_table :characters do
            primary_key :id
            varchar :name, :size => 32
            varchar :fandom, :size => 32
        end

        DB.create_table :tournaments do
            primary_key :id
            timestamp :start_time
            boolean :complete, :default => false
        end

        DB.create_table :tournaments_characters do
            foreign_key :character_id, :characters
            foreign_key :tournament_id, :tournaments
            varchar :status, :size => 10, :default => 'ready'
        end

        DB.create_table :matches do
            primary_key :id
            foreign_key :combatant_a_id, :characters
            foreign_key :combatant_b_id, :characters
            foreign_key :tournament_id, :tournaments
            boolean :complete, :default => false
            varchar :result, :size => 5
        end

        DB.create_table :votes do
            primary_key :id
            foreign_key :match_id, :matches
            varchar :vote, :size => 10
            varchar :user, :size => 32
            varchar :tweet_id, :size => 32
            text :explanation
        end
    end

    def self.down
        DB.drop_table :characters, :tournaments, :tournaments_characters, :matches, :votes
    end
end
