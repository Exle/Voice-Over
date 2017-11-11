#pragma newdecls required

ConVar sm_vg_url;

public Plugin myinfo =
{
	name	= "Voice-Over",
	author	= "Exle",
	version	= "1.0.1",
	url		= "http://steamcommunity.com/id/ex1e/"
};

public void OnPluginStart()
{
	sm_vg_url = CreateConVar("sm_vg_url", "http://tts.voicetech.yandex.net/tts?text={TEXT}");

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

	KeyValues panel = new KeyValues("data");

	panel.SetString("title", "Voice-Over");
	panel.SetNum("type", MOTDPANEL_TYPE_URL);

	panel.SetString("msg", url);

	ShowVGUIPanel(client, "info", panel, false);
	delete panel;
}