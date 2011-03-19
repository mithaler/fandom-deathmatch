#!/usr/bin/ruby

class Character < Sequel::Model
    many_to_many :tournaments, :join_table => :tournaments_characters

    def to_s
        self.name
    end
end

class Tournament < Sequel::Model
    one_to_many :matches
    many_to_many :characters, {
        :join_table => :tournaments_characters,
        :select => [:id, :name, :fandom, :status],
        :after_add => Proc.new { |t, c|
            assoc = DB[:tournaments_characters].where(:tournament_id => t.id, :character_id => c.id).update(:status => 'ready')
        }
    }

    def current_match
        self.matches_dataset.where(:complete => false).first
    end

    def ready_combatants
        self.characters_dataset.where(:status => 'won').update(:status => 'ready')
    end

    def next_match
        m = Match.new
        m.tournament = self

        pool = self.characters_dataset.where(:status => 'ready')
        count = pool.count

        if count == 0
            # go to next level
        elsif count == 1
            # check if tournament is over, if not, match with another winner
        else
            c = pool.all[rand(pool.count)]
            DB[:tournaments_characters].where(:character_id => c.id, :tournament_id => self.id).update(:status => 'fighting')
            m.combatant_a = c

            pool = self.characters_dataset.where(:status => 'ready')
            count = pool.count
            c = pool.all[rand(pool.count)]
            DB[:tournaments_characters].where(:character_id => c.id, :tournament_id => self.id).update(:status => 'fighting')
            m.combatant_b = c
        end

        m.save
    end

    def self.get_current
        Tournament.where(:complete => false).filter(:start_time <= Time.now).first
    end
end

class Match < Sequel::Model
    one_to_many :votes
    many_to_one :tournament
    many_to_one :combatant_a, :key => :combatant_a_id, :class => :Character
    many_to_one :combatant_b, :key => :combatant_b_id, :class => :Character

    def first_post
        $CLIENT.update("Match starting: #{self.combatant_a.to_s} vs. #{self.combatant_b.to_s}! Who wins?")
    end

    def ended?
        Time.now - self.start_time > $MATCH_TIME
    end

    def result
        results = {:a => 0, :b => 0, :team => 0}
        votes.each do |v|
            results[v.vote] += 1
        end
        results
    end
end

class Vote < Sequel::Model
    many_to_one :match

    def self.max_id
        self.max(:tweet_id)
    end
end
