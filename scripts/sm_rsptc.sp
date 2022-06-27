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

	RegAdminCmd("respawn", Respawn, ADMFLAG_ROOT, "Usage: respawn [target]");
	RegAdminCmd("rip", RespawnInPlace, ADMFLAG_ROOT, "Usage: respawn [target]");
	RegAdminCmd("move", CT, ADMFLAG_ROOT, "Usage: move [target] <team> (1 = Spec / 2 = Red / 3 = Blue)");
	RegAdminCmd("movewod", CT_WITHOUT_DEATH, ADMFLAG_ROOT, "Usage: movewod [target] <team> (1 = Spec / 2 = Red / 3 = Blue)");
	RegAdminCmd("spec", SPEC, ADMFLAG_ROOT, "Usage: spec [target]");
}

public Action Respawn(int client, int args)
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

public Action RespawnInPlace(int client, int args)
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

	float absOrg[3];
	float absAng[3];

	for (int i = 0; i < target_count; i++)
	{
		if(!IsValidClient(target_list[i]))
		{
			continue;
		}

		GetClientAbsOrigin(target_list[i], absOrg);
		GetClientAbsAngles(target_list[i], absAng);

		TF2_RespawnPlayer(target_list[i]);

		TeleportEntity(target_list[i], absOrg, absAng, NULL_VECTOR);
		
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

public Action CT_WITHOUT_DEATH(int client, int args)
{
	if(args == 0 || args > 2)
	{
		ReplyToCommand(client, "\x03[SM]\x01Usage: movewod [name] <team#1/2/3>");
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

		int lifeState = GetEntProp(target_list[i], Prop_Send, "m_lifeState");
		SetEntProp(target_list[i], Prop_Send, "m_lifeState", 2);
		ChangeClientTeam(target_list[i], Team);
		SetEntProp(target_list[i], Prop_Send, "m_lifeState", lifeState);

		LogAction(client, target_list[i], "\"%L\" changed team of \"%L\" without death", client, target_list[i]);
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

public Action SPEC(int client, int args)
{
	if(args == 0 || args > 1)
	{
		ReplyToCommand(client, "\x03[SM]\x01Usage: spec [name]");
		return Plugin_Handled;
	}

	char arg1[MAX_NAME_LENGTH];

	GetCmdArg(1, arg1, sizeof(arg1));

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

	float absOrg[3];
	float absAng[3];

	for (int i = 0; i < target_count; i++)
	{
		if(!IsValidClient(target_list[i]))
		{
			continue;
		}
		GetClientAbsOrigin(target_list[i], absOrg);
		GetClientAbsAngles(target_list[i], absAng);

		TF2_ChangeClientTeam(target_list[i], TFTeam_Unassigned);
		TF2_RespawnPlayer(target_list[i]);
		SetEntProp(target_list[i], Prop_Send, "m_iTeamNum", 1);

		TeleportEntity(target_list[i], absOrg, absAng, NULL_VECTOR);

		LogAction(client, target_list[i], "\"%L\" made \"%L\" spectator without death", client, target_list[i]);
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