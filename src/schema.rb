#!/usr/bin/ruby

require 'rubygems'
require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://my.db')

DB.create_table :characters do
    primary_key :id
    varchar :name, :size => 32
    varchar :fandom, :size => 32
end

DB.create_table :tournaments do
    primary_key :id
    timestamp :start_time
end

DB.create_table :tournaments_characters do
    foreign_key :character_id, :characters
    foreign_key :tournament_id, :tournaments
    varchar :status, :size => 10
end

DB.create_table :matches do
    primary_key :id
    foreign_key :combatant_a, :characters
    foreign_key :combatant_b, :characters
    foreign_key :tournament_id, :tournaments
    boolean :complete
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
