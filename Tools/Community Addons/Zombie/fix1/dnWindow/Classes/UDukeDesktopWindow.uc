//==========================================================================
// 
// FILE:			UDukeDesktopWindow.uc
// 
// AUTHOR:			Timothy L. Weisser (lots o' changes by Brandon Reinhart)
// 
// DESCRIPTION:		Expansion of UTs root menuing system
// 
// NOTES:			Similate a Win9x interface, with clickable icons to execute
//					commands or open submenus instead of drop-down menus, 
//					and other Shades Operating System animations and functionality
//  
// MOD HISTORY: 
//	2000-02-01		Added the bootup sequence as the first animation that is
//					played when the game starts (given that the Entry level's 
//					GameInfo type = DukeIntro). DukeIntro should launch the 
//					UWindowSystem right away, and then the first time UDukeDesktopWindow
//					Paints, the SOS bootup sequence flics should go
// 
//==========================================================================
class UDukeDesktopWindow expands UDukeDesktopWindowBase;

#exec OBJ LOAD FILE=..\Textures\SMK3.dtx
#exec OBJ LOAD FILE=..\Textures\SMK7.dtx
#exec OBJ LOAD FILE=..\Sounds\a_generic.dfx
#exec AUDIO IMPORT NAME=WindowClick FILE=SOUNDS\click4.wav GROUP=dnWindow

const ICON_Game  = 0;
const ICON_Sett  = 1;
const ICON_Multi = 2;
const ICON_Supp  = 3;
const ICON_MAX	 = 4;							// Max number of icons on the main desktop.
const SUB_ICON_MAX = 8;							// Max number of subicons under the main desktop one.

//used for keyboard selection of desktop icons
enum eICON_SELECT_TYPE  {
	eICON_SELECT_UP,
	eICON_SELECT_DOWN,
	eICON_SELECT_LEFT,
	eICON_SELECT_RIGHT,
	eICON_SELECT_MAX
};

//icons that come out of the main/desktop icons, like a sub/dropdown
enum eSUB_ICON_TYPE  {
	// Game
	eSUB_ICON_NewGame,
	eSUB_ICON_SaveGame, 
	eSUB_ICON_LoadGame, 
//	eSUB_ICON_ReturnToGame, 
	eSUB_ICON_Profile, 
	eSUB_ICON_QuitGame, 
	
	// Multi
    eSUB_ICON_LanGames,
    eSUB_ICON_DukeNet,
	eSUB_ICON_OpenLocation,
    eSUB_ICON_PlayerSetup,

	// Settings
	eSUB_ICON_Video, 
	eSUB_ICON_Audio, 
	eSUB_ICON_Game, 
	eSUB_ICON_Controls, 
	eSUB_ICON_SOS,
	eSUB_ICON_ParentControl,
	
	// About
	eSUB_ICON_Update, 
	eSUB_ICON_About3DRealms,
	eSUB_ICON_FunStuff, 
	
	eSUB_ICON_MAX
};

// Direction of fade animation for the Shades OS, happens when exiting or entering.
const SUNGLASS_ANIM_DIRECTION_IN 	 = -1;
const SUNGLASS_ANIM_DIRECTION_STEADY =  0;
const SUNGLASS_ANIM_DIRECTION_OUT	 =  1;
	
var bool bCheckForLoopingSound;					// Checks icons for text cycle, and plays looping sound if appropriate.
var float fLengthOfLoopedSound;					// How long the looping sound is.
var float fTimeSinceLoopedSoundStarted;			// Length of time since the looping sound was started.

var bool bIconsHidden;							// Used to fend of re-entering show/hide of icons.
var	UDukeFakeIcon iconDesktop[5];				// [ICON_MAX];  

var UDukeFakeIcon arraySubIcons[40];			// [ICON_MAX * SUB_ICON_MAX]; 
var() localized string aSubIconLabels[22];		// [eSUB_ICON_TYPE.eSUB_ICON_MAX];
var() string aSubIconTextures[22];				// [eSUB_ICON_TYPE.eSUB_ICON_MAX];

var Texture	texSunglasses[4];					// TLW: I'd put this in an enum, but those don't work to access arrays.
												// 0 = TL of picture
												// 1 = TR of picture
												// 2 = BL of picture
												// 3 = BR of picture
var Texture	texSunglassesGlow[4];
var SmackerTexture flicWallpaper;				// Flic that plays over desktop wallpaper.
var Texture	texWallpaper[12];					// Desktop wallpaper.

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

// Bootup Sequence
var bool bFirstPaint;							// Flag for holding off starting the SOS bootup till all things are loaded.
var bool bDoingBootupSequence;					// Flag for drawing and incrementing time.
var float fBootupSequenceTime;					// How much time has passed since the bootupsequence started.
var() float fBootupSequenceLength;				// How long the bootupsequence should run for.
var float fBootFadeFactor;						// Amount to fade the boot flic to black.
var float fDesktopFadeFactor;					// Amount to fade the desktop from black.
var bool bFadeInDesktop;						// Indicates we are fading in the desktop.
var bool bDoingLevelStartSequence;
var float StartLevelCount;
var SmackerTexture aflicBootup[4];				// Flic that plays in the background for boot.
												// 0 = TL of picture
												// 1 = TR of picture
												// 2 = BL of picture
												// 3 = BR of picture

var float LastClipX;
var float fLocationX;							// Used for lining up the left side of the desktop icons
var float fLocationY[5];						// [ICON_MAX]; Placement of the top of the desktop icons on.

const FullSizeTextureWidth  = 1024;				// 256x256 texture squares for glide/hardware acceleration
const FullSizeTextureHeight = 768;				//	that were created for this screen res

var() float fOversizeFactor;					// Oversize all the desktop icons to make room for 2D animations.
var() int iIconOffsetX;							// Offset for spacing out the sub-icons from the main ones.
var() int iIconOffsetY;							//  "
var() float fNumFramesToAccomplishSlide;		// Simple anim count so all icons come out the same # frames.
var   int iSunglassAnimDir;						// Animation direction for fading SOS in and out.
var() int iNumFramesToBringUpSunglasses;		// Animation frame # for fading SOS in and out.
var   bool bHideSunglasses;                     // Hide the sunglasses

//var() config string BrowserClassName;
var() config bool ShowHelp;						// Flag for showing menubar help or not.

// Regions for windows opened by the desktop icons.
var(ExplorerSizes) Region regGame_BotmatchWindow;
var(ExplorerSizes) Region regMulti_DukeNet;
var(ExplorerSizes) Region regMulti_LANGames;
var(ExplorerSizes) Region regMulti_PlayerSetup;
var(ExplorerSizes) Region regSett_Video;
var(ExplorerSizes) Region regSett_Game;
var(ExplorerSizes) Region regSett_Audio;
var(ExplorerSizes) Region regSett_Controls;
var(ExplorerSizes) Region regSett_SOS;

// Game Over Buttons
var UDukeMissionOverButton ContinueButton;
var UDukeMissionOverButton QuitButton;

var sound DeathSequenceSound;

var UDukeProfileWindow	ProfileWindow;

function Created() 
{
	local Texture texIconGame;
	local Texture texIconMultiplayer;
	local Texture texIconSetup;
	local Texture texIconSupport;

	bAlwaysBehind = true;	// Makes this window always at the bottom of the z-order, but above parent...?

	texSunglasses[0]	= Texture(DynamicLoadObject("hud_effects.mainmenu.sunglassesTL", class'Texture'));
	texSunglasses[1]	= Texture(DynamicLoadObject("hud_effects.mainmenu.sunglassesTR", class'Texture'));
	texSunglasses[2]	= Texture(DynamicLoadObject("hud_effects.mainmenu.sunglassesBL", class'Texture'));
	texSunglasses[3]	= Texture(DynamicLoadObject("hud_effects.mainmenu.sunglassesBR", class'Texture'));

	texSunglassesGlow[0]= Texture(DynamicLoadObject("hud_effects.mainmenu.sunglassesTLglo", class'Texture'));
	texSunglassesGlow[1]= Texture(DynamicLoadObject("hud_effects.mainmenu.sunglassesTRglo", class'Texture'));
	texSunglassesGlow[2]= Texture(DynamicLoadObject("hud_effects.mainmenu.sunglassesBLglo", class'Texture'));
	texSunglassesGlow[3]= Texture(DynamicLoadObject("hud_effects.mainmenu.sunglassesBRglo", class'Texture'));

	texWallpaper[0]		= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_top1", class'Texture'));
	texWallpaper[1]		= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_top2", class'Texture'));
	texWallpaper[2]		= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_top3", class'Texture'));
	texWallpaper[3]		= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_top4", class'Texture'));

	texWallpaper[4]		= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_middle1", class'Texture'));
	texWallpaper[5]		= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_middle2", class'Texture'));
	texWallpaper[6]		= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_middle3", class'Texture'));
	texWallpaper[7]		= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_middle4", class'Texture'));

	texWallpaper[8]		= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_bottom1", class'Texture'));
	texWallpaper[9]		= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_bottom2", class'Texture'));
	texWallpaper[10]	= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_bottom3", class'Texture'));
	texWallpaper[11]	= Texture(DynamicLoadObject("DukeLookAndFeel.menubk_bottom4", class'Texture'));

	aflicDeath[0]		= SmackerTexture'hud_effects.missionover.mover_tleft';
	aflicDeath[1]		= SmackerTexture'hud_effects.missionover.mover_tright';
	aflicDeath[2]		= SmackerTexture'hud_effects.missionover.mover_bleft';
	aflicDeath[3]		= SmackerTexture'hud_effects.missionover.mover_bright';

	flicWallpaper		= SmackerTexture(DynamicLoadObject("SMK3.s_igreenletters2", class'SmackerTexture'));
	texIconGame			= Texture(DynamicLoadObject("menutheme1.iconbig_game", class'Texture'));
	texIconMultiplayer	= Texture(DynamicLoadObject("menutheme1.iconbig_multiplayer", class'Texture'));
	texIconSetup		= Texture(DynamicLoadObject("menutheme1.iconbig_settings", class'Texture'));
	texIconSupport		= Texture(DynamicLoadObject("menutheme1.iconbig_support", class'Texture'));

	// Start in the center, minus the (icon sizes + spacing between).
	CalculateIconPlacement(WinWidth, WinHeight, texIconGame.VSize);
	
	// Setup buttons/icons.
	CreateIconsForGameIconString(texIconGame);
	CreateIconsForSettingsIconString(texIconSetup);
	CreateIconsForMultiplayerIconString(texiconMultiplayer);
	CreateIconsForSupportIconString(texIconSupport);
	
	// Load LookAndFeel textures, if not already loaded.
	if(	LookAndFeel.Active == None) 
		LookAndFeel.Active = Texture(DynamicLoadObject("DukeLookAndFeel.DukeActiveFrame", class'Texture'));
	if( LookAndFeel.ActiveS == None)  
		LookAndFeel.ActiveS = Texture(DynamicLoadObject("DukeLookAndFeel.DukeActiveFrmSt", class'Texture'));
	
	if( LookAndFeel.InActive == None)  
		LookAndFeel.InActive = Texture(DynamicLoadObject("DukeLookAndFeel.DukeInActiveFrm", class'Texture'));
	if (LookAndFeel.InActiveS == None)  
		LookAndFeel.InActiveS = Texture(DynamicLoadObject("DukeLookAndFeel.DukeInActiveFrS", class'Texture'));
	
	DukeConsole(Root.Console).bShowBootup = true;	// Just do the first time for right now.

	DukeConsole(Root.Console).Desktop = Self;
}

function StartSunglassesAnimation()
{
	//Hide all the icons, until sunglass animation is done.
	HideIcons();
	iSunglassAnimDir = SUNGLASS_ANIM_DIRECTION_IN;
	iNumFramesToBringUpSunglasses = default.iNumFramesToBringUpSunglasses;	//should already equal?
}

function EndSunglassesAnimation()
{
	// Hide all the icons, until sunglass animation is done.
	HideIcons();
	iSunglassAnimDir = SUNGLASS_ANIM_DIRECTION_OUT;
	iNumFramesToBringUpSunglasses = 0;

	//Hide the help bar if there is one
	if(	UDukeRootWindow(Root) != None && UDukeRootWindow(Root).StatusBar != None )
		UDukeRootWindow(Root).StatusBar.HideWindow();
}

function CalculateIconPlacement(float fNewWidth, float fNewHeight, float fIconHeight)
{
	local float fIconOffsetY;
	
	// All aligned on the left side.
	fLocationX = fNewWidth * 0.1;
	
	// Figure out the placement of the two icons above the center one.
	fLocationY[0] = (fNewHeight * 0.20) - (fIconHeight * 0.5);
	fLocationY[1] = (fNewHeight * 0.40) - (fIconHeight * 0.5);	//0.35);

	// Set the center icon.
//	fLocationY[2] = (fNewHeight * 0.5) - (fIconHeight * 0.5);

	// Figure out the placement of the two icons below the center one.
	fLocationY[2] = (fNewHeight * 0.60) - (fIconHeight * 0.5);	//0.65);
	fLocationY[3] = (fNewHeight * 0.80) - (fIconHeight * 0.5);
}

function ResolutionChanged(float W, float H)
{
	local int i, j;
	local float LocationX, LocationY;
	local float smalliconW, iconW, iconH;

	Super.ResolutionChanged(W, H);

	CalculateIconPlacement(W, H, iconDesktop[ICON_Game].UpTexture.VSize);

	if (ContinueButton != None)
	{
		ContinueButton.WinLeft = 31 * (WinWidth/1024.f) * 2.0;
		ContinueButton.WinTop = 278 * (WinHeight/768.f) * 1.6666;
		ContinueButton.SetSize( ContinueButton.UpTexture.USize * (WinWidth/1024.f) * 2.0, ContinueButton.UpTexture.VSize * (WinHeight/768.f) * 1.66666 );
	}
	if (QuitButton != None)
	{
		QuitButton.WinLeft = 287 * (WinWidth/1024.f) * 2.0;
		QuitButton.WinTop = 278 * (WinHeight/768.f) * 1.6666;
		QuitButton.SetSize( QuitButton.UpTexture.USize * (WinWidth/1024.f) * 2.0, QuitButton.UpTexture.VSize * (WinHeight/768.f) * 1.6666 );
	}

	for ( i=ICON_Game; i<ICON_MAX; i++ )
	{
		smalliconW = arraySubIcons[0].UpTexture.USize + 32*(W/1024);
		iconW = iconDesktop[i].UpTexture.USize * (W/1024);
		iconH = iconDesktop[i].UpTexture.VSize * (H/768);

		iconDesktop[i].WinLeft = fLocationX;
		iconDesktop[i].WinTop  = fLocationY[i];
		iconDesktop[i].SetSize(iconW, iconH*1.5);
		
		LocationX = iconDesktop[i].WinLeft + iconDesktop[i].WinWidth + iIconOffsetX + 16*(W/1024);
		LocationY = iconDesktop[i].WinTop;
		for ( j=0; j<SUB_ICON_MAX; j++ )
		{
			if ( arraySubIcons[i*SUB_ICON_MAX+j] == None )
				break;
			arraySubIcons[i*SUB_ICON_MAX+j].WinLeft = LocationX;
			arraySubIcons[i*SUB_ICON_MAX+j].fLocationDesired_X = LocationX;
			arraySubIcons[i*SUB_ICON_MAX+j].WinTop  = LocationY + iconH*0.333; 
			arraySubIcons[i*SUB_ICON_MAX+j].SetSize(smalliconW, iconH*1.5);
			IncrementIconPlacement(arraySubIcons[i*SUB_ICON_MAX+j], LocationX, LocationY, W);
		}
	}
}

function CreateIconsForGameIconString(Texture texIconGame)
{
	local float fLocX, fLocY;
	local float iconW, iconH;
	local int iArrayOffset;

	iconW = texIconGame.USize * (Root.WinWidth/1024);
	iconH = texIconGame.VSize * (Root.WinHeight/768);
	iconDesktop[ICON_Game] = 
		UDukeFakeIcon(CreateWindow( class'UDukeFakeIcon', fLocationX, 
									fLocationY[ICON_Game], iconW, iconH*1.5, self));
	iconDesktop[ICON_Game].CannotClick = true;
	iconDesktop[ICON_Game].UpTexture   = texIconGame;
	iconDesktop[ICON_Game].DownTexture = texIconGame;
	iconDesktop[ICON_Game].OverTexture = texIconGame;
//	iconDesktop[ICON_Game].classExplorer = class'UDukeFakeExplorerWindow';
//	iconDesktop[ICON_Game].eTypeOfExplorerToCreate = eEXPLORER_Game;
	iconDesktop[ICON_Game].bDesktopIcon = true;
	iconDesktop[ICON_Game].SetText("Game");
	iconDesktop[ICON_Game].TextY = texIconGame.VSize;
	iconDesktop[ICON_Game].Align = TA_Center;

	// Start to the right of the main icon, and tile across and down.
	fLocX = iconDesktop[ICON_Game].WinLeft + iconDesktop[ICON_Game].WinWidth + iIconOffsetX;
	fLocY = iconDesktop[ICON_Game].WinTop;

	// Setup buttons/icons.
	iArrayOffset = ICON_Game * SUB_ICON_MAX;
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_NewGame );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeNewGameWindow';
	//arraySubIcons[iArrayOffset].strTravelCommand = "!z1l1_1";
	//arraySubIcons[iArrayOffset].eWindowCommand = eWINDOW_COMMAND_Close;
	iArrayOffset++;

	// SaveGame icon
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_SaveGame );
//	arraySubIcons[iArrayOffset].eWindowCommand = eWINDOW_COMMAND_Save
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeSaveGameWindow';
	iArrayOffset++;
	
	// LoadGame icon
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset],fLocX, fLocY, eSUB_ICON_LoadGame );
//	arraySubIcons[iArrayOffset].strTravelCommand = "UT-Logo-Map.unr?Game=Botpack.LadderLoadGame";
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeLoadGameWindow';
	iArrayOffset++;
	
/*	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_ReturnToGame );
	arraySubIcons[iArrayOffset].eWindowCommand = eWINDOW_COMMAND_Close;
	iArrayOffset++; */
	
	// Profile icon
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Profile);
	arraySubIcons[iArrayOffset].eWindowCommand = eWINDOW_COMMAND_Profile;
	iArrayOffset++;

	// QuitGame icon
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_QuitGame );
	arraySubIcons[iArrayOffset].eWindowCommand = eWINDOW_COMMAND_Quit;	
}

function CreateIconsForMultiplayerIconString(Texture texIconMultiplayer)
{
	local float fLocX, fLocY;
	local float iconW, iconH;
	local int iArrayOffset;

	iconW = texIconMultiplayer.USize * (Root.WinWidth/1024);
	iconH = texIconMultiplayer.VSize * (Root.WinHeight/768);
	iconDesktop[ICON_Multi] = UDukeFakeIcon(CreateWindow( class'UDukeFakeIcon', 
													  fLocationX, fLocationY[ICON_Multi], 
													  iconW, iconH*1.5, self
										   	  )
	);
	iconDesktop[ICON_Multi].CannotClick = true;
	iconDesktop[ICON_Multi].UpTexture   = texIconMultiplayer;
	iconDesktop[ICON_Multi].DownTexture = texIconMultiplayer;
	iconDesktop[ICON_Multi].OverTexture = texIconMultiplayer;
//	iconDesktop[ICON_Multi].classExplorer = class'UDukeFakeExplorerWindow';
//	iconDesktop[ICON_Multi].eTypeOfExplorerToCreate = eEXPLORER_Multiplayer;
	iconDesktop[ICON_Multi].bDesktopIcon = true;
	iconDesktop[ICON_Multi].SetText("Multiplayer");
	iconDesktop[ICON_Multi].TextY = texIconMultiplayer.VSize;
	iconDesktop[ICON_Multi].Align = TA_Center;
	
	// Start to the right of the main icon, and tile across and down.
	fLocX = iconDesktop[ICON_Multi].WinLeft + iconDesktop[ICON_Multi].WinWidth + iIconOffsetX;
	fLocY = iconDesktop[ICON_Multi].WinTop;

	// Setup button/icons.
	iArrayOffset = ICON_Multi * SUB_ICON_MAX;


    DoExplorerCoords();

	// LAN Games
    CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_LANGames );
	arraySubIcons[iArrayOffset].classExplorer       = class'UDukeFakeExplorerWindowLANGames';
    arraySubIcons[iArrayOffset].WindowOffsetAndSize = regMulti_LANGames;
	iArrayOffset++;

	// DukeNet
    CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_DukeNet );
	arraySubIcons[iArrayOffset].classExplorer       = class'UDukeFakeExplorerWindowDukeNet';
	arraySubIcons[iArrayOffset].WindowOffsetAndSize = regMulti_DukeNet;
	iArrayOffset++;

	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_OpenLocation );
	arraySubIcons[iArrayOffset].winToOpen      = arraySubIcons[iArrayOffset - 1].winToOpen;
    arraySubIcons[iArrayOffset].eWindowCommand = eWINDOW_COMMAND_BrowseLocation;
	iArrayOffset++;

    CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_PlayerSetup );
	arraySubIcons[iArrayOffset].classExplorer       = class'UDukeFakeExplorerWindowPlayerSetup';
    arraySubIcons[iArrayOffset].WindowOffsetAndSize = regMulti_PlayerSetup;
	iArrayOffset++;
}

function DoExplorerCoords()
{
	regMulti_LanGames.X = ( WinWidth / 12 ) / 2;
    regMulti_LanGames.Y = ( WinHeight / 12 ) / 2;
    regMulti_LanGames.W = WinWidth  - ( WinWidth / 12 );
    regMulti_LanGames.H = WinHeight - ( Winheight / 12 );

	regMulti_DukeNet.X = ( WinWidth / 12 ) / 2;
    regMulti_DukeNet.Y = ( WinHeight / 12 ) / 2;
    regMulti_DukeNet.W = WinWidth  - ( WinWidth / 12 );
    regMulti_DukeNet.H = WinHeight - ( Winheight / 12 );
}

function Resized()
{
    Super.Resized();

    DoExplorerCoords();
}

function CreateIconsForSettingsIconString(Texture texIconSettings)
{
	local float fLocX, fLocY;
	local float iconW, iconH;
	local int iArrayOffset;

	iconW = texIconSettings.USize * (Root.WinWidth/1024);
	iconH = texIconSettings.VSize * (Root.WinHeight/768);

	iconDesktop[ICON_Sett] = UDukeFakeIcon(CreateWindow(class'UDukeFakeIcon', 
												  fLocationX, fLocationY[ICON_Sett], 
												  iconW, iconH*1.5, self
										   )
	);
	iconDesktop[ICON_Sett].CannotClick = true;
	iconDesktop[ICON_Sett].UpTexture   = texIconSettings;
	iconDesktop[ICON_Sett].DownTexture = texIconSettings;
	iconDesktop[ICON_Sett].OverTexture = texIconSettings;
//	iconDesktop[ICON_Sett].classExplorer = class'UDukeFakeExplorerWindow';
//	iconDesktop[ICON_Sett].eTypeOfExplorerToCreate = eEXPLORER_Settings;
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
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Video,	regSett_Video );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeFakeExplorerWindowVideo';
	iArrayOffset++;
	
	//eICON_Audio
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Audio,	regSett_Audio );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeFakeExplorerWindowAudio';
	iArrayOffset++;

	//eICON_Game
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Game, regSett_Game );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeFakeExplorerWindowGame';
	iArrayOffset++;
		
	//eICON_Controls
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Controls, regSett_Controls );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeFakeExplorerWindowControls';
	iArrayOffset++;	

	//eICON_SOS
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_SOS, regSett_SOS );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeFakeExplorerWindowSOS';
	iArrayOffset++;	
	
	//
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_ParentControl);
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeParentLockWindow';
	iArrayOffset++;	
}

function CreateIconsForSupportIconString(Texture texIconTools)
{
	local float fLocX, fLocY;
	local float iconW, iconH;
	local int iArrayOffset;

	iconW = texIconTools.USize * (Root.WinWidth/1024);
	iconH = texIconTools.VSize * (Root.WinHeight/768);

	iconDesktop[ICON_Supp] = UDukeFakeIcon(CreateWindow( class'UDukeFakeIcon', 
												fLocationX, fLocationY[ICON_Supp], 
												iconW, iconH*1.5, self
										)
	);
	iconDesktop[ICON_Supp].CannotClick = true;
	iconDesktop[ICON_Supp].UpTexture   = texIconTools;
	iconDesktop[ICON_Supp].DownTexture = texIconTools;	//Texture(DynamicLoadObject("DukeLookAndFeel.Support_Flipped", class'Texture'));
	iconDesktop[ICON_Supp].OverTexture = texIconTools;	//iconDesktop[ICON_Supp].DownTexture;
//	iconDesktop[ICON_Supp].classExplorer = class'UDukeFakeExplorerWindow';
//	iconDesktop[ICON_Supp].eTypeOfExplorerToCreate = eEXPLORER_Tools;
	iconDesktop[ICON_Supp].bDesktopIcon = true;
	iconDesktop[ICON_Supp].SetText("Support");
	iconDesktop[ICON_Supp].TextY = texIconTools.VSize;
	iconDesktop[ICON_Supp].Align = TA_Center;

	//Start to the right of the main icon, and tile across and down
	fLocX = iconDesktop[ICON_Supp].WinLeft + iconDesktop[ICON_Supp].WinWidth + iIconOffsetX;
	fLocY = iconDesktop[ICON_Supp].WinTop;

	//setup button/icons
	iArrayOffset = ICON_Supp * SUB_ICON_MAX;
	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_Update);
	arraySubIcons[iArrayOffset].eWindowCommand  = eWINDOW_COMMAND_LatestVer;
	iArrayOffset++;

	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_About3DRealms);
	arraySubIcons[iArrayOffset].eWindowCommand  = eWINDOW_COMMAND_About;
	iArrayOffset++;

	CreateIconAndIncrementPosition(	arraySubIcons[iArrayOffset], fLocX, fLocY, eSUB_ICON_FunStuff );
	arraySubIcons[iArrayOffset].classExplorer = class'UDukeFakeExplorerWindowFunStuff';
	arraySubIcons[iArrayOffset].eTypeOfExplorerToCreate = eEXPLORER_FunStuff;
}

function CreateIconAndIncrementPosition(out UDukeFakeIcon buttonNew, 
										out float fLocX, out float fLocY,
										eSUB_ICON_TYPE eIconType,
										optional Region regSizeOfNewWin)	
{
	local Texture texIconToUse; 
	texIconToUse = Texture(DynamicLoadObject(aSubIconTextures[eIconType], class'Texture'));
	
	buttonNew = UDukeFakeIcon(CreateWindow(class'UDukeFakeIcon', 
											  fLocX, fLocY, 
											  texIconToUse.USize * fOversizeFactor,	//to avoid clipping words 
											  texIconToUse.VSize * fOversizeFactor,
											  self
								)
	);
	buttonNew.UpTexture   = texIconToUse;
	if ("DukeLookAndFeel.generic" == aSubIconTextures[eIconType])
		buttonNew.DownTexture = Texture(DynamicLoadObject("DukeLookAndFeel.generic_Flipped", class'Texture'));
	else
		buttonNew.DownTexture = texIconToUse;	
	buttonNew.OverTexture = buttonNew.DownTexture;
	buttonNew.SetText(aSubIconLabels[eIconType]);
	buttonNew.TextY = texIconToUse.VSize;				// Put at the bottom of icon texture.
	buttonNew.fLocationDesired_X = buttonNew.WinLeft;	// Setup desired location used for icon move animation.

	// Only if a valid region is passed in, set the new buttons winoffset and size member.
	if (regSizeOfNewWin.W != 0 && regSizeOfNewWin.H != 0)  
		buttonNew.WindowOffsetAndSize = regSizeOfNewWin;
		
	// Set this sub-desktop icon to be invisible by default/initially.
	buttonNew.HideWindow();
	
	IncrementIconPlacement(buttonNew, fLocX, fLocY);
}

function IncrementIconPlacement(UDukeFakeIcon button, out float fLocX, out float fLocY,
								optional float fMaxWidth)
{
	if (fMaxWidth  <= 0.0)	
		fMaxWidth  = WinWidth;
	fMaxWidth -= button.WinWidth;

	fLocX += button.WinWidth + iIconOffsetX;
	if (fLocX > fMaxWidth)
	{
		fLocY += button.UpTexture.VSize + iIconOffsetY;

		// Line up to first icon, plus halfway between to offset each new row.
		fLocX = fLocationX + iconDesktop[0].WinWidth + iIconOffsetX + 
				((button.WinWidth + iIconOffsetX) / 2);		
	}
}


function Paint(Canvas C, float MouseX, float MouseY)
{
	local float FlashScale;

	if (C.ClipX != LastClipX)
	{
		LastClipX = C.ClipX;
		ResolutionChanged(C.ClipX, C.ClipY);
	}

	if (bDoing3DRLogo)
		Draw3DRLogo(C);
	else if (bDoingNukemLogo)
		DrawNukemLogo(C);
	else if (bDoingBootupSequence)
		DrawBootupSequence(C);
	else if (bDoingDeathSequence)
		DrawDeathSequence(C);
	else if (bDoingLevelStartSequence)
	{
		// Maybe do something here?
	} 
	else
		DrawBackdrop(C);

	// Increment the frame #, unless iSunglassAnimDir == SUNGLASS_ANIM_DIRECTION_STEADY
	// in which case the frame number doesn't increment (+= 0)
	iNumFramesToBringUpSunglasses += iSunglassAnimDir;
	if (bDoingLevelStartSequence)
	{
		if (StartLevelCount == 0.0)
		{
			FlashScale = FMax(float(iNumFramesToBringUpSunglasses) / float(default.iNumFramesToBringUpSunglasses), 0.1);
			GetPlayerOwner().FlashScale = vect(FlashScale,FlashScale,FlashScale);
		} else {
			GetPlayerOwner().FlashScale = vect(0.1, 0.1, 0.1);
		}
	}
	if(iSunglassAnimDir == SUNGLASS_ANIM_DIRECTION_IN)  {
		if( iNumFramesToBringUpSunglasses == 0)  {
			// Start showing the desktop icons and menu bar again.
			StartUpAnimationEnded();	
			iSunglassAnimDir = SUNGLASS_ANIM_DIRECTION_STEADY;
		}
	}
	else if(iSunglassAnimDir == SUNGLASS_ANIM_DIRECTION_OUT)  {
		if( iNumFramesToBringUpSunglasses == default.iNumFramesToBringUpSunglasses)  {
			// Now close/hide the UWindowSystem for sure this time.
			if (!bDoingLevelStartSequence && (StartLevelCount == 0.0))
			{
				Root.Console.CloseUWindow();	
				iSunglassAnimDir = SUNGLASS_ANIM_DIRECTION_STEADY;
			} else
				EndLevelSequence();
		}
	}	

	if ( bFirstPaint )
	{
		bFirstPaint = false;
		StartNukemLogo();
	}
}

function AfterPaint(Canvas C, float MouseX, float MouseY)
{
	local float fTextureSizeRatioX, fTextureSizeRatioY,		
				fTextureSizeX, fTextureSizeY;

	Super.AfterPaint(C, MouseX, MouseY);

	fTextureSizeRatioX = WinWidth  / FullSizeTextureWidth;
	fTextureSizeRatioY = WinHeight / FullSizeTextureHeight;
	DrawSunglasses(C, fTextureSizeRatioX, fTextureSizeRatioY);
}

function Draw3DRLogo(Canvas C)
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

function DrawNukemLogo(Canvas C)
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

// hud_effects.scanlines.nightlines1BC

function DrawBackdrop(Canvas C)
{
	local int XOffset, YOffset;
	local float W, H,
				HeightToUse;
	local float fDrawWidth, fDrawHeight;
	local float fBackgroundDist;
	local Region R;

	HeightToUse = WinHeight;

	W = texWallpaper[0].USize * C.ClipX / 1024;
	H = texWallpaper[0].VSize * C.ClipY / 768;

	fDrawWidth  = W /*- 1*/;
	fDrawHeight = H /*- 1*/;
	
//	if(iNumFramesToBringUpSunglasses < default.iNumFramesToBringUpSunglasses)
//		fBackgroundDist = 
//		  1.0 - Sin( (iNumFramesToBringUpSunglasses / float(default.iNumFramesToBringUpSunglasses)) * (Pi * 0.5) );
	fBackgroundDist = 1.0f;
	
	C.DrawColor.R = (fBackgroundDist * 255) * fDesktopFadeFactor;
	C.DrawColor.G = C.DrawColor.R * fDesktopFadeFactor;
	C.DrawColor.B = C.DrawColor.R * fDesktopFadeFactor;

	DrawStretchedTexture(C, (0 * fDrawWidth), (0 * fDrawHeight), W, H, texWallpaper[0], 1.0f);
	DrawStretchedTexture(C, (0 * fDrawWidth), (1 * fDrawHeight), W, H, texWallpaper[4], 1.0f);
	DrawStretchedTexture(C, (0 * fDrawWidth), (2 * fDrawHeight), W, H, texWallpaper[8], 1.0f);

	DrawStretchedTexture(C, (1 * fDrawWidth), (0 * fDrawHeight), W, H, texWallpaper[1], 1.0f);
	DrawStretchedTexture(C, (1 * fDrawWidth), (1 * fDrawHeight), W, H, texWallpaper[5], 1.0f);
	DrawStretchedTexture(C, (1 * fDrawWidth), (2 * fDrawHeight), W, H, texWallpaper[9], 1.0f);

	DrawStretchedTexture(C, (2 * fDrawWidth), (0 * fDrawHeight), W, H, texWallpaper[2], 1.0f);
	DrawStretchedTexture(C, (2 * fDrawWidth), (1 * fDrawHeight), W, H, texWallpaper[6], 1.0f);
	DrawStretchedTexture(C, (2 * fDrawWidth), (2 * fDrawHeight), W, H, texWallpaper[10], 1.0f);

	DrawStretchedTexture(C, (3 * fDrawWidth), (0 * fDrawHeight), W, H, texWallpaper[3], 1.0f);
	DrawStretchedTexture(C, (3 * fDrawWidth), (1 * fDrawHeight), W, H, texWallpaper[7], 1.0f);
	DrawStretchedTexture(C, (3 * fDrawWidth), (1 * fDrawHeight), W, H, texWallpaper[7], 1.0f);
	DrawStretchedTexture(C, (3 * fDrawWidth), (2 * fDrawHeight), W, H, texWallpaper[11], 1.0f);
	
	XOffset = 0;

	R.X = 0;
	R.Y = 0;
	R.W = flicWallpaper.USize;
	R.H = flicWallpaper.VSize * (C.ClipY/768);

	YOffset = (HeightToUse / 2) - (R.H / 2);	//start at bottom of top strip
		
	C.DrawColor.R = 96 * fDesktopFadeFactor;
	C.DrawColor.G = C.DrawColor.R * fDesktopFadeFactor;
	C.DrawColor.B = C.DrawColor.R * fDesktopFadeFactor;
		
	C.Style = 3;
	DrawHorizTiledPieces(C, XOffset, YOffset, WinWidth, R.H, R, flicWallpaper, 1.0f, false );
	C.Style = 1;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
}

function DrawSunglasses(Canvas C, float fTextureSizeRatioX, float fTextureSizeRatioY, optional bool bForce)
{	
	local float fTextureSizeX,
				fTextureSizeY;
	local float fOffsetRatio,
				fOffsetRatioInverted;

	if ( bHideSunglasses && !bForce)
		return;

	// Want smooth accelerated movement, rather than straight linear one.
	fOffsetRatio = Sin( (iNumFramesToBringUpSunglasses / float(default.iNumFramesToBringUpSunglasses)) * (Pi * 0.5));
	fOffsetRatioInverted = 1.0 - fOffsetRatio;
				
	C.Style = 2;
	fTextureSizeX = texSunglasses[0].USize * fTextureSizeRatioX;
	fTextureSizeY = texSunglasses[0].VSize * fTextureSizeRatioY;
	DrawStretchedTexture(C, fOffsetRatio * -fTextureSizeX, fOffsetRatio * -fTextureSizeY, 
						 fTextureSizeX, fTextureSizeY, texSunglasses[0], 1.0f);
	C.Style = 3;
	fTextureSizeX = texSunglassesGlow[0].USize * fTextureSizeRatioX;
	fTextureSizeY = texSunglassesGlow[0].VSize * fTextureSizeRatioY;
	DrawStretchedTexture(C, 
						 fOffsetRatio * -fTextureSizeX,
						 fOffsetRatio * -fTextureSizeY, 
						 C.ClipX/2 + fOffsetRatio * -fTextureSizeX,
						 C.ClipY/2 + fOffsetRatio * -fTextureSizeY,
						 texSunglassesGlow[0], 1.0f);

	//Draw the topright section of the quad	
	C.Style = 2;
	fTextureSizeX = texSunglasses[1].USize * fTextureSizeRatioX;
	fTextureSizeY = texSunglasses[1].VSize * fTextureSizeRatioY;
	DrawStretchedTexture(C, WinWidth - (fTextureSizeX * fOffsetRatioInverted), 
						 fOffsetRatio * -fTextureSizeY, fTextureSizeX, fTextureSizeY, texSunglasses[1], 1.0f);
	C.Style = 3;
	fTextureSizeX = texSunglassesGlow[1].USize * fTextureSizeRatioX;
	fTextureSizeY = texSunglassesGlow[1].VSize * fTextureSizeRatioY;
	DrawStretchedTextureSegment( C, C.ClipX/2, fOffsetRatio * -fTextureSizeY, 
							 	 C.ClipX/2 + fOffsetRatio * fTextureSizeX,
								 C.ClipY/2 + fOffsetRatio * -fTextureSizeY,
								 1*fTextureSizeRatioX, 1*fTextureSizeRatioY, texSunglassesGlow[1].USize, texSunglassesGlow[1].VSize - 1*fTextureSizeRatioY,
								 texSunglassesGlow[1], 1.0f );

	//Draw the bottomleft section of the quad	
	C.Style = 2;
	fTextureSizeX = texSunglasses[2].USize * fTextureSizeRatioX;
	fTextureSizeY = texSunglasses[2].VSize * fTextureSizeRatioY;
	DrawStretchedTexture(C, fOffsetRatio * -fTextureSizeX, WinHeight - (fTextureSizeY * fOffsetRatioInverted), 
						 fTextureSizeX, fTextureSizeY, texSunglasses[2], 1.0f);
	C.Style = 3;
	fTextureSizeX = texSunglassesGlow[2].USize * fTextureSizeRatioX;
	fTextureSizeY = texSunglassesGlow[2].VSize * fTextureSizeRatioY;
	DrawStretchedTextureSegment( C, fOffsetRatio * -fTextureSizeX, C.ClipY/2, 
							 	 C.ClipX/2 + fOffsetRatio * -fTextureSizeX,
								 C.ClipY/2 + fOffsetRatio * fTextureSizeY,
								 -1*fTextureSizeRatioX, 1*fTextureSizeRatioY, texSunglassesGlow[2].USize, texSunglassesGlow[2].VSize - 1*fTextureSizeRatioY,
								 texSunglassesGlow[2], 1.0f );

	//Draw the bottomright section of the quad	
	C.Style = 2;
	fTextureSizeX = texSunglasses[3].USize * fTextureSizeRatioX;
	fTextureSizeY = texSunglasses[3].VSize * fTextureSizeRatioY;
	DrawStretchedTexture(C, WinWidth  - (fTextureSizeX * fOffsetRatioInverted), 
						 WinHeight - (fTextureSizeY * fOffsetRatioInverted), 
						 fTextureSizeX, fTextureSizeY, texSunglasses[3], 1.0f);
	C.Style = 3;
	fTextureSizeX = texSunglassesGlow[3].USize * fTextureSizeRatioX;
	fTextureSizeY = texSunglassesGlow[3].VSize * fTextureSizeRatioY;
	DrawStretchedTextureSegment( C, C.ClipX/2, C.ClipY/2, 
							 	 C.ClipX/2 + fOffsetRatio*fTextureSizeX,
								 C.ClipY/2 + fOffsetRatio*fTextureSizeY,
								 1*fTextureSizeRatioX, 1*fTextureSizeRatioY, texSunglassesGlow[3].USize, texSunglassesGlow[3].VSize - 1*fTextureSizeRatioY,
								 texSunglassesGlow[3], 1.0f );
	C.Style = 2;

}

//==========================================================================================
//	HideProfileWindow
//==========================================================================================
function HideProfileWindow()
{
	if ( ProfileWindow != None )
		ProfileWindow.HideWindow();
	ShowIcons();
	ShowMenuBar();
}

//==========================================================================================
//	ShowProfileWindow
//==========================================================================================
function ShowProfileWindow(optional bool Force)
{
	local float					LWinWidth, LWinHeight, LWinPosX, LWinPosY;

	if (!Force && GetPlayerOwner().GetCurrentPlayerProfile() != "")
	{
		HideProfileWindow();
		return;		// No need
	}

	HideIcons();

	if (ProfileWindow != None)
	{
		ProfileWindow.ShowWindow();		// Already created, just show it again
		return;
	}

	//
	//	Create the ProfileWindow for the first time
	//

	// Set Width/Height
	LWinWidth = 215;
	LWinHeight = 140;

	// Center the LoginScreen
	LWinPosX = (WinWidth*0.5f)-(LWinWidth*0.5f);
	LWinPosY = (WinHeight*0.2f);//-(LWinHeight*0.5f);

	ProfileWindow = UDukeProfileWindow(	CreateWindow(class'UDukeProfileWindow', 
										LWinPosX, 
										LWinPosY, 
										LWinWidth, 
										LWinHeight, 
										self));
}

function StartUpAnimationEnded()
{
	// When SOS starting sequence is over, end the animations, and start showing Icons and the menu bar again.
	if (!DukeConsole(Root.Console).bShowDeathSequence)
	{
		ShowProfileWindow();
	}
}

function DesktopIconMouseEvent(UDukeFakeIcon iconClicked)
{
	ToggleButtonsState(ICON_Game,  iconDesktop[ICON_Game] == iconClicked);
	ToggleButtonsState(ICON_Sett,  iconDesktop[ICON_Sett] == iconClicked); 
	ToggleButtonsState(ICON_Multi, iconDesktop[ICON_Multi] == iconClicked); 
	ToggleButtonsState(ICON_Supp,  iconDesktop[ICON_Supp] == iconClicked); 
//	ToggleButtonsState(ICON_Credit,  iconDesktop[ICON_Credit] == iconClicked);
}

function SelectIcon(eICON_SELECT_TYPE eDirection)
{
	local int iDesktopIconSelected,
			  iSubIconSelected;
	local int iNewSelection;

	for ( iDesktopIconSelected = ICON_Game; iDesktopIconSelected < ICON_MAX; iDesktopIconSelected++)
	{
		if(iconDesktop[iDesktopIconSelected].bHighlightButton)  {
			break; 	// Found the selected desktop icon.
		}
	}
	for ( iSubIconSelected = iDesktopIconSelected * SUB_ICON_MAX; iSubIconSelected < ICON_MAX * SUB_ICON_MAX; iSubIconSelected++)
	{
		if(	arraySubIcons[iSubIconSelected] == None ||
			arraySubIcons[iSubIconSelected].bHighlightButton)
		{
			break; 	// Found the selected sub-desktop icon or a NULL icon.
		}
	}

	if ( eDirection <= eICON_SELECT_DOWN )  
	{
	
		if ( eDirection == eICON_SELECT_UP )
		{
			iNewSelection = iDesktopIconSelected - 1;
			if( iNewSelection < 0 )
				iNewSelection = ICON_MAX - 1;
		}
		else
		{
			iNewSelection = iDesktopIconSelected + 1;
			if( iNewSelection >= ICON_MAX )
				iNewSelection = 0;
		}	
		
		// Deselect old selection, and select new one.
		if ( iDesktopIconSelected < ICON_MAX )
			ToggleButtonsState(iDesktopIconSelected, false);
		ToggleButtonsState(iNewSelection, true);
		iconDesktop[iNewSelection].ActivateWindow(0, false);
	}
	else
	{	
		// First make sure iDesktopIconSelected is a valid value.
		if ( iDesktopIconSelected >= ICON_MAX )
		{
			iDesktopIconSelected = ICON_Game;
			ToggleButtonsState(iDesktopIconSelected, true);
		}
			
		if ( eDirection == eICON_SELECT_LEFT )
		{
			iNewSelection = iSubIconSelected - 1;
			if ( iNewSelection < iDesktopIconSelected * SUB_ICON_MAX )
			{
				iNewSelection  = (iDesktopIconSelected + 1) * SUB_ICON_MAX - 1;

				// Keep going down the line until a valid icon is found.
				while ( arraySubIcons[iNewSelection] == None )
					iNewSelection--;
			}
		}
		else
		{
			iNewSelection = iSubIconSelected + 1;
			if( (iNewSelection >= (iDesktopIconSelected + 1) * SUB_ICON_MAX) ||
				arraySubIcons[iNewSelection] == None )
				iNewSelection = iDesktopIconSelected * SUB_ICON_MAX;
		}
		
		// Deselect old selection, and select new one.
		if(arraySubIcons[iSubIconSelected] != None)
			arraySubIcons[iSubIconSelected].bHighlightButton = false;
		arraySubIcons[iNewSelection].HighlightButton();
		arraySubIcons[iNewSelection].ActivateWindow(0, false);			
	}
}

function ToggleButtonsState(int iIconToChange, bool bSelected)
{
	local int i, iEnd;
	local bool bResetVisibility;

	// Reset all desktopicon's highlight state/flag.
	if (bSelected)
	{
		bResetVisibility = !iconDesktop[iIconToChange].bHighlightButton;
		iconDesktop[iIconToChange].HighlightButton();
		if(bResetVisibility)
			SetupIconSlideAnimation(iIconToChange);
	}
	else
	{
		// Always reset visibility, because it is possible that mouse already left button and reset state to false.
		bResetVisibility = true;
	 	iconDesktop[iIconToChange].bHighlightButton = false;
	}
	
	if (bResetVisibility)  
	{
		i = iIconToChange * SUB_ICON_MAX;
		for (iEnd = i + SUB_ICON_MAX; i < iEnd; i++)  
		{
			if (arraySubIcons[i] != None)  
			{
				if (iconDesktop[iIconToChange].bHighlightButton)
					arraySubIcons[i].ShowWindow();
				else
					arraySubIcons[i].HideWindow();				
			}			
		}
	}
}

function SetupIconSlideAnimation(int iIconToChange)
{
	local int i, iEnd;
	i = iIconToChange * SUB_ICON_MAX;
	
	for (iEnd = i + SUB_ICON_MAX; i < iEnd; i++)  
	{
		if (arraySubIcons[i] != None && 
			arraySubIcons[i].WinLeft == arraySubIcons[i].fLocationDesired_X)  
		{

			// Setup slide so that animation takes just as long, no matter how many icons or distance to reach their destination.
			arraySubIcons[i].fVelocity_X = (arraySubIcons[i].fLocationDesired_X - fLocationX) / 
											fNumFramesToAccomplishSlide;
			arraySubIcons[i].WinLeft = fLocationX + arraySubIcons[i].fVelocity_X;
		}
	}
}

function ShowMenuBar()
{
	if (ShowHelp &&	UDukeRootWindow(Root) != None && UDukeRootWindow(Root).StatusBar != None)
		UDukeRootWindow(Root).StatusBar.ShowWindow();
}

function ShowWindow()
{
	ShowMenuBar();
	Super.ShowWindow();
}

function HideWindow()
{
	if (UDukeRootWindow(Root) != None && UDukeRootWindow(Root).StatusBar != None)
		UDukeRootWindow(Root).StatusBar.HideWindow();
	Super.HideWindow();
}

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

	if (bIconsHidden)  
	{
		bIconsHidden = false;
		for (i=0; i<ICON_MAX; i++)  
		{
			// Show the icons, and reset the default text, so it cycles again.
			iconDesktop[i].ShowWindow(); 
		}		
	}
}

function StartBootupSequence()
{
	local int i;

	if (DukeConsole(Root.Console).bShowBootup)  
	{
		LookAndFeel.PlayMenuSound(Self, MS_WindowSystemActivated);
		DukeConsole(Root.Console).bShowBootup = false;
		bDoingBootupSequence = true;
		Root.Console.bDontDrawMouse = true;
		fBootFadeFactor = 1.0;
		iSunglassAnimDir = SUNGLASS_ANIM_DIRECTION_STEADY;
		iNumFramesToBringUpSunglasses = 0;
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
	bFadeInDesktop = true;
	fDesktopFadeFactor = 0.0f;
	Root.DontCloseOnEscape = false;
	Root.bAllowConsole = true;
	//StartUpAnimationEnded();

	for (i=0; i<4; i++)
	{
		aflicBootup[i].pause = true;
	}
}

function StartDeathSequence()
{
	local int i;

	Root.DontCloseOnEscape = true;
	Root.bAllowConsole = false;

	StartSunglassesAnimation();

	GetPlayerOwner().PlaySound( DeathSequenceSound, SLOT_Interact );
	bDoingDeathSequence = true;
	Root.Console.bDontDrawMouse = true;
	fBootFadeFactor = 1.0;
//	iSunglassAnimDir = SUNGLASS_ANIM_DIRECTION_STEADY;

	// Create the game over buttons.
	if (ContinueButton == None)
		ContinueButton = UDukeMissionOverButton(CreateWindow(class'UDukeMissionOverButton', 0, 0, 0, 0, Self));
	ContinueButton.bSolid = true;
	ContinueButton.bStretched = true;
	ContinueButton.WinLeft = 31 * (WinWidth/1024.f) * 2.0;
	ContinueButton.WinTop = 278 * (WinHeight/768.f) * 1.6666;
	ContinueButton.SetSize( texture'hud_effects.missionover.mover_continue'.USize * (WinWidth/1024.f) * 2.0, texture'hud_effects.missionover.mover_continue'.VSize * (WinHeight/768.f) * 1.66666 );
	ContinueButton.HideWindow();
	ContinueButton.Desktop = Self;

	if (QuitButton == None)
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

	for (i=0; i<4; i++)
	{
		aflicDeath[i].pause = true;
	}
}

function StartLevelSequence()
{
	bDoingLevelStartSequence = true;
	Root.Console.bDontDrawMouse = true;
	Root.Console.bNoDrawWorld = false;
	GetPlayerOwner().SetPause( false );
	Root.DontCloseOnEscape = true;
	Root.bAllowConsole = false;

	GetPlayerOwner().FlashFog = vect(0,0,0);
	GetPlayerOwner().FlashScale = vect(0.1,0.1,0.1);
	StartLevelCount = 0.5;

	HideIcons();
	iSunglassAnimDir = SUNGLASS_ANIM_DIRECTION_STEADY;
	iNumFramesToBringUpSunglasses = 0;
}

function EndLevelSequence()
{
	Root.DontCloseOnEscape = false;
	Root.bAllowConsole = true;

	GetPlayerOwner().FlashFog = vect(0.0,0.0,0.0);
	GetPlayerOwner().FlashScale = vect(1.0,1.0,1.0);

	DukeConsole(Root.Console).bShowDeathSequence = false;
	DukeConsole(Root.Console).bShowBootup = false;
	DukeConsole(Root.Console).bShowStartLevelSequence = false;

	bDoingBootupSequence = false;
	bDoingDeathSequence = false;
	bDoingLevelStartSequence = false;

	Root.Console.bDontDrawMouse = false;
	Root.Console.bCloseForSureThisTime = true;
	Root.Console.CloseUWindow();
	fDesktopFadeFactor = 1.0;
}

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

	if ( bForceToEnd )
	{
		StartSunglassesAnimation();
		bFadeInDesktop = true;
	}
	else
		StartBootupSequence();
}

function StartNukemLogo()
{
	local int i;

	Root.DontCloseOnEscape = true;
	Root.bAllowConsole = false;
	bDoingNukemLogo = true;
	Root.Console.bDontDrawMouse = true;
	HideIcons();

	aflicNukem[0] = smackertexture'smk7.nuke_topleft';
	aflicNukem[1] = smackertexture'smk7.nuke_topright';
	aflicNukem[2] = smackertexture'smk7.nuke_botleft';
	aflicNukem[3] = smackertexture'smk7.nuke_botright';
	for (i=0; i<4; i++)
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

	if ( bForceToEnd )
	{
		StartSunglassesAnimation();
		bFadeInDesktop = true;
	}
	else
		Start3drLogo();
}

function StartShadesOS()
{
    bHideSunglasses = false;
	// Start the sunglasses animation before rendering everything.
	if (DukeConsole(Root.Console).bShowBootup)
		StartBootupSequence();
	else if (DukeConsole(Root.Console).bShowDeathSequence)
		StartDeathSequence();
	else if (DukeConsole(Root.Console).bShowStartLevelSequence)
		StartLevelSequence();
	else
		StartSunglassesAnimation();
}

function EndShadesOS()
{
	//Start the sunglasses animation in reverse order
	LookAndFeel.PlayMenuSound(Self, MS_WindowSystemDeActivated);
	EndSunglassesAnimation();
}

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
	else if (bDoingLevelStartSequence && (StartLevelCount > 0.0))
	{
		StartLevelCount -= Delta;
		if (StartLevelCount < 0.0)
		{
			StartLevelCount = 0.0;
			EndSunglassesAnimation();
		}
	}
	else if (bFadeInDesktop)
	{
		if (fDesktopFadeFactor < 1.0f)
		{
			fDesktopFadeFactor += Delta*2;
			if (fDesktopFadeFactor > 1.0f)
			{
				fDesktopFadeFactor = 1.0f;
				StartUpAnimationEnded();
			}
		}
	}
	else if (bCheckForLoopingSound)  
	{
	}
}

function DeathButtonEvent(UWindowDialogControl C, byte E)
{
	if (E == DE_Click)
	{
		if (C == ContinueButton)
			ContinueClicked();
		else if (C == QuitButton)
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
	fDesktopFadeFactor = 1.0;
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
	fDesktopFadeFactor = 1.0;
	GetPlayerOwner().ClientTravel("entry?nologo", TRAVEL_Absolute, false);
}

defaultproperties
{
     bCheckForLoopingSound=True
     aSubIconLabels(0)="New Game"
     aSubIconLabels(1)="Save Game"
     aSubIconLabels(2)="Load Game"
     aSubIconLabels(3)="Profile"
     aSubIconLabels(4)="Quit Game"
     aSubIconLabels(5)="LAN Games"
     aSubIconLabels(6)="DukeNet"
     aSubIconLabels(7)="Open Location"
     aSubIconLabels(8)="Player Setup"
     aSubIconLabels(9)="Video"
     aSubIconLabels(10)="Audio"
     aSubIconLabels(11)="Game"
     aSubIconLabels(12)="Controls"
     aSubIconLabels(13)="SOS"
     aSubIconLabels(14)="Parental Control"
     aSubIconLabels(15)="Latest Version"
     aSubIconLabels(16)="About 3D Realms"
     aSubIconLabels(17)="Fun Stuff"
     aSubIconTextures(0)="DukeLookAndFeel.generic"
     aSubIconTextures(1)="DukeLookAndFeel.i_savegame"
     aSubIconTextures(2)="DukeLookAndFeel.i_loadgame"
     aSubIconTextures(3)="DukeLookAndFeel.generic"
     aSubIconTextures(4)="DukeLookAndFeel.i_quitgame"
     aSubIconTextures(5)="DukeLookAndFeel.i_findlangame"
     aSubIconTextures(6)="DukeLookAndFeel.i_findinternetg"
     aSubIconTextures(7)="DukeLookAndFeel.i_openlocation"
     aSubIconTextures(8)="DukeLookAndFeel.generic"
     aSubIconTextures(9)="DukeLookAndFeel.i_video"
     aSubIconTextures(10)="DukeLookAndFeel.i_audio"
     aSubIconTextures(11)="DukeLookAndFeel.generic"
     aSubIconTextures(12)="DukeLookAndFeel.i_controls"
     aSubIconTextures(13)="DukeLookAndFeel.i_hud"
     aSubIconTextures(14)="DukeLookAndFeel.generic"
     aSubIconTextures(15)="DukeLookAndFeel.i_downloadlates"
     aSubIconTextures(16)="DukeLookAndFeel.i_about"
     aSubIconTextures(17)="DukeLookAndFeel.generic"
     LogoSound=Sound'a_generic.Logo.3DRLogo01'
     fDeathSequenceLength=4.300000
     bFirstPaint=True
     fBootupSequenceLength=12.500000
     fBootFadeFactor=1.000000
     fOversizeFactor=1.500000
     iIconOffsetX=12
     iIconOffsetY=32
     fNumFramesToAccomplishSlide=10.000000
     iNumFramesToBringUpSunglasses=35
     ShowHelp=True
     regGame_BotmatchWindow=(X=200,Y=200,W=350,h=200)
     regMulti_DukeNet=(X=200,Y=200,W=600,h=400)
     regMulti_LANGames=(X=200,Y=200,W=600,h=400)
     regMulti_PlayerSetup=(X=200,Y=200,W=600,h=400)
     regSett_Video=(X=240,W=350,h=300)
     regSett_Game=(X=240,Y=100,W=350,h=240)
     regSett_Audio=(X=240,Y=50,W=350,h=210)
     regSett_Controls=(X=240,W=350,h=400)
     regSett_SOS=(X=240,W=350,h=270)
     DeathSequenceSound=Sound'a_generic.missionover.MissionOver05a'
}
