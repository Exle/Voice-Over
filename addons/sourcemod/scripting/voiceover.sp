#include <sourcemod>
#tryinclude <base64>

#pragma semicolon 1
#pragma newdecls required

ConVar sm_vg_url;
EngineVersion engine;

public Plugin myinfo =
{
	name	= "Voice-Over",
	author	= "Exle",
	version	= "1.0.2.7",
	url		= "http://steamcommunity.com/id/ex1e/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	engine = GetEngineVersion();
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	sm_vg_url = CreateConVar("sm_vo_url", "https://tts.voicetech.yandex.net/tts?text={TEXT}");
	RegAdminCmd("sm_vsay", vSay_Callback, ADMFLAG_ROOT);
}

public Action vSay_Callback(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_vsay <#userid|name> \"text\"");
		return Plugin_Handled;
	}

	char buffer[216],
		 target_name[MAX_TARGET_LENGTH];

	GetCmdArg(1, buffer, 216);

	int target_list[MAXPLAYERS],
		target_count;

	bool tn_is_ml;

	if ((target_count = ProcessTargetString(buffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, MAX_TARGET_LENGTH, tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	{
		char buffer2[255];

		GetCmdArgString(buffer2, 255);
		ReplaceString(buffer2, 255, buffer, "");

		TrimString(buffer2);
		StripQuotes(buffer2);

		if (!buffer2[0])
		{
			return Plugin_Handled;
		}

		sm_vg_url.GetString(buffer, 216);
		ReplaceString(buffer, 216, "{TEXT}", buffer2, false);

		if (engine == Engine_CSGO)
		{
			EncodeBase64(buffer2, 216, buffer);
			FormatEx(buffer, 216, "https://exle.github.io/Voice-Over/#%s", buffer2);
		}
	}

	for (int i = 0; i < target_count; i++)
	{
		PlayUrl(target_list[i], buffer);
	}

	return Plugin_Handled;
}

void PlayUrl(int client, const char[] url)
{
	if (!IsClientInGame(client))
	{
		return;
	}

	KeyValues kv = new KeyValues("data");

	kv.SetString("title", "Voice-Over");
	kv.SetNum("type", MOTDPANEL_TYPE_URL);

	kv.SetString("msg", url);

	ShowVGUIPanel(client, "info", kv, false);
	delete kv;
}