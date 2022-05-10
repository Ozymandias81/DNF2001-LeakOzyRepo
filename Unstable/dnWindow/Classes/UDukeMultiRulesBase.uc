class UDukeMultiRulesBase extends UDukePageWindow;

var UDukeCreateMultiCW  myParent;

var bool Initialized;

var config bool         bLanPlay;
var Class               IpServerClass;

// Frag Limit
var UWindowLabelControl	FragLabel;
var UWindowEditControl  FragEdit;
var localized string    FragText;
var localized string    FragHelp;

// Time Limit
var UWindowLabelControl	TimeLabel;
var UWindowEditControl  TimeEdit;
var localized string    TimeText;
var localized string    TimeHelp;

// Max Players
var UWindowLabelControl	MaxPlayersLabel;
var UWindowEditControl  MaxPlayersEdit;
var localized string    MaxPlayersText;
var localized string    MaxPlayersHelp;

// Max Spectators
var UWindowLabelControl	MaxSpectatorsLabel;
var UWindowEditControl  MaxSpectatorsEdit;
var localized string    MaxSpectatorsText;
var localized string    MaxSpectatorsHelp;

// Weapons Stay
var UWindowLabelControl	WeaponsLabel;
var UWindowCheckbox     WeaponsCheck;
var localized string    WeaponsText;
var localized string    WeaponsHelp;

// Tourney
var UWindowLabelControl	TourneyLabel;
var UWindowCheckbox		TourneyCheck;
var localized string	TourneyText;
var localized string	TourneyHelp;

// Force Respawns
var UWindowLabelControl	ForceRespawnLabel;
var UWindowCheckbox		ForceRespawnCheck;
var localized string	ForceRespawnText;
var localized string	ForceRespawnHelp;

// Admin EMail
var UWindowLabelControl AdminEMailLabel;
var UWindowEditControl  AdminEMailEdit;
var localized string    AdminEMailText;
var localized string    AdminEMailHelp;

// Admin Name
var UWindowLabelControl AdminNameLabel;
var UWindowEditControl  AdminNameEdit;
var localized string    AdminNameText;
var localized string    AdminNameHelp;

// MOTD Line 1
var UWindowLabelControl MOTDLine1Label;
var UWindowEditControl  MOTDLine1Edit;
var localized string    MOTDLine1Text;
var localized string    MOTDLine1Help;

// MOTD Line 2
var UWindowLabelControl MOTDLine2Label;
var UWindowEditControl  MOTDLine2Edit;
var localized string    MOTDLine2Text;
var localized string    MOTDLine2Help;

// MOTD Line 3
var UWindowLabelControl MOTDLine3Label;
var UWindowEditControl  MOTDLine3Edit;
var localized string    MOTDLine3Text;
var localized string    MOTDLine3Help;

// MOTD Line 4
var UWindowLabelControl MOTDLine4Label;
var UWindowEditControl  MOTDLine4Edit;
var localized string    MOTDLine4Text;
var localized string    MOTDLine4Help;

// Server Name
var UWindowLabelControl ServerNameLabel;
var UWindowEditControl  ServerNameEdit;
var localized string    ServerNameText;
var localized string    ServerNameHelp;

// Do Uplink
var UWindowLabelControl DoUplinkLabel;
var UWindowCheckbox     DoUplinkCheck;
var localized string    DoUplinkText;
var localized string    DoUplinkHelp;

// Lan Play
var UWindowLabelControl	LanPlayLabel;
var UWindowCheckbox     LanPlayCheck;
var localized string    LanPlayText;
var localized string    LanPlayHelp;

// Change levels
var UWindowLabelControl ChangeLevelsLabel;
var UWindowCheckbox     ChangeLevelsCheck;
var localized string    ChangeLevelsText;
var localized string    ChangeLevelsHelp;

var float               ControlOffset;
var bool                bControlRight;

var float				NextControlTop;	// Set this in derivative classes to tell the base where the bottom controls should go.

function Created()
{
	local int S;

	Super.Created();

	myParent        = UDukeCreateMultiCW( GetParent( class'UDukeCreateMultiCW' ) );
	if ( myParent == None )
		Log( "Error: UDukeMultiRulesBase without UDukeCreateMultiCW parent." );

	// Frag Limit
	FragLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	FragLabel.SetText(FragText);
	FragLabel.SetFont(F_Normal);
	FragLabel.Align = TA_Right;

	FragEdit = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1 ) );
	FragEdit.SetHelpText( FragHelp );
	FragEdit.SetFont( F_Normal );
	FragEdit.SetNumericOnly( true );
	FragEdit.SetMaxLength( 3 );
	FragEdit.Align = TA_Right;

	// Time Limit
	TimeLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	TimeLabel.SetText(TimeText);
	TimeLabel.SetFont(F_Normal);
	TimeLabel.Align = TA_Right;

	TimeEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', 1, 1, 1, 1 ) );
	TimeEdit.SetHelpText( TimeHelp );
	TimeEdit.SetFont( F_Normal );
	TimeEdit.SetNumericOnly( True );
	TimeEdit.SetMaxLength( 3 );
	TimeEdit.Align = TA_Right;

	// WeaponsStay
	WeaponsLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	WeaponsLabel.SetText(WeaponsText);
	WeaponsLabel.SetFont(F_Normal);
	WeaponsLabel.Align = TA_Right;

	WeaponsCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', 1, 1, 1, 1 ) );
	WeaponsCheck.SetHelpText( WeaponsHelp );
	WeaponsCheck.SetFont( F_Normal );
	WeaponsCheck.bChecked = myParent.GameClass.Default.bCoopWeaponMode;
	WeaponsCheck.Align = TA_Right;

	// Tournament
	TourneyLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	TourneyLabel.SetText(TourneyText);
	TourneyLabel.SetFont(F_Normal);
	TourneyLabel.Align = TA_Right;

	TourneyCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', 1, 1, 1, 1 ) );
	TourneyCheck.SetHelpText( TourneyHelp );
	TourneyCheck.SetFont( F_Normal );
	TourneyCheck.Align = TA_Right;

	// Force Respawn
	ForceRespawnLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	ForceRespawnLabel.SetText(ForceRespawnText);
	ForceRespawnLabel.SetFont(F_Normal);
	ForceRespawnLabel.Align = TA_Right;

	ForceRespawnCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', 1, 1, 1, 1 ) );
	ForceRespawnCheck.SetHelpText( ForceRespawnHelp );
	ForceRespawnCheck.SetFont( F_Normal );
	ForceRespawnCheck.Align = TA_Right;

	// Uplink
	DoUplinkLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	DoUplinkLabel.SetText(DoUplinkText);
	DoUplinkLabel.SetFont(F_Normal);
	DoUplinkLabel.Align = TA_Right;

	DoUplinkCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', 1, 1, 1, 1 ) );
	DoUplinkCheck.SetHelpText( DoUplinkHelp );
	DoUplinkCheck.SetFont( F_Normal );
	DoUplinkCheck.Align = TA_Right;

	IPServerClass = Class( DynamicLoadObject( "IpServer.UdpServerUplink", class'Class' ) );
	DoUplinkCheck.bChecked = GetPlayerOwner().ConsoleCommand("get IpServer.UdpServerUplink DoUplink") ~= "true";

	// Uplink
	LanPlayLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	LanPlayLabel.SetText(LanPlayText);
	LanPlayLabel.SetFont(F_Normal);
	LanPlayLabel.Align = TA_Right;

	LanPlayCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', 1, 1, 1, 1 ) );
	LanPlayCheck.SetHelpText( LanPlayHelp );
	LanPlayCheck.SetFont( F_Normal );
	LanPlayCheck.Align = TA_Right;

    // Change Levels Checkbox
	ChangeLevelsLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	ChangeLevelsLabel.SetText( ChangeLevelsText );
	ChangeLevelsLabel.SetFont( F_Normal );
	ChangeLevelsLabel.Align = TA_Right;

    ChangeLevelsCheck = UWindowCheckbox( CreateControl( class'UWindowCheckbox', 1, 1, 1, 1 ) );
	ChangeLevelsCheck.SetHelpText( ChangeLevelsHelp );
	ChangeLevelsCheck.SetFont( F_Normal );
	ChangeLevelsCheck.Align = TA_Right;

	SetupNetworkOptions();
	SetChangeLevels();
}

function AfterCreate()
{
	Super.AfterCreate();

	// Create the stuff that shows up after all the rules.

	// Admin EMail
	AdminEMailLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	AdminEMailLabel.SetText(AdminEMailText);
	AdminEMailLabel.SetFont(F_Normal);
	AdminEMailLabel.Align = TA_Right;

	AdminEMailEdit = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1 ) );
	AdminEMailEdit.SetHelpText( AdminEMailHelp );
	AdminEMailEdit.SetFont( F_Normal );
	AdminEMailEdit.Align = TA_Right;

	// Admin Name
	AdminNameLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	AdminNameLabel.SetText(AdminNameText);
	AdminNameLabel.SetFont(F_Normal);
	AdminNameLabel.Align = TA_Right;

	AdminNameEdit = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1 ) );
	AdminNameEdit.SetHelpText( AdminNameHelp );
	AdminNameEdit.SetFont( F_Normal );
	AdminNameEdit.Align = TA_Right;

	// MOTD Line 1
	MOTDLine1Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MOTDLine1Label.SetText(MOTDLine1Text);
	MOTDLine1Label.SetFont(F_Normal);
	MOTDLine1Label.Align = TA_Right;

	MOTDLine1Edit = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1 ) );
	MOTDLine1Edit.SetHelpText( MOTDLine1Help );
	MOTDLine1Edit.SetFont( F_Normal );
	MOTDLine1Edit.Align = TA_Right;

	// MOTD Line 2
	MOTDLine2Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MOTDLine2Label.SetText(MOTDLine2Text);
	MOTDLine2Label.SetFont(F_Normal);
	MOTDLine2Label.Align = TA_Right;

	MOTDLine2Edit = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1 ) );
	MOTDLine2Edit.SetHelpText( MOTDLine2Help );
	MOTDLine2Edit.SetFont( F_Normal );
	MOTDLine2Edit.Align = TA_Right;

	// MOTD Line 3
	MOTDLine3Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MOTDLine3Label.SetText(MOTDLine3Text);
	MOTDLine3Label.SetFont(F_Normal);
	MOTDLine3Label.Align = TA_Right;

	MOTDLine3Edit = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1 ) );
	MOTDLine3Edit.SetHelpText( MOTDLine3Help );
	MOTDLine3Edit.SetFont( F_Normal );
	MOTDLine3Edit.Align = TA_Right;

	// MOTD Line 4
	MOTDLine4Label = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MOTDLine4Label.SetText(MOTDLine4Text);
	MOTDLine4Label.SetFont(F_Normal);
	MOTDLine4Label.Align = TA_Right;

	MOTDLine4Edit = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1 ) );
	MOTDLine4Edit.SetHelpText( MOTDLine4Help );
	MOTDLine4Edit.SetFont( F_Normal );
	MOTDLine4Edit.Align = TA_Right;

	// Server Name
	ServerNameLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	ServerNameLabel.SetText(ServerNameText);
	ServerNameLabel.SetFont(F_Normal);
	ServerNameLabel.Align = TA_Right;

	ServerNameEdit = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1 ) );
	ServerNameEdit.SetHelpText( ServerNameHelp );
	ServerNameEdit.SetFont( F_Normal );
	ServerNameEdit.Align = TA_Right;

	LoadCurrentValues();
	Initialized = True;
}

function SetupNetworkOptions()
{
	local int ControlWidth, ControlLeft, ControlRight;
	local int CenterWidth, CenterPos, ButtonWidth, ButtonLeft;

	ControlWidth = WinWidth/2.5;
	ControlLeft = ( WinWidth/2 - ControlWidth )/2;
	ControlRight = WinWidth/2 + ControlLeft;

	CenterWidth = ( WinWidth/4 )*3;
	CenterPos = ( WinWidth - CenterWidth )/2;

	// Max Players
	MaxPlayersLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MaxPlayersLabel.SetText(MaxPlayersText);
	MaxPlayersLabel.SetFont(F_Normal);
	MaxPlayersLabel.Align = TA_Right;

	MaxPlayersEdit = UWindowEditControl( CreateControl( class'UWindowEditControl', 1, 1, 1, 1 ) );
	MaxPlayersEdit.SetHelpText( MaxPlayersHelp );
	MaxPlayersEdit.SetFont( F_Normal );
	MaxPlayersEdit.SetNumericOnly( True );
	MaxPlayersEdit.SetMaxLength( 2 );
	MaxPlayersEdit.Align = TA_Right;
	MaxPlayersEdit.SetDelayedNotify( True );

	// Max Spectators
	MaxSpectatorsLabel = UWindowLabelControl(CreateControl(class'UWindowLabelControl', 1, 1, 1, 1));
	MaxSpectatorsLabel.SetText(MaxSpectatorsText);
	MaxSpectatorsLabel.SetFont(F_Normal);
	MaxSpectatorsLabel.Align = TA_Right;

	MaxSpectatorsEdit = UWindowEditControl( CreateControl(class'UWindowEditControl', 1, 1, 1, 1 ) );
	MaxSpectatorsEdit.SetHelpText( MaxSpectatorsHelp );
	MaxSpectatorsEdit.SetFont( F_Normal );
	MaxSpectatorsEdit.SetNumericOnly( True );
	MaxSpectatorsEdit.SetMaxLength( 2 );
	MaxSpectatorsEdit.Align = TA_Right;
	MaxSpectatorsEdit.SetDelayedNotify( True );
}

function BeforePaint( Canvas C, float X, float Y )
{
	local int CenterWidth;
	local int CColLeft, CColRight;
	local float YOff, W, W2;

	Super.BeforePaint( C, X, Y );

	CenterWidth = (WinWidth/4)*3;
	CColLeft = (WinWidth / 2) - 7;
	CColRight = (WinWidth / 2) + 7;

	FragEdit.SetSize( 50, FragEdit.WinHeight );
	FragLabel.AutoSize( C );
	TimeEdit.SetSize( 50, TimeEdit.WinHeight );
	TimeLabel.AutoSize( C );

	FragEdit.WinTop = 0;
	FragLabel.WinTop = FragEdit.WinTop + 12;

	TimeEdit.WinTop = 0;
	TimeLabel.WinTop = TimeEdit.WinTop + 12;

	W = FragEdit.WinWidth + FragLabel.WinWidth + 14;
	W2 = TimeEdit.WinWidth + TimeLabel.WinWidth + 14;

	FragLabel.WinLeft = (WinWidth - (W+W2+32))/2;
	FragEdit.WinLeft = FragLabel.WinLeft + FragLabel.WinWidth + 14;

	TimeLabel.WinLeft = FragEdit.WinLeft + FragEdit.WinWidth + 32 + 20;
	TimeEdit.WinLeft = TimeLabel.WinLeft + TimeLabel.WinWidth + 14 + 20;

	YOff = TimeEdit.WinTop + TimeEdit.WinHeight + 5;

	MaxPlayersEdit.SetSize( 50, MaxPlayersEdit.WinHeight );
	MaxPlayersLabel.AutoSize( C );

	MaxPlayersEdit.WinLeft = FragEdit.WinLeft;
	MaxPlayersEdit.WinTop = YOff;

	MaxPlayersLabel.WinLeft = FragEdit.WinLeft - 14 - MaxPlayersLabel.WinWidth;
	MaxPlayersLabel.WinTop = MaxPlayersEdit.WinTop + 8;

	MaxSpectatorsEdit.SetSize( 50, MaxSpectatorsEdit.WinHeight );
	MaxSpectatorsLabel.AutoSize( C );

	MaxSpectatorsEdit.WinLeft = TimeEdit.WinLeft;
	MaxSpectatorsEdit.WinTop = MaxPlayersEdit.WinTop;

	MaxSpectatorsLabel.WinLeft = TimeEdit.WinLeft - 14 - MaxSpectatorsLabel.WinWidth;
	MaxSpectatorsLabel.WinTop = MaxSpectatorsEdit.WinTop + 8;

	WeaponsCheck.SetSize( CenterWidth-90+16, WeaponsCheck.WinHeight );
	WeaponsLabel.AutoSize( C );

	WeaponsCheck.WinLeft = FragEdit.WinLeft;
	WeaponsCheck.WinTop = MaxSpectatorsEdit.WinTop + MaxSpectatorsEdit.WinHeight + 5;

	WeaponsLabel.WinLeft = FragEdit.WinLeft - 14 - WeaponsLabel.WinWidth;
	WeaponsLabel.WinTop = WeaponsCheck.WinTop + 10;

	TourneyCheck.SetSize( CenterWidth-90+16, TourneyCheck.WinHeight );
	TourneyLabel.AutoSize( C );

	TourneyCheck.WinLeft = TimeEdit.WinLeft;
	TourneyCheck.WinTop = MaxSpectatorsEdit.WinTop + MaxSpectatorsEdit.WinHeight + 5;

	TourneyLabel.WinLeft = TimeEdit.WinLeft - 14 - TourneyLabel.WinWidth;
	TourneyLabel.WinTop = TourneyCheck.WinTop + 10;

	ForceRespawnCheck.SetSize( CenterWidth-90+16, ForceRespawnCheck.WinHeight );
	ForceRespawnLabel.AutoSize( C );

	ForceRespawnCheck.WinLeft = FragEdit.WinLeft;
	ForceRespawnCheck.WinTop = WeaponsCheck.WinTop + WeaponsCheck.WinHeight + 5;

	ForceRespawnLabel.WinLeft = FragEdit.WinLeft - 14 - ForceRespawnLabel.WinWidth;
	ForceRespawnLabel.WinTop = ForceRespawnCheck.WinTop + 10;

	ChangeLevelsCheck.SetSize( CenterWidth-90+16, ChangeLevelsCheck.WinHeight );
	ChangeLevelsLabel.AutoSize( C );

	ChangeLevelsCheck.WinLeft = TimeEdit.WinLeft;
	ChangeLevelsCheck.WinTop = WeaponsCheck.WinTop + WeaponsCheck.WinHeight + 5;

	ChangeLevelsLabel.WinLeft = TimeEdit.WinLeft - 14 - ChangeLevelsLabel.WinWidth;
	ChangeLevelsLabel.WinTop = ChangeLevelsCheck.WinTop + 10;

	DoUplinkCheck.SetSize( CenterWidth-90+16, DoUplinkCheck.WinHeight );
	DoUplinkLabel.AutoSize( C );

	DoUplinkCheck.WinLeft = FragEdit.WinLeft;
	DoUplinkCheck.WinTop = ChangeLevelsCheck.WinTop + ChangeLevelsCheck.WinHeight + 5;

	DoUplinkLabel.WinLeft = FragEdit.WinLeft - 14 - DoUplinkLabel.WinWidth;
	DoUplinkLabel.WinTop = DoUplinkCheck.WinTop + 10;

	LANPlayCheck.SetSize( CenterWidth-90+16, LANPlayCheck.WinHeight );
	LANPlayLabel.AutoSize( C );

	LANPlayCheck.WinLeft = TimeEdit.WinLeft;
	LANPlayCheck.WinTop = ChangeLevelsCheck.WinTop + ChangeLevelsCheck.WinHeight + 5;

	LANPlayLabel.WinLeft = TimeEdit.WinLeft - 14 - LANPlayLabel.WinWidth;
	LANPlayLabel.WinTop = LANPlayCheck.WinTop + 10;

	if ( NextControlTop == -1 )
		NextControlTop = DoUplinkCheck.WinTop + DoUplinkCheck.WinHeight + 5;

	AdminEMailEdit.SetSize( 280, AdminEMailEdit.WinHeight );
	AdminEMailEdit.WinLeft = CColRight - 80;
	AdminEMailEdit.WinTop = NextControlTop;

	AdminEMailLabel.AutoSize( C );
	AdminEMailLabel.WinLeft = CColLeft - AdminEMailLabel.WinWidth - 80;
	AdminEMailLabel.WinTop = AdminEMailEdit.WinTop + 8;

	AdminNameEdit.SetSize( 280, AdminNameEdit.WinHeight );
	AdminNameEdit.WinLeft = CColRight - 80;
	AdminNameEdit.WinTop = AdminEMailEdit.WinTop + AdminEMailEdit.WinHeight + 5;

	AdminNameLabel.AutoSize( C );
	AdminNameLabel.WinLeft = CColLeft - AdminNameLabel.WinWidth - 80;
	AdminNameLabel.WinTop = AdminNameEdit.WinTop + 8;

	MOTDLine1Edit.SetSize( 280, MOTDLine1Edit.WinHeight );
	MOTDLine1Edit.WinLeft = CColRight - 80;
	MOTDLine1Edit.WinTop = AdminNameEdit.WinTop + AdminNameEdit.WinHeight + 5;

	MOTDLine1Label.AutoSize( C );
	MOTDLine1Label.WinLeft = CColLeft - MOTDLine1Label.WinWidth - 80;
	MOTDLine1Label.WinTop = MOTDLine1Edit.WinTop + 8;

	MOTDLine2Edit.SetSize( 280, MOTDLine2Edit.WinHeight );
	MOTDLine2Edit.WinLeft = CColRight - 80;
	MOTDLine2Edit.WinTop = MOTDLine1Edit.WinTop + MOTDLine1Edit.WinHeight + 5;

	MOTDLine2Label.AutoSize( C );
	MOTDLine2Label.WinLeft = CColLeft - MOTDLine2Label.WinWidth - 80;
	MOTDLine2Label.WinTop = MOTDLine2Edit.WinTop + 8;

	MOTDLine3Edit.SetSize( 280, MOTDLine3Edit.WinHeight );
	MOTDLine3Edit.WinLeft = CColRight - 80;
	MOTDLine3Edit.WinTop = MOTDLine2Edit.WinTop + MOTDLine2Edit.WinHeight + 5;

	MOTDLine3Label.AutoSize( C );
	MOTDLine3Label.WinLeft = CColLeft - MOTDLine3Label.WinWidth - 80;
	MOTDLine3Label.WinTop = MOTDLine3Edit.WinTop + 8;

	MOTDLine4Edit.SetSize( 280, MOTDLine4Edit.WinHeight );
	MOTDLine4Edit.WinLeft = CColRight - 80;
	MOTDLine4Edit.WinTop = MOTDLine3Edit.WinTop + MOTDLine3Edit.WinHeight + 5;

	MOTDLine4Label.AutoSize( C );
	MOTDLine4Label.WinLeft = CColLeft - MOTDLine4Label.WinWidth - 80;
	MOTDLine4Label.WinTop = MOTDLine4Edit.WinTop + 8;

	ServerNameEdit.SetSize( 280, ServerNameEdit.WinHeight );
	ServerNameEdit.WinLeft = CColRight - 80;
	ServerNameEdit.WinTop = MOTDLine4Edit.WinTop + MOTDLine4Edit.WinHeight + 5;

	ServerNameLabel.AutoSize( C );
	ServerNameLabel.WinLeft = CColLeft - ServerNameLabel.WinWidth - 80;
	ServerNameLabel.WinTop = ServerNameEdit.WinTop + 8;

	DesiredHeight = ServerNameEdit.WinTop + ServerNameEdit.WinHeight + 10;

	NextControlTop = -1;
}

function Notify( UWindowDialogControl C, byte E )
{
	if ( !Initialized )
		return;

	Super.Notify( C, E );

	switch(E)
	{
	case DE_Change:
		switch(C)
		{
			case FragEdit:
				FragChanged();
				break;
			case TimeEdit:
				TimeChanged();
				break;
			case MaxPlayersEdit:
				MaxPlayersChanged();
				break;
			case MaxSpectatorsEdit:
				MaxSpectatorsChanged();
				break;
			case WeaponsCheck:
				WeaponsChecked();
				break;
			case TourneyCheck:
				TourneyChecked();
				break;
			case ForceRespawnCheck:
				ForceRespawnChecked();
				break;
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
				if ( DoUplinkCheck.bChecked )
					GetPlayerOwner().ConsoleCommand( "set IpServer.UdpServerUplink DoUplink True" );
				else
					GetPlayerOwner().ConsoleCommand( "set IpServer.UdpServerUplink DoUplink False" );
				IPServerClass.Static.StaticSaveConfig();
				break;
			case LanPlayCheck:
				bLanPlay = LanPlayCheck.bChecked;
				break;
			case ChangeLevelsCheck:
				ChangeLevelsChanged();
				break;
		}
	}
}

function FragChanged();
function TimeChanged();
function MaxPlayersChanged();
function MaxSpectatorsChanged();
function WeaponsChecked();
function LoadCurrentValues();
function TourneyChecked();
function ForceRespawnChecked();

function SaveConfigs()
{
    SaveConfig();
	Super.SaveConfigs();
	class'Engine.GameReplicationInfo'.static.StaticSaveConfig();
}

function ChangeLevelsChanged()
{
	local class<dnDeathMatchGame>DMG;

	DMG = class<dnDeathMatchGame>(myParent.GameClass);

	if ( DMG != None )
	{
		DMG.default.bChangeLevels = ChangeLevelsCheck.bChecked;
		DMG.static.StaticSaveConfig();
	}
}

function SetChangeLevels()
{
	local class<dnDeathMatchGame> DMG;

	DMG = class<dnDeathMatchGame>(myParent.GameClass);
	
	if ( DMG == None )
	{
		ChangeLevelsCheck.HideWindow();
	}
	else
	{
		ChangeLevelsCheck.ShowWindow();
		ChangeLevelsCheck.bChecked = DMG.default.bChangeLevels;
	}
}

defaultproperties
{
	ControlOffset=20
	FragText="Frag Limit"
	FragHelp="The game will end if a player achieves this many frags. A value of 0 sets no frag limit."
	TimeText="Time Limit"
	TimeHelp="The game will end if after this many minutes. A value of 0 sets no time limit."
	MaxPlayersText="Max Players"
	MaxPlayersHelp="Maximum number of human players allowed to connect to the game."
	MaxSpectatorsText="Max Spectators"
	MaxSpectatorsHelp="Maximum number of spectators allowed to connect to the game."
	WeaponsText="Weapons Stay"
	WeaponsHelp="If checked, weapons will stay at their pickup location after being picked up, instead of respawning."
 	TourneyText="Tournament"
	TourneyHelp="If checked, each player must indicate they are ready by clicking their fire button before the match begins."
	ForceRespawnText="Force Respawn"
	ForceRespawnHelp="If checked, players will be automatically respawned when they die, without waiting for the user to press Fire."
	bBuildDefaultButtons=false
    bNoScanLines=true
    bNoClientTexture=true
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
	LanPlayText="LAN Optimize"
	LanPlayHelp="If checked, a dedicated server started will be optimized for play on a LAN."
	ChangeLevelsText="Map Cycle"
	ChangeLevelsHelp="If this setting is checked, the server will cycle levels according to the map list for this game type."
}