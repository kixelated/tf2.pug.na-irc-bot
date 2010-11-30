module Constants
  afk_threshold = 60 * 10
  afk_delay = 45
  picking_delay = 45

  players = {}
  afk = []

  team_size = 6
  team_classes = { "scout" => 2, "soldier" => 2, "demo" => 1, "medic" => 1, "captain" => 1 }
  team_count = 2
  team_names = ["Red team", "Blue team"]
  team_colours = [4, 10]
end