/*-----------------------------------------------------------------------------
	DukeHUD
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DukeHUD extends HUD;

#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx
#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Sounds\a_generic.dfx
#exec OBJ LOAD FILE=..\Sounds\a_creatures.dfx

var Pawn PawnOwner;						// Pawn currently managing this HUD (May be the ViewTarget).
var dnFontInfo MyFonts;
var transient font VerySmallFont, SmallFont, MediumFont, LargeFont, HugeFont;
var transient font HUDFont;

// Resolution and Scale
var bool ResChanged;					// True if the resolution changed since last frame.
var float OldClipX;						// Tracks previous frame's resolution.
var globalconfig bool bHideHUD;
var globalconfig bool bHideCrosshair;

// Color customization.
var globalconfig float Opacity;
var globalconfig color CrosshairColor;
var globalconfig color TextColor;
var globalconfig color HUDColor;

// Message system.
var HUDLocalizedMessage MessageQueue[4];
var float MessageFade[4];

// Index Items.
// 0 reserved for EGO.
// 1 reserved for Energy.
// 2 reserved for Ammo.
// 3 reserved for AltAmmo.
// 4 reserved for Shield.
// 5 reserved for Oxygen.
// 6 reserved for Vehicle Health.
// 7 reserved for Jetpack.
// 8 reserved for Bomb
// 10 reserved for Cash.
// 11 reserved for Frags or Credits.
var float DesiredIndexTop, RootIndexTop;
var float IndexTop, IndexBottom;
var float IndexAdjust;
var float BarOffset;
var HUDIndexItem IndexItems[12];
var int MaxIndexItems;								// Max number of index items.
var int ItemSpace;									// How much space to pad between index items.
var float TextRightAdjust;							// How much to the right to draw the index items.
var float BarPos, BarLeft;
var float TitleLeft, TitleOffset;
var float SlideRate;
var float IndexTopOffset;
var localized string IndexName;
var texture GradientTexture;
var texture IndexBarLeftTexture;
var texture IndexBarRightTexture;
var texture IndexBarBottomTexture;
var texture InventoryBarTopTexture;
var texture InventoryBarBotTexture;
var texture InventoryCatHLTexture;
var texture InventoryCatHLTexture2;
var texture MiscBarTabTexture;
var texture MiscBarHLTexture;
var texture HUDTemplateTexture;
var texture ItemSlantTexture;
var texture ItemSlantHLTexture;
var texture MiscBarTexture;
var texture MiscBarTexture2;
var texture NumberCircleTexture;
var smackertexture InventorySmackTop;
var smackertexture InventorySmackBot;
var bool PlayOpenInv, PlayedOpenInv, PlayCloseInv;
var float InvSmackTime, LastSmackTime;
var RenderActor OldLookActor;
var bool InventoryUp, MiscBarOut, ShowMakersLabel;
var int CashRefs;
var float CashTime;
var float IndexNameX, IndexNameY;
var HUDIndexItem DecoHealthItem;

// Typing prompt.
var float CursorTime;
var bool TypingCursor;
var HUDIndexItem_Prompt PromptItem;

// Crosshair.
var globalconfig int CrosshairCount;
var texture CrosshairTextures[20];

// Heal draw effect.
var float LastFrameEgo, LastFrameEnergy;
var float FrameDamage;
var float FrameHeal;
var float FrameEnergy;
var struct HealthChange
{
	var float HealthDelta;
	var float Time;
	var bool bIsEnergy;
} HealthChanges[8];

// Blood smack effect.
var struct BloodSmack
{
	var float SmackSize;
	var float SmackIntensity;
} BloodSmacks[4];
var texture BloodSmackTexLeft, BloodSmackTexTop;

// Blood slash effect.
var int BloodSlashType;
var float BloodSlashTime;
var texture BloodSlashTex, BloodSlashLeft[4], BloodSlashDown[4], BloodSlashDouble[4], BloodSlashOctabrain[4],
			BloodSlashBite[4], BloodSlashTail[4], BloodSlashRight[4];
var sound BloodSlashSound;

// Draw control.
var transient bool bNotFirstDraw;

// Item select box.
var texture ItemSelectTexture;

// Inventory Interface
var texture OutOfAmmo;
var texture InnerCircle;
var texture HighlightBubble;
var texture OuterCircle;
var float inventoryRotations[7];
var float inventoryFade[7];
var float highlightRotation;
var int DestResX, DestResY;
var sound QMenuHL;
var Inventory OldSelectedItem;

// Can pickup inventory list.
var int CanPickupInv[6];

// Categories
var string CategoryStrings[7];

// Pickup events.
var struct PickupEvent
{
	var float EventTime;
	var texture EventTexture;
} PickupEvents[7];
var int CurrentPickupsIndex;

// Use Key.
var enum ESpecialKeys
{
	SK_Use,
	SK_Zoom,
	SK_Heat,
	SK_Night
} SpecialK;
var string SpecialKeys[30];
var string KeyNames[255];
var string KeyAlias[255];

// DOT Effects.
var texture DOTTex[10];
var texture SafeModeTex;
var texture SafeModeLabel;
var bool bShowDOTList;

// Fade messages.
var transient struct FadeMessage
{
	var string Text;
	var int X, Y;
	var float Time;
	var font Font;
	var color TextColor;
	var int MessageIcon;
	var bool Inventory;
	var bool DoneDrawing;
	var float DoneTime;
} FadeMessages[16];
var string PendingEventMsg1;
var string PendingEventMsg2;
var int PendingEventX;
var int PendingEventY;
var int PendingIcon;
var color GreyColor;
var sound SOSMessageSound;
var bool bTitleDisplayed;
var float HUDTimeSeconds;

var texture LocationAnim[15];
var texture MessageAnim[15];

// Tool tip.
//var ToolTipWindow ToolTip;

// Debug
var bool bDrawBounds, bDrawCyl, bDrawDebugHUD, bDrawDebugAIHUD;
var bool bDrawNetWeapDebugHUD, bDrawNetPlayerDebugHUD;
var bool bDrawActorDebugHUD, bDrawCorpseDebugHUD;
var class<Actor> ActorClass;
var float ActorRadius;

var transient font DebugFont;
var Pawn AIWatchTarget;

// Objectives
var bool bObjectivesLoop;
var texture ObjectivesCheck, ObjectivesChecked;
var smackertexture ObjectivesLoop[2];
var smackertexture ObjectivesStart[2];

var bool bIsSpectator;
var localized string SpectatorMessage;
var localized string SpectatorModeMessage;
var localized string SpectatorViewingMessage;
var localized string HealthMessage;

var bool	bDrawPlayerIcons;
var float	IconSize;
var float	SmallIconSize;

// Level title fade in.
//var float TitleFadeTime;
//var float TitleStayTime;



/*-----------------------------------------------------------------------------
	Setup and preparation functions.
-----------------------------------------------------------------------------*/

simulated function PostBeginPlay()
{
	MyFonts = spawn(class'dnFontInfo');
	Super.PostBeginPlay();
	SetTimer(1.0, True);

	currentInventoryCategory = -1;
	currentInventoryItem = 0;

	bNotFirstDraw = false;
}

simulated event Destroyed()
{
	local int i;

	Super.Destroyed();

	for ( i=0; i<12; i++ )
	{
		if ( IndexItems[i] != None )
		{
			IndexItems[i].Destroy();
			IndexItems[i] = None;
		}
	}

	if ( DecoHealthItem != None )
	{
		DecoHealthItem.Destroy();
		DecoHealthItem = None;
	}
}

simulated function SetupScale(Canvas C)
{
	HUDScaleX		= C.ClipX/1024.0;
	HUDScaleY		= C.ClipY/768.0;
	BarOffset		= Default.BarOffset * HUDScaleY;
	BarLeft			= Default.BarLeft * HUDScaleX;
	TitleOffset		= Default.TitleOffset * HUDScaleY;
	TitleLeft		= Default.TitleLeft * HUDScaleX;
	ItemSpace		= Default.ItemSpace * HUDScaleY;
	TextRightAdjust	= Default.TextRightAdjust * HUDScaleX;
	SlideRate		= Default.SlideRate * HUDScaleY;
	IndexTopOffset	= Default.IndexTopOffset * HUDScaleY;
	RootIndexTop	= Default.RootIndexTop * HUDScaleY;
	DesiredIndexTop	= RootIndexTop - IndexAdjust*HUDScaleY;
	IndexTop		= RootIndexTop - IndexAdjust*HUDScaleY;
	BarPos			= (Default.TextRightAdjust+4.0) * HUDScaleX;
	IndexNameX		= 0;

	VerySmallFont	= MyFonts.GetVerySmallFont(C);
	SmallFont		= MyFonts.GetSmallFont(C);
	MediumFont		= MyFonts.GetMediumFont(C);
	LargeFont		= MyFonts.GetBigFont(C);
	HugeFont		= MyFonts.GetHugeFont(C);
}

// Called first frame.
simulated function FirstDraw( canvas C )
{
    local class<GameInfo> GameInfoClass;

	// Set the HUD scale
	SetupScale( C );

	// Add the default items.
	if ( IndexItems[0] == None )
		IndexItems[0] = spawn( class'HUDIndexItem_EGO' );
	if ( IndexItems[1] == None )
		IndexItems[1] = spawn( class'HUDIndexItem_Energy' );
	if ( IndexItems[2] == None )
		IndexItems[2] = spawn( class'HUDIndexItem_WeaponAmmo', Owner );
	if ( IndexItems[3] == None )
		IndexItems[3] = spawn( class'HUDIndexItem_WeaponAltAmmo', Owner );

	// Add the prompt item.
	PromptItem = spawn( class'HUDIndexItem_Prompt' );

	// Load keys...
	LoadKeyBindings();

	// Force creation of a root window if one doesn't exist.
	if ( WindowConsole(PlayerPawn(Owner).Player.Console).Root == None )
		WindowConsole(PlayerPawn(Owner).Player.Console).CreateRootWindow(C);

	// Add the tool tip window.
//	ToolTip = ToolTipWindow(WindowConsole(PlayerPawn(Owner).Player.Console).Root.CreateWindow(
//		class'ToolTipWindow', 10, 10, 10, 10));
//	ToolTip.HideWindow();
}

// Load key bindings. :)
simulated function LoadKeyBindings()
{
	local int i;

	for (i=0; i<255; i++)
	{
		KeyNames[i] = PlayerPawn(Owner).ConsoleCommand( "KEYNAME "$i );
		KeyAlias[i] = PlayerPawn(Owner).ConsoleCommand( "KEYBINDING "$KeyNames[i] );

		// Need the use key.
		if (KeyAlias[i] ~= "Use")
			SpecialKeys[ESpecialKeys.SK_Use] = KeyNames[i];
		if (KeyAlias[i] ~= "Zoom")
			SpecialKeys[ESpecialKeys.SK_Zoom] = KeyNames[i];
		if (KeyAlias[i] ~= "HeatVision")
			SpecialKeys[ESpecialKeys.SK_Heat] = KeyNames[i];
		if (KeyAlias[i] ~= "NightVision")
			SpecialKeys[ESpecialKeys.SK_Night] = KeyNames[i];
	}
}

// Called each frame to setup the HUD to be drawn.
simulated function HUDSetup( canvas C )
{
	local int i;
	local float XL, YL;

	// Update in case of resolution change.
	ResChanged = (C.ClipX != OldClipX);
	OldClipX = C.ClipX;

	// Reset the HUD scale if res changed.
	if ( ResChanged )
		SetupScale( C );
	
	// Keep track of current managing Pawn.
	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner == None )
		return;
	if ( PlayerOwner.ViewTarget == None )
		PawnOwner = PlayerOwner;
	else if ( PlayerOwner.ViewTarget.bIsPawn )
		PawnOwner = Pawn(PlayerOwner.ViewTarget);
	else 
		PawnOwner = PlayerOwner;

	bIsSpectator = (((PlayerOwner.PlayerReplicationInfo != None) && (PlayerOwner.PlayerReplicationInfo.bIsSpectator || PlayerOwner.PlayerReplicationInfo.bWaitingPlayer)) || (PlayerOwner.ViewTarget != None));

	// Setup the way we want to draw all HUD elements.
	C.Reset();
	C.SpaceX=0;
	C.Font = SmallFont;
	Style = ERenderStyle.STY_Translucent;
	C.Style = Style;

	HUDColor = default.HUDColor;
	TextColor = default.TextColor;
}

function DrawPlayerIcon( Canvas C ) {}

/*-----------------------------------------------------------------------------
	PostRender
-----------------------------------------------------------------------------*/

simulated function PostRender( canvas C )
{
	local float XL, YL, X1, X2, Y1, Y2;
	local vector X,Y,Z, StartTrace, EndTrace, HitLocation, HitNormal, SurfBase, HitUV;
	local vector DrawOffset, Min, Max, temp;
	local Actor A;
	local texture T, MeshHitTex;
	local ConstraintJoint CJ;

	// Initial first draw setup.
	if ( !bNotFirstDraw )
	{
		FirstDraw( C );
		bNotFirstDraw = true;
	}

	// Prepare the canvas.
	HUDSetup( C );

	// Hide the tool tip.
//	if ( ToolTip.bWindowVisible )
//		ToolTip.HideWindow();

	// Determine if the owner is valid.
	if ((PawnOwner == None) || (PlayerOwner.PlayerReplicationInfo == None))
		return;

	// Draw the title.
	if ( !bTitleDisplayed && (HUDTimeSeconds > 1.0) && (Level.LevelEnterText != "") )
		DrawTitle( C );

	// Draw crosshair.
	if ( !PlayerOwner.bBehindView && !PlayerOwner.bEMPulsed && !bHideCrosshair
		&& (Level.LevelAction == LEVACT_None) && (!DukePlayer(PlayerOwner).DrawHand)
		&& (PlayerOwner.ViewMapper == None) )
	{
		C.DrawColor = WhiteColor;
		DrawCrosshair( C, 0, 0 );
	}	
	
	/*
	// Spectator messages
	if ( bIsSpectator )
		DisplaySpectatorMessage( C );			
	*/

	// Draw inventory.
	if ( !bIsSpectator )
		DrawInventory( C );

	// Draw objectives.
	if ( !bIsSpectator && bDrawObjectives )
		DrawObjectives(C);

	if ( PlayerOwner.bEMPulsed )
		return;

	// Draw a brief version if hidden.
	if ( bHideHUD )
	{
		if ( PlayerOwner.Player.Console.bTyping )
			DrawTypingPrompt(C, PlayerOwner.Player.Console);
	}

	if ( !bHideHUD )
	{
		// Draw message area.
		DrawMessageArea(C);

		if ( bDrawPlayerIcons )
			DrawPlayerIcon(C);

		// Draw status index.
		if ( !bIsSpectator )
			DrawStatusIndex(C);

	    // Draw warnings
		if ( !bIsSpectator )
			DrawThreat(C);
	}

	// Draw pickup event list.
	if ( !bIsSpectator )
		DrawPickupEvents(C);

	// Draw DOT.
	if ( !bIsSpectator )
		DrawDOT(C);

	// Health changes.
	if ( !bIsSpectator && !bHideHUD )
		DrawHealthChanges(C);

	// Weapon post render.
	if ( !bIsSpectator && PawnOwner.Weapon != None )
		PawnOwner.Weapon.PostRender(C);

	// Draw lookat information.
	if ( !bIsSpectator )
		DrawLookAtInformation(C);

	// Draw fade messages.
	DrawFadeMessages(C);

	// Draw blood smacks.
	if ( !bIsSpectator )
	{
//		DrawBloodSmacks(C);
		DrawBloodSlash(C);
	}

	// Draw debug HUD.
	if ( bDrawDebugHUD )
		DrawDebugHUD(C);

	// Draw net web debug HUD.
	if ( bDrawNetWeapDebugHUD )
		DrawNetWeapDebugHUD(C);

	// Draw net web debug HUD.
	if ( bDrawNetPlayerDebugHUD )
		DrawNetPlayerDebugHUD(C);

	// Draw Actor debug HUD.
	if ( bDrawActorDebugHUD )
		DrawActorDebugHUD(C);

	// Draw carcass debug HUD
	if ( bDrawCorpseDebugHUD )
		DrawCorpseDebugHUD(C);

	// Draw bounds
	if ( bDrawBounds )
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 0;
		C.DrawColor.B = 255;

		foreach AllActors(class'Actor', A)
		{
			if (!A.bHidden && (A.DrawType == DT_Mesh))
			{
				C.GetRenderBoundingBox( A, Min, Max );

				C.DrawLine( vect(Min.X,Min.Y,Min.Z), vect(Min.X,Min.Y,Max.Z), true );
				C.DrawLine( vect(Max.X,Min.Y,Min.Z), vect(Max.X,Min.Y,Max.Z), true );
				C.DrawLine( vect(Min.X,Max.Y,Min.Z), vect(Min.X,Max.Y,Max.Z), true );
				C.DrawLine( vect(Max.X,Max.Y,Min.Z), vect(Max.X,Max.Y,Max.Z), true );

				C.DrawLine( vect(Min.X,Min.Y,Min.Z), vect(Min.X,Max.Y,Min.Z), true );
				C.DrawLine( vect(Max.X,Min.Y,Min.Z), vect(Max.X,Max.Y,Min.Z), true );
				C.DrawLine( vect(Min.X,Min.Y,Max.Z), vect(Min.X,Max.Y,Max.Z), true );
				C.DrawLine( vect(Max.X,Min.Y,Max.Z), vect(Max.X,Max.Y,Max.Z), true );

				C.DrawLine( vect(Min.X,Min.Y,Min.Z), vect(Max.X,Min.Y,Min.Z), true );
				C.DrawLine( vect(Min.X,Max.Y,Min.Z), vect(Max.X,Max.Y,Min.Z), true );
				C.DrawLine( vect(Min.X,Min.Y,Max.Z), vect(Max.X,Min.Y,Max.Z), true );
				C.DrawLine( vect(Min.X,Max.Y,Max.Z), vect(Max.X,Max.Y,Max.Z), true );
			}
		}
	}

	// Draw cyl
	if ( bDrawCyl )
	{
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 255;

		foreach AllActors(class'Actor', A)
		{
			if ( !A.bHidden )
				C.DrawCylinder( A.Location, A.CollisionRadius, A.CollisionHeight );
		}
	}

	// Reset draw color.
	C.DrawColor = WhiteColor;
}

simulated function color GetTextColor()
{
	return TextColor;
}

simulated function DrawTitle( canvas C )
{
	local float XL, YL, XL2, YL2, X1, X2, Y1, Y2, TitleFadeTime;

	if ( HUDTimeSeconds < 4.0 )
	{
		// Fade in.
		TitleFadeTime = HUDTimeSeconds - 1.0;
		C.DrawColor.R = TextColor.R * (TitleFadeTime / 3.0);
		C.DrawColor.G = TextColor.G * (TitleFadeTime / 3.0);
		C.DrawColor.B = TextColor.B * (TitleFadeTime / 3.0);

	}
	else if ( HUDTimeSeconds < 7.0 )
	{
		// Stay up.
		C.DrawColor = TextColor;
	}
	else if ( HUDTimeSeconds < 10.0 )
	{
		// Fade out.
		TitleFadeTime = 3.0 - (HUDTimeSeconds - 7.0);
		C.DrawColor.R = TextColor.R * (TitleFadeTime / 3.0);
		C.DrawColor.G = TextColor.G * (TitleFadeTime / 3.0);
		C.DrawColor.B = TextColor.B * (TitleFadeTime / 3.0);
	}
	else
	{
		// Do nothing.
		bTitleDisplayed = true;
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	}

	C.Font = font'HUDFont';
	C.TextSize( Level.LevelEnterText, XL, YL, 0.9*HUDScaleX, 0.9*HUDScaleY );
	C.SetPos( C.ClipX/2 - XL/2, 620.0*HUDScaleY );
	C.DrawText( Caps(Level.LevelEnterText),,,, 0.9*HUDScaleX, 0.9*HUDScaleY );

	C.TextSize( Level.LocationName, XL2, YL2, 0.7*HUDScaleX, 0.7*HUDScaleY );
	C.SetPos( C.ClipX/2 - XL2/2, 620.0*HUDScaleY + YL + 2*HUDScaleY );
	C.DrawText( Caps(Level.LocationName),,,, 0.7*HUDScaleX, 0.7*HUDScaleY  );
}

//============================================================================
//DisplaySpectatorMessage
//============================================================================
simulated function DisplaySpectatorMessage( Canvas C )
{	
	local float XL, YL, YOffset;

	C.StrLen("TEST", XL, YL);
	C.DrawColor    = TextColor;
	C.bCenter      = true;
	C.Font         = MediumFont;
	
	if ( bIsSpectator ) 
	{
		// This should be shown for true spectators and not endcams
		C.SetPos(0, 0.75 * C.ClipY + YOffset );
		C.DrawText( SpectatorMessage, false );
		YOffset += YL + 2;
	}

	C.SetPos(0, 0.75 * C.ClipY + YOffset );
	
	if ( PawnOwner == Owner ) 
	{
		// viewing through own eyes
		C.DrawText( SpectatorModeMessage, false );
	}
	else 
	{
		// viewing another player
		C.DrawText( SpectatorViewingMessage $ PawnOwner.PlayerReplicationInfo.PlayerName, false );
	}

	YOffset += YL + 2;
	
	C.DrawColor	= WhiteColor;
	C.bCenter	= false;
}

/*-----------------------------------------------------------------------------
	Damage Over Time
-----------------------------------------------------------------------------*/

simulated function DrawDOT( canvas C )
{
	local float X, Y, XL, YL, DOTOffset;
	local texture DOT;
	local int i, IconsDisplayed[10];
	local DOTAffector CurrentDOT;

	C.DrawColor = RedColor;

	/*
	if (!PlayerOwner.bWeaponsActive && !PlayerOwner.bSnatched )
	{
		XL = SafeModeTex.USize * HUDScaleX;
		YL = SafeModeTex.VSize * HUDScaleY;
		X = C.ClipX - (SafeModeTex.USize+32)*HUDScaleX;
		Y = 32*HUDScaleY;
		C.SetPos( X, Y );
		C.DrawTile( SafeModeTex, XL, YL, 0, 0, SafeModeTex.USize, SafeModeTex.VSize );
		DOTOffset += SafeModeTex.USize + 8;
	}
	*/

	DOTOffset = 8*HUDScaleX;
	for ( CurrentDOT = PlayerOwner.DOTAffectorList; CurrentDOT != None; CurrentDOT = CurrentDOT.NextAffector )
	{
		i = CurrentDOT.Type;

		if ( IconsDisplayed[i] == 0 )
		{
			XL = DOTTex[i].USize * HUDScaleX;
			YL = DOTTex[i].VSize * HUDScaleY;
			X = C.ClipX - XL - DOTOffset;
			Y = 16*HUDScaleY;
			C.SetPos( X, Y );
			C.DrawTile( DOTTex[i], XL, YL, 0, 0, DOTTex[i].USize, DOTTex[i].VSize );
			DOTOffset += XL + 8*HUDScaleX;
			IconsDisplayed[i] = 1;
		}
	}

	C.DrawColor = WhiteColor;
}

/*-----------------------------------------------------------------------------
	Blood smacks.
-----------------------------------------------------------------------------*/

simulated function DrawBloodSmacks( canvas C )
{
	local int i;
	local float XL, YL, SmackTime, StretchLen;
	local float BloodSmackSizeX, BloodSmackSizeY;

	BloodSmackSizeX = BloodSmackTexLeft.USize * HUDScaleX;
	BloodSmackSizeY = BloodSmackTexLeft.VSize * HUDScaleY;

	for (i=0; i<4; i++)
	{
		StretchLen = 256.0;
		SmackTime = BloodSmacks[i].SmackIntensity;
		if (SmackTime > 0.0)
		{
			if (SmackTime < 0.5)
			{
				C.DrawColor.R = WhiteColor.R * (SmackTime/0.5);
				C.DrawColor.G = WhiteColor.G * (SmackTime/0.5);
				C.DrawColor.B = WhiteColor.B * (SmackTime/0.5);
			} else {
				C.DrawColor.R = WhiteColor.R;
				C.DrawColor.G = WhiteColor.G;
				C.DrawColor.B = WhiteColor.B;
			}
			XL = ((1.0-BloodSmacks[i].SmackSize)*StretchLen) * HUDScaleX;
			YL = ((1.0-BloodSmacks[i].SmackSize)*StretchLen) * HUDScaleY;
			if (i == 0)
			{
				// Left...
				C.SetPos( 0, 0 );
				C.DrawTile( BloodSmackTexLeft, XL, YL, 0, 0, BloodSmackSizeX, BloodSmackSizeY);

				C.SetPos( 0, C.ClipY - YL );
				C.DrawTile( BloodSmackTexTop, XL, YL, 0, 0, BloodSmackSizeX, BloodSmackSizeY);
			} else if (i == 1) {
				// Right...
				C.SetPos( C.ClipX - XL, 0 );
				C.DrawTile( BloodSmackTexLeft, XL, YL, 0, 0, BloodSmackSizeX, BloodSmackSizeY,,,,,,true );

				C.SetPos( C.ClipX - XL, C.ClipY - YL );
				C.DrawTile( BloodSmackTexLeft, XL, YL, 0, 0, BloodSmackSizeX, BloodSmackSizeY,,,,,,,true );
			} else if (i == 2) {
				// Down...
				C.SetPos( 0, C.ClipY - YL );
				C.DrawTile( BloodSmackTexTop, XL, YL, 0, 0, BloodSmackSizeX, BloodSmackSizeY );

				C.SetPos( C.ClipX - XL, C.ClipY - YL );
				C.DrawTile( BloodSmackTexTop, XL, YL, 0, 0, BloodSmackSizeX, BloodSmackSizeY,,,,,,true );
			} else if (i == 3) {
				// Up...
				C.SetPos( 0, 0 );
				C.DrawTile( BloodSmackTexLeft, XL, YL, 0, 0, BloodSmackSizeX, BloodSmackSizeY);

				C.SetPos( C.ClipX - XL, 0 );
				C.DrawTile( BloodSmackTexLeft, XL, YL, 0, 0, BloodSmackSizeX, BloodSmackSizeY,,,,,,true );
			}
		}
	}

	C.DrawColor = WhiteColor;
}

simulated function DrawBloodSlash( canvas C )
{
	local float SlashTime, XL, SlashLength;
	local int SlashFrame;
	local texture BloodTex;

	if ( Level.TimeSeconds < 1.0 )
		return;
	if ( BloodSlashType == -1 )
		return;
	C.DrawColor = WhiteColor;
	C.Style = ERenderStyle.STY_Modulated;
	SlashTime = Level.TimeSeconds - BloodSlashTime;
	SlashLength = 0.75;
	if ( (PlayerOwner.GetControlState() == CS_Dead) || (SlashTime < SlashLength) )
	{
		if (PlayerOwner.GetControlState() == CS_Dead)
			SlashFrame = 0;
		else if (SlashTime > SlashLength - 0.05)
			SlashFrame = 3;
		else if (SlashTime > SlashLength - 0.1)
			SlashFrame = 2;
		else if (SlashTime > SlashLength - 0.15)
			SlashFrame = 1;
		else
			SlashFrame = 0;
		C.SetPos( 0, 0 );
		switch (BloodSlashType)
		{
		case 0:
			BloodTex = BloodSlashDown[SlashFrame];
			C.DrawTile( BloodTex, C.ClipX, C.ClipY, 0, 0, BloodTex.USize, BloodTex.VSize );
			break;
		case 1:
			BloodTex = BloodSlashLeft[SlashFrame];
			C.DrawTile( BloodTex, C.ClipX, C.ClipY, 0, 0, BloodTex.USize, BloodTex.VSize,,,,,,,true );
			break;
		case 2:
			BloodTex = BloodSlashLeft[SlashFrame];
			C.DrawTile( BloodTex, C.ClipX, C.ClipY, 0, 0, BloodTex.USize, BloodTex.VSize,,,,,, true, true );
			break;
		case 3:
			BloodTex = BloodSlashDouble[SlashFrame];
			C.DrawTile( BloodTex, C.ClipX, C.ClipY, 0, 0, BloodTex.USize, BloodTex.VSize );
			break;
		case 4:
			BloodTex = BloodSlashOctabrain[SlashFrame];
			C.DrawTile( BloodTex, C.ClipX, C.ClipY, 0, 0, BloodTex.USize, BloodTex.VSize ); //,,,,,,,true );
			break;
		case 5:
			BloodTex = BloodSlashBite[SlashFrame];
			C.DrawTile( BloodTex, C.ClipX, C.ClipY, 0, 0, BloodTex.USize, BloodTex.VSize ); //,,,,,,,true );
			break;
		case 6:
			BloodTex = BloodSlashTail[SlashFrame];
			broadcastmessage(" BLOODTEX: "$BloodTex );
			C.DrawTile( BloodTex, C.ClipX, C.ClipY, 0, 0, BloodTex.USize, BloodTex.VSize ); //,,,,,,,true );
			break;
		case 7:
			BloodTex = BloodSlashRight[SlashFrame];
			C.DrawTile( BloodTex, C.ClipX, C.ClipY, 0, 0, BloodTex.USize, BloodTex.VSize );
			break;
		}
	} else
		BloodSlashType = -1;
	C.Style = ERenderStyle.STY_Translucent;
}

simulated function RegisterBloodSlash(int type)
{
	PlayerOwner.PlaySound(BloodSlashSound, SLOT_Talk);
	BloodSlashTime = Level.TimeSeconds;
	BloodSlashType = type;
}



/*-----------------------------------------------------------------------------
	Debug HUD
-----------------------------------------------------------------------------*/

exec function DebugHUD()
{
	bDrawDebugHUD = !bDrawDebugHUD;
}

simulated function DrawDebugHUD( canvas C )
{
	local float XL, YL, XL2, YL2, XPos, YPos;
	local int i, j, saveRow;
	local Actor A;
	local Texture T;
	local class<Material> M;
	local bool bNoMaterial;
    local MeshInstance minst;
	local Decoration D;
	local int NumDecorations, NumNoneDecos, NumFallingDecos;
	local Inventory Inv;
	local string InvName;
	local DOTAffector CurrentDOT;

	if (DebugFont == None)
		DebugFont = C.CreateTTFont( "Tahoma", 10 );
	C.Font = DebugFont;
	C.Style = ERenderStyle.STY_Normal;

	XPos = 10*HUDScaleX;
	YPos = 64*HUDScaleY;

	// Weapon Status
	C.DrawColor = GoldColor;
	C.SetPos( XPos, YPos );
	C.DrawText( "Weapon Status" );
	C.TextSize( "Weapon Status", XL, YL );
	C.DrawColor = WhiteColor;
	C.SetPos( XPos, YPos+YL );
	C.DrawText( "Class:" );
	C.SetPos( XPos, YPos+YL*2 );
	C.DrawText( "State:" );
	C.SetPos( XPos, YPos+YL*3 );
	C.DrawText( "Sequence:" );
	C.SetPos( XPos, YPos+YL*4 );
	C.DrawText( "bFire:" );
	C.SetPos( XPos, YPos+YL*5 );
	C.DrawText( "CantSendFire:" );
	C.SetPos( XPos, YPos+YL*6 );
	C.DrawText( "WS:" );

	C.TextSize( "PADDING PADDING PAD", XL2, YL2 );
	C.SetPos( XPos + XL2, YPos+YL );
    if ( PlayerOwner.Weapon != None )
    {
    	C.DrawText( PlayerOwner.Weapon.Class );
	    C.SetPos( XPos + XL2, YPos+YL*2 );
	    C.DrawText( PlayerOwner.Weapon.GetStateName() );
	    C.SetPos( XPos + XL2, YPos+YL*3 );
	    C.DrawText( PlayerOwner.Weapon.AnimSequence );
	    C.SetPos( XPos + XL2, YPos+YL*4 );
	    C.DrawText( PlayerOwner.bFire );
	    C.SetPos( XPos + XL2, YPos+YL*5 );
	    C.DrawText( PlayerOwner.Weapon.bCantSendFire );
	    C.SetPos( XPos + XL2, YPos+YL*6 );
	    C.DrawText( PlayerOwner.Weapon.GetWeaponStateString() );
    }
    else
    {
    	C.DrawText( "None" );
	    C.SetPos( XPos + XL2, YPos+YL*2 );
	    C.DrawText( "None" );
	    C.SetPos( XPos + XL2, YPos+YL*3 );
	    C.DrawText( "None" );
	    C.SetPos( XPos + XL2, YPos+YL*4 );
	    C.DrawText( PlayerOwner.bFire );
	    C.SetPos( XPos + XL2, YPos+YL*5 );
	    C.DrawText( "N/A" );
	    C.SetPos( XPos + XL2, YPos+YL*6 );
	    C.DrawText( "N/A" );
    }

	// Look Actor
	C.DrawColor = OrangeColor;
	C.SetPos( XPos, YPos+YL*7 );
	C.DrawText( "Look Actor" );
	C.DrawColor = WhiteColor;
	C.SetPos( XPos, YPos+YL*8 );
	C.DrawText( "Name:" );
	C.SetPos( XPos, YPos+YL*9 );
	C.DrawText( "State:" );
	C.SetPos( XPos, YPos+YL*10 );
	C.DrawText( "Location:" );
	C.SetPos( XPos, YPos+YL*11 );
	C.DrawText( "Rotation:" );
	C.SetPos( XPos, YPos+YL*12 );
	C.DrawText( "Tag:" );

	if ( OldLookActor != None )
	{
		C.SetPos( XPos + XL2, YPos+YL*8 );
		C.DrawText( OldLookActor );
		C.SetPos( XPos + XL2, YPos+YL*9 );
		C.DrawText( OldLookActor.GetStateName() );
		C.SetPos( XPos + XL2, YPos+YL*10 );
		C.DrawText( OldLookActor.Location );
		C.SetPos( XPos + XL2, YPos+YL*11 );
		C.DrawText( OldLookActor.Rotation );
		C.SetPos( XPos + XL2, YPos+YL*12 );
		C.DrawText( OldLookActor.Tag );
		if ( OldLookActor.IsA('PlayerPawn') )
		{
			C.SetPos( XPos, YPos+YL*13 );
			C.DrawText( "Physics:" );
			C.SetPos( XPos, YPos+YL*14 );
			C.DrawText( "UpperBody:" );
			C.SetPos( XPos + XL2, YPos+YL*13 );
			C.DrawText( PlayerPawn(OldLookActor).GetPhysicsString() );
			C.SetPos( XPos + XL2, YPos+YL*14 );
			C.DrawText( PlayerPawn(OldLookActor).GetUpperBodyStateString() );
		}
	}
	else
	{
		C.SetPos( XPos + XL2, YPos+YL*8 );
		C.DrawText( "N/A" );
		C.SetPos( XPos + XL2, YPos+YL*9 );
		C.DrawText( "N/A" );
		C.SetPos( XPos + XL2, YPos+YL*10 );
		C.DrawText( "N/A" );
		C.SetPos( XPos + XL2, YPos+YL*11 );
		C.DrawText( "N/A" );
		C.SetPos( XPos + XL2, YPos+YL*12 );
		C.DrawText( "N/A" );
	}

	// Player Coordinates
	C.DrawColor = GoldColor;
	C.SetPos( XPos, YPos+YL*16 );
	C.DrawText( "Player Coordinates" );
	C.DrawColor = WhiteColor;
	C.SetPos( XPos, YPos+YL*17 );
	C.DrawText( "Location:" );
	C.SetPos( XPos, YPos+YL*18 );
	C.DrawText( "Rotation:" );
	C.SetPos( XPos, YPos+YL*19 );
	C.DrawText( "View Rotation:" );
	C.SetPos( XPos, YPos+YL*20 );
    C.DrawText( "Torso Rotation:" );
	C.SetPos( XPos, YPos+YL*21 );
    C.DrawText( "Leg Yaw(Curr/Dest):" );
	C.SetPos( XPos, YPos+YL*22 );
	C.DrawText( "Acceleration:" );
	C.SetPos( XPos, YPos+YL*23 );
    C.DrawText( "Velocity:" );
	C.SetPos( XPos, YPos+YL*24 );
	C.DrawText( "Speed:" );
	C.SetPos( XPos, YPos+YL*25 );
	C.DrawText( "Standing On:" );
	C.SetPos( XPos, YPos+YL*26 );
	C.DrawText( "Region:" );

	C.SetPos( XPos + XL2, YPos+YL*17 );
	C.DrawText( PlayerOwner.Location );
	C.SetPos( XPos + XL2, YPos+YL*18 );
	C.DrawText( PlayerOwner.Rotation );
	C.SetPos( XPos + XL2, YPos+YL*19 );
	C.DrawText( PlayerOwner.ViewRotation );
	C.SetPos( XPos + XL2, YPos+YL*20 );
	C.DrawText( PlayerOwner.SmoothRotation );
	C.SetPos( XPos + XL2, YPos+YL*21 );
	C.DrawText( PlayerOwner.TorsoTracking.Rotation.Roll@"/"@PlayerOwner.TorsoTracking.DesiredRotation.Roll );
	C.SetPos( XPos + XL2, YPos+YL*22 );
	C.DrawText( PlayerOwner.Acceleration );
	C.SetPos( XPos + XL2, YPos+YL*23 );
	C.DrawText( PlayerOwner.Velocity );
	C.SetPos( XPos + XL2, YPos+YL*24 );
	C.DrawText( VSize(PlayerOwner.Velocity) );

	T = PlayerOwner.TraceTexture( PlayerOwner.Location + vect(0,0,-PlayerOwner.CollisionHeight - 20), PlayerOwner.Location );
	if ( T != None )
	{
		M = T.GetMaterial();
		if ( M != None )
		{
			C.SetPos( XPos + XL2, YPos+YL*25 );
			C.DrawText( M );
		} else
			bNoMaterial = true;
	} else
		bNoMaterial = true;
	if ( bNoMaterial )
	{
		C.SetPos( XPos + XL2, YPos+YL*25 );
		C.DrawText( "None" );
	}
	C.SetPos( XPos + XL2, YPos+YL*26 );
	C.DrawText( PlayerOwner.Region.Zone.ZoneName );


	// Decoration Summary
	foreach AllActors(class'Decoration', D)
	{
		NumDecorations++;
		if ( D.Physics == PHYS_None )
			NumNoneDecos++;
		else if ( D.Physics == PHYS_Falling )
			NumFallingDecos++;
	}
	C.DrawColor = OrangeColor;
	C.SetPos( XPos, YPos+YL*27 );
	C.DrawText("Decoration Summary");
	C.DrawColor = WhiteColor;
	C.SetPos( XPos, YPos+YL*28 );
	C.DrawText("Total Decorations:");
	C.SetPos( XPos, YPos+YL*29 );
	C.DrawText("PHYS_None:");
	C.SetPos( XPos, YPos+YL*30 );
	C.DrawText("PHYS_Falling:");
	C.SetPos( XPos, YPos+YL*31 );
	C.DrawText("Used Item:");
	C.SetPos( XPos, YPos+YL*32 );
	C.DrawText("Overlay Actor:");
	C.SetPos( XPos, YPos+YL*33 );
	C.DrawText("Carried Decoration:");
	C.SetPos( XPos + XL2, YPos+YL*28 );
	C.DrawText(NumDecorations);
	C.SetPos( XPos + XL2, YPos+YL*29 );
	C.DrawText(NumNoneDecos);
	C.SetPos( XPos + XL2, YPos+YL*30 );
	C.DrawText(NumFallingDecos);
	C.SetPos( XPos + XL2, YPos+YL*31 );
	C.DrawText(PlayerOwner.UsedItem);
	C.SetPos( XPos + XL2, YPos+YL*32 );
	C.DrawText(PlayerOwner.OverlayActor);
	C.SetPos( XPos + XL2, YPos+YL*33 );
	C.DrawText(PlayerOwner.CarriedDecoration);

	// Touching Actors
	C.DrawColor = GoldColor;
	C.SetPos( XPos, YPos+YL*35 );
	C.DrawText( "Touching Actors" );
	C.DrawColor = WhiteColor;
	foreach PlayerOwner.TouchingActors( class'Actor', A )
	{
		C.SetPos( XPos, YPos+YL*(36+j) );
		C.DrawText( A );
		j++;
	}

    XPos = (C.ClipX / 2) + 10*HUDScaleX;
	YPos = 64*HUDScaleY;

	i=1;
    // Player State
    C.DrawColor = OrangeColor;
	C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Player States" );
    C.DrawColor = WhiteColor;
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Posture State:");
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Control State:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Movement State:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "UpperBody State:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Turning:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Physics:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Ldder/Rope/Grnd:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "ExplosiveArea:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "PendingWeapon:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "ShieldProtection:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "JetpackState:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "LaisseizFaire:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "BaseEyeHeight:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "EyeHeight:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "CollisionRadius:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "CollisionHeight:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Behindview:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "bAlwaysRelevant:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "bPressedJump:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "bBunnyHop:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Mesh:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Self:" );
	C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "isSpectator:" );
	
	i = 2;
    XL2 += 15;
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.GetPostureStateString() );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.GetControlStateString() );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.GetMovementStateString() );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.GetUpperBodyStateString() );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.bIsTurning );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.GetPhysicsString() );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.bOnLadder @ PlayerOwner.bOnRope @ PlayerOwner.bOnGround );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.ExplosiveArea );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.PendingWeapon );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.ShieldProtection );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.GetJetpackStateString() );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.bLaissezFaireBlending );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.BaseEyeHeight );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.EyeHeight );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.CollisionRadius );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.CollisionHeight );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.bBehindview );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.bAlwaysRelevant );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.bPressedJump );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.bBunnyHop );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.Mesh );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner );
    C.SetPos( XPos + XL2, YPos+YL*i++ );
	bIsSpectator = (((PlayerOwner.PlayerReplicationInfo != None) && (PlayerOwner.PlayerReplicationInfo.bIsSpectator || PlayerOwner.PlayerReplicationInfo.bWaitingPlayer)) || (PlayerOwner.ViewTarget != None));
	C.DrawText( bIsSpectator );

    C.DrawColor = GoldColor;
	C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Player Animation/Frame" );
    C.DrawColor = WhiteColor;
    minst = PlayerOwner.MeshInstance;
    for( j=0; j<4; j++ )
    {
        C.SetPos( XPos, YPos+YL*i++ );
        C.DrawText( "AnimSequence["$j$"]:"$minst.MeshChannels[j].AnimSequence$" : "$minst.MeshChannels[j].AnimFrame$" : "$minst.MeshChannels[j].AnimBlend );
    }

    C.DrawColor = GoldColor;
	C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "View Target" );
    
	saveRow = i;
	C.DrawColor = WhiteColor;
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "ViewTarget:");
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Location:" );
    C.SetPos( XPos, YPos+YL*i++ );
	C.DrawText( "Rotation:" );
    
	i = saveRow;
	C.SetPos( XPos + XL2, YPos+YL*i++ );
	C.DrawText( PlayerOwner.ViewTarget );
	
	if ( PlayerOwner.ViewTarget != None )
	{
	    C.SetPos( XPos + XL2, YPos+YL*i++ );
		C.DrawText( PlayerOwner.ViewTarget.Location );
		C.SetPos( XPos + XL2, YPos+YL*i++ );
		C.DrawText( PlayerOwner.ViewTarget.Rotation );
	}
	else
	{
		i+= 2;
	}

	if ( bShowDOTList )
	{
		// DOT List
		C.DrawColor = OrangeColor;
		C.SetPos( XPos, YPos+YL*i++ );
		C.DrawText( "DOT Affectors" );
		C.DrawColor = WhiteColor;

		for ( CurrentDOT = PlayerOwner.DOTAffectorList; CurrentDOT != None; CurrentDOT = CurrentDOT.NextAffector )
		{
			C.SetPos( XPos, YPos+YL*i );
			C.DrawText( CurrentDOT.Name@CurrentDOT.Type@CurrentDOT.Damage@CurrentDOT.Time@CurrentDOT.Counter@CurrentDOT.Duration@CurrentDOT.TouchingActor );
			i++;
		}

	}
	else
	{
		// Inventory List
		C.DrawColor = OrangeColor;
		C.SetPos( XPos, YPos+YL*i++ );
		C.DrawText( "Inventory/State (Set bShowDOTList for DOT instead)" );
		C.DrawColor = WhiteColor;

		for ( Inv=PlayerOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
		{
			InvName = string(Inv);
			j = InStr( InvName, "." );
			InvName = Right( InvName, Len(InvName) - j - 1 );
			C.SetPos( XPos, YPos+YL*i );
			C.DrawText( InvName );
			C.SetPos( XPos+XL2, YPos+YL*i++ );
			C.DrawText( Inv.GetStateName() );
		}
	}

	C.DrawColor = WhiteColor;
	C.Style = ERenderStyle.STY_Translucent;
}

exec function NetWeapDebugHUD()
{
	bDrawNetWeapDebugHUD = !bDrawNetWeapDebugHUD;
}

simulated function DrawNetWeapDebugHUD( canvas C )
{
	local float XL, YL, XL2, YL2, XPos, YPos;
	local int i, j;
	local Pawn P;
	local Inventory Inv;
	local string InvName;

	if ( DebugFont == None )
		DebugFont = C.CreateTTFont( "Tahoma", 10 );
	C.Font = DebugFont;
	C.Style = ERenderStyle.STY_Normal;

	YPos = 64*HUDScaleY;

	// Draw the weapon status of each pawn.
	C.TextSize( "PADDING PADDING PAD", XL, YL );
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		XPos = 10*HUDScaleX;

		// Weapon Status
		C.DrawColor = WhiteColor;
		C.SetPos( XPos, YPos+YL );
		C.DrawText( "PlayerName:" );
		C.SetPos( XPos, YPos+YL*2 );
		C.DrawText( "Weapon:" );
		C.SetPos( XPos, YPos+YL*3 );
		C.DrawText( "Sequence:" );
		C.SetPos( XPos, YPos+YL*4 );
		C.DrawText( "State:" );

		if ( P.Weapon != None )
		{
			C.SetPos( XPos + XL, YPos+YL );
	    	C.DrawText( P.PlayerReplicationInfo.PlayerName );
		    C.SetPos( XPos + XL, YPos+YL*2 );
			C.DrawText( P.Weapon );
		    C.SetPos( XPos + XL, YPos+YL*3 );
		    C.DrawText( P.Weapon.AnimSequence );
			C.SetPos( XPos + XL, YPos+YL*4 );
		    C.DrawText( P.Weapon.GetStateName() );
		}
		YPos += YL*5;

		XPos = 16*HUDScaleX;
		C.DrawColor = OrangeColor;
		C.SetPos( XPos, YPos );
		C.DrawText( "Inventory" );
		C.DrawColor = WhiteColor;
		for ( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
		{
			YPos += YL;
			InvName = string(Inv);
			j = InStr( InvName, "." );
			InvName = Right( InvName, Len(InvName) - j - 1 );
			C.SetPos( XPos, YPos );
			C.DrawText( InvName );
			C.SetPos( XPos+XL, YPos );
			C.DrawText( Inv.GetStateName() );
		}
		YPos += YL;
	}
}

exec function NetPlayerDebugHUD()
{
	bDrawNetPlayerDebugHUD = !bDrawNetPlayerDebugHUD;
}

simulated function DrawNetPlayerDebugHUD( canvas C )
{
	local float XL, YL, XL2, YL2, XPos, YPos;
	local int i, j;
	local Pawn P;

	if ( DebugFont == None )
		DebugFont = C.CreateTTFont( "Tahoma", 10 );

	C.Font  = DebugFont;
	C.Style = ERenderStyle.STY_Normal;

	YPos = 64*HUDScaleY;

	// Draw the states of each pawn.
	C.TextSize( "PADDING PADDING PAD", XL, YL );
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		XPos = 10*HUDScaleX;

		C.DrawColor = WhiteColor;
		C.SetPos( XPos, YPos+YL );
		C.DrawText( "PlayerName:" );
		C.SetPos( XPos, YPos+YL*2 );
		C.DrawText( "Control State:" );
		C.SetPos( XPos, YPos+YL*3 );
		C.DrawText( "Posture State:" );
		C.SetPos( XPos, YPos+YL*4 );
		C.DrawText( "Movement State:" );

		C.SetPos( XPos + XL, YPos+YL );
	    C.DrawText( P.PlayerReplicationInfo.PlayerName );
		C.SetPos( XPos + XL, YPos+YL*2 );
		C.DrawText( P.GetControlStateString() );
		C.SetPos( XPos + XL, YPos+YL*3 );
		C.DrawText( P.GetPostureStateString() );
		C.SetPos( XPos + XL, YPos+YL*4 );
		C.DrawText( P.GetMovementStateString() );

		YPos += YL*5;
	}
}

exec function ActorDebugHUD()
{
	bDrawActorDebugHUD = !bDrawActorDebugHUD;
}

exec function CorpseDebugHUD()
{
	bDrawCorpseDebugHUD = !bDrawCorpseDebugHUD;
}

exec function DebugActor( string AClass )
{	
	ActorClass = class<Actor>( DynamicLoadObject( AClass, class'Class' ) );
	BroadcastMessage( "Now Debugging" @ ActorClass );
}

exec function DebugActorRadius( int Radius )
{
	ActorRadius = Radius;
	BroadcastMessage( "Debug Actor Radius Change" @ Radius );
}

simulated function DrawCorpseDebugHUD( canvas C )
{
	local float XL, YL, XL2, YL2, XPos, YPos;
	local int i, j;
	local dnCarcass carc;	


	if ( DebugFont == None )
		DebugFont = C.CreateTTFont( "Tahoma", 10 );

	C.Font  = DebugFont;
	C.Style = ERenderStyle.STY_Normal;

	YPos	= 64*HUDScaleY;

	// Draw the states of each class specified	
	C.TextSize( "PADDING PADDING PAD", XL, YL );
	C.DrawColor = WhiteColor;

	foreach AllActors( class'dnCarcass', carc )
	{
		C.SetPos( XPos, YPos+YL );
		C.DrawText( "Name:" $ carc.Name );
		YPos += YL;

		C.SetPos( XPos, YPos+YL );
		C.DrawText( "State:" $ carc.ChunkCarcassState );
		YPos += YL;

		C.SetPos( XPos, YPos+YL );
		C.DrawText( "Hidden:" $ carc.bHidden );
		YPos += YL;

		C.SetPos( XPos, YPos+YL );
		C.DrawText( "bOwnerGetFrameOnly:" $ carc.bOwnerGetFrameOnly );
		YPos += YL;

		YPos += YL;

	}
}


simulated function DrawActorDebugHUD( canvas C )
{
	local float XL, YL, XL2, YL2, XPos, YPos;
	local int i, j;
	local Actor A;	
	local float distance;
	local vector delta;


	if ( DebugFont == None )
		DebugFont = C.CreateTTFont( "Tahoma", 10 );

	C.Font  = DebugFont;
	C.Style = ERenderStyle.STY_Normal;

	YPos	= 64*HUDScaleY;

	// Draw the states of each class specified	
	C.TextSize( "PADDING PADDING PAD", XL, YL );
	C.DrawColor = WhiteColor;

	if ( ActorRadius > 0 )
	{
		foreach Owner.RadiusActors( ActorClass, A, ActorRadius )
		{
			delta		= A.Location - Owner.Location;
			distance	= VSize(delta);
			XPos		= 10*HUDScaleX;

			C.SetPos( XPos, YPos+YL );
			C.DrawText( A.Name $ ":" $ distance );

			YPos += YL;
		}
	}
	else
	{
		foreach AllActors( ActorClass, A )
		{
			delta		= A.Location - Owner.Location;
			distance	= VSize(delta);
			XPos		= 10*HUDScaleX;

			C.SetPos( XPos, YPos+YL );
			C.DrawText( A.Name $ ":" $ distance );

			YPos += YL;
		}
	}
}

/*-----------------------------------------------------------------------------
	Look At Information
-----------------------------------------------------------------------------*/

simulated function DrawLookAtInformation( canvas C )
{
	local string ItemName, SearchString;
	local RenderActor LookActor, TempActor;
	local float XOff, YOff, OldBarPos;
	local float XL, YL, XL2, YL2;
	local float MaxHealth, HealthAmount;
	local int i, j;

	if ( PlayerOwner == None )
		return;

	// No lookat information when using viewmappers.
	// No lookat information when dead
	if ( ( PlayerOwner.ViewMapper != None ) || ( PlayerOwner.GetControlState() == CS_Dead ) )
	{
		LookActor = None;
		OldLookActor = None;
	}

	// Set up drawing environment.
	C.DrawColor = TextColor;
	C.Font = font'HUDFont';
	C.Style = ERenderStyle.STY_Translucent;

	// Find out if we are looking at anything.
	if ( PlayerOwner.CameraStyle == PCS_ZoomMode )
		LookActor = RenderActor(PlayerOwner.TraceFromCrosshair( 2000 ));
	else
	{
		if ( PlayerOwner.LookHitActor == None )
		{
			LookActor = RenderActor(PlayerOwner.TraceFromCrosshair( PlayerOwner.UseDistance ));
			PlayerOwner.LookHitActor = LookActor;
		}
		else
			LookActor = PlayerOwner.LookHitActor;
	}

	if ( LookActor == None )
	{
		OldLookActor = None;
		return;
	}

	// For decorations that have "special look" ask for a look actor.
	if ( LookActor.bSpecialLook )
	{
		TempActor = LookActor.SpecialLook(PlayerOwner);
		if ( TempActor != None )
			LookActor = TempActor;
	}

	// For clients, don't let us look at hidden stuff.
	if ( LookActor.bHidden )
	{
		LookActor = None;
		OldLookActor = None;
		return;
	}

	// Are we looking at a carcass?
	if ( LookActor.IsA('Carcass') )
	{
		// If this is a carcass, build the "can pickup inventory" list.
		if ( LookActor != OldLookActor )
			BuildCanPickupInventoryList( Carcass(LookActor) );
	}

	// Perform the drawing.
	if ( !LookActor.bNotTargetable &&
		 (LookActor.IsA('dnDecoration') || LookActor.IsA('Inventory') ||
		  LookActor.IsA('TriggerCrane') || LookActor.IsA('Mover') || LookActor.IsA('Carcass'))
	   )
	{
		XOff = 340*HUDScaleX;
		YOff = IndexTop - 16*HUDScaleY;

		// Setup the name.
		ItemName = Caps( LookActor.ItemName );
		C.TextSize( ItemName, XL, YL, 0.7*HUDScaleX, 0.7*HUDScaleY );
		C.SetPos( XOff, YOff+16*HUDScaleY );
		C.DrawText( ItemName,,,, 0.7*HUDScaleX, 0.7*HUDScaleY );

		// Draw the health of decorations.
		if ( LookActor.IsA('dnDecoration') )
		{
			if ( DecoHealthItem == None )
				DecoHealthItem = spawn( class'HUDIndexItem_DecoHealth' );

			DecoHealthItem.Value = dnDecoration(LookActor).Health;
			if ( OldLookActor != LookActor )
				DecoHealthItem.LastValue = DecoHealthItem.Value;
			switch ( dnDecoration(LookActor).HealthPrefab )
			{
				case HEALTH_UseHealthVar:
					DecoHealthItem.MaxValue = dnDecoration(LookActor).default.Health;
					break;
				case HEALTH_Easy:
					DecoHealthItem.MaxValue = 1;
					break;
				case HEALTH_Medium:
					DecoHealthItem.MaxValue = 12;
					break;
				case HEALTH_SortaHard:
					DecoHealthItem.MaxValue = 45;
					break;
				case HEALTH_Hard:
					DecoHealthItem.MaxValue = 100;
					break;
				case HEALTH_NeverBreak:
					DecoHealthItem.Value	= 100;
					DecoHealthItem.MaxValue = 100;
					break;
			}

			OldBarPos = BarPos;
			BarPos = XOff;
			DecoHealthItem.DrawItem( C, Self, YOff+18*HUDScaleY+YL );
			BarPos = OldBarPos;
		}

		// Inventory list for carcasses.
		if ( LookActor.IsA('Carcass') && Carcass(LookActor).bSearchable )
		{
			XOff +=16*HUDScaleX;

			C.DrawColor = TextColor;

			C.TextSize( "Inventory", XL2, YL2, 0.5*HUDScaleX, 0.5*HUDScaleY );
			C.SetPos( XOff, YOff+18*HUDScaleY+YL );
			C.DrawText( "Inventory",,,, 0.5*HUDScaleX, 0.5*HUDScaleY );

			if ( dnCarcass(LookActor) != None )
			{
				if ( Carcass(LookActor).bCanHaveCash )
				{
					C.DrawColor = HUDColor;
					C.SetPos( XOff + 70*HUDScaleX*i, YOff+19*HUDScaleY+YL+YL2 );
					C.DrawScaledIcon( class'Money'.default.PickupIcon, HUDScaleX, HUDScaleY );
					i++;
				}
				if ( Carcass(LookActor).AmmoClassAmount > 0 )
				{
					if ( CanPickupInv[0] == 0 )
					{
						C.DrawColor.R = 180;
						C.DrawColor.G = 0;
						C.DrawColor.B = 0;
					} else
						C.DrawColor = HUDColor;
					C.SetPos( XOff + 70*HUDScaleX*i, YOff+19*HUDScaleY+YL+YL2 );
					if ( Carcass(LookActor).AmmoClass != None )
						C.DrawScaledIcon( Carcass(LookActor).AmmoClass.default.PickupIcon, HUDScaleX, HUDScaleY );
					i++;
				}
				for ( j=0; j<5; j++ )
				{
					if ( dnCarcass(LookActor).SearchableItems[j] != None )
					{
						if ( CanPickupInv[j+1] == 0 )
						{
							C.DrawColor.R = 180;
							C.DrawColor.G = 0;
							C.DrawColor.B = 0;
						} else
							C.DrawColor = HUDColor;
						C.SetPos( XOff + 70*HUDScaleX*i, YOff+19*HUDScaleY+YL+YL2 );
						C.DrawScaledIcon( dnCarcass(LookActor).SearchableItems[j].default.PickupIcon, HUDScaleX, HUDScaleY );
						i++;
					}
				}
			}
		}
	}
	C.DrawColor = TextColor;
	OldLookActor = LookActor;
}

simulated function BuildCanPickupInventoryList( Carcass LookCarc )
{
	local int j;
	local Inventory Inv;
	local class<Inventory> InvClass;

	// Clear the list.
	for (j=0; j<6; j++)
	{
		CanPickupInv[j] = 0;
	}

	// Check each item on the new look carcass and see if we can pick it up.
	if ( LookCarc.AmmoClassAmount > 0 )
	{
		if ( LookCarc.AmmoClass.static.CanPickup(PlayerOwner, LookCarc.AmmoClass, Inv) )
			CanPickupInv[0] = 1;
	}
	if ( dnCarcass(LookCarc) != None )
	{
		for (j=0; j<5; j++)
		{
			InvClass = dnCarcass(lookCarc).SearchableItems[j];
			if ( (InvClass != None) && InvClass.static.CanPickup(PlayerOwner, InvClass, Inv) )
				CanPickupInv[j+1] = 1;
		}
	}

}

/*-----------------------------------------------------------------------------
	Mouse click.
-----------------------------------------------------------------------------*/

simulated function bool MouseClick()
{
	local float MouseX, MouseY, XTabPos;

	if ( HUDScaleX != 1.0 )
		return false;

	MouseX = PlayerOwner.Player.Console.MouseX;
	MouseY = PlayerOwner.Player.Console.MouseY;

	// Some silly stuff.
	XTabPos = 274;
	if ( !MiscBarOut && 
		 (MouseX > XTabPos*HUDScaleX) && (MouseX < (XTabPos+48)*HUDScaleX) &&
		 (MouseY > IndexTop+20*HUDScaleY) && (MouseY < IndexTop+84*HUDScaleY) )
	{
		MiscBarOut = true;
		ShowMakersLabel = true;
		return true;
	}
	
	XTabPos += 128+40;
	if ( MiscBarOut &&
		 (MouseX > XTabPos*HUDScaleX) && (MouseX < (XTabPos+48)*HUDScaleX) &&
		 (MouseY > IndexTop+20*HUDScaleY) && (MouseY < IndexTop+84*HUDScaleY) )
	{
		MiscBarOut = false;
		ShowMakersLabel = false;
		return true;
	}

	return false;
}

/*-----------------------------------------------------------------------------
	Status Index functions.
-----------------------------------------------------------------------------*/

simulated function DrawStatusIndex( canvas C )
{
	local float XL, YL, YPos, YMod, OldClipX, OldClipY, TestRoot;
	local texture Tex;
	local int i;

	// Draw the index background bar.
	C.DrawColor = HUDColor;
	C.Style = ERenderStyle.STY_Translucent;
	C.SetPos( 0, IndexTop );
	C.DrawScaledIcon( IndexBarLeftTexture, HUDScaleX, HUDScaleY );
	C.SetPos( 256*HUDScaleX, IndexTop );
	C.DrawScaledIcon( IndexBarRightTexture, HUDScaleX, HUDScaleY );
	C.SetPos( 0, IndexTop + 128*HUDScaleY );
	C.DrawTile( IndexBarBottomTexture, IndexBarBottomTexture.USize*HUDScaleX, 64*HUDScaleY, 0, 0, IndexBarBottomTexture.USize*HUDScaleX, IndexBarBottomTexture.VSize*HUDScaleY );

	// Draw the inventory bar tab.
	if ( !InventoryUp && !PlayCloseInv )
	{
		C.DrawColor = HUDColor;
		C.SetPos( 2*HUDScaleX, IndexTop-22*HUDScaleY );
		OldClipX = C.ClipX;
		OldClipY = C.ClipY;
		C.SetClip( C.ClipX, IndexTop );
		Tex = InventoryBarTopTexture;
		C.DrawScaledIconClipped( Tex, HUDScaleX, HUDScaleY );
		C.SetClip( OldClipX, OldClipY );

	}

	// Draw the misc bar.
	DrawMiscBar( C );

	// Draw the 12 normal items.
	C.DrawColor = HUDColor;
	YMod = IndexTopOffset;
	for ( i=0; i<MaxIndexItems; i++ )
	{
		if ( IndexItems[i] != None )
		{
			if ( !bIsSpectator || ( bIsSpectator && IndexItems[i].bDrawForSpectator && ( PawnOwner != Owner ) ) )
			{
				IndexItems[i].DrawItem( C, self, IndexTop+YMod );
				IndexItems[i].GetSize( C, self, XL, YL );
				YMod += YL;
				if ( YL > 0 )
					YMod += Round(ItemSpace*HUDScaleY);
			}
		}
	}

	// Draw the prompt item if needed.
	if ( PlayerOwner.Player.Console.bTyping )
	{
		PromptItem.DrawItem( C, self, IndexTop+YMod );
		PromptItem.GetSize( C, self, XL, YL );
		YMod += YL + ItemSpace*HUDScaleY;
	}

	TestRoot = RootIndexTop - IndexAdjust*HUDScaleY;
	if ( TestRoot+YMod > 768.0*HUDScaleY )
		DesiredIndexTop = TestRoot - ((TestRoot+YMod) - (768.0*HUDScaleY));
	else
		DesiredIndexTop	= TestRoot;
}

simulated function DrawMiscBar( canvas C )
{
	local texture Tex;
	local float XTabPos, XL, YL;

	XTabPos = 274;
	if ( MiscBarOut )
	{
		// Draw the misc bar.
		C.DrawColor = HUDColor;
		C.SetPos( 274*HUDScaleX, IndexTop+19*HUDScaleY );
		Tex = MiscBarTexture;
		C.DrawScaledIcon( Tex, HUDScaleX, HUDScaleY );
		C.SetPos( (274+128)*HUDScaleX, IndexTop+19*HUDScaleY );
		Tex = MiscBarTexture2;
		C.DrawScaledIcon( Tex, HUDScaleX, HUDScaleY );

		XTabPos += 128+40;
	}

	// Draw the misc bar tab.
	C.DrawColor = HUDColor;
	C.SetPos( XTabPos*HUDScaleX, IndexTop+19*HUDScaleY );
	Tex = MiscBarTabTexture;
	C.DrawScaledIcon( Tex, HUDScaleX, HUDScaleY );

	if ( ShowMakersLabel )
	{
		// Muahaha.
		C.DrawColor = WhiteColor;
		C.SetPos( 300*HUDScaleX, IndexTop+40*HUDScaleY );
		C.Font = C.SmallFont;
		C.DrawText( "Shades Operating System" );
		C.TextSize( "Shades Operating System", XL, YL );
		C.SetPos( 300*HUDScaleX, IndexTop+40*HUDScaleY+YL );
		C.DrawText( "Design by Cozzi" );
		C.SetPos( 300*HUDScaleX, IndexTop+40*HUDScaleY+YL*2 );
		C.DrawText( "Code by Reinhart Labs" );
	}
}

simulated function SetIndexItem( HUDIndexItem NewItem, int i )
{
	IndexItems[i] = NewItem;
	if ( NewItem != None )
		NewItem.SetOwner( PlayerOwner );
}

simulated function RegisterCashItem(HUDIndexItem CashItem)
{
	if ( CashItem == None )
		CashRefs--;
	else
		CashRefs++;
	if ( (CashItem != None) || ( (CashItem == None) && (CashRefs == 0) ) )
	{
		if ( IndexItems[10] != None )
			IndexItems[10].Destroy();
		SetIndexItem( CashItem, 10 );
	}
}

simulated function FlashCash()
{
	if ( CashTime == 0.0 )
		RegisterCashItem( spawn(class'HUDIndexItem_Cash') );
	CashTime = 2.0;
}

simulated function RegisterAirItem( HUDIndexItem NewItem )
{
	if ( IndexItems[5] == None )
		SetIndexItem( NewItem, 5 );
}

simulated function RemoveAirItem()
{
	if ( IndexItems[5] != None )
	{
		IndexItems[5].Destroy();
		IndexItems[5] = None;
	}
}

simulated function RegisterActorHealthItem( HUDIndexItem NewItem )
{
    SetIndexItem( NewItem, 6 );
}

simulated function RemoveActorHealthItem( Actor A )
{
    if( IndexItems[6] != None )
    {
        if ( HUDIndexItem_ActorHealth(IndexItems[5]).healthActor == A )
        {
            IndexItems[6].Destroy();
            IndexItems[6] = None;
        }
    }
}

simulated function RegisterJetpackItem( HUDIndexItem NewItem )
{
	if ( IndexItems[7] == None )
		SetIndexItem( NewItem, 7 );
}

simulated function RemoveJetpackItem()
{
	if ( IndexItems[7] != None )
	{
		IndexItems[7].Destroy();
		IndexItems[7] = None;
	}
}

simulated function RegisterShieldItem( HUDIndexItem NewItem )
{
	if ( IndexItems[4] == None )
		SetIndexItem( NewItem, 4 );
}

simulated function RemoveShieldItem()
{
	if ( IndexItems[4] != None )
	{
		IndexItems[4].Destroy();
		IndexItems[4] = None;
	}
}

simulated function RegisterBombItem( HUDIndexItem NewItem )
{
	if ( IndexItems[8] == None )
		SetIndexItem( NewItem, 8 );
}

simulated function RemoveBombItem()
{
	if ( IndexItems[8] != None )
	{
		IndexItems[8].Destroy();
		IndexItems[8] = None;
	}
}

function OwnerDied()
{
	RemoveAirItem();
}

/*-----------------------------------------------------------------------------
	Threat
-----------------------------------------------------------------------------*/

function color ThreatColor( float distance, float alpha )
{
    if ( distance < 200 )
        return NewColor( 1*alpha, 0, 0 );
    else if ( distance < 1000 )
        return NewColor( 1*alpha, 1*alpha, 0 );
    else
        return NewColor( 0, 1*alpha, 0 );
}

simulated function DrawThreat( canvas Canvas )
{
	local texture Tex;
    local int i;
    local float leftSize,rightSize,startY;

    // If there is some kind of threat to the player, 
    // then draw warning icons in the appropriate color.
    Canvas.Style       = ERenderStyle.STY_Translucent;
	Tex                = texture'hud_effects.am_rpg';
	
    // count how many threats there are to set up the drawing spots for the icons
    for ( i=0; i<6; i++ )
    {
        if ( PlayerOwner.leftThreats[i].Actor != None )
        {
            leftSize += Tex.VSize;
        }
        if ( PlayerOwner.rightThreats[i].Actor != None )
        {
            rightSize += Tex.VSize;
        }
    }

    if ( leftSize != 0 )
    {
        startY = Canvas.ClipY/2 - leftSize/2;
        for( i=0; i<6; i++ )
        {
            if ( PlayerOwner.leftThreats[i].actor == None )
                continue;

            Canvas.DrawColor = ThreatColor( PlayerOwner.leftThreats[i].distance,
                                            PlayerOwner.leftThreats[i].alpha
                                          );
            Canvas.SetPos( 0, startY + Tex.VSize*i );
	        Canvas.DrawTile( Tex, Tex.USize, Tex.VSize, 0, 0, Tex.USize, Tex.VSize );
        }
    }

    if ( rightSize != 0 )
    {
        startY = Canvas.ClipY/2 - rightSize/2;
        for( i=0; i<6; i++ )
        {
            if ( PlayerOwner.rightThreats[i].actor == None )
                continue;

            Canvas.DrawColor = ThreatColor( PlayerOwner.rightThreats[i].distance,
                                            PlayerOwner.rightThreats[i].alpha
                                          );
            Canvas.SetPos( Canvas.ClipX - Tex.USize, startY + Tex.VSize*i );
	        Canvas.DrawTile( Tex, Tex.USize, Tex.VSize, 0, 0, Tex.USize, Tex.VSize );
        }
    }
}

/*-----------------------------------------------------------------------------
	Objectives
-----------------------------------------------------------------------------*/

simulated exec function ShowObjectives()
{
	/*
	if ( bDrawObjectives )
		HideObjectives();
	else
	{
		ObjectivesStart[0].currentFrame = 0;
		ObjectivesStart[1].currentFrame = 0;
		ObjectivesStart[0].pause = false;
		ObjectivesStart[1].pause = false;
		ObjectivesLoop[0].currentFrame = 0;
		ObjectivesLoop[1].currentFrame = 0;
//		PlayerOwner.Player.console.MouseCapture = true;
//		PlayerOwner.InputHookActor = Owner;
		bDrawObjectives = true;
		bObjectivesLoop = false;
	}
	*/
}

simulated function HideObjectives()
{
	/*
	ObjectivesLoop[0].pause = true;
	ObjectivesLoop[1].pause = true;
//	PlayerOwner.Player.console.MouseCapture = false;
//	PlayerOwner.Player.console.MouseLineMode = false;
//	PlayerOwner.InputHookActor = none;
	bDrawObjectives = false;
	*/
}

simulated function DrawObjectives(canvas C)
{
	local float XL, YL, XL2, XPos;
	local int i, j;
	local texture t;

	/*
	C.Font = MediumFont;
	C.DrawColor = HUDColor;

	if ( !bObjectivesLoop )
	{
		C.SetPos( (C.ClipX - 384.f*HUDScaleX) / 2.f, 64.f*HUDScaleY );
		t = ObjectivesStart[0];
		C.DrawTile(t, t.USize * HUDScaleX, t.VSize * HUDScaleY, 0, 0, t.USize, t.VSize);
		C.SetPos( (C.ClipX - 384.f*HUDScaleX) / 2.f + 256.f*HUDScaleX, 64.f*HUDScaleY );
		t = ObjectivesStart[1];
		C.DrawTile(t, t.USize * HUDScaleX, t.VSize * HUDScaleY, 0, 0, t.USize, t.VSize);

		if ( ObjectivesStart[0].currentFrame == 39 )
		{
			ObjectivesStart[0].pause = true;
			ObjectivesStart[1].pause = true;
			ObjectivesLoop[0].pause = false;
			ObjectivesLoop[1].pause = false;
			bObjectivesLoop = true;
		}
	} else {
		C.SetPos( (C.ClipX - 384.f*HUDScaleX) / 2.f, 64.f*HUDScaleY );
		t = ObjectivesLoop[0];
		C.DrawTile(t, t.USize * HUDScaleX, t.VSize * HUDScaleY, 0, 0, t.USize, t.VSize);
		C.SetPos( (C.ClipX - 384.f*HUDScaleX) / 2.f + 256.f*HUDScaleX, 64.f*HUDScaleY );
		t = ObjectivesLoop[1];
		C.DrawTile(t, t.USize * HUDScaleX, t.VSize * HUDScaleY, 0, 0, t.USize, t.VSize);
	}

	// Find the largest objective string.
	for (i=0; i<6; i++)
	{
		if ( Level.ObjectiveInfos[i].Text != "" )
		{
			C.TextSize( Level.ObjectiveInfos[i].Text, XL, YL );
			if ( XL > XL2 )
				XL2 = XL;
		}
	}
	if ( XL2 == 0.f )
		C.TextSize( "No Objectives Available", XL2, YL );
	else
		XL2 += 40.f*HUDScaleX;
	XPos = (C.ClipX - XL2) / 2.f;

	for (i=0; i<6; i++)
	{
		if ( Level.ObjectiveInfos[i].Text != "" )
		{
			C.SetPos( XPos, 160.f*HUDScaleY + 32.f*HUDScaleY*j );

			if ( !Level.ObjectiveInfos[i].Complete )
			{
				C.DrawColor = HUDColor;
				t = ObjectivesCheck;
				C.DrawTile(t, t.USize * HUDScaleX, t.VSize * HUDScaleY, 0, 0, t.USize, t.VSize);
			}
			else
			{
				C.DrawColor.R = HUDColor.R / 4;
				C.DrawColor.G = HUDColor.G / 4;
				C.DrawColor.B = HUDColor.B / 4;
				t = ObjectivesChecked;
				C.DrawTile(t, t.USize * HUDScaleX, t.VSize * HUDScaleY, 0, 0, t.USize, t.VSize);
			}

			C.SetPos( XPos + 40.f*HUDScaleX, 176.f*HUDScaleY + 32.f*HUDScaleY*j );
			C.DrawTextDropShadowed( Level.ObjectiveInfos[i].Text );

			j++;
		}
	}

	if ( j == 0 )
	{
		C.SetPos( XPos, 144.f*HUDScaleY + 32.f*HUDScaleY*j );
		C.DrawTextDropShadowed( "No Objectives Available" );
	}

	C.DrawColor = WhiteColor;
	*/
}

/*-----------------------------------------------------------------------------
	Inventory
-----------------------------------------------------------------------------*/

final function bool pointInRect(int x, int y, int left, int top, int right, int bottom )
{
	if(x<left)   return false;
	if(x>right)  return false;
	if(y<top)	 return false;
	if(y>bottom) return false;
	return true;
}

simulated function CloseInventory()
{
	local int i;

	for ( i=0; i<7; i++ )
		inventoryFade[i] = 0.0;

	PlayOpenInv = false;
	PlayedOpenInv = false;

	MiscBarOut = false;
	ShowMakersLabel = false;

	Super.CloseInventory();
}

simulated function bool DrawInventoryItem( canvas C, int x, int y, inventory Inv, int Row )
{
	local int i, curX, curY, origX, origY;
	local texture t;
	local int ammo, maxAmmo;
	local int altAmmo, maxAltAmmo;
	local int OldFrame;
	local float XL, YL;
	local bool bOutOfAmmo;
	local vector HSV;

	if ( Inv == none )
		return false;
	if ( Inv.icon == none ) 
		return false;

	curX = x;
	curY = y;
	origX = curX;
	origY = curY;

	// Draw the item slant.
	C.DrawColor = HUDColor;
	C.SetPos( curX - 22*HUDScaleX, curY - 5*HUDScaleY );
	C.DrawScaledIcon( ItemSlantTexture, HUDScaleX, HUDScaleY );

	// Draw the item's icon.
	if ( Inv.IsA('dnWeapon') && (dnWeapon(Inv).OutOfAmmo()) )
	{
		bOutOfAmmo = true;
		C.DrawColor = RedColor;
	}

	t = Inv.icon;
	C.SetPos( curX, curY );
	C.DrawScaledIcon( t, HUDScaleX * 0.8, HUDScaleY * 0.8 );

	// Draw out of ammo indicator.
	if ( bOutOfAmmo )
	{
		t = OutOfAmmo;

		C.DrawColor = WhiteColor;
		C.SetPos(curX, curY);
		C.DrawTile(t, t.USize * HUDScaleX, t.VSize * HUDScaleY, 0, 0, t.USize, t.VSize);
	} 
	else if ( !PlayerOwner.bWeaponsActive && Inv.IsA('Weapon') && !Weapon(Inv).bUseAnytime )
	{
		t = SafeModeLabel;
		C.DrawColor = WhiteColor;
		C.SetPos(curX, curY);
		C.DrawTile(t, t.USize * HUDScaleX, t.VSize * HUDScaleY, 0, 0, t.USize, t.VSize);
	}

	// If it's a weapon, ask the weapon to draw its ammo.
	if ( Inv.IsA('dnWeapon') )
		dnWeapon(Inv).DrawAmmoAmount(C, self, curX, curY);
	else
		Inv.DrawChargeAmount(C, self, curX, curY);

	// Highlight it if its selected.
	C.DrawColor = HUDColor;
	if ( !bOutOfAmmo )
	{
		C.SetPos( curX - 16*HUDScaleX, curY );
		if ( PlayerOwner.SelectedItem == Inv )
		{
			C.DrawColor = HUDColor;
			C.SetPos( curX - 21*HUDScaleX, curY - 2*HUDScaleY );
			C.DrawScaledIcon( ItemSlantHLTexture, HUDScaleX, HUDScaleY );

			C.DrawColor = TextColor;
			C.SetPos( 128*HUDScaleX, IndexTop-510.0*HUDScaleY );
			C.Font = font'HUDFont';
			C.DrawText( Inv.ItemName,,,, 0.6*HUDScaleX, 0.6*HUDScaleY );

			C.Style = ERenderStyle.STY_Translucent;
		}
	
		if ( (PlayerOwner.SelectedItem != None) && (OldSelectedItem != PlayerOwner.SelectedItem) )
			PlayerOwner.PlaySound( QMenuHL, SLOT_Interface );
		OldSelectedItem = PlayerOwner.SelectedItem;

		// Update the currently selected item.
		if ( PlayerOwner.Player.console.MouseCapture )
			if( PointInRect(
				PlayerOwner.Player.console.MouseX,
				PlayerOwner.Player.console.MouseY,
				origX, origY, origX+Inv.icon.USize*HUDScaleX, origY+Inv.icon.VSize*HUDScaleY) )
			{
				PlayerOwner.SelectedItem = Inv;
				currentInventoryCategory = i;
				return true;
			}
	}

	return false;
}

simulated function DrawCloseInventorySmack( canvas C )
{
	C.SetPos( 0, IndexTop-478*HUDScaleY );
	C.DrawScaledIcon( InventorySmackTop, HUDScaleX, HUDScaleY );
	C.SetPos( 0, (IndexTop-478*HUDScaleY)+256*HUDScaleY );
	C.DrawScaledIcon( InventorySmackBot, HUDScaleX, HUDScaleY );

	InvSmackTime += Level.TimeSeconds - LastSmackTime;
	LastSmackTime = Level.TimeSeconds;

	if ( InvSmackTime > 0.02 )
	{
		if ( InventorySmackTop.currentFrame == 0 )
		{
			PlayCloseInv = false;
			RegisterCashItem( None );
		}
		else
		{
			InventorySmackTop.currentFrame--;
			InventorySmackBot.currentFrame--;
			InvSmackTime = 0.0;
		}
	}
}

simulated function DrawOpenInventorySmack( canvas C )
{
	C.SetPos( 0, IndexTop-478*HUDScaleY );
	C.DrawScaledIcon( InventorySmackTop, HUDScaleX, HUDScaleY );
	C.SetPos( 0, (IndexTop-478*HUDScaleY)+256*HUDScaleY );
	C.DrawScaledIcon( InventorySmackBot, HUDScaleX, HUDScaleY );

	InvSmackTime += Level.TimeSeconds - LastSmackTime;
	LastSmackTime = Level.TimeSeconds;

	if ( InvSmackTime > 0.02 )
	{
		if ( InventorySmackTop.currentFrame == 2 )
		{
			PlayOpenInv = false;
			PlayedOpenInv = true;
			RegisterCashItem( spawn(class'HUDIndexItem_Cash') );
		}
		else
		{
			InventorySmackTop.currentFrame++;
			InventorySmackBot.currentFrame++;
			InvSmackTime = 0.0;
		}
	}
}

simulated function DrawInventory( canvas C )
{
	local int i, j;
	local float curX, curY, XL, YL;
	local inventory CategoryEntries[7], Inv;
	local bool gotSelectedItem;
	local vector HSV;

	C.DrawColor = HUDColor;

	// If we are tagged to play the closing animation, do it.
	if ( PlayCloseInv )
	{
		DrawCloseInventorySmack( C );
		return;
	}

	// If the inventory is closed, do this.
	if ( currentInventoryCategory < 0 )
	{
		if ( InventoryUp )
		{
			PlayCloseInv = true;
			LastSmackTime = Level.TimeSeconds;
			InvSmackTime = 0.0;
			InventoryUp = false;
			InventorySmackTop.currentFrame = 2;
			InventorySmackBot.currentFrame = 2;
		}
		return;
	}

	// Count down to when we should close.
	if ( InventoryGoAwayDelay > 0 )
	{
		InventoryGoAwayDelay -= Level.TimeDeltaSeconds;
		if ( InventoryGoAwayDelay <= 0 )
		{
			CloseInventory();
			return;
		}
	}

	// Open up.
	if ( !InventoryUp )
	{
		PlayOpenInv = false;
		PlayedOpenInv = false;
	}
	InventoryUp = true;

	// Start the open inventory smack.
	if ( !PlayOpenInv && !PlayedOpenInv )
	{
		PlayOpenInv = true;
		InventorySmackTop.currentFrame = 0;
		InventorySmackBot.currentFrame = 0;
		LastSmackTime = Level.TimeSeconds;
		InvSmackTime = 0.0;
	}

	// Play the open smack.
	if ( PlayOpenInv )
	{
		DrawOpenInventorySmack( C );
		return;
	}

	// When we are done playing the fold out smack, do the hard work.
	if ( !PlayOpenInv && PlayedOpenInv )
	{
		// Draw the bar.
		C.DrawColor = HUDColor;
		C.SetPos( 0, IndexTop-512*HUDScaleY );
		C.DrawScaledIcon( InventoryBarTopTexture, HUDScaleX, HUDScaleY );
		C.SetPos( 0, (IndexTop-512*HUDScaleY)+256*HUDScaleY );
		C.DrawScaledIcon( InventoryBarBotTexture, HUDScaleX, HUDScaleY );

		// Draw the entire inventory.
		curY = (IndexTop - 490*HUDScaleY);
		for ( i=0; i<7; i++ )
		{
			// Draw the circle things.
			HSV = VEC_RGBToHSV( HUDColor );
			HSV.x -= 0.03;
			if ( HSV.x < 0.0 )
				HSV.x = 0.0;
			C.DrawColor = VEC_HSVToRGB( HSV );
			curX = 62*HUDScaleX;
			C.SetPos( curX, curY + 6*HUDScaleY );
			C.DrawScaledIcon( NumberCircleTexture, HUDScaleX, HUDScaleY );

			// Draw the number.
			C.DrawColor = TextColor;
			C.Font = font'hudfont';
			C.TextSize( i+1, XL, YL );
			C.SetPos( curX + 22*HUDScaleX - XL/2, curY + 26*HUDScaleY - YL/2 );
			C.DrawText( i+1,,,, HUDScaleX, HUDScaleY );

			curX = 131*HUDScaleX;
			// Init the list.
			for ( j=0; j<7; j++ )
			{
				CategoryEntries[j] = None;
			}

			// Sort the inventory category.
			for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory )
			{
				if ( (Inv.dnInventoryCategory==i) && (Inv.bActivatable) && (Inv.icon != None) )
					CategoryEntries[Inv.dnCategoryPriority] = Inv;
			}

			// Draw the list.
			for ( j=0; j<7; j++ )
			{
				if ( CategoryEntries[j] != None )
				{
					if ( DrawInventoryItem( C, curX, curY, CategoryEntries[j], i ) )
					{
						PlayerOwner.SelectedItem = CategoryEntries[j];
						currentInventoryCategory = i;
						gotSelectedItem = true;
					}
					curX += (CategoryEntries[j].icon.USize + 32.0) * HUDScaleX * 0.8;
				}
			}

			if ( gotSelectedItem && (currentInventoryCategory > -1) && (i == currentInventoryCategory) )
			{
				C.DrawColor = HUDColor;
				C.SetPos( 32.0*HUDScaleX, curY - 6.0*HUDScaleY );
				C.DrawScaledIcon( InventoryCatHLTexture, HUDScaleX, HUDScaleY );

				HSV = VEC_RGBToHSV( HUDColor );
				HSV.x -= 0.03;
				if ( HSV.x < 0.0 )
					HSV.x = 0.0;
				C.DrawColor = VEC_HSVToRGB( HSV );
				C.SetPos( 9.0*HUDScaleX, curY - 1.0*HUDScaleY );
				C.DrawScaledIcon( InventoryCatHLTexture2, HUDScaleX, HUDScaleY );
			}

			curY += 70.0 * HUDScaleY;
		}
	}

	if ( !gotSelectedItem && PlayerOwner.Player.console.MouseCapture )
		PlayerOwner.SelectedItem = none;
}



/*-----------------------------------------------------------------------------
	Crosshair functions.
-----------------------------------------------------------------------------*/

simulated function DrawCrossHair( canvas C, int X, int Y)
{
	local float XScale;
	local float XLength;
	local texture T;

	if ( (PawnOwner.Weapon == None) || !PawnOwner.Weapon.CanDrawCrosshair() )
		return;

 	if ( Crosshair > 8 )
		return;

	if ( Crosshair == -1 )
	{
		if ( dnWeapon(PawnOwner.Weapon) == None )
			T = CrosshairTextures[0];
		else
			T = CrosshairTextures[dnWeapon(PawnOwner.Weapon).CrosshairIndex];
	} else
		T = CrosshairTextures[Crosshair];

	XScale = FMax( 1, int(0.1 + C.ClipX/640.0) );
	XLength = XScale * T.USize;

	C.SetPos( 0.5 * (C.ClipX - XLength), 0.5 * (C.ClipY - XLength) );

	if ( PlayerOwner.CameraStyle == PCS_HeatVision )
	{
		C.Style = ERenderStyle.STY_Masked;
		C.DrawColor = RedColor;
	}
	else if ( PlayerOwner.CameraStyle == PCS_NightVision )
	{
		C.Style = ERenderStyle.STY_Masked;
		C.DrawColor = WhiteColor;
	}
	else
	{
		C.Style = Style;
		C.DrawColor = HUDColor;
	}

	if ( T != None )
		C.DrawTile( T, XLength, XLength, 0, 0, T.USize, T.VSize );
	C.Style = Style;
}

/*-----------------------------------------------------------------------------
	Prompt functions.
-----------------------------------------------------------------------------*/

simulated function string GetTypingPrompt()
{
	local string TypingPrompt;
	local console Console;

	Console = PlayerOwner.Player.Console;

	TypingPrompt = ">"@Console.TypedStr;
	CursorTime += Level.TimeDeltaSeconds;
	if (CursorTime >= 0.3)
	{
		CursorTime = 0.0;
		TypingCursor = !TypingCursor;
	}
	if (TypingCursor)
		TypingPrompt = TypingPrompt$"_";

	return TypingPrompt;
}

simulated function DrawTypingPrompt( canvas C, console Console )
{
	local string TypingPrompt;
	local float XL, YL, YPos;

	C.DrawColor = TextColor;
	TypingPrompt = "Command >"@Console.TypedStr$"_";
	C.TextSize( TypingPrompt, XL, YL );
	YPos = C.ClipY - YL;
	C.SetPos( 4, YPos );
	C.DrawText( TypingPrompt, false );
	C.DrawColor = WhiteColor;
}


/*-----------------------------------------------------------------------------
	Messaging functions.
-----------------------------------------------------------------------------*/

simulated function DrawMessageArea( canvas C )
{
	local int i, j;
	local float XPos, XL, YL;
	local int YPos, YLines;

	C.Font = font'mainmenufontsmall';

	for (i=0; i<4; i++)
	{
		if (MessageFade[i] < 0.9)
			MessageFade[i] += Level.TimeDeltaSeconds;
		
		if (MessageFade[i] > 0.9)
			MessageFade[i] = 0.9;
		
		if (MessageQueue[i].Message != None)
		{
			if ( MessageQueue[i].Message.Default.bComplexString )
			{
				C.TextSize(	MessageQueue[i].Message.Static.AssembleString( 
							self, 
							MessageQueue[i].Switch, 
							MessageQueue[i].RelatedPRI, 
							MessageQueue[i].StringMessage ),
							MessageQueue[i].XL, MessageQueue[i].YL );
			}
			else
			{
				C.TextSize(MessageQueue[i].StringMessage, MessageQueue[i].XL, MessageQueue[i].YL);
			}

			MessageQueue[i].numLines = 1;
			
			/*
			// FIXME: Enable multiline message support.
			if ( MessageQueue[i].YL > YL )
			{
				MessageQueue[i].numLines++;
				for (j=2; j<5-i; j++)
				{
					if (MessageQueue[i].YL > YL*j)
						MessageQueue[i].numLines++;
				}
			}
			*/

			// Keep track of the amount of lines a message overflows, to offset the next message with.
			
			if ( MessageQueue[i].Message.static.bCenter )
			{
				C.bCenter = true;
				C.SetPos( 0,  MessageQueue[i].Message.static.GetOffset( 
										MessageQueue[i].Switch, 
										MessageQueue[i].YL,
										C.ClipY ) );
			}
			else
			{
				C.bCenter = false;
				C.SetPos( ( IconSize + 15 ) * HUDScaleX, YPos );
				YPos += MessageQueue[i].YL + ItemSpace;	
			}

			YLines += MessageQueue[i].numLines;

//			if ( YLines > 4 )
//				break; 

			if ( MessageQueue[i].Message.Default.bComplexString )
			{
				// Use this for string messages with multiple colors.
				MessageQueue[i].Message.Static.RenderComplexMessage( 
					C,	MessageQueue[i].XL, MessageQueue[i].YL, MessageQueue[i].StringMessage,
					MessageQueue[i].Switch,	MessageQueue[i].RelatedPRI,
					None, MessageQueue[i].OptionalObject);				
			} 
			else
			{
				ScaleColor( C.DrawColor, MessageQueue[i].Message.Default.DrawColor, MessageFade[i] );
				C.DrawText( MessageQueue[i].StringMessage, false );
				C.bCenter = false;
			}
		} 
		else
		{
			YLines++;
		}
	}
	C.Font = SmallFont;
}

// Message: Entry point for string messages.
// Add the string message to the message queue.
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local int i;
	local Class<LocalMessage> MessageClass;

	switch ( MsgType )
	{
		case 'Say':
		case 'TeamSay':
			MessageClass = class'dnSayMessage';
			break;
		case 'Private':
			MessageClass = class'dnPrivateMessage';
			break;
		case 'CriticalEvent':
			MessageClass = class'CriticalString';
			LocalizedMessage( MessageClass, 0, None, None, None, Msg );
			return;
		default:
			MessageClass = class'StringMessage';
			break;
	}

	// Find an empty slot.
	for ( i=0; i<4; i++ )
	{
		if ( MessageQueue[i].Message == None )
		{
			AddMessage( i, MessageClass, PRI, Msg );
			return;
		}
	}

	// No empty slots.  Force a message out.
	for ( i=0; i<3; i++ )
		CopyMessage( MessageQueue[i], MessageQueue[i+1] );

	AddMessage( 3, MessageClass, PRI, Msg );
}

// LocalizedMessage: Entry point for localized message classes.
// Upon receiving a localized message, prepare it to be drawn in the message area.
simulated function LocalizedMessage
	( 
	class<LocalMessage>				Message, 
	optional int					Switch, 
	optional PlayerReplicationInfo	RelatedPRI_1, 
	optional PlayerReplicationInfo	RelatedPRI_2, 
	optional Object					OptionalObject, 
	optional String					CriticalString,
	optional class<Actor>			OptionalClass
	)
{
	local int i;

	// Find an empty slot.
	for ( i=0; i<4; i++ )
	{
		if ( MessageQueue[i].Message == None )
		{
			AddLocalMessage( i, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString, OptionalClass );
			return;
		}
	}

	// No empty slots.  Force a message out.
	for ( i=0; i<3; i++ )
		CopyMessage( MessageQueue[i], MessageQueue[i+1] );

	AddLocalMessage( 3, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, CriticalString, OptionalClass );
}

simulated function AddMessage(int i, class<LocalMessage> Message, PlayerReplicationInfo PRI, string Msg)
{
	MessageFade[i]				= 0.0;
	MessageQueue[i].Message		= Message;
	MessageQueue[i].Switch		= 0;
	MessageQueue[i].RelatedPRI	= PRI;
	MessageQueue[i].EndOfLife	= 3 + Level.TimeSeconds;
	
	if ( Message.Default.bComplexString )
		MessageQueue[i].StringMessage = Msg;
	else
		MessageQueue[i].StringMessage = Message.Static.AssembleString(self,0,PRI,Msg);
}

simulated function AddLocalMessage
(
	int								i,
	class<LocalMessage>				Message, 
	optional int					Switch, 
	optional PlayerReplicationInfo	RelatedPRI_1,
	optional PlayerReplicationInfo	RelatedPRI_2,
	optional Object					OptionalObject, 
	optional String					CriticalString,
	optional class<Actor>			OptionalClass
)
{
	MessageFade[i] = 0.0;
	MessageQueue[i].Message			= Message;
	MessageQueue[i].Switch			= Switch;
	MessageQueue[i].RelatedPRI		= RelatedPRI_1;
	MessageQueue[i].OptionalObject	= OptionalObject;
	MessageQueue[i].EndOfLife		= 3 + Level.TimeSeconds;
	
	if ( Message.Default.bComplexString )
		MessageQueue[i].StringMessage = CriticalString;
	else
		MessageQueue[i].StringMessage = Message.Static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, OptionalClass );
}

simulated function RegisterFadeMessage( string FadeText, int FadeX, int FadeY, font FadeFont, color FadeColor, int MessageIcon, bool Inventory, optional int slot )
{
	local int i, j;

	j = slot;
	for ( i=0; (i<16) && (j==0); i++ )
	{
		if ( FadeMessages[i].Text == "" )
			j = i;
	}
	FadeMessages[j].Text		= FadeText;
	FadeMessages[j].X			= FadeX;
	FadeMessages[j].Y			= FadeY;
	FadeMessages[j].Font		= FadeFont;
	FadeMessages[j].TextColor	= FadeColor;
	FadeMessages[j].Time		= Level.TimeSeconds;
	FadeMessages[j].MessageIcon = MessageIcon;
	FadeMessages[j].Inventory	= Inventory;
	FadeMessages[j].DoneDrawing = false;
}

simulated function RegisterSOSEventMessage( string EventMsg1, string EventMsg2, int X, int Y, int MessageIcon )
{
	/*
	local float XL, YL;
	PlayerOwner.PlaySound( SOSMessageSound, SLOT_Interface );
	PendingEventMsg1 = EventMsg1;
	PendingEventMsg2 = EventMsg2;
	PendingEventX = X;
	PendingEventY = Y;
	PendingIcon = MessageIcon;

//	RegisterFadeMessage( EventMsg1, ,, font'HUDFont', TextColor, 0, false );
*/
}

simulated function bool DisplayMessages(canvas C)
{
	return true;
}

simulated function DrawFadeMessages( canvas C )
{
	local int i, j, cChars, cWholeChars, iconFrame;
	local float XL, YL, X, Y, fadeAmount;
	local string S;
	local texture Tex;
	local float FadeCount, X2, Y2, FadeTime, cTime;
	local int FadeChar, FadeLength;

	C.Style = ERenderStyle.STY_Translucent;

	for (i=0; i<16; i++)
	{
		if (FadeMessages[i].Text != "")
		{
			C.Font = FadeMessages[i].Font;

			cTime = Level.TimeSeconds - FadeMessages[i].Time;

			// Find the right icon frame.
			for (j=0; (j<15) && (iconFrame == 0); j++)
			{
				if (cTime < j*0.1)
					iconFrame = j;
			}
			if (iconFrame == 0)
				iconFrame = 14;
			
			X = FadeMessages[i].X;
			Y = FadeMessages[i].Y;
			j=0;
			if ( !FadeMessages[i].Inventory && FadeMessages[i].DoneDrawing && (Level.TimeSeconds - FadeMessages[i].DoneTime > 2.0) )
			{
				// Faded away, remove it.
				FadeMessages[i].Text = "";
			} 
			else if ( FadeMessages[i].DoneDrawing )
			{
				// Fading away...
				if ( FadeMessages[i].Inventory )
					fadeamount = 1.0;
				else
				{
					fadeAmount = (Level.TimeSeconds - FadeMessages[i].DoneTime) / 5.0;
					fadeAmount = 1.0 - fadeAmount;
				}
				C.DrawColor.R = WhiteColor.R * fadeAmount;
				C.DrawColor.G = WhiteColor.G * fadeAmount;
				C.DrawColor.B = WhiteColor.B * fadeAmount;
				if ( FadeMessages[i].MessageIcon != 0 )
				{
					if (FadeMessages[i].MessageIcon == 1)
						Tex = MessageAnim[iconFrame];
					else if (FadeMessages[i].MessageIcon == 2)
						Tex = LocationAnim[iconFrame];
					C.SetPos( X + (Tex.USize/4)*HUDScaleX, Y );
					C.DrawTile( Tex, (Tex.USize/2)*HUDScaleX, (Tex.VSize/2)*HUDScaleY, 0, 0, Tex.USize, Tex.VSize );
					X += Tex.USize*HUDScaleX;
				}
				C.DrawColor.R = FadeMessages[i].TextColor.R * fadeAmount;
				C.DrawColor.G = FadeMessages[i].TextColor.G * fadeAmount;
				C.DrawColor.B = FadeMessages[i].TextColor.B * fadeAmount;
				C.SetPos( X, Y );
				C.DrawText( FadeMessages[i].Text );
			}
			else
			{
				// Drawing in...
				if ( FadeMessages[i].MessageIcon != 0 )
				{
					if (FadeMessages[i].MessageIcon == 1)
						Tex = MessageAnim[iconFrame];
					else if (FadeMessages[i].MessageIcon == 2)
						Tex = LocationAnim[iconFrame];
					C.SetPos( X + (Tex.USize/4)*HUDScaleX, Y );
					C.DrawColor = WhiteColor;
					C.DrawTile( Tex, (Tex.USize/2)*HUDScaleX, (Tex.VSize/2)*HUDScaleY, 0, 0, Tex.USize, Tex.VSize );
					X += Tex.USize*HUDScaleX;
				}

				X2 = 0; Y2 = 0;
				S = FadeMessages[i].Text;
				FadeTime = Level.TimeSeconds - FadeMessages[i].Time;
				FadeTime *= 3;
				for ( FadeChar = 0; FadeTime - (FadeChar * 0.1) > 0.0; FadeChar++ )
				{
					FadeCount = FadeTime - (FadeChar * 0.1);
					if ((FadeChar == Len(S) - 1) && (255 * (1.0 - FadeCount) < 0))
					{
						FadeMessages[i].DoneDrawing = true;
						FadeMessages[i].DoneTime = Level.TimeSeconds;
					}

					C.DrawColor.R = Min(255 * (0.0 + FadeCount), FadeMessages[i].TextColor.R);
					C.DrawColor.G = Min(255 * (0.0 + FadeCount), FadeMessages[i].TextColor.G);
					C.DrawColor.B = Min(255 * (0.0 + FadeCount), FadeMessages[i].TextColor.B);
					C.SetPos( X+X2, Y+Y2 );
					C.DrawText( Mid(S, FadeChar, 1) );
					C.TextSize( Left(S, FadeChar+1), XL, YL );
					X2 = XL;
					FadeLength = XL;
				}
			}
		}
	}

	C.Style = ERenderStyle.STY_Normal;
}

exec function ResetFade()
{
	local int i;

	for (i=0; i<16; i++)
	{
		FadeMessages[i].Time = Level.TimeSeconds;
	}
}

/*-----------------------------------------------------------------------------
	Display pickup events.
-----------------------------------------------------------------------------*/

simulated function AddPickupEvent( class<Inventory> InvClass )
{
	local int i;

	// Move everything up and add us to the start.
	for (i=6; i>0; i--)
	{
		PickupEvents[i].EventTexture = PickupEvents[i-1].EventTexture;
		PickupEvents[i].EventTime = PickupEvents[i-1].EventTime;
	}
	PickupEvents[0].EventTexture = InvClass.default.PickupIcon;
	PickupEvents[0].EventTime = 5.0;
}

simulated function DrawPickupEvents(Canvas C)
{
	local int i;

	C.DrawColor = HUDColor;
	for (i=0; i<7; i++)
	{
		if (PickupEvents[i].EventTexture != None)
		{
			if (Style == 3)
			{
				C.DrawColor.R = HUDColor.R * (PickupEvents[i].EventTime / 5.0);
				C.DrawColor.G = HUDColor.G * (PickupEvents[i].EventTime / 5.0);
				C.DrawColor.B = HUDColor.B * (PickupEvents[i].EventTime / 5.0);
			}

			C.SetPos( C.ClipX - 70*HUDScaleX - 0.5, int(C.ClipY - 8*HUDScaleY - (70*HUDScaleY*(i+3))) + 0.5 );
			C.DrawIcon( PickupEvents[i].EventTexture, HUDScaleY );
		}
	}
	C.DrawColor = WhiteColor;
}

/*-----------------------------------------------------------------------------
	Damage system functions.
-----------------------------------------------------------------------------*/

simulated function HUDTakeDamage(float HitDamage, vector HitLocation)
{
	local rotator Dir;
	local float Left, Top;

	if (HitDamage <= 1.0)
		return;

	// Calculate the total damage taken this frame.
	FrameDamage -= HitDamage;
/*
	// Determine the screen direction of the damage.
	Dir = PlayerOwner.ViewRotation;
	Top = Normal(PlayerOwner.Location - HitLocation) dot Normal(vector(Dir));
	if (Top >= 0.0)
	{
		// Attack came from the bottom.
		if (BloodSmacks[2].SmackIntensity == 0.0)
		{
			BloodSmacks[2].SmackIntensity = 0.5;
			BloodSmacks[2].SmackSize = 0.3;
		} else
			BloodSmacks[2].SmackIntensity += 0.2;
		if (BloodSmacks[2].SmackIntensity > 0.6)
			BloodSmacks[2].SmackIntensity = 0.6;
	}
	else
	{
		// Attack came from the top.
		if (BloodSmacks[3].SmackIntensity == 0.0)
		{
			BloodSmacks[3].SmackIntensity = 0.5;
			BloodSmacks[3].SmackSize = 0.3;
		} else
			BloodSmacks[3].SmackIntensity += 0.2;
		if (BloodSmacks[3].SmackIntensity > 0.6)
			BloodSmacks[3].SmackIntensity = 0.6;
	}

	Dir = PlayerOwner.ViewRotation;
	Dir.Yaw += 16384;
	Left = Normal(PlayerOwner.Location - HitLocation) dot Normal(vector(Dir));
	if (Left > 0.0)
	{
		// Attack came from the left.
		if (BloodSmacks[0].SmackIntensity == 0.0)
		{
			BloodSmacks[0].SmackIntensity = 0.5;
			BloodSmacks[0].SmackSize = 0.3;
		} else
			BloodSmacks[0].SmackIntensity += 0.2;
		if (BloodSmacks[0].SmackIntensity > 0.6)
			BloodSmacks[0].SmackIntensity = 0.6;
	}
	else if (Left < 0.0)
	{
		// Attack came from the right.
		if (BloodSmacks[1].SmackIntensity == 0.0)
		{
			BloodSmacks[1].SmackIntensity = 0.5;
			BloodSmacks[1].SmackSize = 0.3;
		} else
			BloodSmacks[1].SmackIntensity += 0.2;
		if (BloodSmacks[1].SmackIntensity > 0.6)
			BloodSmacks[1].SmackIntensity = 0.6;
	}
	*/
}

simulated function HUDTakeHeal(float HitHeal)
{
	if (HitHeal <= 0.0)
		return;

	FrameHeal += HitHeal;
}

simulated function HUDAddEnergy(int Energy)
{
	if (Energy <= 0.0)
		return;

	FrameEnergy += Energy;
}

simulated function UpdateHealth( int FrameHealth, optional bool bIsEnergy )
{
	local int i;

	// Add to recent list of health changes.
	for (i=7; i>0; i--)
	{
		HealthChanges[i].HealthDelta = HealthChanges[i-1].HealthDelta;
		HealthChanges[i].Time		 = HealthChanges[i-1].Time;
		HealthChanges[i].bIsEnergy   = HealthChanges[i-1].bIsEnergy;
	}
	HealthChanges[0].HealthDelta = FrameHealth;
	HealthChanges[0].Time		 = Level.TimeSeconds;
	HealthChanges[0].bIsEnergy   = bIsEnergy;
}

simulated function DrawHealthChanges( canvas C )
{
	local float XL, YL, Time;
	local int i;
	local string HealthString;

	if ( FrameHeal != 0 )
		UpdateHealth( FrameHeal );
	if ( FrameDamage != 0 )
		UpdateHealth( FrameDamage );
	if ( FrameEnergy != 0 )
		UpdateHealth( FrameEnergy, true );

	FrameHeal = 0;
	FrameDamage = 0;
	FrameEnergy = 0;

	C.Style = ERenderStyle.STY_Translucent;
	for ( i=0; i<8; i++ )
	{
		Time = Level.TimeSeconds - HealthChanges[i].Time;
		if ( (HealthChanges[i].HealthDelta != 0.0) && (Time < 5.0) )
		{
			if ( HealthChanges[i].HealthDelta < 0.0 )
			{
				C.DrawColor.R = RedColor.R * (1.0 - (Time / 5.0));
				C.DrawColor.G = RedColor.G * (1.0 - (Time / 5.0));
				C.DrawColor.B = RedColor.B * (1.0 - (Time / 5.0));
				HealthString = string(int(HealthChanges[i].HealthDelta));
			}
			else if ( HealthChanges[i].bIsEnergy )
			{
				C.DrawColor.R = GoldColor.R * (1.0 - (Time / 5.0));
				C.DrawColor.G = GoldColor.G * (1.0 - (Time / 5.0));
				C.DrawColor.B = GoldColor.B * (1.0 - (Time / 5.0));
				HealthString = "+"$int(HealthChanges[i].HealthDelta);
			}
			else
			{
				C.DrawColor.R = GreenColor.R * (1.0 - (Time / 5.0));
				C.DrawColor.G = GreenColor.G * (1.0 - (Time / 5.0));
				C.DrawColor.B = GreenColor.B * (1.0 - (Time / 5.0));
				HealthString = "+"$int(HealthChanges[i].HealthDelta);
			}

			C.Font = font'HUDFont';
			C.TextSize( HealthString, XL, YL );
			C.SetPos( 16*HUDScaleX, int(IndexTop - BarOffset - 22*HUDScaleY - ((YL+8*HUDScaleY)*(i+1))) + 0.5 );
			C.DrawText( HealthString );
		}
	}
	C.Style = ERenderStyle.STY_Normal;

	C.DrawColor = WhiteColor;
}



/*-----------------------------------------------------------------------------
	Utilities and command functions.
-----------------------------------------------------------------------------*/

simulated function ScaleColor(out color OutColor, color InColor, float Scale)
{
	OutColor.R = InColor.R * Scale;
	OutColor.G = InColor.G * Scale;
	OutColor.B = InColor.B * Scale;
}

exec function GrowHUD()
{
	if (bHideCrosshair)
		bHideCrosshair = false;
	else if (bHideHUD)
		bHideHUD = false;
}

exec function ShrinkHUD()
{
	if (!bHideHUD)
		bHideHUD = true;
	else if (!bHideCrosshair)
		bHideCrosshair = true;
}



/*-----------------------------------------------------------------------------
	Timing functions.
-----------------------------------------------------------------------------*/

simulated function Tick( float Delta )
{
	local int i;

	Super.Tick( Delta );

	if ( PlayerOwner != None )
	{
		// Check for a change in ego.
		if ( LastFrameEgo > 0 )
		{
			if ( PlayerOwner.Health < LastFrameEgo )
				HUDTakeDamage( LastFrameEgo - PlayerOwner.Health, vect(0,0,0) );
			else if ( PlayerOwner.Health > LastFrameEgo )
				HUDTakeHeal( PlayerOwner.Health - LastFrameEgo );
		}
		LastFrameEgo = PlayerOwner.Health;

		// Check for pickups.
		if ( CurrentPickupsIndex != PlayerOwner.RecentPickupsIndex )
		{
			if ( PlayerOwner.RecentPickupsIndex < CurrentPickupsIndex )
			{
				for ( i=CurrentPickupsIndex; i<6; i++ )
					AddPickupEvent( PlayerOwner.RecentPickups[i] );
				for ( i=0; i<PlayerOwner.RecentPickupsIndex; i++ )
					AddPickupEvent( PlayerOwner.RecentPickups[i] );
			}
			else 
			{
				for ( i=CurrentPickupsIndex; i<PlayerOwner.RecentPickupsIndex; i++ )
					AddPickupEvent( PlayerOwner.RecentPickups[i] );
			}
			CurrentPickupsIndex = PlayerOwner.RecentPickupsIndex;
		}
	}

	// Increment our private timer.
	HUDTimeSeconds += Delta;

	if ( CashTime > 0.0 )
	{
		CashTime -= Delta;
		if ( CashTime <= 0.0 )
		{
			CashTime = 0.0;
			RegisterCashItem( None );
		}
	}
/*
	for ( i=0; i<4; i++ )
	{
		if ( BloodSmacks[i].SmackIntensity > 0.0 )
		{
			BloodSmacks[i].SmackIntensity -= Delta/2;
			if ( BloodSmacks[i].SmackIntensity < 0.0 )
				BloodSmacks[i].SmackIntensity = 0.0;
		}
		if ( BloodSmacks[i].SmackSize > 0.0 )
		{
			BloodSmacks[i].SmackSize -= Delta/5;
			if ( BloodSmacks[i].SmackSize < 0.0 )
				BloodSmacks[i].SmackSize = 0.0;
		}
	}
*/
	for ( i=0; i<7; i++ )
	{
		if ( PickupEvents[i].EventTime > 0.0 )
		{
			PickupEvents[i].EventTime -= Delta;
			if ( PickupEvents[i].EventTime < 0.0 )
			{
				PickupEvents[i].EventTime = 0.0;
				PickupEvents[i].EventTexture = None;
			}
		}
	}

	if ( currentInventoryCategory >= 0 )
	{
		highlightRotation -= Delta*3;
		if ( highlightRotation < 0.0 )
			highlightRotation = 3.14*2;

		if ( PlayerOwner.SelectedItem != None )
		{
			inventoryRotations[currentInventoryCategory] += Delta;
			if ( inventoryRotations[currentInventoryCategory] > 3.14*2 )
				inventoryRotations[currentInventoryCategory] = 0.0;
		}

		for ( i=0; i<7; i++ )
		{
			if ( inventoryFade[i] > 0.0 )
			{
				inventoryFade[i] -= Delta*2;
				if ( inventoryFade[i] < 0.0 )
					inventoryFade[i] = 0.0;
			}
		}
		if ( PlayerOwner.SelectedItem != None )
		{
			inventoryFade[currentInventoryCategory] += Delta*4;
			if ( inventoryFade[currentInventoryCategory] > 1.0 )
				inventoryFade[currentInventoryCategory] = 1.0;
		}
	}

	if ( IndexTop > DesiredIndexTop )
	{
		IndexTop -= Delta*SlideRate;
		if ( IndexTop < DesiredIndexTop )
			IndexTop = DesiredIndexTop;
	}
	else if ( IndexTop < DesiredIndexTop )
	{
		IndexTop += Delta*SlideRate;
		if ( IndexTop > DesiredIndexTop )
			IndexTop = DesiredIndexTop;
	}
}

simulated function Timer(optional int TimerNum)
{
	local int i, j;

	// Age the short message queue.
	for (i=0; i<4; i++)
	{
		// Purge expired messages.
		if ((MessageQueue[i].Message != None) && (Level.TimeSeconds >= MessageQueue[i].EndOfLife))
		{
			for (j=i; j<3; j++)
				CopyMessage(MessageQueue[j],MessageQueue[j+1]);
			ClearMessage(MessageQueue[3]);
		}
	}
}

defaultproperties
{
	LastFrameEgo=100
	LastFrameEnergy=100
    Opacity=0.570000
    CrosshairColor=(G=16)
    TextColor=(R=200,G=200,B=200)
	HUDColor=(R=95,G=255,B=213)
    RootIndexTop=682.0
	IndexAdjust=20.0
	BarOffset=0.0
    MaxIndexItems=12
    ItemSpace=5.0
	TextRightAdjust=76.0
    BarLeft=0.000000
    TitleLeft=6.000000
    TitleOffset=18.000000
    SlideRate=400.000000
	IndexTopOffset=27.0
    IndexName="S.O.S v1"
    GradientTexture=Texture'hud_effects.ingame_hud.ing_gradient1BC'
//    IndexBarTexture=Texture'hud_effects.ingame_hud.ing_greenp1BC'
	IndexBarLeftTexture=texture'hud_effects.ingame_hud.ingame_main1BC'
	IndexBarRightTexture=texture'hud_effects.ingame_hud.ingame_main2BC'
	IndexBarBottomTexture=texture'hud_effects.ingame_hud.ingame_main_repeat1bc'
	InventoryBarTopTexture=texture'hud_effects.ingame_hud.ingame_wepbar1BC'
	InventoryBarBotTexture=texture'hud_effects.ingame_hud.ingame_wepbar2BC'
	MiscBarTabTexture=texture'hud_effects.ingame_hud.ingame_rightslant1BC'
	MiscBarHLTexture=texture'hud_effects.ingame_hud.ingame_miscbar_alert1'
	InventorySmackTop=smackertexture'hud_effects.ingame_hud.ingame_wepbar_topext'
	InventorySmackBot=smackertexture'hud_effects.ingame_hud.ingame_wepbar_botext'
	InventoryCatHLTexture=texture'hud_effects.ingame_hud.ingame_wepbar_highlight1bc'
	InventoryCatHLTexture2=texture'hud_effects.ingame_hud.ingame_wepbar_highlight2bc'
	ItemSlantTexture=texture'hud_effects.ingame_hud.ingame_itemslant1bc'
	ItemSlantHLTexture=texture'hud_effects.ingame_hud.ingame_itemslant_highlightbc'
	MiscBarTexture=texture'hud_effects.ingame_hud.ingame_miscbar1bc'
	MiscBarTexture2=texture'hud_effects.ingame_hud.ingame_miscbar2bc'
	NumberCircleTexture=texture'hud_effects.ingame_hud.ingame_numbercircleBC'
    CrosshairCount=9
    CrosshairTextures(0)=Texture'hud_effects.ingame_hud.crosshair1BC'
    CrosshairTextures(1)=Texture'hud_effects.ingame_hud.crosshair2BC'
    CrosshairTextures(2)=Texture'hud_effects.ingame_hud.crosshair3BC'
    CrosshairTextures(3)=Texture'hud_effects.ingame_hud.crosshair4BC'
    CrosshairTextures(4)=Texture'hud_effects.ingame_hud.crosshair5BC'
    CrosshairTextures(5)=Texture'hud_effects.ingame_hud.crosshair6BC'
    CrosshairTextures(6)=Texture'hud_effects.ingame_hud.crosshair7BC'
    CrosshairTextures(7)=Texture'hud_effects.ingame_hud.crosshair8BC'
    CrosshairTextures(8)=Texture'hud_effects.ingame_hud.crosshair9BC'
    CrosshairTextures(9)=Texture'hud_effects.ingame_hud.crosshair10BC'
    CrosshairTextures(10)=Texture'hud_effects.ingame_hud.crosshair11BC'
    CrosshairTextures(11)=Texture'hud_effects.ingame_hud.crosshair12BC'
    CrosshairTextures(12)=Texture'hud_effects.ingame_hud.crosshair13BC'
    CrosshairTextures(13)=Texture'hud_effects.ingame_hud.crosshair14BC'
    BloodSmackTexLeft=Texture't_generic.bloodsmack.bloodsmack3aRC'
    BloodSmackTexTop=Texture't_generic.bloodsmack.bloodsmack3RC'
    BloodSlashBite(0)=Texture'hud_effects.blood.belloslash1a_01'
    BloodSlashBite(1)=Texture'hud_effects.blood.belloslash1a_02'
    BloodSlashBite(2)=Texture'hud_effects.blood.belloslash1a_03'
    BloodSlashBite(3)=Texture'hud_effects.blood.bloodslashB_03s'
    BloodSlashTail(0)=Texture'hud_effects.blood.belloslash2a_01'
    BloodSlashTail(1)=Texture'hud_effects.blood.belloslash2a_02'	  
    BloodSlashTail(2)=Texture'hud_effects.blood.belloslash2a_03'
    BloodSlashTail(3)=Texture'hud_effects.blood.bloodslashB_03s'
    BloodSlashLeft(0)=Texture'hud_effects.blood.bloodslash1ABC'
    BloodSlashLeft(1)=Texture'hud_effects.blood.bloodslashA_01'
    BloodSlashLeft(2)=Texture'hud_effects.blood.bloodslashA_02'
    BloodSlashLeft(3)=Texture'hud_effects.blood.bloodslashB_03s'
    BloodSlashRight(0)=Texture'hud_effects.blood.bloodslash1ABC'
	BloodSlashRight(1)=Texture'hud_effects.blood.bloodslasha_01'
	BloodSlashRight(2)=Texture'hud_effects.blood.bloodslasha_02'
	BloodSlashRight(3)=Texture'hud_effects.blood.bloodslashB_03s'
    BloodSlashDown(0)=Texture'hud_effects.blood.bloodslash1BBC'
    BloodSlashDown(1)=Texture'hud_effects.blood.bloodslashB_01'
    BloodSlashDown(2)=Texture'hud_effects.blood.bloodslashB_02'
    BloodSlashDown(3)=Texture'hud_effects.blood.bloodslashB_03s'
    BloodSlashDouble(0)=Texture'hud_effects.blood.blooddualslash1ABC'
    BloodSlashDouble(1)=Texture'hud_effects.blood.blooddualslash1A_01'
    BloodSlashDouble(2)=Texture'hud_effects.blood.blooddualslash1A_02'
    BloodSlashDouble(3)=Texture'hud_effects.blood.bloodslashB_03s'
    BloodSlashOctabrain(0)=Texture'hud_effects.blood.blooddualslash2a_01'
    BloodSlashOctabrain(1)=Texture'hud_effects.blood.blooddualslash2a_02'
    BloodSlashOctabrain(2)=Texture'hud_effects.blood.blooddualslash2a_03'
    BloodSlashOctabrain(3)=Texture'hud_effects.blood.bloodslashB_03s'
    BloodSlashSound=Sound'a_creatures.Tentacle.TentacleSlash1'
    bNotFirstDraw=False
    ItemSelectTexture=Texture'hud_effects.ingame_hud.ob_select1bc'
    OutOfAmmo=Texture'hud_effects.Inventory.mitem_noammo'
    InnerCircle=Texture'hud_effects.Inventory.bubbcircle1BC'
    HighlightBubble=Texture'hud_effects.Inventory.bubble1BC'
    OuterCircle=Texture'hud_effects.Inventory.bubb_highlight1'
    highlightRotation=6.280000
    QMenuHL=Sound'a_generic.Menu.QMenuHL1'
    CategoryStrings(0)="Melee"
    CategoryStrings(1)="Assault"
    CategoryStrings(2)="Explosive"
    CategoryStrings(3)="High Tech"
    CategoryStrings(4)="SOS Powers"
    CategoryStrings(5)="Items"
    CategoryStrings(6)="Special"
    DOTTex(0)=Texture'hud_effects.ingame_hud.dmg_electric'
    DOTTex(1)=Texture'hud_effects.ingame_hud.dmg_fire'
    DOTTex(2)=Texture'hud_effects.ingame_hud.dmg_freeze'
    DOTTex(3)=Texture'hud_effects.ingame_hud.dmg_poison'
    DOTTex(4)=Texture'hud_effects.ingame_hud.dmg_radiation'
    DOTTex(5)=Texture'hud_effects.ingame_hud.dmg_toxicchem'
    DOTTex(6)=Texture'hud_effects.ingame_hud.dmg_water'
    DOTTex(7)=Texture'hud_effects.ingame_hud.dmg_steroids'
    DOTTex(8)=Texture'hud_effects.ingame_hud.dmg_shrink'
    DOTTex(9)=Texture'hud_effects.ingame_hud.dmg_expand'
    SafeModeTex=Texture'hud_effects.ingame_hud.dmg_safemode'
    SafeModeLabel=Texture'hud_effects.Inventory.mitem_safemode'
	GreyColor=(R=128,G=128,B=128)
	SOSMessageSound=sound'a_generic.sos.SOSMessage'
	MessageAnim(0)=texture'hud_effects.stat_dwnlobj_00'
	MessageAnim(1)=texture'hud_effects.stat_dwnlobj_01'
	MessageAnim(2)=texture'hud_effects.stat_dwnlobj_02'
	MessageAnim(3)=texture'hud_effects.stat_dwnlobj_03'
	MessageAnim(4)=texture'hud_effects.stat_dwnlobj_04'
	MessageAnim(5)=texture'hud_effects.stat_dwnlobj_06'
	MessageAnim(6)=texture'hud_effects.stat_dwnlobj_10'
	MessageAnim(7)=texture'hud_effects.stat_dwnlobj_14'
	MessageAnim(8)=texture'hud_effects.stat_dwnlobj_18'
	MessageAnim(9)=texture'hud_effects.stat_dwnlobj_18'
	MessageAnim(10)=texture'hud_effects.stat_dwnlobj_18'
	MessageAnim(11)=texture'hud_effects.stat_dwnlobj_18'
	MessageAnim(12)=texture'hud_effects.stat_dwnlobj_18'
	MessageAnim(13)=texture'hud_effects.stat_dwnlobj_18'
	MessageAnim(14)=texture'hud_effects.stat_dwnlobj_18'
	LocationAnim(0)=texture'hud_effects.stat_memobj_00'
	LocationAnim(1)=texture'hud_effects.stat_memobj_01'
	LocationAnim(2)=texture'hud_effects.stat_memobj_02'
	LocationAnim(3)=texture'hud_effects.stat_memobj_03'
	LocationAnim(4)=texture'hud_effects.stat_memobj_05'
	LocationAnim(5)=texture'hud_effects.stat_memobj_10'
	LocationAnim(6)=texture'hud_effects.stat_memobj_05'
	LocationAnim(7)=texture'hud_effects.stat_memobj_10'
	LocationAnim(8)=texture'hud_effects.stat_memobj_05'
	LocationAnim(9)=texture'hud_effects.stat_memobj_10'
	LocationAnim(10)=texture'hud_effects.stat_memobj_05'
	LocationAnim(11)=texture'hud_effects.stat_memobj_10'
	LocationAnim(12)=texture'hud_effects.stat_memobj_05'
	LocationAnim(13)=texture'hud_effects.stat_memobj_10'
	LocationAnim(14)=texture'hud_effects.stat_memobj_03'
	BloodSlashType=-1
	ObjectivesCheck=texture'hud_effects.checkbox_offbc'
	ObjectivesChecked=texture'hud_effects.checkbox_onbc'
	ObjectivesLoop(0)=smackertexture'hud_effects.objleft_loop'
	ObjectivesLoop(1)=smackertexture'hud_effects.objright_loop'
	ObjectivesStart(0)=smackertexture'hud_effects.objleft_start'
	ObjectivesStart(1)=smackertexture'hud_effects.objright_start'
	SpectatorMessage="SPECTATOR MODE"
	SpectatorViewingMessage="Currently Viewing:"
	SpectatorModeMessage="Fly Mode"
	HealthMessage="EGO:"

	HUDTemplateTexture=texture'hud_effects.ingame_hud.ingame_example'
	HUDFont=font'hudfont'

	bDrawPlayerIcons=false
	IconSize=64
	SmallIconSize=16
}
