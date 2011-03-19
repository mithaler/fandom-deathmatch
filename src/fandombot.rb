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
    if m.nil?
        m = t.next_match
        m.first_post
    end

    # check if match is over
    if m.ended?
        # announce match result
    else
        # search for new votes and tally them
        search = Twitter::Search.new
        search.mentioning($BOT_USERNAME).no_retweets.since_id(Vote.max_id).each do |tweet|
            text = tweet.text
            text.gsub! /@#{$BOT_USERNAME} /, ''

            # check first character of each tweet minus the @username, that's the vote
            # everything after that in the tweet is saved as the explanation
            if $VOTE_OPTION[text[0,1]]
                v = Vote.new
                v.vote = $VOTE_OPTION[text[0,1]]
                v.match = m
                v.user = tweet.from_user
                v.tweet_id = tweet.id
                v.explanation = text.gsub(/[\d]+[,: ]{1,2}/, '')
                v.save
            end
        end
    end
end

get '/' do
    haml :index
end
