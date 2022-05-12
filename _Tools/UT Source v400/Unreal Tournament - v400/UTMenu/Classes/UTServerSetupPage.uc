class UTServerSetupPage extends UMenuServerSetupPage;

var UWindowEditControl GamePasswordEdit;
var localized string GamePasswordText;
var localized string GamePasswordHelp;

var UWindowEditControl AdminPasswordEdit;
var localized string AdminPasswordText;
var localized string AdminPasswordHelp;

var UWindowCheckbox EnableWebserverCheck;
var localized string EnableWebserverText;
var localized string EnableWebserverHelp;

var UWindowEditControl WebAdminUsernameEdit;
var localized string WebAdminUsernameText;
var localized string WebAdminUsernameHelp;

var UWindowEditControl WebAdminPasswordEdit;
var localized string WebAdminPasswordText;
var localized string WebAdminPasswordHelp;

var UWindowEditControl ListenPortEdit;
var localized string ListenPortText;
var localized string ListenPortHelp;

var bool bInitialized;

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

	GamePasswordEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	GamePasswordEdit.SetText(GamePasswordText);
	GamePasswordEdit.SetHelpText(GamePasswordHelp);
	GamePasswordEdit.SetFont(F_Normal);
	GamePasswordEdit.SetNumericOnly(False);
	GamePasswordEdit.SetMaxLength(16);
	GamePasswordEdit.SetDelayedNotify(True);
	GamePasswordEdit.SetValue(GetPlayerOwner().ConsoleCommand("get engine.gameinfo GamePassword"));
	ControlOffset += 20;

	AdminPasswordEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	AdminPasswordEdit.SetText(AdminPasswordText);
	AdminPasswordEdit.SetHelpText(AdminPasswordHelp);
	AdminPasswordEdit.SetFont(F_Normal);
	AdminPasswordEdit.SetNumericOnly(False);
	AdminPasswordEdit.SetMaxLength(16);
	AdminPasswordEdit.SetDelayedNotify(True);
	AdminPasswordEdit.SetValue(GetPlayerOwner().ConsoleCommand("get engine.gameinfo AdminPassword"));
	ControlOffset += 20;

	EnableWebserverCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', CenterPos, ControlOffset, CenterWidth, 1));
	EnableWebserverCheck.SetText(EnableWebserverText);
	EnableWebserverCheck.SetHelpText(EnableWebserverHelp);
	EnableWebserverCheck.SetFont(F_Normal);
	EnableWebserverCheck.Align = TA_Left;
	EnableWebserverCheck.bChecked = class'WebServer'.default.bEnabled;
	ControlOffset += 20;

	WebAdminUsernameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	WebAdminUsernameEdit.SetText(WebAdminUsernameText);
	WebAdminUsernameEdit.SetHelpText(WebAdminUsernameHelp);
	WebAdminUsernameEdit.SetFont(F_Normal);
	WebAdminUsernameEdit.SetNumericOnly(False);
	WebAdminUsernameEdit.SetMaxLength(16);
	WebAdminUsernameEdit.SetDelayedNotify(True);
	WebAdminUsernameEdit.SetValue(class'UTServerAdmin'.default.AdminUsername);
	ControlOffset += 20;

	WebAdminPasswordEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	WebAdminPasswordEdit.SetText(WebAdminPasswordText);
	WebAdminPasswordEdit.SetHelpText(WebAdminPasswordHelp);
	WebAdminPasswordEdit.SetFont(F_Normal);
	WebAdminPasswordEdit.SetNumericOnly(False);
	WebAdminPasswordEdit.SetMaxLength(16);
	WebAdminPasswordEdit.SetDelayedNotify(True);
	WebAdminPasswordEdit.SetValue(class'UTServerAdmin'.default.AdminPassword);
	ControlOffset += 20;

	ListenPortEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', CenterPos, ControlOffset, CenterWidth, 1));
	ListenPortEdit.SetText(ListenPortText);
	ListenPortEdit.SetHelpText(ListenPortHelp);
	ListenPortEdit.SetFont(F_Normal);
	ListenPortEdit.SetNumericOnly(True);
	ListenPortEdit.SetMaxLength(16);
	ListenPortEdit.SetDelayedNotify(True);
	ListenPortEdit.SetValue(string(class'WebServer'.default.ListenPort));
	ControlOffset += 20;

	bInitialized = True;
}

function Notify(UWindowDialogControl C, byte E)
{
	if(bInitialized)
	{
		switch(E)
		{
		case DE_Change:
			switch(C)
			{
			case GamePasswordEdit:
				GetPlayerOwner().ConsoleCommand("set engine.gameinfo GamePassword "$GamePasswordEdit.GetValue());
				break;
			case AdminPasswordEdit:
				GetPlayerOwner().ConsoleCommand("set engine.gameinfo AdminPassword "$AdminPasswordEdit.GetValue());
				break;
			case EnableWebserverCheck:
				class'WebServer'.default.bEnabled = EnableWebserverCheck.bChecked;
				class'WebServer'.static.StaticSaveConfig();
				break;
			case WebAdminUsernameEdit:
				class'UTServerAdmin'.default.AdminUsername = WebAdminUsernameEdit.GetValue();
				class'UTServerAdmin'.static.StaticSaveConfig();
				break;
			case WebAdminPasswordEdit:
				class'UTServerAdmin'.default.AdminPassword = WebAdminPasswordEdit.GetValue();
				class'UTServerAdmin'.static.StaticSaveConfig();
				break;
			case ListenPortEdit:
				class'WebServer'.default.ListenPort = Int(ListenPortEdit.GetValue());
				class'WebServer'.static.StaticSaveConfig();
				break;
			}
		}
	}
	Super.Notify(C, E);
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

	GamePasswordEdit.SetSize(CenterWidth, 1);
	GamePasswordEdit.WinLeft = CenterPos;
	GamePasswordEdit.EditBoxWidth = EditWidth;

	AdminPasswordEdit.SetSize(CenterWidth, 1);
	AdminPasswordEdit.WinLeft = CenterPos;
	AdminPasswordEdit.EditBoxWidth = EditWidth;

	WebAdminPasswordEdit.SetSize(CenterWidth, 1);
	WebAdminPasswordEdit.WinLeft = CenterPos;
	WebAdminPasswordEdit.EditBoxWidth = EditWidth;

	WebAdminUsernameEdit.SetSize(CenterWidth, 1);
	WebAdminUsernameEdit.WinLeft = CenterPos;
	WebAdminUsernameEdit.EditBoxWidth = EditWidth;

	EnableWebserverCheck.SetSize(CenterWidth-EditWidth+16, 1);
	EnableWebserverCheck.WinLeft = CenterPos;

	ListenPortEdit.SetSize(CenterWidth-EditWidth+35, 1);
	ListenPortEdit.WinLeft = CenterPos;
	ListenPortEdit.EditBoxWidth = 35;
}

defaultproperties
{
	GamePasswordText="Game Password"
	GamePasswordHelp="If this is set, a player needs use this password to be allowed to login to the server."
	AdminPasswordText="Admin Password"
	AdminPasswordHelp="If this is set, a player can join your server using this password and have access to admin-only console commands."
	EnableWebserverText="WWW Remote Admin"
	EnableWebserverHelp="If checked, you will be able to administer your UT server remotely using a web browser."
	WebAdminUsernameText="WWW Username"
	WebAdminUsernameHelp="The username needed to login to the WWW-based remote server administration."
	WebAdminPasswordText="WWW Password"
	WebAdminPasswordHelp="The password needed to login to the WWW-based remote server administration."
	ListenPortText="Webserver Port No."
	ListenPortHelp="The port number that the remote administration webserver will listen on for incoming connections."
}
