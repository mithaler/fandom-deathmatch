#!/usr/bin/ruby

$MATCH_TIME = 1800

Twitter.configure do |config|
    config.consumer_key = ENV['TWITTER_KEY']
    config.consumer_secret = ENV['TWITTER_SECRET']
    config.oauth_token = ENV['TWITTER_TOKEN']
    config.oauth_token_secret = ENV['TWITTER_TOKEN_SECRET']
end

