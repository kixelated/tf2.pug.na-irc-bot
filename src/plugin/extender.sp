#include <sourcemod>

new Handle:mp_timelimit;

new bool:overtime;
new short:blue_score;
new short:red_score;

public Plugin:myinfo =
{
	name = "Timelimit Extender",
	author = "pingu",
	description = "Extends the timelimit if the scores are tied.",
	version = "1.0.0.0",
	url = "http://tf2pug.us/"
};
 
public OnPluginStart() {
  mp_timelimit = FindConVar("mp_timelimit");

  HookEvent("teamplay_win_panel", Event_TeamPlayWinPanel);
  
	CreateTimer(5.0, ExtendLimit, _, TIMER_REPEAT);
}

public OnMapStart() {
  overtime = false;
  blue_score = 0;
  red_score = 0;
}

public Event_TeamPlayWinPanel(Handle:event, const String:name[], bool:dontBroadcast) {
  blue_score = GetEventInt(event, "blue_score");
	red_score = GetEventInt(event, "red_score");
  
  if (overtime) {
    new timelimit = GetConVarInt(mp_timelimit);
    ServerCommand("mp_timelimit %i", timelimit - 10);
  }
}

public Action:ExtendLimit(Handle:timer) {
  new timelimit = GetConVarInt(mp_timelimit);
  new timeleft;
  
	GetMapTimeLeft(timeleft);

  if (!overtime && timelimit != 0 && timeleft < 30.0 && blue_score == red_score) {
    overtime = true;
    
    ServerCommand("mp_timelimit %i", timelimit + 10);
    PrintToChatAll("Stalemate detected, adding 10 minutes sudden-death overtime.");
  }
  
  return Plugin_Continue;
}