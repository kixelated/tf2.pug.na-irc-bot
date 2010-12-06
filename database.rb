require 'singleton'
require 'sqlite3'


class Database
  include Singleton
  
  def initialize
    @database = SQLite3::Database.new("./dat/pugdata.db")
  end
  
  def execute! sql
    @database.execute( sql )
  end
  
  def getvalue! sql
    @database.get_first_value( sql )
  end
  
  #player table
  def get_player playerid
    @database.get_first_row("SELECT * FROM Player WHERE PlayerID = ?;",  playerid)
  end
  
  def insert_player email, password, steamid, accesslevel, registrationcode
    @database.execute("INSERT INTO Player (PlayerID, Email, Password, SteamID, AccessLevel, RegistrationCode, IsActivated) VALUES (?,?,?,?,?,?,?);", "NULL", email, password, steamid, accesslevel, registrationcode, 1)
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
  def get_pug pugid
    @database.get_first_row("SELECT * FROM Pug WHERE PugID = ?;",  pugid)
  end
  
  def insert_pug serverid, type, map #returns pugid
    @database.execute("INSERT INTO Pug (PugID, ServerID, Type, Map, CreatedDateTime) VALUES (?,?,?,?,?);", "NULL", serverid, type, map, Time.now.to_s)
    @database.get_first_value("SELECT last_insert_rowid() FROM Pug;")
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
  def get_team_player pugid, playerid
    @database.execute("SELECT * FROM Team WHERE PugID = ? AND PlayerID = ?;", pugid, playerid)
  end
 
  def get_team pugid, team
    @database.execute("SELECT * FROM Team WHERE PugID = ? AND Team = ?", pugid, team)
  end
  
  def insert_team_player pugid, playerid, team, classname, iscaptain
    @database.execute("INSERT INTO Team (PugID, PlayerID, Team, Class, IsCaptain) VALUES (?,?,?,?,?);", pugid, playerid, team, classname, iscaptain)
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