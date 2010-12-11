require 'active_record'

class Player < ActiveRecord::Base
  has_many :stats
  has_many :teams
  has_many :matches
  
  def insert steamid, authname
    Player.create do |p|
      p.steam_id = steamid
      p.auth_name = authname
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
  
end