require_relative '../config'

require 'tf2pug/database'
Dir['../../lib/tf2pug/model/*'].each { |file| require file }

DataMapper.finalize
DataMapper.auto_migrate!

# Create server objects
[   #  name  #  #      host        #  # pass #  # rcon #  # ftp #   # ftp pass #  #   ftp dir   #
  [ "chicago1", "chicago1.tf2pug.us", "tf2pug", "secret", "pugna",  "ftp_secret", "/orangebox/tf" ],
  [ "dallas1",  "dallas1.tf2pug.us",  "tf2pug", "secret", "pugna",  "ftp_secret", "/orangebox/tf" ],
  [ "chicago2", "chicago2.tf2pug.us", "tf2pug", "secret", "pugna2", "ftp_secret", "/orangebox/tf" ],
  [ "dallas2",  "dallas2.tf2pug.us",  "tf2pug", "secret", "pugna3", "ftp_secret", "/orangebox/tf" ]
].each do |name, host, pass, rcon, ftp_user, ftp_pass, ftp_dir|
  Server.create(:name => name, :host => host, :pass => pass, :rcon => rcon, :ftp => Ftp.create(:host => host, :user => ftp_user, :pass => ftp_pass, :dir => ftp_dir))
end

# Create ftp object (web host)
Ftp.create(:host => "tf2pug.us", :user => "demos@tf2pug.us", :pass => "secret", :dir => "", :web => true)

# Create map objects
[
  [ "badlands",   "cp_badlands",       12 ],
  [ "granary",    "cp_granary",         8 ],
  [ "snakewater", "cp_snakewater_rc2",  6 ],
  [ "gullywash",  "cp_gullywash_pro",   6 ],
  [ "coldfront",  "cp_coldfront",       4 ],
  [ "viaduct",    "koth_viaduct",       4 ],
  [ "yukon",      "cp_yukon_final",     2 ],
  [ "ashville",   "koth_ashville_rc1",  1 ],
  [ "freight",    "cp_freight_final1",  1 ],
  [ "obscure",    "cp_obscure_final",   1 ]
].each do |name, file, weight|
  Map.create(:name => name, :file => file, :weight => weight)
end

# Create class objects
[
  [ "scout",    2 ], 
  [ "soldier",  2 ], 
  [ "pyro",     0 ], 
  [ "demoman",  1 ], 
  [ "heavy",    0 ], 
  [ "engineer", 0 ], 
  [ "medic",    1 ], 
  [ "sniper",   0 ], 
  [ "spy",      0 ]
].each do |name, pug_count|
  Tfclass.create(:name => name, :pug_count => pug_count)
end

# Create pug team objects
[
  "High Flying Maggots",
  "Ingeniously Igneous Eagles",
  "Inappropriate Vikings",
  "Introverted Urgency",
  "Chocolate Snow",
  "Berserk Sealions",
  "Dallas Exploding Bazookas",
  "Sexy Sedimentary Keeper of the Keys and Grounds",
  "Melancholy Tornadoes",
  "Very Sad Clouds",
  "Rudely Responsible Rappers",
  "UnBendable Steel",
  "Melancholy Ravens",
  "Tokyo Earthquakes",
  "Mighty Metamorphic Killers",
  "Flexible Aluminum Racoons",
  "Melancholy Grenades",
  "Cockeyed Fightin' Lords",
  "Nuts Tuff Tigers",
  "Data Center Dogs"
].each do |name|
  Team.create(:name => name, :pug => true)
end
