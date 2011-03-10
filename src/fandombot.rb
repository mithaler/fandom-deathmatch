#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'twitter'
require 'sequel'
require 'erb'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://my.db')
require 'src/config'
require 'src/models'

=begin
get '/update' do
    match = DB[:matches].where(:complete => false).first
    if match.nil?
        match = setup_match
    end
end
=end

get '/' do
    erb :index
end
