DROP TABLE IF EXISTS "picks";
CREATE TABLE "picks" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "match_id" INTEGER,
  "team_id" INTEGER,
  "tfclass_id" INTEGER,
  "user_id" INTEGER
);
CREATE INDEX "picks_match" ON "picks" ("match_id");
CREATE INDEX "picks_team" ON "picks" ("team_id");
CREATE INDEX "picks_user" ON "picks" ("user_id");
INSERT INTO "picks" ("match_id", "team_id", "user_id", "tfclass_id") SELECT p.match_id, p.team_id, p.user_id, s.tfclass_id FROM "players" AS "p", "stats" AS "s" WHERE p.id = s.player_id;
DROP TABLE "players";
DROP TABLE "stats";
CREATE TABLE "signups" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "match_id" INTEGER,
  "user_id" INTEGER
);
CREATE INDEX "signups_match" ON "signups" ("match_id");
CREATE INDEX "signups_user" ON "signups" ("user_id");
CREATE TABLE "signups_tfclasses" (
  "signup_id" INTEGER,
  "tfclass_id" INTEGER
);
CREATE INDEX "signups_tfclasses_signup" ON "signups_tfclasses" ("signup_id");
