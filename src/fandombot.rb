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
        winner = m.result
        if (winner == :a)
            winner = m.a
            $CLIENT.update("Match ended! The winner is #{winner.name}! The next match will start shortly.")
        elsif (winner == :b)
            winner = m.b
            $CLIENT.update("Match ended! The winner is #{winner.name}! The next match will start shortly.")
        elsif (winner == :team)
            winner = Team.new
            winner.add_character(m.a)
            winner.add_character(m.b)
            winner.tournament = t
            winner.save
            $CLIENT.update("Match ended! The combatants teamed up! The next match will start shortly.")
        end
    else
        # search for new votes and tally them
        search = Twitter::Search.new
        search.mentioning(settings.bot_username).no_retweets.since_id(Vote.max_id).each do |tweet|
            text = tweet.text
            text.gsub! /@#{settings.bot_username} /, ''

            # check first character of each tweet minus the @username, that's the vote
            # everything after that in the tweet is saved as the explanation
            if settings.vote_options[text[0,1]]
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

# These are meant for human consumption

get '/' do
    haml :index
end

get '/style.css' do
    scss :style
end

get '/new-character' do
    @characters = Tournament.get_current.characters
    haml :new_character
end

post '/new-character' do
    character = Character.new
    character.name = params[:name]
    character.fandom = params[:fandom]
    t = Tournament.get_current
    t.add_character character
    t.save

    @characters = Tournament.get_current.characters
    haml :new_character
end
