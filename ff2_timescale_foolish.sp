#include <sourcemod>
#include <sdktools>

#include "freak_fortress_2"
#include "freak_fortress_2_subplugin"

#pragma semicolon 1
#pragma newdecls required

ConVar g_cvarHostTimescale;
ConVar g_cvarPhysTimescale;
ConVar g_cvarCheats;

Handle g_hTimer = null;

bool g_bCanAbilityInvoked = false;

public void OnPluginStart2()
{
    HookEvent("teamplay_round_start", OnRoundStart, EventHookMode_PostNoCopy);
    HookEvent("teamplay_round_win", OnRoundEnd, EventHookMode_PostNoCopy);
    
    g_cvarHostTimescale = FindConVar("host_timescale");
    g_cvarPhysTimescale = FindConVar("phys_timescale");
    g_cvarCheats = FindConVar("sv_cheats");
}

public void OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    g_bCanAbilityInvoked = true;
}

public void OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
    ChangeTimescale();
    delete g_hTimer;
    g_bCanAbilityInvoked = false;
}

public Action FF2_OnAbility2(int boss, const char[] plugin_name, const char[] ability_name, int status)
{
    if(!g_bCanAbilityInvoked)
        return Plugin_Continue;
    
    if(StrEqual(ability_name, "foolish_timescale"))
    {
        FF2Data ff2data = FF2Data(boss, this_plugin_name, ability_name);

        if(ff2data.Invalid)
            return Plugin_Continue;

        if(!ff2data.HasAbility())
            return Plugin_Continue;

        float timescale = ff2data.GetArgF("value", 0.5);
        float duration = ff2data.GetArgF("duration", 10.0);

        if(timescale <= 0.1)
            timescale = 0.1;
        
        ChangeTimescale(timescale);

        g_hTimer = CreateTimer(timescale * duration, RevertTimescale);
    }

    return Plugin_Continue;
}

public Action RevertTimescale(Handle timer)
{
    ChangeTimescale();
}

stock void ChangeTimescale(float time = 1.0)
{
    g_cvarHostTimescale.SetFloat(time);
    g_cvarPhysTimescale.SetFloat(time);

    for(int i = 1; i <= MaxClients; i++)
    {
        if(!IsValidClient(i) || IsFakeClient(i))
            continue;

        g_cvarCheats.ReplicateToClient(i, (time == 1.0) ? "0" : "1");
    }
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