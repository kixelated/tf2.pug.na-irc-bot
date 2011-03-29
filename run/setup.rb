require 'bundler/setup'

Dir["../src/model/*.rb"].each { |file| require_relative file }

DataMapper.finalize
DataMapper.auto_migrate!

Server.create(
  name: "chicago1",
  host: "chicago1.tf2pug.us",
  pass: "tf2pug",
  rcon: "secret",
  ftp_user: "pugna", 
  ftp_pass: "secret",
  ftp_dir: "/orangebox/tf"
)

Server.create(
  name: "dallas1",
  host: "dallas1.tf2pug.us",
  pass: "tf2pug",
  rcon: "secret",
  ftp_user: "pugna", 
  ftp_pass: "secret",
  ftp_dir: "/orangebox/tf"
)

Server.create(
  name: "chicago2",
  host: "chicago2.tf2pug.us",
  pass: "tf2pug",
  rcon: "secret",
  ftp_user: "pugna2", 
  ftp_pass: "secret",
  ftp_dir: "/orangebox/tf"
)

Server.create(
  name: "dallas2",
  host: "dallas2.tf2pug.us",
  pass: "tf2pug",
  rcon: "secret",
  ftp_user: "pugna3", 
  ftp_pass: "secret",
  ftp_dir: "/orangebox/tf"
)

Map.create(
  name: "badlands",
  file: "cp_badlands",
  weight: 16
)

Map.create(
  name: "granary",
  file: "cp_granary",
  weight: 8
)

Map.create(
  name: "gullywash",
  file: "cp_gullywash_pro",
  weight: 6
)

Map.create(
  name: "snakewater",
  file: "cp_snakewater_rc2",
  weight: 6
)

Map.create(
  name: "coldfront",
  file: "cp_coldfront",
  weight: 4
)

Map.create(
  name: "viaduct",
  file: "koth_viaduct",
  weight: 4
)

Map.create(
  name: "yukon",
  file: "cp_yukon_final",
  weight: 2
)

Map.create(
  name: "ashville",
  file: "koth_ashville_rc1",
  weight: 1
)

Map.create(
  name: "freight",
  file: "cp_freight_final1",
  weight: 1
)

Map.create(
  name: "obscure",
  file: "cp_obscure_final",
  weight: 1
)

["scout", "soldier", "pyro", "demo", "heavy", "engineer", "medic", "sniper", "spy", "civilian", "captain"].each do |clss|
  Tfclass.create(:name => clss)
end
