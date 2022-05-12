class UMenuServerSetupPage extends UMenuPageWindow;

var int ControlOffset;
var bool bInitialized;

var UWindowEditControl AdminEMailEdit;
var localized string AdminEMailText;
var localized string AdminEMailHelp;

var UWindowEditControl AdminNameEdit;
var localized string AdminNameText;
var localized string AdminNameHelp;

var UWindowEditControl MOTDLine1Edit;
var localized string MOTDLine1Text;
var localized string MOTDLine1Help;

var UWindowEditControl MOTDLine2Edit;
var localized string MOTDLine2Text;
var localized string MOTDLine2Help;

var UWindowEditControl MOTDLine3Edit;
var localized string MOTDLine3Text;
var localized string MOTDLine3Help;

var UWindowEditControl MOTDLine4Edit;
var localized string MOTDLine4Text;
var localized string MOTDLine4Help;

var UWindowEditControl ServerNameEdit;
var localized string ServerNameText;
var localized string ServerNameHelp;

var UWindowCheckbox DoUplinkCheck;
var localized string DoUplinkText;
var localized string DoUplinkHelp;

var UWindowCheckbox ngWorldStatsCheck;
var localized string ngWorldStatsText;
var localized string ngWorldStatsHelp;

var UWindowCheckbox LanPlayCheck;
var localized string LanPlayText;
var localized string LanPlayHelp;

var config bool bLanPlay;
var Class IpServerClass;

function Created()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;

	ControlOffset = 20;
	bInitialized = False;

	Super.Created();

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/4)*3;
	CenterPos = (WinWidth - CenterWidth)/2;

	ServerNameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	ServerNameEdit.SetText(ServerNameText);
	ServerNameEdit.SetHelpText(ServerNameHelp);
	ServerNameEdit.SetFont(F_Normal);
	ServerNameEdit.SetNumericOnly(False);
	ServerNameEdit.SetMaxLength(205);
	ServerNameEdit.SetDelayedNotify(True);
	ServerNameEdit.SetValue(class'Engine.GameReplicationInfo'.default.ServerName);
	ControlOffset += 20;

	AdminNameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	AdminNameEdit.SetText(AdminNameText);
	AdminNameEdit.SetHelpText(AdminNameHelp);
	AdminNameEdit.SetFont(F_Normal);
	AdminNameEdit.SetNumericOnly(False);
	AdminNameEdit.SetMaxLength(205);
	AdminNameEdit.SetDelayedNotify(True);
	AdminNameEdit.SetValue(class'Engine.GameReplicationInfo'.default.AdminName);
	ControlOffset += 20;
	
	AdminEmailEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	AdminEmailEdit.SetText(AdminEmailText);
	AdminEmailEdit.SetHelpText(AdminEmailHelp);
	AdminEmailEdit.SetFont(F_Normal);
	AdminEmailEdit.SetNumericOnly(False);
	AdminEmailEdit.SetMaxLength(205);
	AdminEmailEdit.SetDelayedNotify(True);
	AdminEmailEdit.SetValue(class'Engine.GameReplicationInfo'.default.AdminEmail);
	ControlOffset += 20;

	MOTDLine1Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	MOTDLine1Edit.SetText(MOTDLine1Text);
	MOTDLine1Edit.SetHelpText(MOTDLine1Help);
	MOTDLine1Edit.SetFont(F_Normal);
	MOTDLine1Edit.SetNumericOnly(False);
	MOTDLine1Edit.SetMaxLength(205);
	MOTDLine1Edit.SetDelayedNotify(True);
	MOTDLine1Edit.SetValue(class'Engine.GameReplicationInfo'.default.MOTDLine1);
	ControlOffset += 20;

	MOTDLine2Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	MOTDLine2Edit.SetText(MOTDLine2Text);
	MOTDLine2Edit.SetHelpText(MOTDLine2Help);
	MOTDLine2Edit.SetFont(F_Normal);
	MOTDLine2Edit.SetNumericOnly(False);
	MOTDLine2Edit.SetMaxLength(205);
	MOTDLine2Edit.SetDelayedNotify(True);
	MOTDLine2Edit.SetValue(class'Engine.GameReplicationInfo'.default.MOTDLine2);
	ControlOffset += 20;

	MOTDLine3Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	MOTDLine3Edit.SetText(MOTDLine3Text);
	MOTDLine3Edit.SetHelpText(MOTDLine3Help);
	MOTDLine3Edit.SetFont(F_Normal);
	MOTDLine3Edit.SetNumericOnly(False);
	MOTDLine3Edit.SetMaxLength(205);
	MOTDLine3Edit.SetDelayedNotify(True);
	MOTDLine3Edit.SetValue(class'Engine.GameReplicationInfo'.default.MOTDLine3);
	ControlOffset += 20;

	MOTDLine4Edit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	MOTDLine4Edit.SetText(MOTDLine4Text);
	MOTDLine4Edit.SetHelpText(MOTDLine4Help);
	MOTDLine4Edit.SetFont(F_Normal);
	MOTDLine4Edit.SetNumericOnly(False);
	MOTDLine4Edit.SetMaxLength(205);
	MOTDLine4Edit.SetDelayedNotify(True);
	MOTDLine4Edit.SetValue(class'Engine.GameReplicationInfo'.default.MOTDLine4);
	ControlOffset += 20;

	DoUplinkCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	DoUplinkCheck.SetText(DoUplinkText);
	DoUplinkCheck.SetHelpText(DoUplinkHelp);
	DoUplinkCheck.SetFont(F_Normal);
	DoUplinkCheck.Align = TA_Left;
	// Force IPServer to load!!!
	IPServerClass = Class(DynamicLoadObject("IpServer.UdpServerUplink", class'Class'));
	DoUplinkCheck.bChecked = GetPlayerOwner().ConsoleCommand("get IpServer.UdpServerUplink DoUplink") ~= "True";
	ControlOffset += 20;

	ngWorldStatsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	ngWorldStatsCheck.SetText(ngWorldStatsText);
	ngWorldStatsCheck.SetHelpText(ngWorldStatsHelp);
	ngWorldStatsCheck.SetFont(F_Normal);
	ngWorldStatsCheck.Align = TA_Left;
	if (GetLevel().Game != None)
		ngWorldStatsCheck.bChecked = GetLevel().Game.Default.bWorldLog;
	else
		ngWorldStatsCheck.bDisabled = True;
	ControlOffset += 20;

	LanPlayCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	LanPlayCheck.SetText(LanPlayText);
	LanPlayCheck.SetHelpText(LanPlayHelp);
	LanPlayCheck.SetFont(F_Normal);
	LanPlayCheck.Align = TA_Left;
	LanPlayCheck.bChecked = bLanPlay;
	ControlOffset += 20;
}

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
	case DE_Change:
		switch(C)
		{
		case AdminEMailEdit:
			class'Engine.GameReplicationInfo'.default.AdminEmail = AdminEmailEdit.GetValue();
			break;
		case AdminNameEdit:
			class'Engine.GameReplicationInfo'.default.AdminName = AdminNameEdit.GetValue();
			break;
		case MOTDLine1Edit:
			class'Engine.GameReplicationInfo'.default.MOTDLine1 = MOTDLine1Edit.GetValue();
			break;
		case MOTDLine2Edit:
			class'Engine.GameReplicationInfo'.default.MOTDLine2 = MOTDLine2Edit.GetValue();
			break;
		case MOTDLine3Edit:
			class'Engine.GameReplicationInfo'.default.MOTDLine3 = MOTDLine3Edit.GetValue();
			break;
		case MOTDLine4Edit:
			class'Engine.GameReplicationInfo'.default.MOTDLine4 = MOTDLine4Edit.GetValue();
			break;
		case ServerNameEdit:
			class'Engine.GameReplicationInfo'.default.ServerName = ServerNameEdit.GetValue();
			break;
		case DoUplinkCheck:
			if(DoUplinkCheck.bChecked)
				GetPlayerOwner().ConsoleCommand("set IpServer.UdpServerUplink DoUplink True");
			else
				GetPlayerOwner().ConsoleCommand("set IpServer.UdpServerUplink DoUplink False");
			IPServerClass.Static.StaticSaveConfig();
			break;
		case ngWorldStatsCheck:
			if (GetLevel().Game != None)
			{
				GetLevel().Game.bWorldLog = ngWorldStatsCheck.bChecked;
				GetLevel().Game.SaveConfig();
			}
			break;
		case LanPlayCheck:
			bLanPlay = LanPlayCheck.bChecked;
			break;
		}
	}
	Super.Notify(C, E);
}

function SaveConfigs()
{
	SaveConfig();
	Super.SaveConfigs();
	class'Engine.GameReplicationInfo'.static.StaticSaveConfig();
}

function AfterCreate()
{
	Super.AfterCreate();

	DesiredWidth = 270;
	DesiredHeight = ControlOffset + 5;

	bInitialized = True;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos;
	local int EditWidth;

	Super.BeforePaint(C, X, Y);

	ControlWidth = WinWidth/2.5;
	ControlLeft = (WinWidth/2 - ControlWidth)/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = (WinWidth/7)*6;
	CenterPos = (WinWidth - CenterWidth)/2;
	
	EditWidth = CenterWidth - 100;

	ServerNameEdit.SetSize(CenterWidth, 1);
	ServerNameEdit.WinLeft = CenterPos;
	ServerNameEdit.EditBoxWidth = EditWidth;

	AdminNameEdit.SetSize(CenterWidth, 1);
	AdminNameEdit.WinLeft = CenterPos;
	AdminNameEdit.EditBoxWidth = EditWidth;

	AdminEmailEdit.SetSize(CenterWidth, 1);
	AdminEmailEdit.WinLeft = CenterPos;
	AdminEmailEdit.EditBoxWidth = EditWidth;

	MOTDLine1Edit.SetSize(CenterWidth, 1);
	MOTDLine1Edit.WinLeft = CenterPos;
	MOTDLine1Edit.EditBoxWidth = EditWidth;

	MOTDLine2Edit.SetSize(CenterWidth, 1);
	MOTDLine2Edit.WinLeft = CenterPos;
	MOTDLine2Edit.EditBoxWidth = EditWidth;
	
	MOTDLine3Edit.SetSize(CenterWidth, 1);
	MOTDLine3Edit.WinLeft = CenterPos;
	MOTDLine3Edit.EditBoxWidth = EditWidth;

	MOTDLine4Edit.SetSize(CenterWidth, 1);
	MOTDLine4Edit.WinLeft = CenterPos;
	MOTDLine4Edit.EditBoxWidth = EditWidth;

	DoUplinkCheck.SetSize(CenterWidth-EditWidth+16, 1);
	DoUplinkCheck.WinLeft = CenterPos;

	ngWorldStatsCheck.SetSize(CenterWidth-EditWidth+16, 1);
	ngWorldStatsCheck.WinLeft = CenterPos;

	LanPlayCheck.SetSize(CenterWidth-EditWidth+16, 1);
	LanPlayCheck.WinLeft = CenterPos;
}

defaultproperties
{
	AdminEMailText="Admin Email"
	AdminEMailHelp="Enter an email address so users of this server can contact you."
	AdminNameText="Admin Name"
	AdminNameHelp="Enter the name of this server's administrator."
	MOTDLine1Text="MOTD Line 1"
	MOTDLine1Help="Enter a message of the day which will be presented to users upon joining your server."
	MOTDLine2Text="MOTD Line 2"
	MOTDLine2Help="Enter a message of the day which will be presented to users upon joining your server."
	MOTDLine3Text="MOTD Line 3"
	MOTDLine3Help="Enter a message of the day which will be presented to users upon joining your server."
	MOTDLine4Text="MOTD Line 4"
	MOTDLine4Help="Enter a message of the day which will be presented to users upon joining your server."
	ServerNameText="Server Name"
	ServerNameHelp="Enter the full description for your server, to appear in query tools such as UBrowser or GameSpy."
	DoUplinkText="Advertise Server"
	DoUplinkHelp="If checked, your server will be advertised to the Master Server, so your server will appear in the global server list."
	ngWorldStatsText="ngWorldStats Logging"
	ngWorldStatsHelp="If checked, your server will upload a log of gameplay to NetGamesUSA for stats collection.  Check out ut.ngworldstats.com for information."
	LanPlayText="Optimize for LAN"
	LanPlayHelp="If checked, a dedicated server started will be optimized for play on a LAN."
}
