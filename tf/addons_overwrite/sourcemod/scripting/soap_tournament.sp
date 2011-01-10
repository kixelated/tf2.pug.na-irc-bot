#pragma semicolon 1
#include <sourcemod>

// ====[ CONSTANTS ]===================================================
#define PLUGIN_NAME		"SOAP Tournament"
#define PLUGIN_AUTHOR		"Lange"
#define PLUGIN_VERSION		"3.2"
#define PLUGIN_CONTACT		"http://steamcommunity.com/id/langeh/"
#define RED 0
#define BLU 1
#define TEAM_OFFSET 2

// ====[ PLUGIN ]======================================================
public Plugin:myinfo =
{
	name			= PLUGIN_NAME,
	author			= PLUGIN_AUTHOR,
	description	= "Automatically loads and unloads plugins when a mp_tournament match goes live or ends.",
	version		= PLUGIN_VERSION,
	url				= PLUGIN_CONTACT
};

// ====[ VARIABLES ]===================================================

new bool:teamReadyState[2] = { false, false },
	bool:g_dm = false;

// ====[ FUNCTIONS ]===================================================

/* OnPluginStart()
 *
 * When the plugin starts up.
 * -------------------------------------------------------------------------- */

public OnPluginStart()
{
	
	// Game restart
	//HookEvent("teamplay_restart_round", GameRestartEvent);

	// Win conditions met (maxrounds, timelimit)
	HookEvent("teamplay_game_over", GameOverEvent);

	// Win conditions met (windifference)
	HookEvent("tf_game_over", GameOverEvent);

	// Hook into mp_tournament_restart
	RegServerCmd("mp_tournament_restart", TournamentRestartHook);
	
	//HookEvent("teamplay_round_restart_seconds", Event_TeamplayRestartSeconds);
	HookEvent("tournament_stateupdate", Event_TournamentStateupdate); 
	
	StartDeathmatching();
}

/* OnMapStart()
 *
 * When the map starts.
 * -------------------------------------------------------------------------- */
public OnMapStart()
{
	teamReadyState[0] = false;
	teamReadyState[1] = false;
	StartDeathmatching();
}

/* StopDeathmatching()
 *
 * Executes soap_live.cfg if it hasn't already been executed..
 * -------------------------------------------------------------------------- */
StopDeathmatching()
{
	if(g_dm == true)
	{
		ServerCommand("exec sourcemod/soap_live.cfg");
		PrintToChatAll("[SOAP] Plugins unloaded.");
		g_dm = false;
	}
}

/* StartDeathmatching()
 *
 * Executes soap_notlive.cfg if it hasn't already been executed..
 * -------------------------------------------------------------------------- */
StartDeathmatching()
{
	if(g_dm == false)
	{
		ServerCommand("exec sourcemod/soap_notlive.cfg");
		PrintToChatAll("[SOAP] Plugins reloaded.");
		g_dm = true;
	}
}

// ====[ CALLBACKS ]===================================================

public Event_TournamentStateupdate(Handle:event, const String:name[], bool:dontBroadcast)
{
	
	new team = GetClientTeam(GetEventInt(event, "userid")) - TEAM_OFFSET;
	new bool:nameChange = GetEventBool(event, "namechange");
	new bool:readyState = GetEventBool(event, "readystate");

	if (!nameChange)
	{
		teamReadyState[team] = readyState;

		// If both teams are ready, StopDeathmatching.
		if (teamReadyState[RED] && teamReadyState[BLU])
		{
			StopDeathmatching();
		} else { // One or more of the teams isn't ready, StartDeathmatching.
			StartDeathmatching();
		}
	}
}

public GameOverEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	teamReadyState[0] = false;
	teamReadyState[1] = false;
	StartDeathmatching();
}

public Action:TournamentRestartHook(args)
{
	teamReadyState[0] = false;
	teamReadyState[1] = false;
	StartDeathmatching();
	return Plugin_Continue;
}
