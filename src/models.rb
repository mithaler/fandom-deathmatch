#!/usr/bin/ruby

class Character < Sequel::Model
    many_to_many :tournaments, :join_table => :tournaments_characters

end

class Tournament < Sequel::Model
    one_to_many :matches
    many_to_many :characters, :join_table => :tournaments_characters, :select => [:name, :fandom, :status]

    def next_match
        m = Match.new

        #TODO: handle one-character-left case

        char_pool = self.characters_dataset.where(:status => 'ready')
        id = char_pool.get(rand(char_pool.count))['id']
        c = Character.where(:id => id).first
        DB[:tournaments_characters].where(:character_id => c.id, :tournament_id => self.id).update(:status => 'fighting')
        c.save

        m.combatant_a = c

        char_pool = self.characters_dataset.where(:status => :ready)
        c = char_pool.get(rand(char_pool.count))
        c = Character.where(:id => c['id']).first
        DB[:tournaments_characters].where(:character_id => c.id, :tournament_id => self.id).update(:status => 'fighting')
        c.save

        m.combatant_b = c

        m.save
    end


end

class Match < Sequel::Model
    one_to_many :votes
    many_to_one :tournament
    many_to_one :combatant_a, :key => :combatant_a_id, :class => :Character
    many_to_one :combatant_b, :key => :combatant_b_id, :class => :Character
end

class Vote < Sequel::Model
    many_to_one :match
end
