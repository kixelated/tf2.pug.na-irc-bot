require './util.rb'
require 'active_record'
require 'composite_primary_keys'

class Team < ActiveRecord::Base
  include Utilities
  set_primary_keys :match_id, :steam_id
  belongs_to :players
  belongs_to :matches
  
  attr_accessor :captain, :players
	attr_accessor :name, :colour
  
  def initialize captain, name, colour
    @captain = captain
		@players = { captain => "captain" }
    
    @name = name
    @colour = colour
	end

  def get_classes
    @players.invert_proper
  end
  
  def my_colourize msg, bg = Const::Black
    colourize msg, @colour, bg
  end
  
  def output_team
    output = players.collect { |k, v| "#{ k } as #{ my_colourize v }" }
    "#{ my_colourize @name }: #{ output.values.join(", ") if output }"
  end

  def insert matchid, steamid, team, clss, iscaptain
    Team.create do |t|
      t.match_id = matchid
      t.steam_id = steamid
      t.team = team
      t.class = clss
      t.is_captain = iscaptain
    end
  end
  
  def update steamid, authname
    Player.update(steamid, { :auth_name => authname } )
  end
  
  def delete steamid
    player = Player.new do |p|
      p.steamid = steamid
    end
    player.destroy
  end
  
  def to_s
    @name
  end
end
