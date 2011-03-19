#!/usr/bin/ruby

set :haml, :format => :html5

$MATCH_TIME = 1800
$BOT_USERNAME = 'FanDeathBot'

Twitter.configure do |config|
    config.consumer_key = ENV['TWITTER_KEY']
    config.consumer_secret = ENV['TWITTER_SECRET']
    config.oauth_token = ENV['TWITTER_TOKEN']
    config.oauth_token_secret = ENV['TWITTER_TOKEN_SECRET']
end

$CLIENT = Twitter::Client.new

$VOTE_OPTIONS = {
    1 => :a,
    2 => :b,
    3 => :team
}
