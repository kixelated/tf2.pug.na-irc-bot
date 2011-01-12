#include <sourcemod>

new bool:overtime;
new short:blue_score;
new short:red_score;

public Plugin:myinfo =
{
	name = "Automatic Overtime",
	author = "pingu",
	description = "Extends the timelimit if the scores are tied.",
	version = "1.0.0",
	url = "http://tf2pug.us/"
};
 
public OnPluginStart() {
  HookEvent("teamplay_win_panel", PointScoredEvent);
	CreateTimer(15.0, CheckTime, _, TIMER_REPEAT);
}

public OnMapStart() {
  overtime = false;
  blue_score = 0;
  red_score = 0;
}

public PointScoredEvent(Handle:event, const String:name[], bool:dontBroadcast) {
  blue_score = GetEventInt(event, "blue_score");
	red_score = GetEventInt(event, "red_score");
  
  if (overtime && blue_score != red_score) {
    overtime = false;
    
    ServerCommand("sm_extend_time -10");
  }
}

public Action:CheckTime(Handle:timer) {
	new timeLeft;
	new timeLimit;
	GetMapTimeLeft(timeLeft);
	GetMapTimeLimit(timeLimit);
  
  if (!overtime && timeLimit != 0 && timeLeft < 30.0 && blue_score == red_score) {
    overtime = true;
    
    ServerCommand("sm_extend_time 10");
    PrintToChatAll("Stalemate detected, adding 10 minutes sudden-death overtime.");
  }
}