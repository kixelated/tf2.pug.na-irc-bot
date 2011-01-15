CREATE TABLE "signups" (
  "player_id" INTEGER,
  "tfclass_id" INTEGER
);
CREATE INDEX "signups_player" ON "signups" ("player_id");
CREATE TABLE "picks" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "player_id" INTEGER,
  "tfclass_id" INTEGER
);
CREATE INDEX "picks_player" ON "picks" ("player_id");
INSERT INTO "picks" ("player_id", "tfclass_id") SELECT "player_id", "tfclass_id" FROM "stats";
DROP TABLE "stats";
CREATE INDEX "players_match" ON "players" ("match_id");
CREATE INDEX "players_team" ON "players" ("team_id");
