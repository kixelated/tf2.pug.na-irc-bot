/*
 * =============================================================================
 * SourceMod Sub Notification Plugin
 * Allows players to call for a sub from the IRC channel
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
 
#include <sourcemod>
#include <menus>
#include <socket>

public Plugin:myinfo = 
{
	name = "Sub Notifier",
	author = "Annuit Coeptis",
	description = "Allows players to request a sub from the IRC channel",
	version = SOURCEMOD_VERSION,
	url = "http://www.tf2pug.us/wiki"
};

new String:port[16];
new String:serverIP[64];
new String:socketData[192];
new String:botAddress[255];
new botPort;
new Handle:g_hSubAddress;
new Handle:g_hSubPort;

public OnPluginStart()
{
	g_hSubAddress = CreateConVar("sm_sub_address", "bot.tf2pug.us", "The host name or IP address of the bot listening for sub notifications.");
	g_hSubPort = CreateConVar("sm_sub_port", "50007", "The port number that the sub notification bot is listening on.");
	
	GetConVarString(FindConVar("ip"), serverIP, sizeof(serverIP));
	IntToString(GetConVarInt(FindConVar("hostport")), port, 10)
	GetConVarString(g_hSubAddress, botAddress, sizeof(botAddress));
	botPort = GetConVarInt(g_hSubPort);
	
	AddCommandListener(ListenCommand, "say");
	AddCommandListener(ListenCommand, "say_team");
}

public SubMenuHandler(Handle:subMenu, MenuAction:action, client, selection)
{
	if (action == MenuAction_Select)
	{
		new String:classNeeded[32];
		GetMenuItem(subMenu, selection, classNeeded, sizeof(classNeeded));
		decl String:steamID[192];
		GetClientAuthString(client, steamID, 192);
		
		decl String:subCmd[192];
		subCmd = "!needsub ";
		if (GetClientTeam(client) == 3)
			StrCat(subCmd, 192, "blue ");
		else
			StrCat(subCmd, 192, "red ");
		
		StrCat(subCmd, 192, classNeeded);
		StrCat(subCmd, 192, " ");
		StrCat(subCmd, 192, steamID);
		StrCat(subCmd, 192, " ");
		StrCat(subCmd, 192, serverIP);
		StrCat(subCmd, 192, ":");
		StrCat(subCmd, 192, port);
		
		SendDataToBot(subCmd);
		
		decl String:clientName[255];
		GetClientName(client, clientName, sizeof(clientName));
		PrintToChatAll("\x01\x03A %s sub has been requested by %s.", classNeeded, clientName);
	}
	else if (action == MenuAction_End)
		CloseHandle(subMenu);
}

/* Parse player communication to identify chat triggers (currently !needsub and !sub) */
public Action:ListenCommand(client, const String:command[], argc)
{
	decl String:userText[192];
	userText[0] = '\0';

	
	decl String:steamID[192];
	GetClientAuthString(client, steamID, 192);

	decl String:sayText[9];
	sayText[0] = '\0';
	GetCmdArg(1, sayText, sizeof(sayText));
	if(StrContains(sayText, "!needsub", false) == 0 || StrContains(sayText, "!sub", false) == 0)
	{
		/* Create and render the sub menu */
		new Handle:subMenu = CreateMenu(SubMenuHandler);
		SetMenuTitle(subMenu, "Select the class which your team needs a sub for.");
		AddMenuItem(subMenu, "scout", "Scout");
		AddMenuItem(subMenu, "soldier", "Soldier");
		AddMenuItem(subMenu, "demo", "Demoman");
		AddMenuItem(subMenu, "medic", "Medic");
		
		DisplayMenu(subMenu, client, 20);

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public OnSocketConnected(Handle:socket, any:arg){
    SocketSend(socket, socketData);
}

public OnSocketDisconnected(Handle:socket, any:arg){
    CloseHandle(socket);
}

public OnSocketError(Handle:socket, const errorType, const errorNum, any:arg){
    CloseHandle(socket);
}

public OnSocketReceive(Handle:socket, String:receiveData[], const dataSize, any:arg){
    return 0;
}

public OnSocketSendqueueEmpty(Handle:socket, any:arg){
    SocketDisconnect(socket);
    CloseHandle(socket);
} 

public SendDataToBot(String:query[])
{
	new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketError);
	Format(socketData, sizeof(socketData), "%s", query);
	SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, botAddress, botPort)
	LogMessage("Sent sub data to %s:%d Message: %s", botAddress, botPort, query);
} 