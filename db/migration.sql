DROP TABLE "picks";
CREATE TABLE "picks" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "match_id" INTEGER,
  "team_id" INTEGER,
  "tfclass_id" INTEGER,
  "user_id" INTEGER
);
INSERT INTO "picks" ("match_id", "team_id", "user_id", "tfclass_id") SELECT p.match_id, p.team_id, p.user_id, s.tfclass_id FROM "players" AS "p", "stats" AS "s" WHERE p.id = s.player_id;
DROP TABLE "players";
DROP TABLE "stats";
CREATE TABLE "signups" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "match_id" INTEGER,
  "user_id" INTEGER
);
CREATE TABLE "signups_tfclasses" (
  "signup_id" INTEGER,
  "tfclass_id" INTEGER
);
