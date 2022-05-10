/*-----------------------------------------------------------------------------
	UDukeDesktopWindow
	Author: Timothy L. Weisser
	Rewrite: Brandon Reinhart
-----------------------------------------------------------------------------*/
class UDukeDesktopWindow expands UDukeDesktopWindowBase;

#exec OBJ LOAD FILE=..\Textures\SMK3.dtx
#exec OBJ LOAD FILE=..\Textures\SMK7.dtx
#exec OBJ LOAD FILE=..\Sounds\a_generic.dfx

// temporary:
#exec OBJ LOAD FILE=..\Textures\mtheme_cobaltblue.dtx

/*-----------------------------------------------------------------------------
	Defines
-----------------------------------------------------------------------------*/

const ICON_Game  = 0;
const ICON_Sett  = 1;
const ICON_Multi = 2;
const ICON_Supp  = 3;
const ICON_MAX	 = 4;							// Max number of icons on the main desktop.
const SUB_ICON_MAX = 8;							// Max number of subicons under the main desktop one.

// Used for keyboard selection of desktop icons.
enum eICON_SELECT_TYPE
{
	eICON_SELECT_UP,
	eICON_SELECT_DOWN,
	eICON_SELECT_LEFT,
	eICON_SELECT_RIGHT,
	eICON_SELECT_MAX
};

// Icons that come out of the main/desktop icons, like a sub/dropdown.
enum eSUB_ICON_TYPE
{
	// Game
	eSUB_ICON_NewGame,
	eSUB_ICON_SaveGame, 
	eSUB_ICON_LoadGame, 
	eSUB_ICON_Profile, 
	eSUB_ICON_QuitGame, 

	// Settings
	eSUB_ICON_Video, 
	eSUB_ICON_Audio, 
	eSUB_ICON_Game, 
	eSUB_ICON_Controls, 
	eSUB_ICON_SOS,
	
	// Multi
    eSUB_ICON_FindGame,
    eSUB_ICON_CreateGame,
	eSUB_ICON_PlayerSetup,

	// About
	eSUB_ICON_Update, 
	eSUB_ICON_About3DRealms,
	
	eSUB_ICON_MAX
};

const FullSizeTextureWidth  = 1024;
const FullSizeTextureHeight = 768;

/*-----------------------------------------------------------------------------
	Theme
-----------------------------------------------------------------------------*/

var globalconfig string ThemePackage;
var globalconfig bool   ThemeColorizable;
var globalconfig bool	ThemeTranslucentIcons;
var globalconfig string BackgroundName;
var globalconfig bool	BackgroundSmack;
var globalconfig int	BackgroundTileCountH;
var globalconfig int	BackgroundTileCountV;
var globalconfig string	BackgroundTiles[12];
var smackertexture		WindowOpenSmack;

/*-----------------------------------------------------------------------------
	Desktop Icons
-----------------------------------------------------------------------------*/

var bool  bCheckForLoopingSound;				// Checks icons for text cycle, and plays looping sound if appropriate.
var float fLengthOfLoopedSound;					// How long the looping sound is.
var float fTimeSinceLoopedSoundStarted;			// Length of time since the looping sound was started.

var bool bIconsHidden;							// Used to fend of re-entering show/hide of icons.
var	UDukeFakeIcon iconDesktop[5];				// [ICON_MAX];  
var UDukeFakeIcon arraySubIcons[40];			// [ICON_MAX * SUB_ICON_MAX]; 
var() localized string aSubIconLabels[22];		// [eSUB_ICON_TYPE.eSUB_ICON_MAX];
var() texture aSubIconTextures[22];				// [eSUB_ICON_TYPE.eSUB_ICON_MAX];
var() texture aSubIconTexturesHL[22];

var() float fOversizeFactor;					// Oversize all the desktop icons to make room for 2D animations.
var() int iIconOffsetX;							// Offset for spacing out the sub-icons from the main ones.
var() int iIconOffsetY;							//  "

var float LastClipX;
var float fLocationX;							// Used for lining up the left side of the desktop icons
var float fLocationY[5];						// [ICON_MAX]; Placement of the top of the desktop icons on.

var() float fNumFramesToAccomplishSlide;		// Simple anim count so all icons come out the same # frames.

var float WinScaleX, WinScaleY;

var UDukeButton BlurButton;
var bool bIconBlur;
var int BlurFrame;
var smackertexture BlurTexBigLeft, BlurTexBigRight;
var smackertexture BlurTexSmallLeft, BlurTexSmallRight;
//var texture BlurTexBigLeft[3], BlurTexBigRight[3];
//var texture BlurTexSmallLeft[3], BlurTexSmallRight[3];
var float BlurFrameTime, LastBlurFrameTime;

/*-----------------------------------------------------------------------------
	Window Regions
-----------------------------------------------------------------------------*/

var(ExplorerSizes) Region regGame_NewGame;
var(ExplorerSizes) Region regGame_SaveGame;
var(ExplorerSizes) Region regGame_LoadGame;
var(ExplorerSizes) Region regGame_BotmatchWindow;
var(ExplorerSizes) Region regMulti_FindGame;
var(ExplorerSizes) Region regMulti_CreateGame;
var(ExplorerSizes) Region regMulti_PlayerSetup;
var(ExplorerSizes) Region regSett_Video;
var(ExplorerSizes) Region regSett_Game;
var(ExplorerSizes) Region regSett_Audio;
var(ExplorerSizes) Region regSett_Controls;
var(ExplorerSizes) Region regSett_SOS;

var() config bool ShowHelp;
var UDukeProfileWindow	ProfileWindow;

/*-----------------------------------------------------------------------------
	Graphics / Movies
-----------------------------------------------------------------------------*/

// Backdrop
var Texture Backdrop[12];

// Sunglasses edges
var Texture	texSunglasses[4];
var Texture	texSunglassesGlow[4];
var bool bHideSunglasses;                     // Hide the sunglasses

// 3DR Logo
var SmackerTexture aflic3DR[4];
var bool bDoing3DRLogo;
var sound LogoSound;

// Nukem Logo
var SmackerTexture aflicNukem[4];
var bool bDoingNukemLogo;

// Death Sequence
var SmackerTexture aflicDeath[4];				// Mission over flic.
var bool bDoingDeathSequence;
var bool bDeathSequenceDone;
var float fDeathSequenceTime;					// How much time has passed since the bootupsequence started.
var() float fDeathSequenceLength;				// How long the bootupsequence should run for.
var UDukeMissionOverButton ContinueButton;
var UDukeMissionOverButton QuitButton;
var sound DeathSequenceSound;

// Bootup Sequence
var bool bFirstPaint;							// Flag for holding off starting the SOS bootup till all things are loaded.
var bool bDoingBootupSequence;					// Flag for drawing and incrementing time.
var float fBootupSequenceTime;					// How much time has passed since the bootupsequence started.
var() float fBootupSequenceLength;				// How long the bootupsequence should run for.
var float fBootFadeFactor;						// Amount to fade the boot flic to black.
var bool bDoingLevelStartSequence;
var float StartLevelCount;
var SmackerTexture aflicBootup[4];				// Flic that plays in the background for boot.

/*-----------------------------------------------------------------------------
	Initialization
-----------------------------------------------------------------------------*/

function Created() 
{
	bAlwaysBehind = true;	// Makes this window always at the bottom of the z-order, but above parent...?

	WinScaleX = WinWidth / 1024.f;
	WinScaleY = WinHeight / 768.f;
	LoadArt();

	// Toggle show bootup, so we show the startup movie.
	DukeConsole(Root.Console).bShowBootup = true;

	// Set a desktop reference on the console.
	DukeConsole(Root.Console).Desktop = Self;
}

function Texture LoadTexture( string TextureName )
{
	local Texture T;

	T = Texture( DynamicLoadObject( ThemePackage$"."$TextureName, class'Texture' ) );
	if ( T == None )
	{
		Log("Theme doesn't implement"@TextureName@"reverting to mtheme_cobaltblue.");
		// Fall back to cobalt blue.
		T = Texture( DynamicLoadObject( "mtheme_cobaltblue."$TextureName, class'Texture' ) );
		if ( T == None )
		{
			Log("Cobalt Blue theme doesn't implement"@TextureName@"reverting to hud_effects.");
			T = Texture( DynamicLoadObject( "hud_effects."$TextureName, class'Texture' ) );
		}
	}
	return T;
}

function SmackerTexture LoadSmack( string SmackName )
{
	local SmackerTexture T;

	T = SmackerTexture( DynamicLoadObject( ThemePackage$"."$SmackName, class'SmackerTexture' ) );
	if ( T == None )
	{
		Log("Theme doesn't implement"@SmackName@"reverting to mtheme_cobaltblue.");
		// Fall back to cobalt blue.
		T = SmackerTexture( DynamicLoadObject( "mtheme_cobaltblue."$SmackName, class'SmackerTexture' ) );
		if ( T == None )
		{
			Log("Cobalt Blue theme doesn't implement"@SmackName@"reverting to hud_effects.");
			T = SmackerTexture( DynamicLoadObject( "hud_effects."$SmackName, class'SmackerTexture' ) );
		}
	}
	return T;
}

function LoadArt()
{
	local Texture texIconGame, texIconMultiplayer, texIconSetup, texIconSupport;
	local Texture texIconGameGlow, texIconMultiplayerGlow, texIconSetupGlow, texIconSupportGlow;
	local Texture texIconGameHL, texIconMultiplayerHL, texIconSetupHL, texIconSupportHL;
	local Texture texIconGameDown, texIconMultiplayerDown, texIconSetupDown, texIconSupportDown;
	local bool bNoCreate;

	// Load backdrop.
	LoadBackdrop();

	// Window open effect.
	WindowOpenSmack		= LoadSmack( "menuopen" );

	// Cursor
	Root.NormalCursor.Tex= LoadTexture( "mainmenu_cursor" );
	Root.SetCursor( Root.NormalCursor );	
	SetCursor( Root.NormalCursor );

	// Load sunglasses art.
	texSunglasses[0]	= LoadTexture( "sunglassesTL" );
	texSunglasses[1]	= LoadTexture( "sunglassesTR" );
	texSunglasses[2]	= LoadTexture( "sunglassesBL" );
	texSunglasses[3]	= LoadTexture( "sunglassesBR" );

	// Load sunglasses glow art.
	texSunglassesGlow[0]= LoadTexture( "sunglassesTLglo" );
	texSunglassesGlow[1]= LoadTexture( "sunglassesTRglo" );
	texSunglassesGlow[2]= LoadTexture( "sunglassesBLglo" );
	texSunglassesGlow[3]= LoadTexture( "sunglassesBRglo" );

	// Load death sequence movie.
	aflicDeath[0]		= LoadSmack( "mover_tleft" );
	aflicDeath[1]		= LoadSmack( "mover_tright" );
	aflicDeath[2]		= LoadSmack( "mover_bleft" );
	aflicDeath[3]		= LoadSmack( "mover_bright" );

	// Load main icons.
	texIconGame			= LoadTexture( "iconbig_game" );
	texIconMultiplayer	= LoadTexture( "iconbig_multiplayer" );
	texIconSetup		= LoadTexture( "iconbig_settings" );
	texIconSupport		= LoadTexture( "iconbig_support" );

	// Load glow icons.
	texIconGameGlow		= LoadTexture( "iconbig_game_glow" );
	texIconMultiplayerGlow= LoadTexture( "iconbig_multiplayer_glow" );
	texIconSetupGlow	= LoadTexture( "iconbig_settings_glow" );
	texIconSupportGlow	= LoadTexture( "iconbig_support_glow" );

	// Load HL icons.
	texIconGameHL		= LoadTexture( "iconbig_game_HL" );
	texIconMultiplayerHL= LoadTexture( "iconbig_multiplayer_HL" );
	texIconSetupHL	= LoadTexture( "iconbig_settings_HL" );
	texIconSupportHL	= LoadTexture( "iconbig_support_HL" );

	// Load Down icons.
	texIconGameDown		= LoadTexture( "iconbig_game_SL" );
	texIconMultiplayerDown= LoadTexture( "iconbig_multiplayer_SL" );
	texIconSetupDown	= LoadTexture( "iconbig_settings_SL" );
	texIconSupportDown	= LoadTexture( "iconbig_support_SL" );

	// Sub icons.
    aSubIconTextures[0] = LoadTexture( "icon_newgame" );
    aSubIconTextures[1] = LoadTexture( "icon_savegame" );
    aSubIconTextures[2] = LoadTexture( "icon_loadgame" );
    aSubIconTextures[3] = LoadTexture( "icon_profiles" );
    aSubIconTextures[4] = LoadTexture( "icon_quit" );
    aSubIconTextures[5] = LoadTexture( "icon_video" );
    aSubIconTextures[6] = LoadTexture( "icon_audio" );
    aSubIconTextures[7] = LoadTexture( "icon_game" );
    aSubIconTextures[8] = LoadTexture( "icon_controls" );
    aSubIconTextures[9] = LoadTexture( "icon_sos" );
    aSubIconTextures[10]= LoadTexture( "icon_findgame" );
    aSubIconTextures[11]= LoadTexture( "icon_creategame" );
    aSubIconTextures[12]= LoadTexture( "icon_playersetup" );
    aSubIconTextures[13]= LoadTexture( "icon_findgame" );
    aSubIconTextures[14]= LoadTexture( "icon_findgame" );
	
	// Sub icon glow.
    aSubIconTexturesHL[0] = LoadTexture( "icon_newgame_glow" );
    aSubIconTexturesHL[1] = LoadTexture( "icon_savegame_glow" );
    aSubIconTexturesHL[2] = LoadTexture( "icon_loadgame_glow" );
    aSubIconTexturesHL[3] = LoadTexture( "icon_profiles_glow" );
    aSubIconTexturesHL[4] = LoadTexture( "icon_quit_glow" );
    aSubIconTexturesHL[5] = LoadTexture( "icon_video_glow" );
    aSubIconTexturesHL[6] = LoadTexture( "icon_audio_glow" );
    aSubIconTexturesHL[7] = LoadTexture( "icon_game_glow" );
    aSubIconTexturesHL[8] = LoadTexture( "icon_controls_glow" );
    aSubIconTexturesHL[9] = LoadTexture( "icon_sos_glow" );
    aSubIconTexturesHL[10]= LoadTexture( "icon_findgame_glow" );
    aSubIconTexturesHL[11]= LoadTexture( "icon_creategame_glow" );
    aSubIconTexturesHL[12]= LoadTexture( "icon_playersetup_glow" );
    aSubIconTexturesHL[13]= LoadTexture( "icon_findgame_glow" );
    aSubIconTexturesHL[14]= LoadTexture( "icon_findgame_glow" );

	// Sub icon blur.
	BlurTexBigLeft = LoadSmack( "iconslidebig_left" );
	BlurTexBigRight = LoadSmack( "iconslidebig_right" );
	BlurTexSmallLeft = LoadSmack( "iconslidesmall_left" );
	BlurTexSmallRight = LoadSmack( "iconslidesmall_right" );
	/*
	BlurTexBigLeft[0] = LoadTexture( "iconslidebig_001a" );
	BlurTexBigLeft[1] = LoadTexture( "iconslidebig_002a" );
	BlurTexBigLeft[2] = LoadTexture( "iconslidebig_003a" );
	BlurTexBigRight[0] = LoadTexture( "iconslidebig_001b" );
	BlurTexBigRight[1] = LoadTexture( "iconslidebig_002b" );
	BlurTexBigRight[2] = LoadTexture( "iconslidebig_003b" );

	BlurTexSmallLeft[0] = LoadTexture( "iconslidesmall_001a" );
	BlurTexSmallLeft[1] = LoadTexture( "iconslidesmall_002a" );
	BlurTexSmallLeft[2] = LoadTexture( "iconslidesmall_003a" );
	BlurTexSmallRight[0] = LoadTexture( "iconslidesmall_001b" );
	BlurTexSmallRight[1] = LoadTexture( "iconslidesmall_002b" );
	BlurTexSmallRight[2] = LoadTexture( "iconslidesmall_003b" );
	*/

	// Start in the center, minus the (icon sizes + spacing between).
	CalculateIconPlacement( WinWidth, WinHeight, texIconGame.VSize );

	// Setup buttons/icons.
	if ( iconDesktop[0] != None )
		bNoCreate = true;

	CreateIconsForGameIconString( texIconGame, texIconGameGlow, texIconGameHL, texIconGameDown, bNoCreate );
	CreateIconsForSettingsIconString( texIconSetup, texIconSetupGlow, texIconSetupHL, texIconSetupDown, bNoCreate );
	CreateIconsForMultiplayerIconString( texIconMultiplayer, texIconMultiplayerGlow, texIconMultiplayerHL, texIconMultiplayerDown, bNoCreate );
	CreateIconsForSupportIconString( texIconSupport, texIconSupportGlow, texIconSupportHL, texIconSupportDown, bNoCreate );

	// Load LookAndFeel textures.
	LookAndFeel.Active = LoadTexture( "menu_windowbc" );
	LookAndFeel.Active2 = LoadTexture( "menu_window2bc" );
	LookAndFeel.Active3 = LoadTexture( "menu_window3bc" );

	// Load LookAndFeel glow.
	LookAndFeel.Glow = LoadTexture( "menu_window_glowbc" );
	LookAndFeel.Glow3 = LoadTexture( "menu_window_glow3bc" );
}

function LoadBackdrop()
{
	local int i, j, k;

	for ( i=0; i<BackgroundTileCountH; i++ )
	{
		for ( j=0; j<BackgroundTileCountV; j++ )
		{
			if ( BackgroundSmack )
				Backdrop[k] = Texture( DynamicLoadObject( BackgroundTiles[k], class'SmackerTexture' ) );
			else
				Backdrop[k] = Texture( DynamicLoadObject( BackgroundTiles[k], class'Texture' ) );
			k++;
		}
	}
}

function ResolutionChanged(float W, float H)
{
	local int i, j;
	local float LocationX, LocationY;
	local float smalliconW, smalliconH, iconW, iconH;

	Super.ResolutionChanged( W, H );

	WinScaleX = WinWidth / 1024.f;
	WinScaleY = WinHeight / 768.f;

	CalculateIconPlacement( W, H, iconDesktop[ICON_Game].UpTexture.VSize );

	if ( ContinueButton != None )
	{
		ContinueButton.WinLeft = 31 * WinScaleX * 2.0;
		ContinueButton.WinTop = 278 * WinScaleY * 1.6666;
		ContinueButton.SetSize( texture'hud_effects.missionover.mover_continue'.USize * WinScaleX * 2.0, texture'hud_effects.missionover.mover_continue'.VSize * WinScaleY * 1.66666 );
	}
	if ( QuitButton != None )
	{
		QuitButton.WinLeft = 287 * WinScaleX * 2.0;
		QuitButton.WinTop = 278 * WinScaleY * 1.6666;
		QuitButton.SetSize( texture'hud_effects.missionover.mover_quit'.USize * WinScaleX * 2.0, texture'hud_effects.missionover.mover_quitHL'.VSize * WinScaleY * 1.6666 );
	}

	for ( i=ICON_Game; i<ICON_MAX; i++ )
	{
		iconW = iconDesktop[i].UpTexture.USize * WinScaleX;
		iconH = iconDesktop[i].UpTexture.VSize * WinScaleY;
		smalliconW = arraySubIcons[0].UpTexture.USize * 1.5;
		smalliconH = iconH;

		iconDesktop[i].WinLeft = fLocationX - iconW*0.1;
		iconDesktop[i].WinTop  = fLocationY[i];
		iconDesktop[i].SetSize( iconW*1.2, iconH*1.5 );
		
		LocationX = (iconDesktop[i].UpTexture.USize + iIconOffsetX + 64) * WinScaleX;
		LocationY = iconDesktop[i].WinTop;
		for ( j=0; j<SUB_ICON_MAX; j++ )
		{
			if ( arraySubIcons[i*SUB_ICON_MAX+j] == None )
				break;
			arraySubIcons[i*SUB_ICON_MAX+j].WinLeft = LocationX;
			arraySubIcons[i*SUB_ICON_MAX+j].WinTop  = LocationY;
			arraySubIcons[i*SUB_ICON_MAX+j].SetSize( smalliconW, smalliconH );
			IncrementIconPlacement( arraySubIcons[i*SUB_ICON_MAX+j], LocationX, LocationY, W );
		}
	}
}

/*-----------------------------------------------------------------------------
	Icon Management
-----------------------------------------------------------------------------*/

function ActivateWindow( int Depth, bool bTransientNoDeactivate )
{
	// Prevent the desktop from becoming the focus if a main window is open.
	if ( Root.FindChildWindow( class'UWindowFramedWindow' ) != None )
		return;
	Super.ActivateWindow( Depth, bTransientNoDeactivate );
}

function CalculateIconPlacement(float fNewWidth, float fNewHeight, float fIconHeight)
{
	local float fIconOffsetY;
	
	// All aligned on the left side.
	fLocationX = fNewWidth * 0.1;
	
	// Figure out the placement of the icons.
	fLocationY[0] = (fNewHeight * 0.20) - (fIconHeight * 0.5);
	fLocationY[1] = (fNewHeight * 0.40) - (fIconHeight * 0.5);
	fLocationY[2] = (fNewHeight * 0.60) - (fIconHeight * 0.5);
	fLocationY[3] = (fNewHeight * 0.80) - (fIconHeight * 0.5);
}

function CreateIconsForGameIconString( texture texIconGame, texture texIconGameGlow, texture texIconGameHL, texture texIconGameDown, optional bool bNoCreate )
{
	local float fLocX, fLocY;
	local float iconW, iconH;
	local int iArrayOffset;

	iconW = texIconGame.USize * (Root.WinWidth/1024);
	iconH = texIconGame.VSize * (Root.WinHeight/768);
	if ( !bNoCreate )
		iconDesktop[ICON_Game] = UDukeFakeIcon(CreateWindow( class'UDukeFakeIcon', fLocationX, fLocationY[ICON_Game], iconW, iconH*1.5, self));
	iconDesktop[ICON_Game].UpTexture   = texIconGame;
	iconDesktop[ICON_Game].DownTexture = texIconGameDown;
	iconDesktop[ICON_Game].OverTexture = texIconGameHL;
	iconDesktop[ICON_Game].GlowTexture = texIconGameGlow;
	iconDesktop[ICON_Game].bDesktopIcon = true;
	iconDesktop[ICON_Game].SetText("Game");
	iconDesktop[ICON_Game].TextY = texIconGame.VSize;
	iconDesktop[ICON_Game].Align = TA_Center;

	// Start to the right of the main icon, and tile across and down.
	fLocX = iconDesktop[ICON_Game].WinLeft + iconDesktop[ICON_Game].WinWidth + iIconOffsetX;
	fLocY = iconDesktop[ICON_Game].WinTop;

	// Setup buttons/icons.
	iArrayOffset = ICON_Game * SUB_ICON_MAX;
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_NewGame, regGame_NewGame, bNoCreate );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeNewGameWindow';
	iArrayOffset++;

	// SaveGame icon
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_SaveGame, regGame_SaveGame, bNoCreate );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeSaveGameWindow';
	iArrayOffset++;
	
	// LoadGame icon
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset],fLocX, fLocY, eSUB_ICON_LoadGame, regGame_LoadGame, bNoCreate );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeLoadGameWindow';
	iArrayOffset++;
	
	// Profile icon
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Profile,, bNoCreate);
	arraySubIcons[iArrayOffset].eWindowCommand = eWINDOW_COMMAND_Profile;
	iArrayOffset++;

	// QuitGame icon
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_QuitGame,, bNoCreate );
	arraySubIcons[iArrayOffset].eWindowCommand = eWINDOW_COMMAND_Quit;	
}

function CreateIconsForMultiplayerIconString( texture texIconMultiplayer, texture texIconMultiplayerGlow, texture texIconMultiplayerHL, texture texIconMultiplayerDown, optional bool bNoCreate )
{
	local float fLocX, fLocY;
	local float iconW, iconH;
	local int iArrayOffset;

	iconW = texIconMultiplayer.USize * (Root.WinWidth/1024);
	iconH = texIconMultiplayer.VSize * (Root.WinHeight/768);
	if ( !bNoCreate )
		iconDesktop[ICON_Multi] = UDukeFakeIcon(CreateWindow( class'UDukeFakeIcon', fLocationX, fLocationY[ICON_Multi], iconW, iconH*1.5, self));
	iconDesktop[ICON_Multi].UpTexture   = texIconMultiplayer;
	iconDesktop[ICON_Multi].DownTexture = texIconMultiplayerDown;
	iconDesktop[ICON_Multi].OverTexture = texIconMultiplayerHL;
	iconDesktop[ICON_Multi].GlowTexture = texIconMultiplayerGlow;
	iconDesktop[ICON_Multi].bDesktopIcon = true;
	iconDesktop[ICON_Multi].SetText("Multiplayer");
	iconDesktop[ICON_Multi].TextY = texIconMultiplayer.VSize;
	iconDesktop[ICON_Multi].Align = TA_Center;
	
	// Start to the right of the main icon, and tile across and down.
	fLocX = iconDesktop[ICON_Multi].WinLeft + iconDesktop[ICON_Multi].WinWidth + iIconOffsetX;
	fLocY = iconDesktop[ICON_Multi].WinTop;

	// Setup button/icons.
	iArrayOffset = ICON_Multi * SUB_ICON_MAX;

    CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_FindGame,, bNoCreate );
	arraySubIcons[iArrayOffset].classExplorer       = class'UDukeJoinMultiWindow';
    arraySubIcons[iArrayOffset].WindowOffsetAndSize = regMulti_FindGame;
	iArrayOffset++;

    CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_CreateGame,, bNoCreate );
	arraySubIcons[iArrayOffset].classExplorer       = class'UDukeCreateMultiWindow';
    arraySubIcons[iArrayOffset].WindowOffsetAndSize = regMulti_CreateGame;
	iArrayOffset++;

    CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_PlayerSetup,, bNoCreate );
	arraySubIcons[iArrayOffset].classExplorer       = class'UDukePlayerSetupWindow';
    arraySubIcons[iArrayOffset].WindowOffsetAndSize = regMulti_PlayerSetup;
	iArrayOffset++;
}

function CreateIconsForSettingsIconString( texture texIconSettings, texture texIconSettingsGlow, texture texIconSettingsHL, texture texIconSettingsDown, optional bool bNoCreate )
{
	local float fLocX, fLocY;
	local float iconW, iconH;
	local int iArrayOffset;

	iconW = texIconSettings.USize * (Root.WinWidth/1024);
	iconH = texIconSettings.VSize * (Root.WinHeight/768);

	if ( !bNoCreate )
		iconDesktop[ICON_Sett] = UDukeFakeIcon(CreateWindow(class'UDukeFakeIcon', fLocationX, fLocationY[ICON_Sett], iconW, iconH*1.5, self));
	iconDesktop[ICON_Sett].UpTexture   = texIconSettings;
	iconDesktop[ICON_Sett].DownTexture = texIconSettingsDown;
	iconDesktop[ICON_Sett].OverTexture = texIconSettingsHL;
	iconDesktop[ICON_Sett].GlowTexture = texIconSettingsGlow;
	iconDesktop[ICON_Sett].bDesktopIcon = true;
	iconDesktop[ICON_Sett].SetText("Settings");
	iconDesktop[ICON_Sett].TextY = texIconSettings.VSize;
	iconDesktop[ICON_Sett].Align = TA_Center;

	//Start to the right of the main icon, and tile across and down
	fLocX = iconDesktop[ICON_Sett].WinLeft + iconDesktop[ICON_Sett].WinWidth + iIconOffsetX;
	fLocY = iconDesktop[ICON_Sett].WinTop;

	//setup button/icons

	//eICON_Video
	iArrayOffset = ICON_Sett * SUB_ICON_MAX;
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Video,	regSett_Video, bNoCreate );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeVideoWindow';
	iArrayOffset++;

	//eICON_Audio
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Audio,	regSett_Audio, bNoCreate );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeAudioWindow';
	iArrayOffset++;

	//eICON_Game
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Game, regSett_Game, bNoCreate );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeGameWindow';
	iArrayOffset++;
		
	//eICON_Controls
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Controls, regSett_Controls, bNoCreate );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeControlsWindow';
	iArrayOffset++;	

	//eICON_SOS
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_SOS, regSett_SOS, bNoCreate );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeSOSWindow';
	iArrayOffset++;	
}

function CreateIconsForSupportIconString( texture texIconTools, texture texIconToolsGlow, texture texIconToolsHL, texture texIconToolsDown, optional bool bNoCreate )
{
	local float fLocX, fLocY;
	local float iconW, iconH;
	local int iArrayOffset;

	iconW = texIconTools.USize * (Root.WinWidth/1024);
	iconH = texIconTools.VSize * (Root.WinHeight/768);

	if ( !bNoCreate )
		iconDesktop[ICON_Supp] = UDukeFakeIcon(CreateWindow( class'UDukeFakeIcon', fLocationX, fLocationY[ICON_Supp], iconW, iconH*1.5, self));
	iconDesktop[ICON_Supp].UpTexture   = texIconTools;
	iconDesktop[ICON_Supp].DownTexture = texIconToolsDown;
	iconDesktop[ICON_Supp].OverTexture = texIconToolsHL;
	iconDesktop[ICON_Supp].GlowTexture = texIconToolsGlow;
	iconDesktop[ICON_Supp].bDesktopIcon = true;
	iconDesktop[ICON_Supp].SetText("Support");
	iconDesktop[ICON_Supp].TextY = texIconTools.VSize;
	iconDesktop[ICON_Supp].Align = TA_Center;
	iconDesktop[ICON_Supp].BlurType = 1;

	//Start to the right of the main icon, and tile across and down
	fLocX = iconDesktop[ICON_Supp].WinLeft + iconDesktop[ICON_Supp].WinWidth + iIconOffsetX;
	fLocY = iconDesktop[ICON_Supp].WinTop;

	//setup button/icons
	iArrayOffset = ICON_Supp * SUB_ICON_MAX;
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Update,, bNoCreate);
	arraySubIcons[iArrayOffset].eWindowCommand  = eWINDOW_COMMAND_LatestVer;
	iArrayOffset++;

	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_About3DRealms,, bNoCreate);
	arraySubIcons[iArrayOffset].eWindowCommand  = eWINDOW_COMMAND_About;
	iArrayOffset++;
}

function CreateIconAndIncrementPosition(out UDukeFakeIcon buttonNew, 
										out float fLocX, out float fLocY,
										eSUB_ICON_TYPE eIconType,
										optional Region regSizeOfNewWin,
										optional bool bNoCreate )	
{
	local Texture texIconToUse;

	texIconToUse = aSubIconTextures[eIconType];
	
	if ( !bNoCreate )
		buttonNew = UDukeFakeIcon(CreateWindow(class'UDukeFakeIcon', fLocX, fLocY, texIconToUse.USize * fOversizeFactor, texIconToUse.VSize * fOversizeFactor, self));
	buttonNew.UpTexture   = texIconToUse;
	buttonNew.DownTexture = texIconToUse;	
	buttonNew.OverTexture = buttonNew.DownTexture;
	buttonNew.GlowTexture = aSubIconTexturesHL[eIconType];
	buttonNew.SetText(aSubIconLabels[eIconType]);

	// Only if a valid region is passed in, set the new buttons winoffset and size member.
	if ( regSizeOfNewWin.W != 0 && regSizeOfNewWin.H != 0 )
		buttonNew.WindowOffsetAndSize = regSizeOfNewWin;
		
	// Set this sub-desktop icon to be invisible by default/initially.
	if ( !bNoCreate )
		buttonNew.HideWindow();
	
	IncrementIconPlacement(buttonNew, fLocX, fLocY);
}

function IncrementIconPlacement( UDukeFakeIcon button, out float fLocX, out float fLocY, optional float fMaxWidth )
{
	fLocX += (button.UpTexture.USize + iIconOffsetX)*WinScaleX;
}

function ToggleButtonsState( int iIconToChange, bool bSelected )
{
	local int i, iEnd;

	i = iIconToChange * SUB_ICON_MAX;
	for ( iEnd = i + SUB_ICON_MAX; i < iEnd; i++ )
	{
		if ( arraySubIcons[i] != None )
		{
			if ( bSelected )
				arraySubIcons[i].ShowWindow();
			else
				arraySubIcons[i].HideWindow();
		}
	}
}

function IconBlur( UDukeButton InButton )
{
	BlurButton = InButton;
	bIconBlur = true;

	/*
	BlurFrame = 0;
	BlurFrameTime = GetLevel().TimeSeconds;
	LastBlurFrameTime = BlurFrameTime;
	*/

	if ( BlurButton.BlurType == 0 )
	{
		BlurTexBigLeft.pause = false;
		BlurTexBigLeft.currentFrame = 0;
		BlurTexBigRight.pause = false;
		BlurTexBigRight.currentFrame = 0;
	}
	else
	{
		BlurTexSmallLeft.pause = false;
		BlurTexSmallLeft.currentFrame = 0;
		BlurTexSmallRight.pause = false;
		BlurTexSmallRight.currentFrame = 0;
	}
}

/*-----------------------------------------------------------------------------
	Rendering
-----------------------------------------------------------------------------*/

function Paint( Canvas C, float MouseX, float MouseY )
{
	local float FlashScale, W, H, OffX, OffY;
	local smackertexture Tex;

	if ( C.ClipX != LastClipX )
	{
		LastClipX = C.ClipX;
		ResolutionChanged( C.ClipX, C.ClipY );
	}

	if ( bFirstPaint )
	{
		StartNukemLogo();
		bFirstPaint = false;
		return;
	}

	if ( bDoing3DRLogo )
		Draw3DRLogo(C);
	else if ( bDoingNukemLogo )
		DrawNukemLogo(C);
	else if ( bDoingBootupSequence )
		DrawBootupSequence(C);
	else if ( bDoingDeathSequence )
		DrawDeathSequence(C);
	else
		DrawBackdrop( C );

	if ( bIconBlur )
	{
		C.Style = 3;
		if ( BlurButton.BlurType == 1 )
			Tex = BlurTexSmallLeft;
		else
			Tex = BlurTexBigLeft;
		/*
		if ( BlurButton.BlurType == 1 )
			Tex = BlurTexSmallLeft[BlurFrame];
		else
			Tex = BlurTexBigLeft[BlurFrame];
		*/
		H = Tex.VSize;
		OffX = BlurButton.WinLeft + 80*WinScaleX;
		OffY = BlurButton.WinTop  + 40*WinScaleY;
		DrawStretchedTexture( C, OffX, OffY, Tex.USize*WinScaleX, Tex.VSize*WinScaleY, Tex, 1.0 );

		OffX += 256 * WinScaleX;
		if ( BlurButton.BlurType == 1 )
			Tex = BlurTexSmallRight;
		else
			Tex = BlurTexBigRight;
		/*
		if ( BlurButton.BlurType == 1 )
			Tex = BlurTexSmallRight[BlurFrame];
		else
			Tex = BlurTexBigRight[BlurFrame];
		*/
		H = Tex.VSize;
		DrawStretchedTexture( C, OffX, OffY, Tex.USize*WinScaleX, Tex.VSize*WinScaleY, Tex, 1.0 );
/*
		if ( GetLevel().TimeSeconds > LastBlurFrameTime + 0.03 )
		{
			LastBlurFrameTime = GetLevel().TimeSeconds;
			BlurFrame++;
			if ( BlurFrame == 3 )
			{
				bIconBlur = false;

				ToggleButtonsState(ICON_Game,  iconDesktop[ICON_Game] == BlurButton);
				ToggleButtonsState(ICON_Sett,  iconDesktop[ICON_Sett] == BlurButton); 
				ToggleButtonsState(ICON_Multi, iconDesktop[ICON_Multi] == BlurButton); 
				ToggleButtonsState(ICON_Supp,  iconDesktop[ICON_Supp] == BlurButton); 
			}
		}
*/

		if ( Tex.currentFrame+1 == Tex.GetFrameCount() )
		{
			bIconBlur = false;

			ToggleButtonsState(ICON_Game,  iconDesktop[ICON_Game] == BlurButton);
			ToggleButtonsState(ICON_Sett,  iconDesktop[ICON_Sett] == BlurButton); 
			ToggleButtonsState(ICON_Multi, iconDesktop[ICON_Multi] == BlurButton); 
			ToggleButtonsState(ICON_Supp,  iconDesktop[ICON_Supp] == BlurButton); 
		}
	}

	if ( !bDoing3DRLogo && !bDoingNukemLogo )
		DrawSunglasses( C, WinWidth  / FullSizeTextureWidth, WinHeight / FullSizeTextureHeight );
}

/*-----------------------------------------------------------------------------
	Tick
-----------------------------------------------------------------------------*/

function Tick(float Delta)
{
	local INT i;

	if ( bDoing3DRLogo )
	{
		if ( aflic3DR[0].currentFrame == 150 )
			End3DRLogo();
	}
	else if ( bDoingNukemLogo )
	{
		if ( aflicNukem[0].currentFrame == 208 )
			EndNukemLogo();
	}
	else if (bDoingBootupSequence)  
	{
		fBootupSequenceTime += Delta;
		if ( fBootupSequenceTime > fBootupSequenceLength )
			fBootFadeFactor -= Delta*2;
		if ( fBootFadeFactor < 0.0 )
			EndBootupSequence();
	}
	else if (bDoingDeathSequence && !bDeathSequenceDone)
	{
		fDeathSequenceTime += Delta;
		if ( fDeathSequenceTime > fDeathSequenceLength )
			EndDeathSequence();
	}
	else if (bCheckForLoopingSound)  
	{
	}
}

/*-----------------------------------------------------------------------------
	Start Up
-----------------------------------------------------------------------------*/

function StartShadesOS()
{
    bHideSunglasses = false;
	if ( DukeConsole(Root.Console).bShowBootup )
		StartBootupSequence();
	else if ( DukeConsole(Root.Console).bShowDeathSequence )
		StartDeathSequence();
	else
	{
		ShowProfileWindow();
		LookAndFeel.PlayMenuSound( Self, MS_MenuEntry );
	}
}

function EndShadesOS()
{
}

/*-----------------------------------------------------------------------------
	3DR Logo Movie
-----------------------------------------------------------------------------*/

function Start3DRLogo()
{
	local int i;

	GetPlayerOwner().PlaySound( LogoSound, SLOT_Interact );
	Root.DontCloseOnEscape = true;
	Root.bAllowConsole = false;
	bDoing3DRLogo = true;
	Root.Console.bDontDrawMouse = true;
	HideIcons();

	aflic3DR[0] = smackertexture(dynamicloadobject("smk7.3drlogo_topleft", class'smackertexture'));
	aflic3DR[1] = smackertexture(dynamicloadobject("smk7.3drlogo_topright", class'smackertexture'));
	aflic3DR[2] = smackertexture(dynamicloadobject("smk7.3drlogo_botleft", class'smackertexture'));
	aflic3DR[3] = smackertexture(dynamicloadobject("smk7.3drlogo_botright", class'smackertexture'));
	for (i=0; i<4; i++)
	{
		aflic3DR[i].currentFrame = 0;
		aflic3DR[i].pause = false;
	}
}

function End3DRLogo( optional bool bForceToEnd )
{
	local int i;

	Root.Console.bDontDrawMouse = false;
	bDoing3DRLogo = false;
	Root.DontCloseOnEscape = false;
	Root.bAllowConsole = true;

	for (i=0; i<4; i++)
	{
		aflic3DR[i].pause = true;
	}

	if ( !bForceToEnd )
		StartBootupSequence();
	else
		ShowProfileWindow();
}

function Draw3DRLogo( Canvas C )
{
	local float		HalfWidth, HalfHeight;
	local byte OldStyle;

	HalfWidth = WinWidth / 2.f;
	HalfHeight= WinHeight/ 2.f;

	C.DrawColor.R = 255; C.DrawColor.G = 255; C.DrawColor.B = 255;

	OldStyle = C.Style;
	C.Style = 1;
	C.SetOrigin( 0, 0 );
	C.SetPos( 0, 0 );
	C.DrawTile( aflic3DR[0], HalfWidth, HalfHeight, 0, 0, 256, 256, , , , true );
	C.SetPos( HalfWidth, 0 );
	C.DrawTile( aflic3DR[1], HalfWidth, HalfHeight, 0, 0, 256, 256, , , , true );
	C.SetPos( 0, HalfHeight );
	C.DrawTile( aflic3DR[2], HalfWidth, HalfHeight, 0, 0, 256, 256, , , , true );
	C.SetPos( HalfWidth, HalfHeight );
	C.DrawTile( aflic3DR[3], HalfWidth, HalfHeight, 0, 0, 256, 256, , , , true );
	C.Style = OldStyle;
}

/*-----------------------------------------------------------------------------
	Nukem Logo Movie
-----------------------------------------------------------------------------*/

function StartNukemLogo()
{
	local int i;

	bDoingNukemLogo = true;
	Root.DontCloseOnEscape = true;
	Root.bAllowConsole = false;
	Root.Console.bDontDrawMouse = true;
	HideIcons();

	aflicNukem[0] = smackertexture'smk7.nuke_topleft';
	aflicNukem[1] = smackertexture'smk7.nuke_topright';
	aflicNukem[2] = smackertexture'smk7.nuke_botleft';
	aflicNukem[3] = smackertexture'smk7.nuke_botright';
	for ( i=0; i<4; i++ )
	{
		aflicNukem[i].currentFrame = 0;
		aflicNukem[i].pause = false;
	}
}

function EndNukemLogo( optional bool bForceToEnd )
{
	local int i;

	Root.Console.bDontDrawMouse = false;
	bDoingNukemLogo = false;
	Root.DontCloseOnEscape = false;
	Root.bAllowConsole = true;

	for (i=0; i<4; i++)
	{
		aflicNukem[i].pause = true;
	}

	if ( !bForceToEnd )
		Start3DRLogo();
	else
		ShowProfileWindow();
}

function DrawNukemLogo( Canvas C )
{
	local float		HalfWidth, HalfHeight;
	local byte OldStyle;

	HalfWidth = WinWidth / 2.f;
	HalfHeight= WinHeight/ 2.f;

	C.DrawColor.R = 255; C.DrawColor.G = 255; C.DrawColor.B = 255;

	OldStyle = C.Style;
	C.Style = 1;
	C.SetOrigin( 0, 0 );
	C.SetPos( 0, 0 );
	C.DrawTile( aflicNukem[0], HalfWidth, HalfHeight, 0, 0, 256, 256, , , , true );
	C.SetPos( HalfWidth, 0 );
	C.DrawTile( aflicNukem[1], HalfWidth, HalfHeight, 0, 0, 256, 256, , , , true );
	C.SetPos( 0, HalfHeight );
	C.DrawTile( aflicNukem[2], HalfWidth, HalfHeight, 0, 0, 256, 256, , , , true );
	C.SetPos( HalfWidth, HalfHeight );
	C.DrawTile( aflicNukem[3], HalfWidth, HalfHeight, 0, 0, 256, 256, , , , true );
	C.Style = OldStyle;
}

/*-----------------------------------------------------------------------------
	SOS Boot Movie
-----------------------------------------------------------------------------*/

function StartBootupSequence()
{
	local int i;

	if (DukeConsole(Root.Console).bShowBootup)  
	{
		DukeConsole(Root.Console).bShowBootup = false;
		bDoingBootupSequence = true;
		Root.Console.bDontDrawMouse = true;
		fBootFadeFactor = 1.0;
		HideIcons();

		// Load the flics
		aflicBootup[0] = SmackerTexture'SMK3.s_intro_tleft';
		aflicBootup[1] = SmackerTexture'SMK3.s_intro_tright';
		aflicBootup[2] = SmackerTexture'SMK3.s_intro_bleft';
		aflicBootup[3] = SmackerTexture'SMK3.s_intro_bright';
		for (i=0; i<4; i++)
		{
			aflicBootup[i].currentFrame = 0;
			aflicBootup[i].pause = false;
		}

		// After the flics are loaded, reset the time.
		fBootupSequenceTime = 0.0f;
	}
	else
		EndBootupSequence();
}

function EndBootupSequence()
{
	local int i;

	Root.Console.bDontDrawMouse = false;
	bDoingBootupSequence = false;
	Root.DontCloseOnEscape = false;
	Root.bAllowConsole = true;
	//StartUpAnimationEnded();

	ShowProfileWindow();

	for (i=0; i<4; i++)
	{
		aflicBootup[i].pause = true;
	}
}

function DrawBootupSequence(Canvas C)
{
	local float		fHalfWidth,	fHalfHeight;	// Half screen extents.
	local int		iQuadBias, i;				// Used to correct image bleeding.

	fHalfWidth  = WinWidth  * 0.5f;
	fHalfHeight = WinHeight * 0.5f;	
	
	C.DrawColor.R = 255 * fBootFadeFactor;
	C.DrawColor.G = 255 * fBootFadeFactor;
	C.DrawColor.B = 255 * fBootFadeFactor;

	iQuadBias = 3;

	// Draw the topleft section of the quad.
	DrawStretchedTextureSegment(C, -iQuadBias, 0, fHalfWidth+iQuadBias, fHalfHeight, 
						 		0, 64, aflicBootup[0].USize, aflicBootup[0].VSize - 64,
						 		aflicBootup[0], 1.0f, true, true );
	
	// Draw the topright section of the quad
	DrawStretchedTextureSegment(C, fHalfWidth, 0, fHalfWidth+iQuadBias, fHalfHeight, 
						 		0, 64, aflicBootup[1].USize, aflicBootup[1].VSize - 64,
								aflicBootup[1], 1.0f, true, true );

	// Draw the bottomleft section of the quad
	DrawStretchedTextureSegment(C, -iQuadBias, fHalfHeight, fHalfWidth+iQuadBias, fHalfHeight, 
						 		0, 0, aflicBootup[2].USize, aflicBootup[2].VSize - 64,
						 		aflicBootup[2], 1.0f, true, true );

	// Draw the bottomright section of the quad
	DrawStretchedTextureSegment(C, fHalfWidth, fHalfHeight, fHalfWidth+iQuadBias, fHalfHeight, 
						 		0, 0, aflicBootup[3].USize, aflicBootup[3].VSize - 64,
						 		aflicBootup[3], 1.0f, true, true );

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}

/*-----------------------------------------------------------------------------
	Game Over Movie
-----------------------------------------------------------------------------*/

function StartDeathSequence()
{
	local int i;

	Root.DontCloseOnEscape = true;
	Root.bAllowConsole = false;

	GetPlayerOwner().PlaySound( DeathSequenceSound, SLOT_Interact );
	bDoingDeathSequence = true;
	Root.Console.bDontDrawMouse = true;
	fBootFadeFactor = 1.0;
	HideIcons();

	// Create the game over buttons.
	if ( ContinueButton == None )
		ContinueButton = UDukeMissionOverButton(CreateWindow(class'UDukeMissionOverButton', 0, 0, 0, 0, Self));
	ContinueButton.bSolid = true;
	ContinueButton.bStretched = true;
	ContinueButton.WinLeft = 31 * (WinWidth/1024.f) * 2.0;
	ContinueButton.WinTop = 278 * (WinHeight/768.f) * 1.6666;
	ContinueButton.SetSize( texture'hud_effects.missionover.mover_continue'.USize * (WinWidth/1024.f) * 2.0, texture'hud_effects.missionover.mover_continue'.VSize * (WinHeight/768.f) * 1.66666 );
	ContinueButton.HideWindow();
	ContinueButton.Desktop = Self;

	if ( QuitButton == None )
		QuitButton = UDukeMissionOverButton(CreateWindow(class'UDukeMissionOverButton', 0, 0, 0, 0, Self));
	QuitButton.bSolid = true;
	QuitButton.bStretched = true;
	QuitButton.WinLeft = 287 * (WinWidth/1024.f) * 2.0;
	QuitButton.WinTop = 278 * (WinHeight/768.f) * 1.6666;
	QuitButton.SetSize( texture'hud_effects.missionover.mover_quit'.USize * (WinWidth/1024.f) * 2.0, texture'hud_effects.missionover.mover_quitHL'.VSize * (WinHeight/768.f) * 1.6666 );
	QuitButton.HideWindow();
	QuitButton.Desktop = Self;

	for (i=0; i<4; i++)
	{
		aflicDeath[i].currentFrame = 0;
		aflicDeath[i].pause = false;
		aflicDeath[i].loop = false;
	}
	fDeathSequenceTime = 0.0f;
	bDeathSequenceDone = false;
}

function EndDeathSequence()
{
	local int i;

	Root.Console.bDontDrawMouse = false;

	ContinueButton.ShowWindow();
	QuitButton.ShowWindow();
	bDeathSequenceDone = true;

//	ShowProfileWindow();

	for (i=0; i<4; i++)
	{
		aflicDeath[i].pause = true;
	}
}

function DrawDeathSequence(Canvas C)
{
	local float		fHalfWidth,	fHalfHeight;	// Half screen extents.
	local int		iQuadBias, i;				// Used to correct image bleeding.
	local texture   Tex;
	local bool		bOldSmooth;

	fHalfWidth  = WinWidth  * 0.5f;
	fHalfHeight = WinHeight * 0.5f;	
	
	C.DrawColor.R = 255 * fBootFadeFactor;
	C.DrawColor.G = 255 * fBootFadeFactor;
	C.DrawColor.B = 255 * fBootFadeFactor;

	bOldSmooth = C.bNoSmooth;

	iQuadBias = 3;

	// Draw the topleft section of the quad.
	DrawStretchedTextureSegment(C, -iQuadBias, 0, fHalfWidth+iQuadBias, fHalfHeight, 
						 		0, 64, aflicDeath[0].USize, aflicDeath[0].VSize - 64,
						 		aflicDeath[0], 1.0f, true, true );

	// Draw the topright section of the quad
	DrawStretchedTextureSegment(C, fHalfWidth, 0, fHalfWidth+iQuadBias, fHalfHeight, 
						 		0, 64, aflicDeath[1].USize, aflicDeath[1].VSize - 64,
								aflicDeath[1], 1.0f, true, true );

	// Draw the bottomleft section of the quad
	DrawStretchedTextureSegment(C, -iQuadBias, fHalfHeight, fHalfWidth+iQuadBias, fHalfHeight, 
						 		0, 0, aflicDeath[2].USize, aflicDeath[2].VSize - 64,
						 		aflicDeath[2], 1.0f, true, true );

	// Draw the bottomright section of the quad
	DrawStretchedTextureSegment(C, fHalfWidth, fHalfHeight, fHalfWidth+iQuadBias, fHalfHeight, 
						 		0, 0, aflicDeath[3].USize, aflicDeath[3].VSize - 64,
						 		aflicDeath[3], 1.0f, true, true );

	// Draw the continue button.
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.Style = 1;
	C.bNoSmooth = false;
	if ((ContinueButton != None) && ContinueButton.bWindowVisible)
	{
		if (ContinueButton.UseOverTexture())
			Tex = texture'hud_effects.missionover.mover_continueH';
		else
			Tex = texture'hud_effects.missionover.mover_continue';
		DrawStretchedTextureSegment(C, ContinueButton.WinLeft, ContinueButton.WinTop, 
			ContinueButton.WinWidth, ContinueButton.WinHeight, 
			0, 0, Tex.USize, Tex.VSize, Tex, 1.0, true, true );
	}
	if ((QuitButton != None) && QuitButton.bWindowVisible)
	{
		if (QuitButton.UseOverTexture())
			Tex = texture'hud_effects.missionover.mover_quitHL';
		else
			Tex = texture'hud_effects.missionover.mover_quit';
		DrawStretchedTextureSegment(C, QuitButton.WinLeft, QuitButton.WinTop, 
			QuitButton.WinWidth, QuitButton.WinHeight, 
			0, 0, Tex.USize, Tex.VSize, Tex, 1.0, true, true );
	}
	C.bNoSmooth = bOldSmooth;

	// Draw the scanlines.
	C.SetClampMode( false );
	C.Style = 4;
	C.SetPos(0, 0);
	if (WinWidth <= 1024)
		C.DrawPattern(texture'hud_effects.scanlines.nightlines1BC', WinWidth, WinHeight, 4.0);
	else
		C.DrawPattern(texture'hud_effects.scanlines.nightlines1BC', WinWidth, WinHeight, 2.0);
	C.Style = 4;
	C.SetClampMode( true );

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}

function DeathButtonEvent(UWindowDialogControl C, byte E)
{
	if ( E == DE_Click )
	{
		if ( C == ContinueButton )
			ContinueClicked();
		else if ( C == QuitButton )
			QuitClicked();
	}
}

function ContinueClicked()
{
	Root.DontCloseOnEscape = false;
	Root.bAllowConsole = true;
	DukeConsole(Root.Console).bShowDeathSequence = false;
	DukeConsole(Root.Console).bShowBootup = false;
	bDoingBootupSequence = false;
	bDoingDeathSequence = false;
	bDoingLevelStartSequence = false;
	ContinueButton.HideWindow();
	QuitButton.HideWindow();
	Root.Console.bCloseForSureThisTime = true;
	Root.Console.CloseUWindow();
	GetPlayerOwner().ConsoleCommand( "restartlevel" );
}

function QuitClicked()
{
	Root.DontCloseOnEscape = false;
	Root.bAllowConsole = true;
	DukeConsole(Root.Console).bShowDeathSequence = false;
	DukeConsole(Root.Console).bShowBootup = false;
	ContinueButton.HideWindow();
	QuitButton.HideWindow();
	bDoingBootupSequence = false;
	bDoingDeathSequence = false;
	bDoingLevelStartSequence = false;
	ShowIcons();
	GetPlayerOwner().ClientTravel("entry?nologo", TRAVEL_Absolute, false);
}

/*-----------------------------------------------------------------------------
	Background
-----------------------------------------------------------------------------*/

function DrawBackdrop( Canvas C )
{
	local float PieceWidth, PieceHeight, X, Y;
	local int i, j, k;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;

	PieceWidth = WinWidth / BackgroundTileCountH;
	PieceHeight= WinHeight / BackgroundTileCountV;

	X = 0;
	Y = 0;
	for ( i=0; i<BackgroundTileCountH; i++ )
	{
		Y = 0;
		for ( j=0; j<BackgroundTileCountV; j++ )
		{
			DrawStretchedTextureSegment( C, X, Y, PieceWidth, PieceHeight, 0, 0, Backdrop[k].USize, Backdrop[k].VSize, Backdrop[k], 1.f, true, true );
			Y += PieceHeight;
			k++;
		}
		X += PieceWidth;
	}
}

/*-----------------------------------------------------------------------------
	Sunglasses
-----------------------------------------------------------------------------*/

function DrawSunglasses( Canvas C, float fTextureSizeRatioX, float fTextureSizeRatioY, optional bool bForce )
{	
	local float	HalfWidth,	HalfHeight;
	local float	SizeX, SizeY;
	local Texture T;
	
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	HalfWidth  = WinWidth  * 0.5f;
	HalfHeight = WinHeight * 0.5f;	

	if ( bHideSunglasses && !bForce )
		return;

	// Draw the topleft section of the quad.
	C.Style = 2;
	T = texSunglasses[0];
	SizeX = T.USize * fTextureSizeRatioX;
	SizeY = T.VSize * fTextureSizeRatioY;
	DrawStretchedTexture( C, 0, 0, SizeX, SizeY, T, 1.0f );

	C.Style = 3;
	T = texSunglassesGlow[0];
	DrawStretchedTexture( C, 0, 0, HalfWidth, HalfHeight, T, 1.0f );

	// Draw the topright section of the quad.
	C.Style = 2;
	T = texSunglasses[1];
	SizeX = T.USize * fTextureSizeRatioX;
	SizeY = T.VSize * fTextureSizeRatioY;
	DrawStretchedTexture( C, WinWidth - SizeX, 0, SizeX, SizeY, T, 1.0f );

	C.Style = 3;
	T = texSunglassesGlow[1];
	DrawStretchedTexture( C, HalfWidth, 0, HalfWidth, HalfHeight, T, 1.0f );

	// Draw the bottomleft section of the quad.
	C.Style = 2;
	T = texSunglasses[2];
	SizeX = T.USize * fTextureSizeRatioX;
	SizeY = T.VSize * fTextureSizeRatioY;
	DrawStretchedTexture( C, 0, WinHeight - SizeY, SizeX, SizeY, T, 1.0f );

	C.Style = 3;
	T = texSunglassesGlow[2];
	DrawStretchedTexture( C, 0, HalfHeight, HalfWidth, HalfHeight, T, 1.0f );

	// Draw the bottomright section of the quad.
	C.Style = 2;
	T = texSunglasses[3];
	SizeX = T.USize * fTextureSizeRatioX;
	SizeY = T.VSize * fTextureSizeRatioY;
	DrawStretchedTexture( C, WinWidth - SizeX, WinHeight - SizeY, SizeX, SizeY, T, 1.0f );

	C.Style = 3;
	T = texSunglassesGlow[3];
	DrawStretchedTexture( C, HalfWidth, HalfHeight, HalfWidth, HalfHeight, T, 1.0f );
}

/*-----------------------------------------------------------------------------
	Profile Window
-----------------------------------------------------------------------------*/

function HideProfileWindow()
{
	if ( ProfileWindow != None )
		ProfileWindow.HideWindow();
	ShowIcons();
}

function ShowProfileWindow(optional bool Force)
{
	local float					LWinWidth, LWinHeight, LWinPosX, LWinPosY;

	if (!Force && GetPlayerOwner().GetCurrentPlayerProfile() != "")
	{
		HideProfileWindow();
		return;		// No need
	}

	if (ProfileWindow != None)
	{
		ProfileWindow.ShowWindow();		// Already created, just show it again
		return;
	}

	//
	//	Create the ProfileWindow for the first time
	//

	// Set Width/Height
	LWinWidth = 420;
	LWinHeight = 240;

	// Center the LoginScreen
	LWinPosX = (WinWidth*0.5f)-(LWinWidth*0.5f);
	LWinPosY = (WinHeight*0.3f);

	ProfileWindow = UDukeProfileWindow(	Root.CreateWindow(class'UDukeProfileWindow', LWinPosX, LWinPosY, LWinWidth, LWinHeight, self) );
}

/*-----------------------------------------------------------------------------
	UWindow
-----------------------------------------------------------------------------*/

function HideIcons()
{
	local int i;
	
	if (!bIconsHidden) 
	{
		bIconsHidden = true;
	
		for (i=0; i<ICON_MAX * SUB_ICON_MAX; i++)
		{
			if (i<ICON_MAX)
				iconDesktop[i].HideWindow();
			if(arraySubIcons[i] != None)
				arraySubIcons[i].HideWindow();
		}
	}
}

function ShowIcons()
{
	local int i;

	if ( bIconsHidden )
	{
		bIconsHidden = false;
		for ( i=0; i<ICON_MAX; i++ )
		{
			// Show the icons, and reset the default text, so it cycles again.
			iconDesktop[i].ShowWindow(); 
		}		
	}
}

defaultproperties
{
    bCheckForLoopingSound=True
    aSubIconLabels(0)="New Game"
    aSubIconLabels(1)="Save Game"
    aSubIconLabels(2)="Load Game"
    aSubIconLabels(3)="Profile"
    aSubIconLabels(4)="Quit Game"
    aSubIconLabels(5)="Video"
    aSubIconLabels(6)="Audio"
    aSubIconLabels(7)="Game"
    aSubIconLabels(8)="Controls"
    aSubIconLabels(9)="SOS"
    aSubIconLabels(10)="Find Game"
    aSubIconLabels(11)="Create Game"
    aSubIconLabels(12)="Player Setup"
    aSubIconLabels(13)="Latest Version"
    aSubIconLabels(14)="About 3D Realms"
    bFirstPaint=true
    fBootupSequenceLength=12.500000
    fBootFadeFactor=1.0
    fDeathSequenceLength=4.3
    fOversizeFactor=1.500000
    iIconOffsetX=48
    iIconOffsetY=32
    fNumFramesToAccomplishSlide=10.000000
    ShowHelp=True
    regGame_NewGame=(X=200,Y=200,W=450,H=360)
    regGame_SaveGame=(X=200,Y=200,W=550,H=400)
    regGame_LoadGame=(X=200,Y=200,W=550,H=400)
    regGame_BotmatchWindow=(X=200,Y=200,W=350,H=200)
    regMulti_FindGame=(X=200,Y=200,W=640,H=480)
    regMulti_CreateGame=(X=200,Y=200,W=620,H=480)
    regMulti_PlayerSetup=(X=200,Y=200,W=640,H=480)
    regSett_Video=(X=240,W=520,H=500)
    regSett_Game=(X=240,Y=100,W=520,H=330)
    regSett_Audio=(X=240,Y=50,W=520,H=280)
    regSett_Controls=(X=240,W=470,H=490)
    regSett_SOS=(X=240,W=520,H=460)
    DeathSequenceSound=sound'a_generic.missionover.MissionOver05a'
	Logosound=sound'a_generic.logo.3drlogo01'
	ThemePackage="mtheme_cobaltblue"
	ThemeTranslucentIcons=true
	BackgroundSmack="true"
	BackgroundTileCountH=2
	BackgroundTileCountV=2
	BackgroundTiles[0]="mtheme_cobaltblue.mback_topleft"
	BackgroundTiles[1]="mtheme_cobaltblue.mback_botleft"
	BackgroundTiles[2]="mtheme_cobaltblue.mback_topright"
	BackgroundTiles[3]="mtheme_cobaltblue.mback_botright"
}
