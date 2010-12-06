require 'singleton'
require 'sqlite3'


class Database
  include Singleton
  
  def initialize
    @database = SQLite3::Database.new("./dat/pugdata.db")
  end
  
  #player table
  def insert_player email, password, steamid, accesslevel, registrationcode
      @database.execute("INSERT INTO Player (Email, Password, SteamID, AccessLevel, RegistrationCode, IsActivated) VALUES (?,?,?,?,?);", email, password, steamid, accesslevel, registrationcode, "False")
  end
  
  def update_player_activate playerid
    @database.execute("UPDATE Player SET IsActivated = ? WHERE PlayerID = ?;", "True", playerid)
  end
  
  def player_steamid_exists? steamid
    @database.get_first_value("SELECT SteamID FROM Player WHERE SteamID = ?;", steamid)
  end
  
  def player_email_exists? email
    @database.get_first_value("SELECT Email FROM Player WHERE Email = ?;", email)
  end
  
  
  #pug table
  def insert_pug? serverid, type, map #returns pugid
    return @database.get_first_value("INSERT INTO Pug (ServerID, Type, Map, CreatedDateTime) VALUES (?,?,?,?); SELECT last_insert_rowid() FROM Pug;", serverid, type, map, Time.now.to_s)
  end
  
  def update_pug_map pugid, map
    @database.execute("UPDATE Pug SET Map = ? WHERE PugID = ?;", map, pugid)
  end
  
  def update_pug_startdatetime pugid
    @database.execute("UPDATE Pug SET StartDateTime = ? WHERE PugID = ?;", Time.now.to_s, pugid)
  end
  
  def update_pug_score pugid, redscore, bluscore
    @database.execute("UPDATE Pug SET RedScore = ?, BluScore = ? WHERE PugID = ?;", pugid, redscore, bluscore)
  end
  
  
  #team table
  def insert_team_player pugid, playerid, team, classs, iscaptain
    @database.execute("INSERT INTO Team (PugID, PlayerID, Team, Class) VALUES (?,?,?,?);", pugid, playerid, team, classs)
  end
  
  def delete_team_player pugid, playerid
    @database.execute("DELETE Team WHERE PugID = ? AND PlayerID = ?;", pugid, playerid)
  end
  
  def update_team_player_score pugid, playerid, score
    @database.execute("UPDATE Team SET Score = ? WHERE PugID = ? AND PlayerID = ?;", score, pugid, playerid)
  end
 
  def update_team_player_needsub pugid, playerid
    @database.execute("UPDATE Team SET NeedSub = True WHERE PugID = ? and PlayerID = ?;", pugid, playerid)
  end

  
  
end