#!/usr/bin/ruby

require 'rubygems'
require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://my.db')

DB.create_table :characters do
    primary_key :id
    string :name, :size => 32
    string :fandom, :size => 32
end

DB.create_table :tournaments do
    primary_key :id
    datetime :start_time
end

DB.create_table :tournaments_characters do
    foreign_key :character_id, :characters
    foreign_key :tournament_id, :tournaments
    string :status, :size => 10
end

DB.create_table :matches do
    primary_key :id
    foreign_key :combatant_a, :characters
    foreign_key :combatant_b, :characters
    foreign_key :tournament_id, :tournaments
    boolean :complete
    string :result, :size => 5
end

DB.create_table :votes do
    primary_key :id
    foreign_key :match_id, :matches
    string :vote, :size => 10
    string :user, :size => 32
    string :tweet_id, :size => 32
    text :explanation
end
