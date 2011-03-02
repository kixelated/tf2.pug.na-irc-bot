#include <clients>
#include <sourcemod>
#include <tf2_stocks>

// Constants
new timerFrequency = 20;  // How frequently players are checked for off-classing. (seconds)
new offclassMax = 1; // Number of off-classers per team allowed.

// Variables
new bool:restrictTeam[2];
new bool:restrictWarning[32];

// Plugin Info
public Plugin:myinfo = {
	name = "tf2.pug.na - Off-class Restriction",
	author = "Luke Curley",
	description = "Limits off-classing using the !restrict command.",
	version = SOURCEMOD_VERSION,
	url = "http://github.com/qpingu/tf2.pug.na-irc-bot"
};

// Code
public OnPluginStart() {
  CreateTimer(timerFrequency, CheckPlayers, _, TIMER_REPEAT);
  HookEvent("player_say", Event_PlayerSay);
}

public OnMapStart() {
  restrictTeam[0] = false;
  restrictTeam[1] = false;
}

public Action:CheckPlayers(Handle:timer) {
  new players = GetClientCount();
  new offclass[2];
  
  for (new i = 1; i <= players; i++) {
    new classID = -1;

    if (IsValidEntity(i) && IsClientInGame(i)) {
      team = GetClientTeam(i) - 2;
      
      if ((team == 0 || team == 1) && restrictTeam[team]) {
        classID = TF2_GetPlayerClass(i);
        
        if (classID != 1 && classID != 3 && classID != 4 && classID != 5) {
          offclass[team] += 1;
          
          if (offclass[team] > offclassMax) {
            if (restrictWarning[i]) {
              PrintToChat(i, "Please switch back to a standard competitive class (scout, soldier, demo, medic).");
              ForcePlayerSuicide(i);
            } else {
              PrintToChat(i, "You have %i seconds to switch back to a standard competitive class (scout, soldier, demo, medic).", availableTime);
              restrictWarning[i] = true;
            }
          }
        } else {
          restrictWarning[i] = false;
        }
      }
    }
  }
}

public Action:Event_PlayerSay(Handle:event, const String:name[], bool:dontBroadcast) {
  new client = GetClientOfUserId(GetEventInt(event, "userid"));
  new team = GetClientTeam(client);
	
	decl String:userText[192];
  userText[0] = '\0';
	if (!GetEventString(event, "text", userText, 192)) {
    return Plugin_Continue;
	}

  if (StrContains(userText, "!restrict") == 0) { 
    team = GetClientTeam(client) - 2;
    if (team == 0 || team == 1) { restrictTeam[team] = true; }
  }

	return Plugin_Continue;	
}


