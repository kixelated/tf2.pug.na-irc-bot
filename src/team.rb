require './database.rb'
require './util.rb'

class Team < ActiveRecord::Base
  include Utilities
  
  has_and_belongs_to_many :players
  has_and_belongs_to_many :matches
	
	def captain
	  get_classes["captain"].first
	end

  def get_classes
    @players.invert_proper
  end
  
  def output_team
    output = players.collect { |k, v| "#{ k } as #{ v }" }
    "#{ @name }: #{ output.values.join(", ") if output }"
  end

  def to_s
    @name
  end
end
