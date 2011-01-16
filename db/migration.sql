CREATE TABLE "signups" (
  "player_id" INTEGER,
  "tfclass_id" INTEGER
);
CREATE INDEX "signups_player" ON "signups" ("player_id");
ALTER TABLE "stats" RENAME TO "picks";
CREATE INDEX "players_match" ON "players" ("match_id");
CREATE INDEX "players_team" ON "players" ("team_id");
