/*
	@name project: EggplantDM
	@desc: Stworzono na potrzeby serwera Infinity-Gaming.net DM
	
	@authors:
		- l0nger <l0nger.programmer@gmail.com>
		- Pamdex <pamdex@myotherworld.net>
		- Andrew <andx98@wp.pl>
		- Roberson <do uzupelnienia>
		- Bantu <bantu3i5@tlen.pl>
		- _l0stfake7 <barpon@gmail.com>
		- _Macias_, <maciekgl@o2.pl>
		- Very special thanks to: SA-MP Team, Y_Less, Incognito, Slice, Sacky, Promsters, and others...
	
	@version: 0.1 pre-alpha
	@licence: GPLv2
	@link package: https://github.com/l0nger/SAMP-EggplantDM
*/

#define SCRIPT_PROJECTNAME "Infinity-Gaming.net DM"
#define SCRIPT_NAME	"EggplantDM"
#define SCRIPT_VERSION "0.1 pre-alpha"
#pragma dynamic 4096

#include <a_samp>

#undef MAX_PLAYERS
#define CFG_PLAYERS (50)
#define MAX_PLAYERS CFG_PLAYERS

#include "external/mysql"
#include "external/sscanf"
#include "external/streamer"
#include "external/audio"
#include "external/regex"
#include "external/djson"
#include "external/YSI\y_va"

#include "header"
#include "internal/CLogging.p"
#include "internal/CUtility.p"
#include "internal/CMySQL.p"
#include "internal/CConfigData.p"
#include "internal/CMessages.p"
#include "internal/CAccounts.p"

main() return 0;

public OnGameModeInit() {
	CExecTick_begin(scriptInit);
	
	// przyklad uzywania duracji:
	// printf("duration time: %d", DURATION(2 days, 3 hour, 20 minutes, 40 seconds));
	
	djson_GameModeInit();
	djStyled(true);
	
	CLogging_Init();
	CConfigData_Init();
	CConfigData_Load();

	// SAMP configuration
	SetGravity(0.008);
	UsePlayerPedAnims();
	DisableInteriorEnterExits();
	
	printf("["SCRIPT_NAME" "SCRIPT_VERSION"]: Loaded successfully in %.2f ms!", float(CExecTick_end(scriptInit))/1000.0);
	CLogging_Insert(CLOG_SERVER, "Starting logging...");
	if(ServerData[esd_codeDebugger] >= _DEBUG_EASY) {
		CLogging_Insert(CLOG_DEBUG, "Debugging mode enabled...");
		printf("["SCRIPT_NAME" - Debugger]: Debug mode enabled. Level debugging: %d", ServerData[esd_codeDebugger]);
	}
	return 1;
}

public OnGameModeExit() {
	CLogging_Insert(CLOG_SERVER, "Terminating logging...");
	CLogging_Exit();
	CMySQL_Exit();
	regex_delete_all();
	djson_GameModeExit();
	return 1;
}

public OnPlayerConnect(playerid) {
	if(playerid>MAX_PLAYERS) {
		SendClientMessage(playerid, -1, "[PL]: Serwer osiagnal limit graczy.");
		SendClientMessage(playerid, -1, "[ENG]: This server is full. Try again.");
		theplayer::kick(playerid);
		return 0;
	}
	
	if(playerid > ServerData[esd_highestPlayerID]) ServerData[esd_highestPlayerID]=playerid;
	
	utility::resetVariablesInEnum(PlayerData[playerid], e_PlayerData);
	GetPlayerName(playerid, PlayerData[playerid][epd_nickname], MAX_PLAYER_NAME);
	GetPlayerIp(playerid, PlayerData[playerid][epd_addressIP], 16);
	
	if(ServerData[esd_codeDebugger] >= _DEBUG_NORMAL) {
		CLogging_Insert(CLOG_DEBUG, "Player %s (ID: %d) (IP: %s) has connect to the server", PlayerData[playerid][epd_nickname], playerid, PlayerData[playerid][epd_addressIP]);
	}
	
	if(theplayer::isRegistered(playerid)) {
		theplayer::showLoginDialog(playerid);
		bit_set(PlayerData[playerid][epd_properties], PLAYER_INLOGINDIALOG);
	} else {
		theplayer::sendMessage(playerid, COLOR_INFO1, "Witamy na serwerze "SCRIPT_PROJECTNAME"!");
		theplayer::sendMessage(playerid, COLOR_INFO1, "System wykry�, �e nie posiadasz u nas konta. Aby je za�o�y� wpisz: <b>/rejestracja</b>");
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	new tmpRecountPlayers;
	for(new i; i<ServerData[esd_highestPlayerID] && IsPlayerConnected(i); i++) {
		if(i != playerid) {
			tmpRecountPlayers++;
		}
	}
	ServerData[esd_highestPlayerID]=tmpRecountPlayers;
	
	if(ServerData[esd_codeDebugger] >= _DEBUG_NORMAL) {
		CLogging_Insert(CLOG_DEBUG, "Player %s (R: %d) (ID: %d) (IP: %s) leave from server", PlayerData[playerid][epd_nickname], reason, playerid, PlayerData[playerid][epd_addressIP]);
	}
	return 1;
}

public OnPlayerSpawn(playerid) {
	if(bit_if(PlayerData[playerid][epd_properties], PLAYER_INLOGINDIALOG)) {
		theplayer::hideDialog(playerid);
		theplayer::sendMessage(playerid, COLOR_ERROR, "Nie ma tak �atwo.");
		theplayer::kick(playerid);
		return false;
	}
	
	if(ServerData[esd_codeDebugger] >= _DEBUG_NORMAL) {
		CLogging_Insert(CLOG_DEBUG, "Player %d spawned", playerid);
	}
	
	TogglePlayerControllable(playerid, true);
	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	if(bit_if(PlayerData[playerid][epd_properties], PLAYER_INLOGINDIALOG)) return false;
	
	if(ServerData[esd_codeDebugger] >= _DEBUG_NORMAL) {
		CLogging_Insert(CLOG_DEBUG, "Player %d requesting class needed", playerid);
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid) {
	if(bit_if(PlayerData[playerid][epd_properties], PLAYER_INLOGINDIALOG)) {
		theplayer::sendMessage(playerid, COLOR_ERROR, "Aby skorzysta� z tej funkcji musisz si� pierw zalogowa�.");
		return false;
	}
	
	if(ServerData[esd_codeDebugger] >= _DEBUG_NORMAL) {
		CLogging_Insert(CLOG_DEBUG, "Player %d requesting spawn needed", playerid);
	}
	return 1;
}

public OnPlayerText(playerid, text[]) {
	if(bit_if(PlayerData[playerid][epd_properties], PLAYER_INLOGINDIALOG)) {
		theplayer::sendMessage(playerid, COLOR_ERROR, "Aby skorzysta� z tej funkcji musisz si� pierw zalogowa�.");
		return false;
	}
	
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
	switch(dialogid) {
		case DIALOG_BLANK: {
			return true;
		}
		case DIALOG_LOGIN: {
			if(!response) {
				theplayer::hideDialog(playerid);
				theplayer::sendMessage(playerid, COLOR_INFO1, "Anulowa�e� logowanie - do zobaczenia ponownie!");
				theplayer::kick(playerid);
				return true;
			}
			theplayer::onEventLogin(playerid, inputtext);
		}
		case DIALOG_REGISTER: {
			if(!response) {
				theplayer::sendMessage(playerid, COLOR_INFO1, "Anulowa�e� rejestracje konta, pomy�l o tym jeszcze!");
				theplayer::hideDialog(playerid);
				return true;
			}
			theplayer::onEventRegister(playerid, inputtext);
		}
	}
	return false;
}

public OnPlayerUpdate(playerid) {

	return 1;
}