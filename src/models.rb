#!/usr/bin/ruby

class Character < Sequel::Model

    def to_s
        name
    end

    def abbreviations
        words = name.split ' '

        if words.length > 1
            initials = ''
            words.each do |w|
                initials << w[0,1]
            end
            words << initials
        end

        words
    end

    def status=(str)
        DB[:tournaments_characters].where(:tournament_id => Tournament.get_current.id, :character_id => id).update(:status => str)
    end

    def status
        DB[:tournaments_characters].where(:tournament_id => Tournament.get_current.id, :character_id => id).first[:status]
    end

    def team_with(other)
        if other.class == 'Team'
            other.add_combatant self
            return other
        else
            t = Team.new
            t.add_combatant self
            t.add_combatant other
            return t
        end
    end
end

class Tournament < Sequel::Model
    one_to_many :matches
    one_to_many :teams
    many_to_many :characters, {
        :join_table => :tournaments_characters,
        :select => [:id, :name, :fandom, :status],
        :after_add => Proc.new { |t, c|
            assoc = DB[:tournaments_characters].where(:tournament_id => t.id, :character_id => c.id).update(:status => 'ready')
        }
    }

    def current_match
        matches_dataset.where(:complete => false).first
    end

    # Resets all combatants that won the previous round to ready status.
    def level_advance
        teams_dataset.where(:status => 'won').update(:status => 'ready')
    end

    def next_match
        m = Match.new
        m.tournament = self

        # This isn't a proper bracket; it's a pool of winners with next combatants randomly chosen from it.
        # Emulates picking winners out of a hat.
        pool = teams_dataset.where(:status => 'ready')
        count = pool.count

        if count == 0
            level_advance
            # run same code as else block
        elsif count == 1
            winners = teams_dataset.where(:status => 'won')
            # pick one winner and make a match with it
        else
            # > 1 ready combatants; choose two at random
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
    many_to_one :team_a, :key => :team_a_id, :class => :Team
    many_to_one :team_b, :key => :team_b_id, :class => :Team

    alias :a :team_a
    alias :b :team_b

    def first_post
        $CLIENT.update("Match starting: #{self.combatant_a.to_s} vs. #{self.combatant_b.to_s}! Who wins?")
    end

    def ended?
        (Time.now - start_time > settings.match_time) && result.length == 1
    end

    def result
        results = {:a => 0, :b => 0, :team => 0}
        votes.each do |v|
            results[v.vote] += 1
        end

        comparable = {}
        results.each do |key, value|
            if !comparable[value]
                comparable[value] = [key]
            else
                comparable[value] << key
            end
        end

        comparable.max_by {|key, value| key}
    end
end

class Vote < Sequel::Model
    many_to_one :match

    def self.max_id
        self.max(:tweet_id)
    end
end

class Team < Sequel::Model
    many_to_many :characters
    many_to_one :tournament

    # Adds another combatant to this Team. If it's another Team, adds all of its members to this one.
    def add_combatant(combatant)
        if combatant.respond_to? :characters
            combatant.characters.each do |c|
                add_character c
            end
        else
            add_character combatant
        end
    end

    def abbreviations
        characters.inject([]) { |all, char| all.concat(char.abbreviations) }
    end

    def to_s
        chars = characters
        names = ''
        chars.each_index do |i|
            if i == chars.length - 1
                names << ' and ' + chars[i].to_s
            elsif i == 0
                names << chars[i].to_s
            else
                names << ', ' + chars[i].to_s
            end
        end
        names
    end
end
