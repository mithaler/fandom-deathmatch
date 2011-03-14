#!/usr/bin/ruby

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'twitter'
require 'sequel'
require 'haml'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://my.db')
require 'src/config'
require 'src/models'

get '/update' do
    t = Tournament.get_current
    m = t.current_match
    if (m.nil?)
        m = t.next_match
        m.first_post
    end

    # check if match is over
    if match.ended?
        # announce match result
    else
        # search for new votes and tally them
        search = Twitter::Search.new
        search.mentioning($BOT_USERNAME).no_retweets.since_id(Vote.max_id).each do |tweet|
            # TODO: make a new Vote and save it
        end
    end
end

get '/' do
    haml :index
end
