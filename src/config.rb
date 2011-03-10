#!/usr/bin/ruby

$MATCH_TIME = 1800

Twitter.configure do |config|
    config.consumer_key = $TWITTER_KEY
    config.consumer_secret = $TWITTER_SECRET
    config.oauth_token = $TWITTER_TOKEN
    config.oauth_token_secret = $TWITTER_TOKEN_SECRET
end

