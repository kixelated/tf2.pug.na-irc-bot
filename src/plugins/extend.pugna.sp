#include <sourcemod>

// Constants
new timerFrequency = 20;  // Timer frequency, determines how accurate the timer is. (seconds)

new extendThreshold = 140; // Maximum amount of time remaining before overtime is triggered. (seconds)
new extendTime = 10;  // Amount of overtime added to the time limit. (minutes)
new extendMax = 2;   // Maximum number of extensions.

new cancelThreshold = 240; // Maximum time since last extend in order to cancel. (seconds)

// Variables
new extendCount = 0;
new lastExtend = 0;
new lastExtendMessage = 0;
new bool:cancelExtension = false;

// Plugin Info
public Plugin:myinfo = {
	name = "tf2.pug.na - Match Extender",
	author = "Luke Curley",
	description = "Enables the !extend command and automatically extends a tied game.",
	version = SOURCEMOD_VERSION,
	url = "http://github.com/qpingu/tf2.pug.na-irc-bot"
};

// Code
public OnPluginStart() {
	CreateTimer(timerFrequency, CheckTime, _, TIMER_REPEAT);
  HookEvent("player_say", Event_PlayerSay);
}

public OnMapStart() {
  extendCount = 0;
  extendCanceled = false;
}

public Action:CheckTime(Handle:timer) {
  new timeLeft;
  new timeLimit;
  GetMapTimeLeft(timeLeft);
  GetMapTimeLimit(timeLimit);

  if (timelimit != 0 && timeLeft <= extendThreshold) {
    new String:blueScore[2];
    new String:redScore[2];
    IntToString(GetTeamScore(3), blueScore, 2);
    IntToString(GetTeamScore(2), redScore, 2);
  
    if (blueScore == redScore && extendMatch()) {
      PrintToChatAll("Stalemate detected, adding %i minutes overtime.", extendTime);
    } else if ((GetTime() - lastExtendMessage) > extendThreshold && extendCount < extendMax) {
      PrintToChatAll("%i minutes left in the match. Type \"!extend\" in chat to increase the time limit.", extendThreshold);
      lastExtendMessage = GetTime();
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
	
	new timeLeft;
  new timeLimit;
  GetMapTimeLeft(timeLeft);
  GetMapTimeLimit(timeLimit);

  if (StrContains(userText, "!cancel") == 0 && (team == 2 || team == 3)) { 
    if ((GetTime() - lastExtend) <= cancelThreshold) {
      if (cancelMatch()) {
        PrintToChatAll("Match canceled by %i", client); // TODO: Print user's name
      }
    } else {
      PrintToChatAll("You can only cancel up to %i minutes after an extension.", cancelThreshold / 60);
    }
  }

  if (StrContains(userText, "!extend") == 0) { 
    if (extendCanceled) {
      PrintToChatAll("The extention was already canceled.");
    } else if (timeLimit != 0 && timeLeft <= extendThreshold && extendMatch()) {
      PrintToChatAll("Match extended %i minutes by %i.", extendTime, client);
    }
  }

	return Plugin_Continue;	
}

public extendMatch() {
  if (extendCount >= extendMax || extendCanceled) {
    return false;
  } else {
    new timeLimit;
    GetMapTimeLimit(timeLimit);
    
    ServerCommand("mp_timelimit %i", timeLimit + extendTime);
    
    lastExtend = GetTime();
    ++extendCount;
  
    if (extendCount == extendMax) { 
      PrintToChatAll("The maximum number of extensions has been met, this extension is final!"); 
    }
    
    return true;
  } 
}

public cancelMatch() {
  extendCanceled = true;

  if (extendCount > 0) {
    new timeLimit;
    GetMapTimeLimit(timeLimit);
  
    ServerCommand("mp_timelimit %i", timeLimit - extendTime);
    --extendCount;
  }
}
