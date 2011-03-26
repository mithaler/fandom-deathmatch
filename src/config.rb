#!/usr/bin/ruby

configure do
    set :haml, :format => :html5

    set :match_time, 1800
    set :bot_username, 'FanDeathBot'

    # TODO: remove this and make it a fuzzy name search
    set :vote_options, {
        1 => :a,
        2 => :b,
        3 => :team
    }
end

Twitter.configure do |config|
    config.consumer_key = ENV['TWITTER_KEY']
    config.consumer_secret = ENV['TWITTER_SECRET']
    config.oauth_token = ENV['TWITTER_TOKEN']
    config.oauth_token_secret = ENV['TWITTER_TOKEN_SECRET']
end

$CLIENT = Twitter::Client.new

