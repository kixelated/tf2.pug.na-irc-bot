require_relative '../config'

require 'tf2pug/database'
Dir['../../lib/tf2pug/model/*'].each { |file| require file }

DataMapper.finalize
DataMapper.auto_migrate!

# TODO: Slim down these lines
Server.create(
  name: "chicago1",
  host: "chicago1.tf2pug.us",
  pass: "tf2pug",
  rcon: "secret",
  ftp: Ftp.create(
    host: "chicago1.tf2pug.us",
    user: "pugna",
    pass: "secret",
    dir: "/orangebox/tf"
  )
)

Server.create(
  name: "dallas1",
  host: "dallas1.tf2pug.us",
  pass: "tf2pug",
  rcon: "secret",
  ftp: Ftp.create(
    host: "dallas1.tf2pug.us",
    user: "pugna",
    pass: "secret",
    dir: "/orangebox/tf"
  )
)

Server.create(
  name: "chicago2",
  host: "chicago2.tf2pug.us",
  pass: "tf2pug",
  rcon: "secret",
  ftp: Ftp.create(
    host: "chicago2.tf2pug.us",
    user: "pugna2",
    pass: "secret",
    dir: "/orangebox/tf"
  )
)

Server.create(
  name: "dallas2",
  host: "dallas2.tf2pug.us",
  pass: "tf2pug",
  rcon: "secret",
  ftp: Ftp.create(
    host: "dallas2.tf2pug.us",
    user: "pugna3",
    pass: "secret",
    dir: "/orangebox/tf"
  )
)

Ftp.create(
  host: "tf2pug.us",
  user: "demos@tf2pug.us",
  pass: "secret",
  dir: "",
  web: true
)

[
  [ "badlands", "cp_badlands", 12 ],
  [ "granary", "cp_granary", 8 ],
  [ "snakewater", "cp_snakewater_rc2", 6 ],
  [ "gullywash", "cp_gullywash_pro", 6 ],
  [ "coldfront", "cp_coldfront", 4 ],
  [ "viaduct", "koth_viaduct", 4 ],
  [ "yukon", "cp_yukon_final", 2 ],
  [ "ashville", "koth_ashville_rc1", 1 ],
  [ "freight", "cp_freight_final1", 1 ],
  [ "obscure", "cp_obscure_final", 1 ]
].each do |name, file, weight|
  Map.create(:name => name, :file => file, :weight => weight)
end

{
  scout: 2, 
  soldier: 2,
  pyro: 0,
  demo: 1, 
  heavy: 0,
  engineer: 0,
  medic: 1,
  sniper: 0,
  spy: 0,
  captain: 1 # this must be 1
}.each do |name, count|
  Tfclass.create(:name => name, :pug => count)
end
