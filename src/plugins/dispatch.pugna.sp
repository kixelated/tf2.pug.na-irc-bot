#include <socket>
#include <sourcemod>
#include <sdktools>

// Variables
new String:serverPort[16];
new String:serverIP[64];
new String:socketData[192];

// Plugin Info
public Plugin:myinfo = {
	name = "tf2.pug.na - Bot Dispatcher",
	author = "Jean-Denis Caron, Luke Curley",
	description = "Communicates with the bot on #tf2.pug.na, sending sub and endgame messages.",
	version = SOURCEMOD_VERSION,
	url = "http://github.com/qpingu/tf2.pug.na-irc-bot"
};

// Code
public OnPluginStart() {
  GetConVarString(FindConVar("ip"), serverIP, sizeof(serverIP));
  IntToString(GetConVarInt(FindConVar("hostport")), serverPort, 10)
  
  HookEvent("player_say", Event_PlayerSay);
  HookEvent("teamplay_game_over", Event_TeamplayGameOver);
  HookEvent("tf_game_over", Event_TeamplayGameOver);
}

public Action:Event_PlayerSay(Handle:event, const String:name[], bool:dontBroadcast) {
	decl String:userText[192];
  userText[0] = '\0';
	
	if (!GetEventString(event, "text", userText, 192)) { return Plugin_Continue; }
	
  if (StrContains(userText, "!needsub") == 0) { 
    sendDataToBot(userText);
  }

	return Plugin_Continue;	
}

public Event_TeamplayGameOver(Handle:event, const String:name[], bool:dontBroadcast) {
  gameOver();
}

public gameOver() {
  decl String:message[192];

  new String:blueScore[2];
  new String:redScore[2];
  IntToString(GetTeamScore(3), blueScore, 2);
  IntToString(GetTeamScore(2), redScore, 2);
        
  message = "";
  StrCat(message, 192, "!gameover");
  StrCat(message, 192, " ");
  StrCat(message, 192, blueScore);
  StrCat(message, 192, ":");
  StrCat(message, 192, redScore);
  
  sendDataToBot(message);
  PrintToChatAll("%s", message);
}

// Sockets
public sendDataToBot(String:message[]) {
  decl String:query[192];

  StripQuotes(message);  
  
  query = "";
  StrCat(query, 192, serverIP);
  StrCat(query, 192, ":");
  StrCat(query, 192, serverPort);
  StrCat(query, 192, " ");
  StrCat(query, 192, message);
  
  new Handle:socket = SocketCreate(SOCKET_TCP, OnSocketError);
  Format(socketData, sizeof(socketData), "%s", query);
  SocketConnect(socket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, "bot.tf2pug.org", 50007)
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
