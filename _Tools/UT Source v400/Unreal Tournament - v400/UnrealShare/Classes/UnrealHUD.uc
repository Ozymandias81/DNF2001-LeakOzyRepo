//=============================================================================
// UnrealHUD
// Parent class of heads up display
//=============================================================================
class UnrealHUD extends HUD;

#exec TEXTURE IMPORT NAME=HalfHud FILE=TEXTURES\HUD\HalfHud.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=HudLine FILE=TEXTURES\HUD\Line.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=HudGreenAmmo FILE=TEXTURES\HUD\greenammo.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=IconHealth FILE=TEXTURES\HUD\i_health.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=IconSelection FILE=TEXTURES\HUD\i_rim.PCX GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=IconSkull FILE=TEXTURES\HUD\i_skull.PCX GROUP="Icons" MIPS=OFF

#exec TEXTURE IMPORT NAME=TranslatorHUD3 FILE=models\TRANHUD3.PCX GROUP="Icons" FLAGS=2 MIPS=OFF

#exec TEXTURE IMPORT NAME=Crosshair1 FILE=Textures\Hud\chair1.PCX GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair2 FILE=Textures\Hud\chair2.PCX GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair3 FILE=Textures\Hud\chair3.PCX GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair4 FILE=Textures\Hud\chair4.PCX GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair5 FILE=Textures\Hud\chair5.PCX GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair6 FILE=Textures\Hud\chair6.PCX GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=Crosshair7 FILE=Textures\Hud\chair7.PCX GROUP="Icons" FLAGS=2 MIPS=OFF

#exec Font Import File=Textures\Lrgred.pcx Name=LargeRedFont
#exec Font Import File=Textures\TinyFont.pcx Name=TinyFont
#exec Font Import File=Textures\TinyFon3.pcx Name=TinyWhiteFont
#exec Font Import File=Textures\TinyFon2.pcx Name=TinyRedFont
#exec Font Import File=Textures\MedFont3.pcx Name=WhiteFont

var int TranslatorTimer;
var() int TranslatorY,CurTranY,SizeY,Count;
var string CurrentMessage;
var bool bDisplayTran, bFlashTranslator;
var float MOTDFadeOutTime;

var float IdentifyFadeTime;
var Pawn IdentifyTarget;

// Identify Strings
var localized string IdentifyName;
var localized string IdentifyHealth;

var() localized string VersionMessage;

var localized string TeamName[4];
var() color TeamColor[4];
var() color AltTeamColor[4];
var color RedColor, GreenColor;

var int ArmorOffset;

// Message Struct
Struct MessageStruct
{
	var name Type;
	var PlayerReplicationInfo PRI;
};

simulated function PostBeginPlay()
{
	MOTDFadeOutTime = 255;

	Super.PostBeginPlay();
}

simulated function ChangeHud(int d)
{
	HudMode = HudMode + d;
	if ( HudMode>5 ) HudMode = 0;
	else if ( HudMode < 0 ) HudMode = 5;
}

simulated function ChangeCrosshair(int d)
{
	Crosshair = Crosshair + d;
	if ( Crosshair>6 ) Crosshair=0;
	else if ( Crosshair < 0 ) Crosshair = 6;
}

simulated function CreateMenu()
{
	if ( PlayerPawn(Owner).bSpecialMenu && (PlayerPawn(Owner).SpecialMenu != None) )
	{
		MainMenu = Spawn(PlayerPawn(Owner).SpecialMenu, self);
		PlayerPawn(Owner).bSpecialMenu = false;
	}
	
	if ( MainMenu == None )
		MainMenu = Spawn(MainMenuType, self);
		
	if ( MainMenu == None )
	{
		PlayerPawn(Owner).bShowMenu = false;
		Level.bPlayersOnly = false;
		return;
	}
	else
	{
		MainMenu.PlayerOwner = PlayerPawn(Owner);
		MainMenu.PlayEnterSound();
		MainMenu.MenuInit();
	}
}

simulated function HUDSetup(canvas canvas)
{
	// Setup the way we want to draw all HUD elements
	Canvas.Reset();
	Canvas.SpaceX=0;
	Canvas.bNoSmooth = True;
	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.b = 255;	
	Canvas.Font = Canvas.LargeFont;
}

simulated function DrawCrossHair( canvas Canvas, int StartX, int StartY )
{
	if (Crosshair>5) Return;
	Canvas.SetPos(StartX, StartY );
	Canvas.Style = 2;
	if		(Crosshair==0) 	Canvas.DrawIcon(Texture'Crosshair1', 1.0);
	else if (Crosshair==1) 	Canvas.DrawIcon(Texture'Crosshair2', 1.0);	
	else if (Crosshair==2) 	Canvas.DrawIcon(Texture'Crosshair3', 1.0);
	else if (Crosshair==3) 	Canvas.DrawIcon(Texture'Crosshair4', 1.0);
	else if (Crosshair==4) 	Canvas.DrawIcon(Texture'Crosshair5', 1.0);	
	else if (Crosshair==5) 	Canvas.DrawIcon(Texture'Crosshair7', 1.0);		
	Canvas.Style = 1;	
}

simulated function DisplayProgressMessage( canvas Canvas )
{
	local int i;
	local float YOffset, XL, YL;

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	Canvas.bCenter = true;
	Canvas.Font = Canvas.MedFont;
	YOffset = 0;
	Canvas.StrLen("TEST", XL, YL);
	for (i=0; i<8; i++)
	{
		Canvas.SetPos(0, 0.25 * Canvas.ClipY + YOffset);
		Canvas.DrawColor = PlayerPawn(Owner).ProgressColor[i];
		Canvas.DrawText(PlayerPawn(Owner).ProgressMessage[i], false);
		YOffset += YL + 1;
	}
	Canvas.bCenter = false;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

simulated function PreRender( canvas Canvas )
{
	if (PlayerPawn(Owner).Weapon != None)
		PlayerPawn(Owner).Weapon.PreRender(Canvas);
}

simulated function DisplayMenu( canvas Canvas )
{
	local float VersionW, VersionH;

	if ( MainMenu == None )
		CreateMenu();
	if ( MainMenu != None )
		MainMenu.DrawMenu(Canvas);

	if ( MainMenu.Class == MainMenuType )
	{
		Canvas.bCenter = false;
		Canvas.Font = Canvas.MedFont;
		Canvas.Style = 1;
		Canvas.StrLen(VersionMessage@Level.EngineVersion, VersionW, VersionH);
		Canvas.SetPos(Canvas.ClipX - VersionW - 4, 4);	
		Canvas.DrawText(VersionMessage@Level.EngineVersion, False);	
	}
}

simulated function PostRender( canvas Canvas )
{
	HUDSetup(canvas);

	if ( PlayerPawn(Owner) != None )
	{
		if ( PlayerPawn(Owner).PlayerReplicationInfo == None )
			return;
		if ( PlayerPawn(Owner).bShowMenu )
		{
			DisplayMenu(Canvas);
			return;
		}
		if ( PlayerPawn(Owner).bShowScores )
		{
			if ( ( PlayerPawn(Owner).Weapon != None ) && ( !PlayerPawn(Owner).Weapon.bOwnsCrossHair ) )
				DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
			if ( (PlayerPawn(Owner).Scoring == None) && (PlayerPawn(Owner).ScoringType != None) )
				PlayerPawn(Owner).Scoring = Spawn(PlayerPawn(Owner).ScoringType, PlayerPawn(Owner));
			if ( PlayerPawn(Owner).Scoring != None )
			{ 
				PlayerPawn(Owner).Scoring.ShowScores(Canvas);
				return;
			}
		}
		else if ( (PlayerPawn(Owner).Weapon != None) && (Level.LevelAction == LEVACT_None) )
		{
			Canvas.Font = Font'WhiteFont';
			PlayerPawn(Owner).Weapon.PostRender(Canvas);
			if ( !PlayerPawn(Owner).Weapon.bOwnsCrossHair )
				DrawCrossHair(Canvas, 0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8);
		}

		if ( PlayerPawn(Owner).ProgressTimeOut > Level.TimeSeconds )
			DisplayProgressMessage(Canvas);

	}

	if (HudMode==5) 
	{
		DrawInventory(Canvas, Canvas.ClipX-96, 0,False);		
		Return;
	}
	if (Canvas.ClipX<320) HudMode = 4;

	// Draw Armor
	if (HudMode<2) DrawArmor(Canvas, 0, 0,False);
	else if (HudMode==3 || HudMode==2) DrawArmor(Canvas, 0, Canvas.ClipY-32,False);
	else if (HudMode==4) DrawArmor(Canvas, Canvas.ClipX-64, Canvas.ClipY-64,True);
	
	// Draw Ammo
	if (HudMode!=4) DrawAmmo(Canvas, Canvas.ClipX-48-64, Canvas.ClipY-32);
	else DrawAmmo(Canvas, Canvas.ClipX-48, Canvas.ClipY-32);
	
	// Draw Health
	if (HudMode<2) DrawHealth(Canvas, 0, Canvas.ClipY-32);
	else if (HudMode==3||HudMode==2) DrawHealth(Canvas, Canvas.ClipX-128, Canvas.ClipY-32);
	else if (HudMode==4) DrawHealth(Canvas, Canvas.ClipX-64, Canvas.ClipY-32);
		
	// Display Inventory
	if (HudMode<2) DrawInventory(Canvas, Canvas.ClipX-96, 0,False);
	else if (HudMode==3) DrawInventory(Canvas, Canvas.ClipX-96, Canvas.ClipY-64,False);
	else if (HudMode==4) DrawInventory(Canvas, Canvas.ClipX-64, Canvas.ClipY-64,True);
	else if (HudMode==2) DrawInventory(Canvas, Canvas.ClipX/2-64, Canvas.ClipY-32,False);	

	// Display Frag count
	if ( (Level.Game == None) || Level.Game.bDeathMatch ) 
	{
		if (HudMode<3) DrawFragCount(Canvas, Canvas.ClipX-32,Canvas.ClipY-64);
		else if (HudMode==3) DrawFragCount(Canvas, 0,Canvas.ClipY-64);
		else if (HudMode==4) DrawFragCount(Canvas, 0,Canvas.ClipY-32);
	}

	// Display Identification Info
	DrawIdentifyInfo(Canvas, 0, Canvas.ClipY - 64.0);

	// Message of the Day / Map Info Header
	if (MOTDFadeOutTime != 0.0)
		DrawMOTD(Canvas);

	// Team Game Synopsis
	if ( PlayerPawn(Owner) != None )
	{
		if ( (PlayerPawn(Owner).GameReplicationInfo != None) && PlayerPawn(Owner).GameReplicationInfo.bTeamGame)
			DrawTeamGameSynopsis(Canvas);
	}
}

simulated function DrawTeamGameSynopsis(Canvas Canvas)
{
	local TeamInfo TI;
	local float XL, YL;

	foreach AllActors(class'TeamInfo', TI)
	{
		if (TI.Size > 0)
		{
			Canvas.Font = Font'WhiteFont';
			Canvas.DrawColor = TeamColor[TI.TeamIndex]; 
			Canvas.StrLen(TeamName[TI.TeamIndex], XL, YL);
			Canvas.SetPos(0, Canvas.ClipY - 128 + 16 * TI.TeamIndex);
			Canvas.DrawText(TeamName[TI.TeamIndex], false);
			Canvas.SetPos(XL, Canvas.ClipY - 128 + 16 * TI.TeamIndex);
			Canvas.DrawText(int(TI.Score), false);
		}
	}

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

simulated function DrawFragCount(Canvas Canvas, int X, int Y)
{
	Canvas.SetPos(X,Y);
	Canvas.DrawIcon(Texture'IconSkull', 1.0);	
	Canvas.CurX -= 19;
	Canvas.CurY += 23;
	if ( Pawn(Owner).PlayerReplicationInfo == None )
		return;
	Canvas.Font = Font'TinyWhiteFont';
	if (Pawn(Owner).PlayerReplicationInfo.Score<100) 
		Canvas.CurX+=6;
	if (Pawn(Owner).PlayerReplicationInfo.Score<10) 
		Canvas.CurX+=6;	
	if (Pawn(Owner).PlayerReplicationInfo.Score<0) 
		Canvas.CurX-=6;
	if (Pawn(Owner).PlayerReplicationInfo.Score<-9)
		Canvas.CurX-=6;
	Canvas.DrawText(int(Pawn(Owner).PlayerReplicationInfo.Score),False);
				
}

simulated function DrawInventory(Canvas Canvas, int X, int Y, bool bDrawOne)
{	
	local bool bGotNext, bGotPrev, bGotSelected;
	local inventory Inv,Prev, Next, SelectedItem;
	local translator Translator;
	local int TempX,TempY, HalfHUDX, HalfHUDY, AmmoIconSize, i;

	if ( HudMode < 4 ) //then draw HalfHUD
	{
		Canvas.Font = Font'TinyFont';
		HalfHUDX = Canvas.ClipX-64;
		HalfHUDY = Canvas.ClipY-32;
		Canvas.CurX = HalfHudX;
		Canvas.CurY = HalfHudY;
		Canvas.DrawIcon(Texture'HalfHud', 1.0);	
	}

	if ( Owner.Inventory==None) Return;
	bGotSelected = False;
	bGotNext = false;
	bGotPrev = false;
	Prev = None;
	Next = None;
	SelectedItem = Pawn(Owner).SelectedItem;

	for ( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( !bDrawOne ) // if drawing more than one inventory, find next and previous items
		{
			if ( Inv == SelectedItem )
				bGotSelected = True;
			else if ( Inv.bActivatable )
			{
				if ( bGotSelected )
				{
					if ( !bGotNext )
					{
						Next = Inv;
						bGotNext = true;
					}
					else if ( !bGotPrev )
						Prev = Inv;
				}
				else
				{
					if ( Next == None )
						Next = Prev;
					Prev = Inv;
					bGotPrev = True;
				}
			}
		}
		
		if ( Translator(Inv) != None )
			Translator = Translator(Inv);

		if ( (HudMode < 4) && (Inv.InventoryGroup>0) && (Weapon(Inv)!=None) ) 
		{
			if (Pawn(Owner).Weapon == Inv) Canvas.Font = Font'TinyWhiteFont';
			else Canvas.Font = Font'TinyFont';
			Canvas.CurX = HalfHudX-3+Inv.InventoryGroup*6;
			Canvas.CurY = HalfHudY+4;
			if (Inv.InventoryGroup<10) Canvas.DrawText(Inv.InventoryGroup,False);
			else Canvas.DrawText("0",False);
		}
		
		
		if ( (HudMode < 4) && (Ammo(Inv)!=None) ) 
		{
			for (i=0; i<10; i++)
			{
				if (Ammo(Inv).UsedInWeaponSlot[i]==1)
				{
					Canvas.CurX = HalfHudX+3+i*6;
					if (i==0) Canvas.CurX += 60;
					Canvas.CurY = HalfHudY+11;
					AmmoIconSize = 16.0*FMin(1.0,(float(Ammo(Inv).AmmoAmount)/float(Ammo(Inv).MaxAmmo)));
					if (AmmoIconSize<8 && Ammo(Inv).AmmoAmount<10 && Ammo(Inv).AmmoAmount>0) 
					{
						Canvas.CurX -= 6;			
						Canvas.CurY += 5;
						Canvas.Font = Font'TinyRedFont';
						Canvas.DrawText(Ammo(Inv).AmmoAmount,False);				
						Canvas.CurY -= 12;
					}
					Canvas.CurY += 19-AmmoIconSize;
					Canvas.CurX -= 6;
					Canvas.DrawColor.g = 255;
					Canvas.DrawColor.r = 0;		
					Canvas.DrawColor.b = 0;					
					if (AmmoIconSize<8) 
					{
						Canvas.DrawColor.r = 255-AmmoIconSize*30;
						Canvas.DrawColor.g = AmmoIconSize*30+40;				
					}
					if (Ammo(Inv).AmmoAmount >0) 
					{
						Canvas.DrawTile(Texture'HudGreenAmmo',4.0,AmmoIconSize,0,0,4.0,AmmoIconSize);		
					}
					Canvas.DrawColor.g = 255;
					Canvas.DrawColor.r = 255;		
					Canvas.DrawColor.b = 255;	
				}
			}
		}


		
	}

	// List Translator messages if activated
	if ( Translator!=None )
	{
		if( Translator.bCurrentlyActivated )
		{
			Canvas.bCenter = false;
			Canvas.Font = Canvas.MedFont;
			TempX = Canvas.ClipX;
			TempY = Canvas.ClipY;
			CurrentMessage = Translator.NewMessage;
			Canvas.Style = 2;	
			Canvas.SetPos(Canvas.ClipX/2-128, Canvas.ClipY/2-68);
			Canvas.DrawIcon(texture'TranslatorHUD3', 1.0);
			Canvas.SetOrigin(Canvas.ClipX/2-110,Canvas.ClipY/2-52);
			Canvas.SetClip(225,110);
			Canvas.SetPos(0,0);
			Canvas.Style = 1;	
			Canvas.DrawText(CurrentMessage, False);	
			HUDSetup(canvas);	
			Canvas.ClipX = TempX;
			Canvas.ClipY = TempY;
		}
		else 
			bFlashTranslator = ( Translator.bNewMessage || Translator.bNotNewMessage );
	}

	if ( HUDMode == 5 )
		return;

	if ( SelectedItem != None )
	{	
		Count++;
		if (Count>20) Count=0;
		
		if (Prev!=None) 
		{
			if ( Prev.bActive || (bFlashTranslator && (Translator == Prev) && (Count>15)) )
			{
				Canvas.DrawColor.b = 0;		
				Canvas.DrawColor.g = 0;		
			}
			DrawHudIcon(Canvas, X, Y, Prev);				
			if ( (Pickup(Prev) != None) && Pickup(Prev).bCanHaveMultipleCopies )
				DrawNumberOf(Canvas,Pickup(Prev).NumCopies,X,Y);
			Canvas.DrawColor.b = 255;
			Canvas.DrawColor.g = 255;		
		}
		if ( SelectedItem.Icon != None )	
		{
			if ( SelectedItem.bActive || (bFlashTranslator && (Translator == SelectedItem) && (Count>15)) )
			{
				Canvas.DrawColor.b = 0;		
				Canvas.DrawColor.g = 0;		
			}
			if ( (Next==None) && (Prev==None) && !bDrawOne) DrawHudIcon(Canvas, X+64, Y, SelectedItem);
			else DrawHudIcon(Canvas, X+32, Y, SelectedItem);		
			Canvas.Style = 2;
			Canvas.CurX = X+32;
			if ( (Next==None) && (Prev==None) && !bDrawOne ) Canvas.CurX = X+64;
			Canvas.CurY = Y;
			Canvas.DrawIcon(texture'IconSelection', 1.0);
			if ( (Pickup(SelectedItem) != None) 
				&& Pickup(SelectedItem).bCanHaveMultipleCopies )
				DrawNumberOf(Canvas,Pickup(SelectedItem).NumCopies,Canvas.CurX-32,Y);
			Canvas.Style = 1;
			Canvas.DrawColor.b = 255;
			Canvas.DrawColor.g = 255;		
		}
		if (Next!=None) {
			if ( Next.bActive || (bFlashTranslator && (Translator == Next) && (Count>15)) )
			{
				Canvas.DrawColor.b = 0;		
				Canvas.DrawColor.g = 0;		
			}
			DrawHudIcon(Canvas, X+64, Y, Next);
			if ( (Pickup(Next) != None) && Pickup(Next).bCanHaveMultipleCopies )
				DrawNumberOf(Canvas,Pickup(Next).NumCopies,Canvas.CurX-32,Y);
			Canvas.DrawColor.b = 255;
			Canvas.DrawColor.g = 255;
		}
	}
}

simulated function DrawNumberOf(Canvas Canvas, int NumberOf, int X, int Y)
{
	local int TempX,TempY;
	
	if (NumberOf<=0) Return;
	
	Canvas.CurX = X + 14;
	Canvas.CurY = Y + 20;
	NumberOf++;
	if (NumberOf<100) Canvas.CurX+=6;
	if (NumberOf<10) Canvas.CurX+=6;	
	Canvas.Font = Font'TinyRedFont';						
	Canvas.DrawText(NumberOf,False);			
}

simulated function DrawArmor(Canvas Canvas, int X, int Y, bool bDrawOne)
{
	Local int ArmorAmount,CurAbs;
	Local inventory Inv,BestArmor;
	Local float XL, YL;

	ArmorAmount = 0;
	ArmorOffset = 0;
	Canvas.Font = Canvas.LargeFont;
	Canvas.CurX = X;
	Canvas.CurY = Y;
	CurAbs=0;
	BestArmor=None;
	for( Inv=Owner.Inventory; Inv!=None; Inv=Inv.Inventory ) 
	{
		if (Inv.bIsAnArmor) 
		{
			ArmorAmount += Inv.Charge;				
			if (Inv.Charge>0 && Inv.Icon!=None) 
			{
				if (!bDrawOne) 
				{
					ArmorOffset += 32;
					DrawHudIcon(Canvas, Canvas.CurX, Y, Inv);
					DrawIconValue(Canvas, Inv.Charge);						
				}
				else if (Inv.ArmorAbsorption>CurAbs) 
				{
					CurAbs = Inv.ArmorAbsorption;
					BestArmor = Inv;
				}
			}
		}
	}
	if (bDrawOne && BestArmor!=None) 
	{
		DrawHudIcon(Canvas, Canvas.CurX, Y, BestArmor);
		DrawIconValue(Canvas, BestArmor.Charge);		
	}
	Canvas.CurY = Y;
	if (ArmorAmount>0 && HudMode==0) {
		Canvas.StrLen(ArmorAmount,XL,YL);
		ArmorOffset += XL;
		Canvas.DrawText(ArmorAmount,False);	
	}
}

// Draw the icons value in text on the icon
//
simulated function DrawIconValue(Canvas Canvas, int Amount)
{
	local int TempX,TempY;

	if (HudMode==0 || HudMode==3) Return;

	TempX = Canvas.CurX;
	TempY = Canvas.CurY;
	Canvas.CurX -= 20;
	Canvas.CurY -= 5;
	if (Amount<100) Canvas.CurX+=6;
	if (Amount<10) Canvas.CurX+=6;	
	Canvas.Font = Font'TinyFont';						
	Canvas.DrawText(Amount,False);
	Canvas.Font = Canvas.LargeFont;
	Canvas.CurX = TempX;
	Canvas.CurY = TempY;						
}

simulated function DrawAmmo(Canvas Canvas, int X, int Y)
{
	if ( (Pawn(Owner).Weapon == None) || (Pawn(Owner).Weapon.AmmoType == None) )
		return;
	Canvas.CurY = Y;
	Canvas.CurX = X;
	Canvas.Font = Canvas.LargeFont;
	if (Pawn(Owner).Weapon.AmmoType.AmmoAmount<10) Canvas.Font = Font'LargeRedFont';	
	if (HudMode==0) {
		if (Pawn(Owner).Weapon.AmmoType.AmmoAmount>=100) Canvas.CurX -= 16;
		if (Pawn(Owner).Weapon.AmmoType.AmmoAmount>=10) Canvas.CurX -= 16;
		Canvas.DrawText(Pawn(Owner).Weapon.AmmoType.AmmoAmount,False);
		Canvas.CurY = Canvas.ClipY-32;
	}
	else Canvas.CurX+=16;
	if (Pawn(Owner).Weapon.AmmoType.Icon!=None) Canvas.DrawIcon(Pawn(Owner).Weapon.AmmoType.Icon, 1.0);
	Canvas.CurY += 29;
	DrawIconValue(Canvas, Pawn(Owner).Weapon.AmmoType.AmmoAmount);
	Canvas.CurX = X+19;
	Canvas.CurY = Y+29;
	if (HudMode!=1 && HudMode!=2 && HudMode!=4)  Canvas.DrawTile(Texture'HudLine',
		FMin(27.0*(float(Pawn(Owner).Weapon.AmmoType.AmmoAmount)/float(Pawn(Owner).Weapon.AmmoType.MaxAmmo)),27),2.0,0,0,32.0,2.0);
}

simulated function DrawHealth(Canvas Canvas, int X, int Y)
{
	Canvas.CurY = Y;
	Canvas.CurX = X;	
	Canvas.Font = Canvas.LargeFont;
	if (Pawn(Owner).Health<25) Canvas.Font = Font'LargeRedFont';
	Canvas.DrawIcon(Texture'IconHealth', 1.0);
	Canvas.CurY += 29;	
	DrawIconValue(Canvas, Max(0,Pawn(Owner).Health));
	Canvas.CurY -= 29;		
	if (HudMode==0) Canvas.DrawText(Max(0,Pawn(Owner).Health),False);	
	Canvas.CurY = Y+29;		
	Canvas.CurX = X+2;
	if (HudMode!=1 && HudMode!=2 && HudMode!=4) 
		Canvas.DrawTile(Texture'HudLine',FMin(27.0*(float(Pawn(Owner).Health)/float(Pawn(Owner).Default.Health)),27),2.0,0,0,32.0,2.0);	
}

simulated function DrawHudIcon(Canvas Canvas, int X, int Y, Inventory Item)
{
	Local int Width;
	if (Item.Icon==None) Return;
	Width = Canvas.CurX;
	Canvas.CurX = X;
	Canvas.CurY = Y;
	Canvas.DrawIcon(Item.Icon, 1.0);
	Canvas.CurX -= 30;
	Canvas.CurY += 28;
	if ((HudMode!=2 && HudMode!=4 && HudMode!=1) || !Item.bIsAnArmor)
		Canvas.DrawTile(Texture'HudLine',fMin(27.0,27.0*(float(Item.Charge)/float(Item.Default.Charge))),2.0,0,0,32.0,2.0);
	Canvas.CurX = Width + 32;
}

simulated function DrawTypingPrompt( canvas Canvas, console Console )
{
	local string TypingPrompt;
	local float XL, YL;

	if ( Console.bTyping )
	{
		Canvas.DrawColor.r = 0;
		Canvas.DrawColor.g = 255;
		Canvas.DrawColor.b = 0;	
		TypingPrompt = "(> "$Console.TypedStr$"_";
		Canvas.Font = Font'WhiteFont';
		Canvas.StrLen( TypingPrompt, XL, YL );
		Canvas.SetPos( 2, Console.FrameY - Console.ConsoleLines - YL - 1 );
		Canvas.DrawText( TypingPrompt, false );
	}
}

simulated function bool DisplayMessages( canvas Canvas )
{
	local string TypingPrompt;
	local float XL, YL;
	local int I, J, YPos, ExtraSpace;
	local float PickupColor;
	local console Console;
	local inventory Inv;
	local MessageStruct ShortMessages[4];
	local string MessageString[4];
	local name MsgType;

	Console = PlayerPawn(Owner).Player.Console;

	Canvas.Font = Font'WhiteFont';

	if ( !Console.Viewport.Actor.bShowMenu )
		DrawTypingPrompt(Canvas, Console);

	if ( (Console.TextLines > 0) && (!Console.Viewport.Actor.bShowMenu || Console.Viewport.Actor.bShowScores) )
	{
		MsgType = Console.GetMsgType(Console.TopLine);
		if ( MsgType == 'Pickup' )
		{
			Canvas.bCenter = true;
			if ( Level.bHighDetailMode )
				Canvas.Style = ERenderStyle.STY_Translucent;
			else
				Canvas.Style = ERenderStyle.STY_Normal;
			PickupColor = 42.0 * FMin(6, Console.GetMsgTick(Console.TopLine));
			Canvas.DrawColor.r = PickupColor;
			Canvas.DrawColor.g = PickupColor;
			Canvas.DrawColor.b = PickupColor;
			Canvas.SetPos(4, Console.FrameY - 44);
			Canvas.DrawText( Console.GetMsgText(Console.TopLine), true );
			Canvas.bCenter = false;
			Canvas.Style = 1;
			J = Console.TopLine - 1;
		} 
		else if ( (MsgType == 'CriticalEvent') || (MsgType == 'LowCriticalEvent')
					|| (MsgType == 'RedCriticalEvent') ) 
		{
			Canvas.bCenter = true;
			Canvas.Style = 1;
			Canvas.DrawColor.r = 0;
			Canvas.DrawColor.g = 128;
			Canvas.DrawColor.b = 255;
			if ( MsgType == 'CriticalEvent' ) 
				Canvas.SetPos(0, Console.FrameY/2 - 32);
			else if ( MsgType == 'LowCriticalEvent' ) 
				Canvas.SetPos(0, Console.FrameY/2 + 32);
			else if ( MsgType == 'RedCriticalEvent' ) {
				PickupColor = 42.0 * FMin(6, Console.GetMsgTick(Console.TopLine));
				Canvas.DrawColor.r = PickupColor;
				Canvas.DrawColor.g = 0;
				Canvas.DrawColor.b = 0;	
				Canvas.SetPos(4, Console.FrameY - 44);
			}

			Canvas.DrawText( Console.GetMsgText(Console.TopLine), true );
			Canvas.bCenter = false;
			J = Console.TopLine - 1;
		} 
		else 
			J = Console.TopLine;

		I = 0;
		while ( (I < 4) && (J >= 0) )
		{
			MsgType = Console.GetMsgType(J);
			if ((MsgType != '') && (MsgType != 'Log'))
			{
				MessageString[I] = Console.GetMsgText(J);
				if ( (MessageString[I] != "") && (Console.GetMsgTick(J) > 0.0) )
				{
					if ( (MsgType == 'Event') || (MsgType == 'DeathMessage') )
					{
						ShortMessages[I].PRI = None;
						ShortMessages[I].Type = MsgType;
						I++;
					} 
					else if ( (MsgType == 'Say') || (MsgType == 'TeamSay') )
					{
						ShortMessages[I].PRI = Console.GetMsgPlayer(J);
						ShortMessages[I].Type = MsgType;
						I++;
					}
				}
			}
			J--;
		}

		// decide which speech message to show face for
		// FIXME - get the face from the PlayerReplicationInfo.TalkTexture
		J = 0;
		Canvas.Font = Font'WhiteFont';
		Canvas.StrLen("TEST", XL, YL );
		for ( I=0; I<4; I++ )
			if (MessageString[3 - I] != "")
			{
				YPos = 2 + (10 * J) + (10 * ExtraSpace); 
				if ( !DrawMessageHeader(Canvas, ShortMessages[3 - I], YPos) )
				{
					if (ShortMessages[3 - I].Type == 'DeathMessage')
						Canvas.DrawColor = RedColor;
					else 
					{
						Canvas.DrawColor.r = 200;
						Canvas.DrawColor.g = 200;
						Canvas.DrawColor.b = 200;	
					}
					Canvas.SetPos(4, YPos);
				}
				if ( !SpecialType(ShortMessages[3 - I].Type) ) {
					Canvas.DrawText(MessageString[3-I], false );
					J++;
				}
				if ( YL == 18.0 )
					ExtraSpace++;
			}
	}
	return true;
}

simulated function bool SpecialType(Name Type)
{
	if (Type == '')
		return true;
	if (Type == 'Log')
		return true;
	if (Type == 'Pickup')
		return true;
	if (Type == 'CriticalEvent')
		return true;
	if (Type == 'LowCriticalEvent')
		return true;
	if (Type == 'RedCriticalEvent')
		return true;
	return false;
}

simulated function float DrawNextMessagePart( Canvas Canvas, coerce string MString, float XOffset, int YPos )
{
	local float XL, YL;

	Canvas.SetPos(4 + XOffset, YPos);
	Canvas.StrLen( MString, XL, YL );
	XOffset += XL;
	Canvas.DrawText( MString, false );
	return XOffset;
}

simulated function bool DrawMessageHeader(Canvas Canvas, MessageStruct ShortMessage, int YPos)
{
	local float XOffset;

	if ( ShortMessage.Type != 'Say' )
		return false;

	Canvas.DrawColor = GreenColor;
	XOffset += ArmorOffset;
	XOffset = DrawNextMessagePart(Canvas, ShortMessage.PRI.PlayerName$": ", XOffset, YPos);	
	Canvas.SetPos(4 + XOffset, YPos);
	return true;
}

simulated function Tick(float DeltaTime)
{
	IdentifyFadeTime -= DeltaTime;
	if (IdentifyFadeTime < 0.0)
		IdentifyFadeTime = 0.0;

	MOTDFadeOutTime -= DeltaTime * 45;
	if (MOTDFadeOutTime < 0.0)
		MOTDFadeOutTime = 0.0;
}

simulated function bool TraceIdentify(canvas Canvas)
{
	local actor Other;
	local vector HitLocation, HitNormal, X, Y, Z, StartTrace, EndTrace;

	StartTrace = Owner.Location;
	StartTrace.Z += Pawn(Owner).BaseEyeHeight;

	EndTrace = StartTrace + vector(Pawn(Owner).ViewRotation) * 1000.0;

	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	if ( (Pawn(Other) != None) && (Pawn(Other).bIsPlayer) )
	{
		IdentifyTarget = Pawn(Other);
		IdentifyFadeTime = 3.0;
	}

	if ( IdentifyFadeTime == 0.0 )
		return false;

	if ( (IdentifyTarget == None) || (!IdentifyTarget.bIsPlayer) ||
		 (IdentifyTarget.bHidden) || (IdentifyTarget.PlayerReplicationInfo == None ))
		return false;

	return true;
}

simulated function DrawIdentifyInfo(canvas Canvas, float PosX, float PosY)
{
	local float XL, YL, XOffset;

	if (!TraceIdentify(Canvas))
		return;

	Canvas.Font = Font'WhiteFont';
	Canvas.Style = 3;

	XOffset = 0.0;
	Canvas.StrLen(IdentifyName$": "$IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
	XOffset = Canvas.ClipX/2 - XL/2;
	Canvas.SetPos(XOffset, Canvas.ClipY - 54);
	
	if(IdentifyTarget.IsA('PlayerPawn'))
		if(PlayerPawn(IdentifyTarget).PlayerReplicationInfo.bFeigningDeath)
			return;

	if(IdentifyTarget.PlayerReplicationInfo.PlayerName != "")
	{
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 160 * (IdentifyFadeTime / 3.0);
		Canvas.DrawColor.B = 0;

		Canvas.StrLen(IdentifyName$": ", XL, YL);
		XOffset += XL;
		Canvas.DrawText(IdentifyName$": ");
		Canvas.SetPos(XOffset, Canvas.ClipY - 54);

		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 255 * (IdentifyFadeTime / 3.0);
		Canvas.DrawColor.B = 0;

		Canvas.StrLen(IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
		Canvas.DrawText(IdentifyTarget.PlayerReplicationInfo.PlayerName);
	}

	Canvas.Style = 1;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

simulated function DrawMOTD(Canvas Canvas)
{
	local GameReplicationInfo GRI;
	local float XL, YL;

	if(Owner == None) return;

	Canvas.Font = Font'WhiteFont';
	Canvas.Style = 3;

	Canvas.DrawColor.R = MOTDFadeOutTime;
	Canvas.DrawColor.G = MOTDFadeOutTime;
	Canvas.DrawColor.B = MOTDFadeOutTime;

	Canvas.bCenter = true;

	foreach AllActors(class'GameReplicationInfo', GRI)
	{
		if (GRI.GameName != "Game")
		{
			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = MOTDFadeOutTime / 2;
			Canvas.DrawColor.B = MOTDFadeOutTime;
			Canvas.SetPos(0.0, 32);
			Canvas.StrLen("TEST", XL, YL);
			if (Level.NetMode != NM_Standalone)
				Canvas.DrawText(GRI.ServerName);
			Canvas.DrawColor.R = MOTDFadeOutTime;
			Canvas.DrawColor.G = MOTDFadeOutTime;
			Canvas.DrawColor.B = MOTDFadeOutTime;

			Canvas.SetPos(0.0, 32 + YL);
			Canvas.DrawText("Game Type: "$GRI.GameName, true);
			Canvas.SetPos(0.0, 32 + 2*YL);
			Canvas.DrawText("Map Title: "$Level.Title, true);
			Canvas.SetPos(0.0, 32 + 3*YL);
			Canvas.DrawText("Author: "$Level.Author, true);
			Canvas.SetPos(0.0, 32 + 4*YL);
			if (Level.IdealPlayerCount != "")
				Canvas.DrawText("Ideal Player Load:"$Level.IdealPlayerCount, true);

			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = MOTDFadeOutTime / 2;
			Canvas.DrawColor.B = MOTDFadeOutTime;

			Canvas.SetPos(0, 32 + 6*YL);
			Canvas.DrawText(Level.LevelEnterText, true);

			Canvas.SetPos(0.0, 32 + 8*YL);
			Canvas.DrawText(GRI.MOTDLine1, true);
			Canvas.SetPos(0.0, 32 + 9*YL);
			Canvas.DrawText(GRI.MOTDLine2, true);
			Canvas.SetPos(0.0, 32 + 10*YL);
			Canvas.DrawText(GRI.MOTDLine3, true);
			Canvas.SetPos(0.0, 32 + 11*YL);
			Canvas.DrawText(GRI.MOTDLine4, true);
		}
	}
	Canvas.bCenter = false;

	Canvas.Style = 1;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

defaultproperties
{
	 TeamName(0)="Red Team: "
	 TeamName(1)="Blue Team: "
	 TeamName(2)="Green Team: "
	 TeamName(3)="Gold Team: "
     TranslatorY=-128
     CurTranY=-128
     MainMenuType=Class'UnrealShare.UnrealMainMenu'
     IdentifyName="Name"
     IdentifyHealth="Health"
     VersionMessage="Version"
	 TeamColor(0)=(R=255,G=0,B=0)
	 TeamColor(1)=(R=0,G=128,B=255)
	 TeamColor(2)=(R=0,G=255,B=0)
	 TeamColor(3)=(R=255,G=255,B=0)
	 AltTeamColor(0)=(R=200,G=0,B=0)
	 AltTeamColor(1)=(R=0,G=94,B=187)
	 AltTeamColor(2)=(R=0,G=128,B=0)
	 AltTeamColor(3)=(R=255,G=255,B=128)
	 RedColor=(R=255,G=0,B=0)
	 GreenColor=(R=0,G=255,B=0)
}
