#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "[TF2] Respawner + Team Changer",
	author = "gameguysz, Jobggun",
	description = "Respawns The Player or Changes the players team",
	version = "0.4",
	url = "https://github.com/jobggun/TF2-Respawner-Team-Changer"
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases.txt");

	RegAdminCmd("respawn", Spawn, ADMFLAG_ROOT, "Usage: respawn [target]");
	RegAdminCmd("move", CT, ADMFLAG_ROOT, "Usage: move [target] <team> (1 = Spec / 2 = Red / 3 = Blue)");
}

public Action Spawn(int client, int args)
{
	if(args != 1)
	{
		ReplyToCommand(client, "\x03[SM]\x01Usage: respawn [target]");
		return Plugin_Handled;
	}
	
	char arg[MAX_NAME_LENGTH];
	GetCmdArg(1, arg, sizeof(arg));

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		if(!IsValidClient(target_list[i]))
		{
			continue;
		}
		TF2_RespawnPlayer(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" respawned \"%L\"", client, target_list[i]);
	}
 
	if (tn_is_ml)
	{
		ReplyToCommand(client, "\x03[SM]\x01%t has been respawned", target_name);
	}
	else
	{
		ReplyToCommand(client, "\x03[SM]\x01%s has been respawned", target_name);
	}

	return Plugin_Handled;
}


public Action CT(int client, int args)
{
	if(args == 0 || args > 2)
	{
		ReplyToCommand(client, "\x03[SM]\x01Usage: move [name] <team#1/2/3>");
		return Plugin_Handled;
	}

	if(args == 1)
	{
		ReplyToCommand(client, "\x03[SM]\x01Please choose a team");
		return Plugin_Handled;
	}

	char arg1[MAX_NAME_LENGTH], arg2[32];
	int Team = 1;

	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	Team = StringToInt(arg2);

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		if(!IsValidClient(target_list[i]))
		{
			continue;
		}
		ChangeClientTeam(target_list[i], Team);
		LogAction(client, target_list[i], "\"%L\" changed team of \"%L\"", client, target_list[i]);
	}
 
	if (tn_is_ml)
	{
		ReplyToCommand(client, "\x03[SM]\x01%t has been team changed (excluding replay bots)", target_name);
	}
	else
	{
		ReplyToCommand(client, "\x03[SM]\x01%s has been team changed (excluding replay bots)", target_name);
	}

	return Plugin_Handled;
}

stock bool IsValidClient(int client, bool replaycheck = true)
{
    if(client <= 0 || client > MaxClients)
        return false;

    if(!IsClientInGame(client))
        return false;

    if(GetEntProp(client, Prop_Send, "m_bIsCoaching"))
        return false;

    if(replaycheck && (IsClientSourceTV(client) || IsClientReplay(client)))
        return false;

    return true;
}