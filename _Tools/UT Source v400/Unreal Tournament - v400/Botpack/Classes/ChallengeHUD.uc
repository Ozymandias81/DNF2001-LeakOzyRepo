//=============================================================================
// ChallengeHUD
// Heads up display
//=============================================================================
class ChallengeHUD extends HUD
	config;

#exec TEXTURE IMPORT NAME=HudLine FILE=..\unrealshare\TEXTURES\HUD\Line.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=IconSelection FILE=..\unrealshare\TEXTURES\HUD\i_rim.PCX GROUP="Icons" FLAGS=2 MIPS=OFF

#exec TEXTURE IMPORT NAME=CHair1  FILE=Textures\Hud\cross1.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=CHair2  FILE=Textures\Hud\cross2.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=CHair3  FILE=Textures\Hud\cross3.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=CHair4  FILE=Textures\Hud\cross4.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=CHair5  FILE=Textures\Hud\cross5.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=CHair6  FILE=Textures\Hud\cross6.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=CHair7  FILE=Textures\Hud\cross7.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=CHair8  FILE=Textures\Hud\cross8.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=CHair9  FILE=Textures\Hud\cross9.PCX GROUP="Icons" MIPS=OFF

#exec Font Import File=..\unrealshare\Textures\TinyFont.pcx Name=TinyFont
#exec Font Import File=..\unrealshare\Textures\TinyFon3.pcx Name=TinyWhiteFont
#exec Font Import File=..\unrealshare\Textures\TinyFon2.pcx Name=TinyRedFont

#exec TEXTURE IMPORT NAME=HudElements1 FILE=TEXTURES\HUD\HudElements1.PCX GROUP="Icons" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=HUDWeapons FILE=TEXTURES\HUD\HudElements2.PCX GROUP="Icons" MIPS=OFF FLAGS=2

#exec TEXTURE IMPORT NAME=FacePanel0 FILE=TEXTURES\HUD\FacePan0.PCX GROUP="FacePanel" MIPS=OFF
#exec TEXTURE IMPORT NAME=FacePanel1 FILE=TEXTURES\HUD\FacePan1.PCX GROUP="FacePanel" MIPS=OFF
#exec TEXTURE IMPORT NAME=FacePanel2 FILE=TEXTURES\HUD\FacePan2.PCX GROUP="FacePanel" MIPS=OFF
#exec TEXTURE IMPORT NAME=FacePanel3 FILE=TEXTURES\HUD\FacePan3.PCX GROUP="FacePanel" MIPS=OFF
#exec TEXTURE IMPORT NAME=FacePanel1a FILE=TEXTURES\HUD\FacePan1a.PCX GROUP="FacePanel" MIPS=OFF
#exec TEXTURE IMPORT NAME=FacePanel2a FILE=TEXTURES\HUD\FacePan2a.PCX GROUP="FacePanel" MIPS=OFF
#exec TEXTURE IMPORT NAME=FacePanel3a FILE=TEXTURES\HUD\FacePan3a.PCX GROUP="FacePanel" MIPS=OFF
#exec TEXTURE IMPORT NAME=FacePanel1b FILE=TEXTURES\HUD\FacePan1b.PCX GROUP="FacePanel" MIPS=OFF
#exec TEXTURE IMPORT NAME=FacePanel2b FILE=TEXTURES\HUD\FacePan2b.PCX GROUP="FacePanel" MIPS=OFF
#exec TEXTURE IMPORT NAME=FacePanel3b FILE=TEXTURES\HUD\FacePan3b.PCX GROUP="FacePanel" MIPS=OFF

#exec TEXTURE IMPORT NAME=DisconnectWarn FILE=TEXTURES\HUD\Disconnect.PCX GROUP="Icons" MIPS=OFF FLAGS=2

#exec OBJ LOAD FILE=..\Textures\LadrStatic.utx PACKAGE=Botpack.LadrStatic

var() int SizeY,Count;
var string CurrentMessage;
var float MOTDFadeOutTime;

var float IdentifyFadeTime;
var PlayerReplicationInfo IdentifyTarget;
var Pawn PawnOwner;	// pawn currently managing this HUD (may be the viewtarget of the owner rather than the owner)
var FontInfo MyFonts;

// Localized Messages
var HUDLocalizedMessage ShortMessageQueue[4];
var HUDLocalizedMessage LocalMessages[10];

var() localized string VersionMessage, PlayerCountString;
var localized string MapTitleString, AuthorString;
var localized string MapTitleString2, AuthorString2;

var localized string RankString;
var localized string SpreadString;

var int PlayerCount;
var bool bTiedScore;

var string ReceivedMessage;
var string ReceivedName;
var ZoneInfo ReceivedZone;
var float ReceivedTime;
var texture TutIconTex;
var int TutIconX, TutIconY;
var float TutIconBlink;

var globalconfig int CrosshairCount;
var globalconfig string CrossHairs[20];
var texture CrossHairTextures[20];

var texture GrayWeapons[11];
var texture FP1[3], FP2[3], FP3[3];
var int LastReportedTime;
var bool bStartUpMessage, bForceScores;
var bool bTimeValid;
var bool bLowRes;
var bool bResChanged;
var int OldClipX;

// configuration options
var bool bAlwaysHideFrags, bHideCenterMessages;
var globalconfig bool bHideAllWeapons, bHideStatus, bHideAmmo, bHideTeamInfo, bHideFrags, bHideHUD, bHideNoviceMessages, bHideFaces;
var globalconfig bool bUseTeamColor;
var globalconfig byte Opacity;	// should be between 1 and 16
var globalconfig float HUDScale, StatusScale, WeaponScale;
var globalconfig color FavoriteHUDColor, CrosshairColor;
var float Scale;
var byte Style;
var color BaseColor, WhiteColor, RedColor, GreenColor, CyanColor, UnitColor, BlueColor,
		 GoldColor, HUDColor, SolidHUDColor, PurpleColor, TurqColor, GrayColor, FaceColor;

// Identify Strings
var localized string IdentifyName, IdentifyHealth, IdentifyCallsign;
var localized string LiveFeed;

// scoring 
var float ScoreTime;
var int rank, lead;

// showing damage
var vector HitPos[4];
var float HitTime[4];
var float HitDamage[4];

var float PickupTime;

var float WeaponNameFade;
var float MessageFadeTime;
var int MessageFadeCount;
var bool bDrawMessageArea;
var bool bDrawFaceArea;
var float FaceAreaOffset, MinFaceAreaOffset;
var class<CriticalEventPlus> TimeMessageClass;

// Server info.
var ServerInfo ServerInfo;
var bool bShowInfo;

var class<ServerInfo> ServerInfoClass;

function Destroyed()
{
	Super.Destroyed();
	if ( MyFonts != None )
		MyFonts.Destroy();
}

function SetDamage(vector HitLoc, float damage)
{
	local int i, best;
	local vector X,Y,Z;
	local float Max, XOffset, YOffset;

	if ( Level.bDropDetail || !PlayerOwner.IsA('TournamentPlayer') )
		return;

	for ( i=0; i<4; i++ )
		if ( Level.TimeSeconds - HitTime[i] > Max )
		{
			best = i;	
			Max = Level.TimeSeconds - HitTime[i];
		}

	HitTime[best] = Level.TimeSeconds;
	HitDamage[best] = FClamp(Damage * 0.06,2,4);
	GetAxes(Owner.Rotation,X,Y,Z);
	XOffset = - 0.5 * FClamp((Y Dot HitLoc)/CollisionRadius , -1, 1);
	YOffset = -0.5 * FClamp((Z Dot HitLoc)/CollisionHeight , -1, 1);

	// hack for positions around head or near legs
	if ( YOffset < -0.35 )
	{
		XOffset *= 0.3;
		YOffset = FMax(HitPos[best].Y, -0.45);
	}
	else if ( YOffset > 0.1 )
	{
		if ( abs(XOffset) < 0.25 )
		{
			if ( XOffset > 0 )
				XOffset = 0.25;
			else
				XOffset = -0.25;
		}				
		YOffset = FMin(YOffset, 0.4);
	}

	HitPos[best].X = 128 * (0.5 + XOffset) - 0.5 * 25 * HitDamage[best];
	HitPos[best].Y = 256 * (0.5 + YOffset) - 0.5 * HitDamage[Best] * 64;
}

simulated function PostBeginPlay()
{
	local int i;

	if ( Level.NetMode != NM_Standalone )
		MOTDFadeOutTime = 350;
	FaceAreaOffset = -64;
	MyFonts = spawn(Class'FontInfo');
	Super.PostBeginPlay();
	SetTimer(1.0, True);

	if ( (PlayerPawn(Owner).GameReplicationInfo != None)
		&& (PlayerPawn(Owner).GameReplicationInfo.RemainingTime > 0) )
		TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject("Botpack.TimeMessage", class'Class'));

	ServerInfo = Spawn(ServerInfoClass, Owner);
}

exec function SetHUDR(int n)
{
	FavoriteHUDColor.R = Clamp(n,0,16);
}

exec function SetHUDG(int n)
{
	FavoriteHUDColor.G = Clamp(n,0,16);
}

exec function SetHUDB(int n)
{
	FavoriteHUDColor.B = Clamp(n,0,16);
}

exec function ShowServerInfo()
{
	if (bShowInfo)
	{
		bShowInfo = False;
	} else {
		bShowInfo = True;
		PlayerPawn(Owner).bShowScores = False;
	}
}

exec function GrowHUD()
{
	if ( bHideHUD )
		bHideHud = false;
	else if ( bHideAmmo )
		bHideAmmo = false;
	else if ( bHideFrags )
		bHideFrags = false;
	else if ( bHideTeamInfo )
		bHideTeamInfo = false;
	else if ( bHideAllWeapons )
		bHideAllWeapons = false;
	else if ( bHideStatus )
		bHideStatus = false;
	else 
		WeaponScale = 1.0;

	SaveConfig();
}

exec function ShrinkHUD()
{
	if ( !bLowRes && (WeaponScale * HUDScale > 0.8) )
		WeaponScale = 0.8/HUDScale;
	else if ( !bHideStatus )
		bHideStatus = true;
	else if ( !bHideAllWeapons )
		bHideAllWeapons = true;
	else if ( !bHideTeamInfo )
		bHideTeamInfo = true;
	else if ( !bHideFrags )
		bHideFrags = true;
	else if ( !bHideAmmo )
		bHideAmmo = true;
	else
		bHideHud = true;

	SaveConfig();
}
	
simulated function ChangeCrosshair(int d)
{
	Crosshair = Crosshair + d;
	if ( Crosshair > CrossHairCount )
		Crosshair = 0;
	else
	if ( Crosshair < 0 )
		Crosshair = CrossHairCount-1;
}

simulated function Texture LoadCrosshair(int c)
{
	CrossHairTextures[c] = Texture(DynamicLoadObject(CrossHairs[c], class'Texture'));
	return CrossHairTextures[c];
}

simulated function HUDSetup(canvas canvas)
{
	local int FontSize;

	bResChanged = (Canvas.ClipX != OldClipX);
	OldClipX = Canvas.ClipX;
		
	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner.ViewTarget == None )
		PawnOwner = PlayerOwner;
	else if ( PlayerOwner.ViewTarget.bIsPawn )
		PawnOwner = Pawn(PlayerOwner.ViewTarget);
	else 
		PawnOwner = PlayerOwner;

	// Setup the way we want to draw all HUD elements
	Canvas.Reset();
	Canvas.SpaceX=0;
	Canvas.bNoSmooth = True;

	FontSize = Min(3, HUDScale * Canvas.ClipX/500);
	Scale = (HUDScale * Canvas.ClipX)/1280.0;

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );

	SolidHUDColor = FavoriteHUDColor * 15.9;
	if ( (Opacity == 16) || !Level.bHighDetailMode )
	{
		Style = ERenderStyle.STY_Normal;
		BaseColor = WhiteColor;
		HUDColor = SolidHUDColor;
	}
	else
	{
		Style = ERenderStyle.STY_Translucent;
		BaseColor = (16 * Opacity + 15) * UnitColor;
		HUDColor = FavoriteHUDColor * (Opacity + 0.9);
	}
	Canvas.DrawColor = BaseColor;
	Canvas.Style = Style;
	bLowRes = ( Canvas.ClipX < 400 );
	if ( bLowRes )
		WeaponScale = 1.0;
}

simulated function DrawDigit(Canvas Canvas, int d, int Step, float UpScale, out byte bMinus )
{
	if ( bMinus == 1 )
	{
		Canvas.CurX -= Step;
		Canvas.DrawTile(Texture'BotPack.HudElements1', UpScale*25, 64*UpScale, 0, 64, 25.0, 64.0);
		bMinus = 0;
	}
	if ( d == 1 )
		Canvas.CurX -= 0.625 * Step;
	else
		Canvas.CurX -= 0.25 * Step;		
	Canvas.DrawTile(Texture'BotPack.HudElements1', UpScale*25, 64*UpScale, d*25, 0, 25.0, 64.0);
	Canvas.CurX += 7*UpScale;
}

// DrawBigNum should already have Canvas set up
// X and Y should be the left most allowed position of the number (will be adjusted right if possible)
simulated function DrawBigNum(Canvas Canvas, int Value, int X, int Y, optional float ScaleFactor)
{
	local int d, Mag, Step;
	local float UpScale;
	local byte bMinus;

	if ( ScaleFactor != 0 )
		UpScale = Scale * ScaleFactor;
	else
		UpScale = Scale;

	Canvas.CurX = X;	
	Canvas.CurY = Y;
	Step = 16 * UpScale;
	if ( Value < 0 )
		bMinus = 1;
	Mag = FMin(9999, Abs(Value));

	if ( Mag >= 1000 )
	{
		Canvas.CurX -= Step;
		d = 0.001 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 1000 * d;
		d = 0.01 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 100 * d;
	}
	else if ( Mag >= 100 )
	{
		d = 0.01 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 100 * d;
	}
	else
		Canvas.CurX += Step;

	if ( Mag >= 10 )
	{
		d = 0.1 * Mag;
		DrawDigit(Canvas, d, Step, UpScale, bMinus);
		Mag = Mag - 10 * d;
	}
	else if ( d > 0 )
		DrawDigit(Canvas, 0, Step, UpScale, bMinus);
	else
		Canvas.CurX += Step;

	DrawDigit(Canvas, Mag, Step, UpScale, bMinus);
}

simulated function DrawStatus(Canvas Canvas)
{
	local float StatScale, ChestAmount, ThighAmount, H1, H2, X, Y, DamageTime;
	Local int ArmorAmount,CurAbs,i;
	Local inventory Inv,BestArmor;
	local bool bChestArmor, bShieldbelt, bThighArmor, bJumpBoots, bHasDoll;
	local Bot BotOwner;
	local TournamentPlayer TPOwner;
	local texture Doll, DollBelt;

	ArmorAmount = 0;
	CurAbs = 0;
	i = 0;
	BestArmor=None;
	for( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
	{ 
		if (Inv.bIsAnArmor) 
		{
			if ( Inv.IsA('UT_Shieldbelt') )
				bShieldbelt = true;
			else if ( Inv.IsA('Thighpads') )
			{
				ThighAmount += Inv.Charge;
				bThighArmor = true;
			}
			else
			{ 
				bChestArmor = true;
				ChestAmount += Inv.Charge;
			}
			ArmorAmount += Inv.Charge;
		}
		else if ( Inv.IsA('UT_JumpBoots') )
			bJumpBoots = true;
		else
		{
			i++;
			if ( i > 100 )
				break; // can occasionally get temporary loops in netplay
		}
	}

	if ( !bHideStatus )
	{	
		TPOwner = TournamentPlayer(PawnOwner);
		if ( Canvas.ClipX < 400 )
			bHasDoll = false;
		else if ( TPOwner != None)
		{
			Doll = TPOwner.StatusDoll;
			DollBelt = TPOwner.StatusBelt;
			bHasDoll = true;
		}
		else
		{
			BotOwner = Bot(PawnOwner);
			if ( BotOwner != None )
			{
				Doll = BotOwner.StatusDoll;
				DollBelt = BotOwner.StatusBelt;
				bHasDoll = true;
			}
		}
		if ( bHasDoll )
		{ 							
			Canvas.Style = ERenderStyle.STY_Translucent;
			StatScale = Scale * StatusScale;
			X = Canvas.ClipX - 128 * StatScale;
			Canvas.SetPos(X, 0);
			if (PawnOwner.DamageScaling > 2.0)
				Canvas.DrawColor = PurpleColor;
			else
				Canvas.DrawColor = HUDColor;
			Canvas.DrawTile(Doll, 128*StatScale, 256*StatScale, 0, 0, 128.0, 256.0);
			Canvas.DrawColor = HUDColor;
			if ( bShieldBelt )
			{
				Canvas.DrawColor = BaseColor;
				Canvas.DrawColor.B = 0;
				Canvas.SetPos(X, 0);
				Canvas.DrawIcon(DollBelt, StatScale);
			}
			if ( bChestArmor )
			{
				ChestAmount = FMin(0.01 * ChestAmount,1);
				Canvas.DrawColor = HUDColor * ChestAmount;
				Canvas.SetPos(X, 0);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 0, 128, 64);
			}
			if ( bThighArmor )
			{
				ThighAmount = FMin(0.02 * ThighAmount,1);
				Canvas.DrawColor = HUDColor * ThighAmount;
				Canvas.SetPos(X, 64*StatScale);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 64, 128, 64);
			}
			if ( bJumpBoots )
			{
				Canvas.DrawColor = HUDColor;
				Canvas.SetPos(X, 128*StatScale);
				Canvas.DrawTile(Doll, 128*StatScale, 64*StatScale, 128, 128, 128, 64);
			}
			Canvas.Style = Style;
			if ( (PawnOwner == PlayerOwner) && Level.bHighDetailMode && !Level.bDropDetail )
			{
				for ( i=0; i<4; i++ )
				{
					DamageTime = Level.TimeSeconds - HitTime[i];
					if ( DamageTime < 1 )
					{
						Canvas.SetPos(X + HitPos[i].X * StatScale, HitPos[i].Y * StatScale);
						if ( (HUDColor.G > 100) || (HUDColor.B > 100) )
							Canvas.DrawColor = RedColor;
						else
							Canvas.DrawColor = (WhiteColor - HudColor) * FMin(1, 2 * DamageTime);
						Canvas.DrawColor.R = 255 * FMin(1, 2 * DamageTime);
						Canvas.DrawTile(Texture'BotPack.HudElements1', StatScale * HitDamage[i] * 25, StatScale * HitDamage[i] * 64, 0, 64, 25.0, 64.0);
					}
				}
			}
		}
	}
	Canvas.DrawColor = HUDColor;
	if ( bHideStatus && bHideAllWeapons )
	{
		X = 0.5 * Canvas.ClipX;
		Y = Canvas.ClipY - 64 * Scale;
	}
	else
	{
		X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
		Y = 64 * Scale;
	}
	Canvas.SetPos(X,Y);
	if ( PawnOwner.Health < 50 )
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = WhiteColor * H2 + (HUDColor - WhiteColor) * H1;
	}
	else
		Canvas.DrawColor = HUDColor;
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 128, 128, 128.0, 64.0);

	if ( PawnOwner.Health < 50 )
	{
		H1 = 1.5 * TutIconBlink;
		H2 = 1 - H1;
		Canvas.DrawColor = Canvas.DrawColor * H2 + (WhiteColor - Canvas.DrawColor) * H1;
	}
	else
		Canvas.DrawColor = WhiteColor;

	DrawBigNum(Canvas, Max(0, PawnOwner.Health), X + 4 * Scale, Y + 16 * Scale, 1);

	Canvas.DrawColor = HUDColor;
	if ( bHideStatus && bHideAllWeapons )
	{
		X = 0.5 * Canvas.ClipX - 128 * Scale;
		Y = Canvas.ClipY - 64 * Scale;
	}
	else
	{
		X = Canvas.ClipX - 128 * StatScale - 140 * Scale;
		Y = 0;
	}
	Canvas.SetPos(X, Y);
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 0, 192, 128.0, 64.0);
	if ( bHideStatus && bShieldBelt )
		Canvas.DrawColor = GoldColor;
	else
		Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, Min(150,ArmorAmount), X + 4 * Scale, Y + 16 * Scale, 1);
}

simulated function DrawAmmo(Canvas Canvas)
{
	local int X,Y;

	Canvas.Style = Style;
	Canvas.DrawColor = HUDColor;
	if ( bHideAllWeapons || (HudScale * WeaponScale * Canvas.ClipX <= Canvas.ClipX - 256 * Scale) )
		Y = Canvas.ClipY - 63.5 * Scale;
	else
		Y = Canvas.ClipY - 127.5 * Scale;
	if ( bHideAllWeapons )
		X = 0.5 * Canvas.ClipX + 128 * Scale;
	else
		X = Canvas.ClipX - 128 * Scale;
	Canvas.SetPos(X, Y);
	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 128, 192, 128.0, 64.0);

	if ( (PawnOwner.Weapon == None) || (PawnOwner.Weapon.AmmoType == None) )
		return;

	Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, PawnOwner.Weapon.AmmoType.AmmoAmount, X + 4 * Scale, Y + 16 * Scale);
}

simulated function DrawFragCount(Canvas Canvas)
{
	local float Whiten;
	local int X,Y;

	if ( PawnOwner.PlayerReplicationInfo == None )
		return;

	Canvas.Style = Style;
	if ( bHideAllWeapons || (HudScale * WeaponScale * Canvas.ClipX <= Canvas.ClipX - 256 * Scale) )
		Y = Canvas.ClipY - 63.5 * Scale;
	else
		Y = Canvas.ClipY - 127.5 * Scale;
	if ( bHideAllWeapons )
		X = 0.5 * Canvas.ClipX - 256 * Scale;
	Canvas.CurX = X;
	Canvas.CurY = Y;
	Canvas.DrawColor = HUDColor; 
	Whiten = Level.TimeSeconds - ScoreTime;
	if ( Whiten < 3.0 )
	{
		if ( HudColor == GoldColor )
			Canvas.DrawColor = WhiteColor;
		else
			Canvas.DrawColor = GoldColor;
		if ( Level.bHighDetailMode )
		{
			Canvas.CurX = X - 64 * Scale;
			Canvas.CurY = Y - 32 * Scale;
			Canvas.Style = ERenderStyle.STY_Translucent;
			Canvas.DrawTile(Texture'BotPack.HUDWeapons', 256 * Scale, 128 * Scale, 0, 128, 256.0, 128.0);
		}
		Canvas.CurX = X;
		Canvas.CurY = Y;
		Whiten = 4 * Whiten - int(4 * Whiten);
		Canvas.DrawColor = Canvas.DrawColor + (HUDColor - Canvas.DrawColor) * Whiten;
	}

	Canvas.DrawTile(Texture'BotPack.HudElements1', 128*Scale, 64*Scale, 0, 128, 128.0, 64.0);
	Canvas.DrawColor = WhiteColor;
	DrawBigNum(Canvas, PawnOwner.PlayerReplicationInfo.Score, X + 40 * Scale, Y + 16 * Scale);
}


simulated function DrawGameSynopsis(Canvas Canvas)
{
	local float XL, YL, XOffset, YOffset;
	local int MaxPlayers;
	local string Spread;

	if ( (PawnOwner.PlayerReplicationInfo == None) 
		|| PawnOwner.PlayerReplicationInfo.bIsSpectator 
		|| (PlayerCount == 1) )
		return;

	Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
	Canvas.DrawColor = WhiteColor;

	// Rank String
	Canvas.StrLen(RankString, XL, YL);
	if ( bHideAllWeapons )
		YOffset = Canvas.ClipY - YL*2;
	else if ( HudScale * WeaponScale * Canvas.ClipX <= Canvas.ClipX - 256 * Scale )
		YOffset = Canvas.ClipY - 64*Scale - YL*2;
	else
		YOffset = Canvas.ClipY - 128*Scale - YL*2;
	Canvas.SetPos(0, YOffset);
	Canvas.DrawText(RankString, False);
	if (bTiedScore)
		Canvas.DrawColor = RedColor;
	Canvas.SetPos(XL, YOffset);
	Canvas.DrawText(" "$Rank@"/"@PlayerCount, False);
	Canvas.DrawColor = WhiteColor;

	// Spread String
	Canvas.SetPos(0, YOffset + YL);
	if (Lead > 0)
		Spread = SpreadString$" +"$Lead;
	else
		Spread = SpreadString$" "$Lead;

	Canvas.DrawText(Spread, False);
}

simulated function DrawWeapons(Canvas Canvas)
{
	local Weapon W, WeaponSlot[11];
	local inventory Inv;
	local int i, j, BaseY, BaseX, Pending, WeapX, WeapY;
	local float AmmoScale, WeaponOffset, WeapScale, WeaponX, TexX, TexY;

	BaseX = 0.5 * (Canvas.ClipX - HudScale * WeaponScale * Canvas.ClipX);
	WeapScale = WeaponScale * Scale;
	Canvas.Style = Style;
	BaseY = Canvas.ClipY - 63.5 * WeapScale;
	WeaponOffset = 0.1 * HUDScale * WeaponScale * Canvas.ClipX;

	if ( PawnOwner.Weapon != None )
	{
		W = PawnOwner.Weapon;
		if ( (Opacity > 8) || !Level.bHighDetailMode )
			Canvas.Style = ERenderStyle.STY_Normal;
		WeaponX = BaseX + (W.InventoryGroup - 1) * WeaponOffset;
		Canvas.CurX = WeaponX;
		Canvas.CurY = BaseY;
		Canvas.DrawColor = SolidHUDColor;
		Canvas.DrawIcon(W.StatusIcon, WeapScale);
		Canvas.DrawColor = GoldColor;
		Canvas.CurX = WeaponX + 4 * WeapScale;
		Canvas.CurY = BaseY + 4 * WeapScale;
		Canvas.Style = Style;
		if ( W.InventoryGroup == 10 )
			Canvas.DrawTile(Texture'BotPack.HudElements1', 0.75 * WeapScale * 25, 0.75 * WeapScale * 64, 0, 0, 25.0, 64.0);
		else
			Canvas.DrawTile(Texture'BotPack.HudElements1', 0.75 * WeapScale * 25, 0.75 * WeapScale * 64, 25*W.InventoryGroup, 0, 25.0, 64.0);

		WeaponSlot[W.InventoryGroup] = W;  
		Canvas.CurX = WeaponX;
		Canvas.CurY = BaseY;
		Canvas.DrawTile(Texture'BotPack.HUDWeapons', 128 * WeapScale, 64 * WeapScale, 128, 64, 128, 64);
	}
	if ( Level.bHighDetailMode && (PawnOwner.PendingWeapon != None) )
	{
		Pending = PawnOwner.PendingWeapon.InventoryGroup;
		Canvas.CurX = BaseX + (Pending - 1) * WeaponOffset - 64 * WeapScale;
		Canvas.CurY = Canvas.ClipY - 96 * WeapScale; 
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = GoldColor;
		Canvas.DrawTile(Texture'BotPack.HUDWeapons', 256 * WeapScale, 128 * WeapScale, 0, 128, 256.0, 128.0);
	}
	else
		Pending = 100;

	Canvas.Style = Style;
	i = 0;
	for ( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if ( Inv.IsA('Weapon') && (Inv != PawnOwner.Weapon) )
		{
			W = Weapon(Inv);
			if ( WeaponSlot[W.InventoryGroup] == None )
				WeaponSlot[W.InventoryGroup] = W;
			else if ( (WeaponSlot[W.InventoryGroup] != PawnOwner.Weapon)
					&& ((W == PawnOwner.PendingWeapon) || (WeaponSlot[W.InventoryGroup].AutoSwitchPriority < W.AutoSwitchPriority)) )
				WeaponSlot[W.InventoryGroup] = W;
		}
		i++;
		if ( i > 100 )
			break; // can occasionally get temporary loops in netplay
	}
	W = PawnOwner.Weapon;

	// draw weapon list
	TexX = 128 * WeapScale;
	TexY = 64 * WeapScale;
	for ( i=1; i<11; i++ )
	{
		if ( WeaponSlot[i] == None )
		{
			Canvas.Style = Style;
			Canvas.DrawColor =  0.5 * HUDColor;
			Canvas.CurX = BaseX + (i - 1) * WeaponOffset;
			Canvas.CurY = BaseY;
			
			WeapX = ((i-1)%4) * 64;
			WeapY = ((i-1)/4) * 32;
			Canvas.DrawTile(Texture'BotPack.HUDWeapons',TexX,TexY,WeapX,WeapY,64.0,32.0);
		}
		else if ( WeaponSlot[i] != W )
		{
			if ( Pending == i )
			{
				if ( (Opacity > 8) || !Level.bHighDetailMode )
					Canvas.Style = ERenderStyle.STY_Normal;
				Canvas.DrawColor = SolidHUDColor;
			}
			else
			{
				Canvas.Style = Style;
				Canvas.DrawColor = 0.5 * HUDColor;
			}
			Canvas.CurX = BaseX + (i - 1) * WeaponOffset;
			Canvas.CurY = BaseY;
			
			if ( WeaponSlot[i].bSpecialIcon )
				Canvas.DrawIcon(WeaponSlot[i].StatusIcon, WeapScale);
			else
			{
				WeapX = ((i-1)%4) * 64;
				WeapY = ((i-1)/4) * 32;
				Canvas.DrawTile(Texture'BotPack.HUDWeapons',TexX,TexY,WeapX,WeapY,64.0,32.0);
			}
		}
	}

	//draw weapon numbers and ammo
	TexX = 0.75 * WeapScale * 25;
	TexY = 0.75 * WeapScale * 64;
	for ( i=1; i<11; i++ )
	{
		if ( WeaponSlot[i] != None )
		{
			WeaponX = BaseX + (i - 1) * WeaponOffset + 4 * WeapScale;
			if ( WeaponSlot[i] != W )
			{
				Canvas.CurX = WeaponX;
				Canvas.CurY = BaseY + 4 * WeapScale;
				Canvas.DrawColor = GoldColor;
				if ( (Opacity > 8) || !Level.bHighDetailMode )
					Canvas.Style = ERenderStyle.STY_Normal;
				else
					Canvas.Style = Style;
				if ( i == 10 )
					Canvas.DrawTile(Texture'BotPack.HudElements1', TexX, TexY, 0, 0, 25.0, 64.0);
				else
					Canvas.DrawTile(Texture'BotPack.HudElements1', TexX, TexY, 25*i, 0, 25.0, 64.0);
			}
			if ( WeaponSlot[i].AmmoType != None )
			{
				// Draw Ammo bar
				Canvas.CurX = WeaponX;
				Canvas.CurY = BaseY + 52 * WeapScale;
				Canvas.DrawColor = BaseColor;
				AmmoScale = FClamp(88.0 * WeapScale * WeaponSlot[i].AmmoType.AmmoAmount/WeaponSlot[i].AmmoType.MaxAmmo, 0, 88);
				Canvas.DrawTile(Texture'BotPack.HudElements1', AmmoScale, 8 * WeapScale,64,64,128.0,8.0);
			}
		}
	}
}

simulated function DisplayProgressMessage( canvas Canvas )
{
	local int i;
	local float XL, YL, YOffset;
	local GameReplicationInfo GRI;

	PlayerOwner.ProgressTimeOut = FMin(PlayerOwner.ProgressTimeOut, Level.TimeSeconds + 8);
	Canvas.Style = ERenderStyle.STY_Normal;	

	Canvas.bCenter = True;
	Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
	Canvas.StrLen("TEST", XL, YL);
	if ( UTIntro(Level.Game) != None )
		YOffset = 64 * scale + 2 * YL;
	else if ( (MOTDFadeOutTime <= 0) || (Canvas.ClipY < 300) )
		YOffset = 64 * scale + 6 * YL;
	else
	{
		YOffset = 64 * scale + 6 * YL;
		GRI = PlayerOwner.GameReplicationInfo;
		if ( GRI != None )
		{
			if ( GRI.MOTDLine1 != "" )
				YOffset += YL;
			if ( GRI.MOTDLine2 != "" )
				YOffset += YL;
			if ( GRI.MOTDLine3 != "" )
				YOffset += YL;
			if ( GRI.MOTDLine4 != "" )
				YOffset += YL;
		}
	}
	for (i=0; i<8; i++)
	{
		Canvas.SetPos(0, YOffset);
		Canvas.DrawColor = PlayerPawn(Owner).ProgressColor[i];
		Canvas.DrawText(PlayerPawn(Owner).ProgressMessage[i], False);
		YOffset += YL + 1;
	}
	Canvas.DrawColor = WhiteColor;
	Canvas.bCenter = False;
	HUDSetup(Canvas);	
}

function DrawTalkFace(Canvas Canvas, int i, float YPos)
{
	if ( !bHideHUD && !PawnOwner.PlayerReplicationInfo.bIsSpectator )
	{
		Canvas.DrawColor = WhiteColor;
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(FaceAreaOffset + 4*Scale, 4*Scale);
		if ( (ShortMessageQueue[i].RelatedPRI != None )
			&& (ShortMessageQueue[i].RelatedPRI.TalkTexture != None) )
			Canvas.DrawTile(ShortMessageQueue[i].RelatedPRI.TalkTexture, YPos - 1*Scale, YPos - 1*Scale, 0, 0, ShortMessageQueue[i].RelatedPRI.TalkTexture.USize, ShortMessageQueue[i].RelatedPRI.TalkTexture.VSize);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = FaceColor;
		Canvas.SetPos(FaceAreaOffset, 0);
		Canvas.DrawTile(texture'LadrStatic.Static_a00', YPos + 7*Scale, YPos + 7*Scale, 0, 0, texture'LadrStatic.Static_a00'.USize, texture'LadrStatic.Static_a00'.VSize);
		Canvas.DrawColor = WhiteColor;
	}
}

function bool DrawSpeechArea( Canvas Canvas, float XL, float YL )
{
	local float YPos, Yadj;
	local float WackNumber;
	local int paneltype;

	YPos = FMax(YL*4 + 8, 70*Scale);
	Yadj = YPos + 7*Scale;
	YPos *=2;
	MinFaceAreaOffset = -1 * Yadj;
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = HUDColor * MessageFadeTime;

	Canvas.SetPos(FaceAreaOffset, 0);
	Canvas.DrawTile(texture'LadrStatic.Static_a00', Yadj, Yadj, 0, 0, texture'LadrStatic.Static_a00'.USize, texture'LadrStatic.Static_a00'.VSize);

	WackNumber = 512*Scale - 64 + FaceAreaOffset; // 256*Scale - (512*Scale - (768*Scale - 64 + FaceAreaOffset));
	if ( !PlayerOwner.Player.Console.bTyping )
		paneltype = 0;
	else 
	{
		Canvas.StrLen("(>"@PlayerOwner.Player.Console.TypedStr$"_", XL, YL);
		if (XL < 768*Scale)
			paneltype = 1;
		else 
			paneltype = 2;
	}

	Canvas.SetPos(Yadj + FaceAreaOffset, 0);
	Canvas.DrawTile(FP1[paneltype], 256*Scale - FaceAreaOffset, YPos, 0, 0, FP1[paneltype].USize, FP1[paneltype].VSize);

	Yadj += 256 * Scale;
	Canvas.SetPos(Yadj, 0);
	Canvas.DrawTile(FP2[paneltype], WackNumber, YPos, 0, 0, FP2[paneltype].USize, FP2[paneltype].VSize);

	Canvas.SetPos(Yadj + WackNumber, 0);
	Canvas.DrawTile(FP3[paneltype], 64, YPos, 0, 0, FP3[paneltype].USize, FP3[paneltype].VSize);
}

//========================================
// Master HUD render function.

simulated function PostRender( canvas Canvas )
{
	local float XL, YL, XPos, YPos, FadeValue;
	local string Message;
	local int M, i, j, k, XOverflow, FaceNum;
	local float OldOriginX;

	HUDSetup(canvas);
	if ( (PawnOwner == None) || (PlayerOwner.PlayerReplicationInfo == None) )
		return;

	if ( bShowInfo )
	{
		ServerInfo.RenderInfo( Canvas );
		return;
	}

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	OldOriginX = Canvas.OrgX;
	// Master message short queue control loop.
	FaceNum = -1;
	bDrawFaceArea = False;
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.StrLen("TEST", XL, YL);
	Canvas.SetClip(768*Scale - 10, Canvas.ClipY);

	if ( !bHideFaces && !PlayerOwner.bShowScores && !bForceScores && !bHideHUD 
			&& !PawnOwner.PlayerReplicationInfo.bIsSpectator && (Scale >= 0.4) )
	{
		DrawSpeechArea(Canvas, XL, YL);
		for (i=0; i<4; i++)
		{
			// If we want to see the faces, draw the area.
			if ( ShortMessageQueue[i].bDrawing )
			{
				bDrawFaceArea = True;
				FaceNum = i;
				if ( !bHideHUD && ((PawnOwner.PlayerReplicationInfo == None) || !PawnOwner.PlayerReplicationInfo.bIsSpectator) )
					Canvas.SetOrigin( FMax(YL*4 + 8, 70*Scale) + 7*Scale + 6 + FaceAreaOffset, Canvas.OrgY );
				break;
			}
		}
	}

	for (i=0; i<4; i++)
	{
		if ( ShortMessageQueue[i].Message != None )
		{
			j++;

			if ( bResChanged || (ShortMessageQueue[i].XL == 0) )
			{
				if ( ShortMessageQueue[i].Message.Default.bComplexString )
					Canvas.StrLen(ShortMessageQueue[i].Message.Static.AssembleString( 
											self,
											ShortMessageQueue[i].Switch,
											ShortMessageQueue[i].RelatedPRI,
											ShortMessageQueue[i].StringMessage), 
								   ShortMessageQueue[i].XL, ShortMessageQueue[i].YL);
				else
					Canvas.StrLen(ShortMessageQueue[i].StringMessage, ShortMessageQueue[i].XL, ShortMessageQueue[i].YL);
				Canvas.StrLen("TEST", XL, YL);
				ShortMessageQueue[i].numLines = 1;
				if ( ShortMessageQueue[i].YL > YL )
				{
					ShortMessageQueue[i].numLines++;
					for (k=2; k<4-i; k++)
					{
						if (ShortMessageQueue[i].YL > YL*k)
							ShortMessageQueue[i].numLines++;
					}
				}
			}

			// Keep track of the amount of lines a message overflows, to offset the next message with.
			Canvas.SetPos(6, 2 + YL * YPos);
			YPos += ShortMessageQueue[i].numLines;
			if ( YPos > 4 )
				break; 

			if ( ShortMessageQueue[i].Message.Default.bComplexString )
			{
				// Use this for string messages with multiple colors.
				ShortMessageQueue[i].Message.Static.RenderComplexMessage( 
					Canvas,
					ShortMessageQueue[i].XL,  YL,
					ShortMessageQueue[i].StringMessage,
					ShortMessageQueue[i].Switch,
					ShortMessageQueue[i].RelatedPRI,
					None,
					ShortMessageQueue[i].OptionalObject
					);				
			} 
			else
			{
				Canvas.DrawColor = ShortMessageQueue[i].Message.Default.DrawColor;
				Canvas.DrawText(ShortMessageQueue[i].StringMessage, False);
			}
		}
	}

	Canvas.DrawColor = WhiteColor;
	Canvas.SetClip(OldClipX, Canvas.ClipY);
	Canvas.SetOrigin(OldOriginX, Canvas.OrgY);

	if ( PlayerOwner.bShowScores || bForceScores )
	{
		if ( (PlayerOwner.Scoring == None) && (PlayerOwner.ScoringType != None) )
			PlayerOwner.Scoring = Spawn(PlayerOwner.ScoringType, PlayerOwner);
		if ( PlayerOwner.Scoring != None )
		{ 
			PlayerOwner.Scoring.OwnerHUD = self;
			PlayerOwner.Scoring.ShowScores(Canvas);
			if ( PlayerOwner.Player.Console.bTyping )
				DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);
			return;
		}
	}

	YPos = FMax(YL*4 + 8, 70*Scale);
	if (FaceNum >= 0)
		DrawTalkFace( Canvas, FaceNum, YPos );
	if (j > 0) 
	{
		bDrawMessageArea = True;
		MessageFadeCount = 2;
	} 
	else 
	{
		bDrawMessageArea = False;
		bDrawFaceArea = False;
	}

	if ( !bHideCenterMessages )
	{
		// Master localized message control loop.
		for (i=0; i<10; i++)
		{
			if (LocalMessages[i].Message != None)
			{
				if (LocalMessages[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
				{
					Canvas.Style = ERenderStyle.STY_Translucent;
					FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
					if (FadeValue > 0.0)
					{
						if ( bResChanged || (LocalMessages[i].XL == 0) )
						{
							if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
								LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
							else // ==2
								LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );
							Canvas.Font = LocalMessages[i].StringFont;
							Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
							LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
						}
						Canvas.Font = LocalMessages[i].StringFont;
						Canvas.DrawColor = LocalMessages[i].DrawColor * (FadeValue/LocalMessages[i].LifeTime);
						Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
						Canvas.DrawText( LocalMessages[i].StringMessage, False );
					}
				} 
				else 
				{
					if ( bResChanged || (LocalMessages[i].XL == 0) )
					{
						if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch) == 1 )
							LocalMessages[i].StringFont = MyFonts.GetBigFont( Canvas.ClipX );
						else // == 2
							LocalMessages[i].StringFont = MyFonts.GetHugeFont( Canvas.ClipX );
						Canvas.Font = LocalMessages[i].StringFont;
						Canvas.StrLen(LocalMessages[i].StringMessage, LocalMessages[i].XL, LocalMessages[i].YL);
						LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, LocalMessages[i].YL, Canvas.ClipY);
					}
					Canvas.Font = LocalMessages[i].StringFont;
					Canvas.Style = ERenderStyle.STY_Normal;
					Canvas.DrawColor = LocalMessages[i].DrawColor;
					Canvas.SetPos( 0.5 * (Canvas.ClipX - LocalMessages[i].XL), LocalMessages[i].YPos );
					Canvas.DrawText( LocalMessages[i].StringMessage, False );
				}
			}
		}
	}
	Canvas.Style = ERenderStyle.STY_Normal;

	if ( !PlayerOwner.bBehindView && (PawnOwner.Weapon != None) && (Level.LevelAction == LEVACT_None) )
	{
		Canvas.DrawColor = WhiteColor;
		PawnOwner.Weapon.PostRender(Canvas);
		if ( !PawnOwner.Weapon.bOwnsCrossHair )
			DrawCrossHair(Canvas, 0,0 );
	}

	if ( (PawnOwner != Owner) && PawnOwner.bIsPlayer )
	{
		Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
		Canvas.bCenter = true;
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor = CyanColor * TutIconBlink;
		Canvas.SetPos(4, Canvas.ClipY - 96 * Scale);
		Canvas.DrawText( LiveFeed$PawnOwner.PlayerReplicationInfo.PlayerName, true );
		Canvas.bCenter = false;
		Canvas.DrawColor = WhiteColor;
		Canvas.Style = Style;
	}

	if ( bStartUpMessage && (Level.TimeSeconds < 5) )
	{
		bStartUpMessage = false;
		PlayerOwner.SetProgressTime(7);
	}
	if ( (PlayerOwner.ProgressTimeOut > Level.TimeSeconds) && !bHideCenterMessages )
		DisplayProgressMessage(Canvas);

	// Display MOTD
	if ( MOTDFadeOutTime > 0.0 )
		DrawMOTD(Canvas);
		 
	if( !bHideHUD )
	{
		if ( !PawnOwner.PlayerReplicationInfo.bIsSpectator )
		{
			Canvas.Style = Style;

			// Draw Ammo
			if ( !bHideAmmo )
				DrawAmmo(Canvas);
			
			// Draw Health/Armor status
			DrawStatus(Canvas);

			// Display Weapons
			if ( !bHideAllWeapons )
				DrawWeapons(Canvas);
			else if ( Level.bHighDetailMode
					&& (PawnOwner == PlayerOwner) && (PlayerOwner.Handedness == 2) )
			{
				// if weapon bar hidden and weapon hidden, draw weapon name when it changes
				if ( PawnOwner.PendingWeapon != None )
				{
					WeaponNameFade = 1.0;
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
					Canvas.DrawColor = PawnOwner.PendingWeapon.NameColor;
					Canvas.SetPos(Canvas.ClipX - 360 * Scale, Canvas.ClipY - 64 * Scale);
					Canvas.DrawText(PawnOwner.PendingWeapon.ItemName, False);
				}
				else if ( (Level.NetMode == NM_Client)  
						&& PawnOwner.IsA('TournamentPlayer') && (TournamentPlayer(PawnOwner).ClientPending != None) )
				{
					WeaponNameFade = 1.0;
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
					Canvas.DrawColor = TournamentPlayer(PawnOwner).ClientPending.NameColor;
					Canvas.SetPos(Canvas.ClipX - 360 * Scale, Canvas.ClipY - 64 * Scale);
					Canvas.DrawText(TournamentPlayer(PawnOwner).ClientPending.ItemName, False);
				}
				else if ( (WeaponNameFade > 0) && (PawnOwner.Weapon != None) )
				{
					Canvas.Font = MyFonts.GetBigFont( Canvas.ClipX );
					Canvas.DrawColor = PawnOwner.Weapon.NameColor;
					if ( WeaponNameFade < 1 )
						Canvas.DrawColor = Canvas.DrawColor * WeaponNameFade;
					Canvas.SetPos(Canvas.ClipX - 360 * Scale, Canvas.ClipY - 64 * Scale);
					Canvas.DrawText(PawnOwner.Weapon.ItemName, False);
				}
			}
			// Display Frag count
			if ( !bAlwaysHideFrags && !bHideFrags )
				DrawFragCount(Canvas);
		}
		// Team Game Synopsis
		if ( !bHideTeamInfo )
			DrawGameSynopsis(Canvas);

		// Display Identification Info
		if ( PawnOwner == PlayerOwner )
			DrawIdentifyInfo(Canvas);

		if ( HUDMutator != None )
			HUDMutator.PostRender(Canvas);

		if ( (PlayerOwner.GameReplicationInfo != None) && (PlayerPawn(Owner).GameReplicationInfo.RemainingTime > 0) ) 
		{
			if ( TimeMessageClass == None )
				TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject("Botpack.TimeMessage", class'Class'));

			if ( (PlayerOwner.GameReplicationInfo.RemainingTime <= 300)
			  && (PlayerOwner.GameReplicationInfo.RemainingTime != LastReportedTime) )
			{
				LastReportedTime = PlayerOwner.GameReplicationInfo.RemainingTime;
				if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 30 )
				{
					bTimeValid = ( bTimeValid || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) );	
					if ( PlayerOwner.GameReplicationInfo.RemainingTime == 30 )
						TellTime(5);
					else if ( bTimeValid && PlayerOwner.GameReplicationInfo.RemainingTime <= 10 )
						TellTime(16 - PlayerOwner.GameReplicationInfo.RemainingTime);
				}
				else if ( PlayerOwner.GameReplicationInfo.RemainingTime % 60 == 0 )
				{
					M = PlayerOwner.GameReplicationInfo.RemainingTime/60;
					TellTime(5 - M);
				}
			}
		}
	}
	if ( PlayerOwner.Player.Console.bTyping )
		DrawTypingPrompt(Canvas, PlayerOwner.Player.Console);

	if ( PlayerOwner.bBadConnectionAlert && (PlayerOwner.Level.TimeSeconds > 5) )
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.DrawColor = WhiteColor;
		Canvas.SetPos(Canvas.ClipX - (64*Scale), Canvas.ClipY / 2);
		Canvas.DrawIcon(texture'DisconnectWarn', Scale);
	}
}

function Timer()
{
	local int i, j;

	if (!bDrawMessageArea)
	{
		if (MessageFadeCount > 0)
			MessageFadeCount--;
	}

	// Age the short message queue.
	for (i=0; i<4; i++)
	{
		// Purge expired messages.
		if ( (ShortMessageQueue[i].Message != None) && (Level.TimeSeconds >= ShortMessageQueue[i].EndOfLife) )
			ClearMessage(ShortMessageQueue[i]);
	}

	// Clean empty slots.
	for (i=0; i<3; i++)
	{
		if ( ShortMessageQueue[i].Message == None )
		{
			for (j=i; j<4; j++)
			{
				if ( ShortMessageQueue[j].Message != None )
				{
					CopyMessage(ShortMessageQueue[i],ShortMessageQueue[j]);
					ClearMessage(ShortMessageQueue[j]);
					break;
				}
			}
		}
	}

	// Age all localized messages.
	for (i=0; i<10; i++)
	{
		// Purge expired messages.
		if ( (LocalMessages[i].Message != None) && (Level.TimeSeconds >= LocalMessages[i].EndOfLife) )
			ClearMessage(LocalMessages[i]);
	}

	// Clean empty slots.
	for (i=0; i<9; i++)
	{
		if ( LocalMessages[i].Message == None )
		{
			CopyMessage(LocalMessages[i],LocalMessages[i+1]);
			ClearMessage(LocalMessages[i+1]);
		}
	}

	if ( (PlayerOwner == None) || (PawnOwner == None) || (PlayerOwner.GameReplicationInfo == None) )
		return;

	// Update the rank and spread.
	UpdateRankAndSpread();
}

function UpdateRankAndSpread()
{
	local PlayerReplicationInfo PRI;
	local int HighScore;
	local int i, j;

	PlayerCount = 0;
	HighScore = -100;
	bTiedScore = False;
	Rank = 1;
	for (i=0; i<32; i++)
	{
		PRI = PlayerOwner.GameReplicationInfo.PRIArray[i];
		if ( (PRI != None) && (!PRI.bIsSpectator || PRI.bWaitingPlayer) )
		{
			PlayerCount++;
			if (PRI != PawnOwner.PlayerReplicationInfo)
			{
				if (PRI.Score > PawnOwner.PlayerReplicationInfo.Score)
					Rank += 1;
				else if (PRI.Score == PawnOwner.PlayerReplicationInfo.Score)
				{
					bTiedScore = True;
					if (PRI.Deaths < PawnOwner.PlayerReplicationInfo.Deaths)
						Rank += 1;
					else if (PRI.Deaths == PawnOwner.PlayerReplicationInfo.Deaths)
						if (PRI.PlayerID < PawnOwner.PlayerReplicationInfo.PlayerID)
							Rank += 1;
				}
				if (PRI.Score > HighScore)
					HighScore = PRI.Score;
			}
		}
	}
	Lead = int(PawnOwner.PlayerReplicationInfo.Score) - HighScore;
}

simulated function TellTime(int num)
{
	PlayerOwner.ReceiveLocalizedMessage( TimeMessageClass, Num );
}

simulated function Tick(float DeltaTime)
{
	local int i;

	Super.Tick(DeltaTime);

	IdentifyFadeTime = FMax(0.0, IdentifyFadeTime - DeltaTime);
	MOTDFadeOutTime = FMax(0.0, MOTDFadeOutTime - DeltaTime * 55);
	
	TutIconBlink += DeltaTime;
	if (TutIconBlink >= 0.5)
		TutIconBlink = 0.0;

	if ( bDrawFaceArea )
	{
		if ( FaceAreaOffset < 0 )
			FaceAreaOffset += DeltaTime * 600;
		if ( FaceAreaOffset > 0 )
			FaceAreaOffset = 0.0;
	} 
	else if ( FaceAreaOffset > MinFaceAreaOffset )
		FaceAreaOffset = FMax(FaceAreaOffset - DeltaTime * 600, MinFaceAreaOffset );

	if ( bDrawMessageArea )
	{
		if ( MessageFadeTime < 1.0 )
		{
			MessageFadeTime += DeltaTime * 8;
			if (MessageFadeTime > 1.0)
				MessageFadeTime = 1.0;
		}
	} 
	else if ( (MessageFadeTime > 0.0) && (MessageFadeCount == 0) )
	{
		MessageFadeTime -= DeltaTime * 2;
		if (MessageFadeTime < 0.0)
			MessageFadeTime = 0.0;
	}
	WeaponNameFade -= DeltaTime;
}

simulated function DrawMOTD(Canvas Canvas)
{
	local GameReplicationInfo GRI;
	local float XL, YL;
	local float InitialY;

	GRI = PlayerPawn(Owner).GameReplicationInfo;
	if ( (GRI == None) || (GRI.GameName == "Game") || (MOTDFadeOutTime <= 0) ) 
		return;

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.Style = Style;
	Canvas.bCenter = true;
	Canvas.DrawColor = UnitColor * MOTDFadeOutTime * 0.5;
	InitialY = 64*Scale;
	Canvas.SetPos(0.0, InitialY);
	Canvas.StrLen("TEST", XL, YL);
	if ( Level.NetMode != NM_Standalone )
	{
		Canvas.DrawText(GRI.ServerName);
		if ( Canvas.ClipY >= 300 )
		{
			Canvas.SetPos(0.0, InitialY + 6*YL);
			Canvas.DrawText(GRI.MOTDLine1, true);
			Canvas.SetPos(0.0, InitialY + 7*YL);
			Canvas.DrawText(GRI.MOTDLine2, true);
			Canvas.SetPos(0.0, InitialY + 8*YL);
			Canvas.DrawText(GRI.MOTDLine3, true);
			Canvas.SetPos(0.0, InitialY + 9*YL);
			Canvas.DrawText(GRI.MOTDLine4, true);
		}
	}
	Canvas.DrawColor = UnitColor * MOTDFadeOutTime * 0.6;
	Canvas.SetPos(0.0, InitialY + YL);
	Canvas.DrawText(GRI.GameName, true);
	Canvas.SetPos(0.0, InitialY + 2*YL);
	Canvas.DrawText(MapTitleString2@Level.Title, true);
	if ( Canvas.ClipY >= 300 )
	{
		Canvas.SetPos(0.0, InitialY + 3*YL);
		Canvas.DrawText(AuthorString2@Level.Author, true);
		if (Level.IdealPlayerCount != "")
		{
			Canvas.SetPos(0.0, InitialY + 4*YL);
			Canvas.DrawText(PlayerCountString$Level.IdealPlayerCount, true);
		}
	}
	Canvas.bCenter = false;
}

simulated function DrawCrossHair( canvas Canvas, int X, int Y)
{
	local float XScale, PickDiff;
	local float XLength;
	local texture T;

 	if (Crosshair>8) Return;
	if ( Canvas.ClipX < 512 )
		XScale = 0.5;
	else
		XScale = FMax(1, int(0.1 + Canvas.ClipX/640.0));
	PickDiff = Level.TimeSeconds - PickupTime;
	if ( PickDiff < 0.4 )
	{
		if ( PickDiff < 0.2 )
			XScale *= (1 + 5 * PickDiff);
		else
			XScale *= (3 - 5 * PickDiff);
	}
	XLength = XScale * 64.0;

	Canvas.bNoSmooth = False;
	if ( PlayerOwner.Handedness == -1 )
		Canvas.SetPos(0.503 * (Canvas.ClipX - XLength), 0.504 * (Canvas.ClipY - XLength));
	else if ( PlayerOwner.Handedness == 1 )
		Canvas.SetPos(0.497 * (Canvas.ClipX - XLength), 0.496 * (Canvas.ClipY - XLength));
	else
		Canvas.SetPos(0.5 * (Canvas.ClipX - XLength), 0.5 * (Canvas.ClipY - XLength));
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = 15 * CrosshairColor;

	T = CrossHairTextures[Crosshair];
	if( T == None )
		T = LoadCrosshair(Crosshair);

	Canvas.DrawTile(T, XLength, XLength, 0, 0, 64, 64);
	Canvas.bNoSmooth = True;
	Canvas.Style = Style;
}

simulated function DrawTypingPrompt( canvas Canvas, console Console )
{
	local string TypingPrompt;
	local float XL, YL, YPos, XOffset;
	local float MyOldClipX, OldClipY, OldOrgX, OldOrgY;

	MyOldClipX = Canvas.ClipX;
	OldClipY = Canvas.ClipY;
	OldOrgX = Canvas.OrgX;
	OldOrgY = Canvas.OrgY;

	Canvas.DrawColor = GreenColor;
	TypingPrompt = "(>"@Console.TypedStr$"_";
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.StrLen( "TEST", XL, YL );
	YPos = YL*4 + 8;
	if (PawnOwner.PlayerReplicationInfo.bIsSpectator || bHideHUD || bHideFaces)
		XOffset = 0;
	else
		XOffset = FMax(0,FaceAreaOffset + 15*Scale + YPos);
	Canvas.SetOrigin(XOffset, FMax(0,YPos + 7*Scale));
	Canvas.SetClip( 760*Scale, Canvas.ClipY );
	Canvas.SetPos( 0, 0 );
	Canvas.DrawText( TypingPrompt, false );
	Canvas.SetOrigin( OldOrgX, OldOrgY );
	Canvas.SetClip( MyOldClipX, OldClipY );
}

// Entry point for string messages.
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local int i;
	local Class<LocalMessage> MessageClass;

	switch (MsgType)
	{
		case 'Say':
		case 'TeamSay':
			MessageClass = class'SayMessagePlus';
			break;
		case 'CriticalEvent':
			MessageClass = class'CriticalStringPlus';
			LocalizedMessage( MessageClass, 0, None, None, None, Msg );
			return;
		case 'DeathMessage':
			MessageClass = class'RedSayMessagePlus';
			break;
		case 'Pickup':
			PickupTime = Level.TimeSeconds;
		default:
			MessageClass = class'StringMessagePlus';
			break;
	}


	for (i=0; i<4; i++)
	{
		if ( ShortMessageQueue[i].Message == None )
		{
			// Add the message here.
			ShortMessageQueue[i].Message = MessageClass;
			ShortMessageQueue[i].Switch = 0;
			ShortMessageQueue[i].RelatedPRI = PRI;
			ShortMessageQueue[i].OptionalObject = None;
			ShortMessageQueue[i].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;
			if ( MessageClass.Default.bComplexString )
				ShortMessageQueue[i].StringMessage = Msg;
			else
				ShortMessageQueue[i].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
			ShortMessageQueue[i].bDrawing = ( ClassIsChildOf(MessageClass, class'SayMessagePlus') || 
				     ClassIsChildOf(MessageClass, class'TeamSayMessagePlus') );
			return;
		}
	}

	// No empty slots.  Force a message out.
	for (i=0; i<3; i++)
		CopyMessage(ShortMessageQueue[i], ShortMessageQueue[i+1]);

	ShortMessageQueue[3].Message = MessageClass;
	ShortMessageQueue[3].Switch = 0;
	ShortMessageQueue[3].RelatedPRI = PRI;
	ShortMessageQueue[3].OptionalObject = None;
	ShortMessageQueue[3].EndOfLife = MessageClass.Default.Lifetime + Level.TimeSeconds;
	if ( MessageClass.Default.bComplexString )
		ShortMessageQueue[3].StringMessage = Msg;
	else
		ShortMessageQueue[3].StringMessage = MessageClass.Static.AssembleString(self,0,PRI,Msg);
	ShortMessageQueue[3].bDrawing = ( ClassIsChildOf(MessageClass, class'SayMessagePlus') || 
			 ClassIsChildOf(MessageClass, class'TeamSayMessagePlus') );
}

simulated function bool DisplayMessages( canvas Canvas )
{
	return true;
}

simulated function float DrawNextMessagePart(Canvas Canvas, string MString, float XOffset, int YPos)
{
	local float XL, YL;

	Canvas.SetPos(4 + XOffset, YPos);
	Canvas.StrLen( MString, XL, YL );
	Canvas.DrawText( MString, false );
	return (XOffset + XL);
}

//================================================================================
// Identify Info

simulated function bool TraceIdentify(canvas Canvas)
{
	local actor Other;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;

	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;
	EndTrace = StartTrace + vector(PawnOwner.ViewRotation) * 1000.0;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	if ( Pawn(Other) != None )
	{
		if ( Pawn(Other).bIsPlayer && !Other.bHidden )
		{
			IdentifyTarget = Pawn(Other).PlayerReplicationInfo;
			IdentifyFadeTime = 3.0;
		}
	}
	else if ( (Other != None) && SpecialIdentify(Canvas, Other) )
		return false;

	if ( (IdentifyFadeTime == 0.0) || (IdentifyTarget == None) || IdentifyTarget.bFeigningDeath )
		return false;

	return true;
}

simulated function bool SpecialIdentify(Canvas Canvas, Actor Other )
{
	return false;
}

simulated function SetIDColor( Canvas Canvas, int type )
{
	Canvas.DrawColor = GreenColor;
	if ( type == 0 )
		Canvas.DrawColor.G = 160 * (IdentifyFadeTime / 3.0);
	else
		Canvas.DrawColor.G = 255 * (IdentifyFadeTime / 3.0);
}

simulated function DrawTwoColorID( canvas Canvas, string TitleString, string ValueString, int YStart )
{
	local float XL, YL, XOffset, X1;

	Canvas.Style = Style;
	Canvas.StrLen(TitleString$": ", XL, YL);
	X1 = XL;
	Canvas.StrLen(ValueString, XL, YL);
	XOffset = Canvas.ClipX/2 - (X1+XL)/2;
	Canvas.SetPos(XOffset, YStart);
	SetIDColor(Canvas,0);
	XOffset += X1;
	Canvas.DrawText(TitleString);
	Canvas.SetPos(XOffset, YStart);
	SetIDColor(Canvas,1);
	Canvas.DrawText(ValueString);
	Canvas.DrawColor = WhiteColor;
	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
}
	
simulated function bool DrawIdentifyInfo(canvas Canvas)
{
	if ( !TraceIdentify(Canvas))
		return false;

	if( IdentifyTarget.PlayerName != "" )
	{
		Canvas.Font = MyFonts.GetBigFont(Canvas.ClipX);
		DrawTwoColorID(Canvas,IdentifyName, IdentifyTarget.PlayerName, Canvas.ClipY - 256 * Scale);
	}
	return true;
}

//=====================================================================
// Deal with a localized message.

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString )
{
	local int i;

	if ( ClassIsChildOf( Message, class'PickupMessagePlus' ) )
		PickupTime = Level.TimeSeconds;

	if ( !Message.Default.bIsSpecial )
	{
		// Find an empty slot.
		for (i=0; i<4; i++)
		{
			if ( ShortMessageQueue[i].Message == None )
			{
				ShortMessageQueue[i].Message = Message;
				ShortMessageQueue[i].Switch = Switch;
				ShortMessageQueue[i].RelatedPRI = RelatedPRI_1;
				ShortMessageQueue[i].OptionalObject = OptionalObject;
				ShortMessageQueue[i].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
				if ( Message.Default.bComplexString )
					ShortMessageQueue[i].StringMessage = CriticalString;
				else
					ShortMessageQueue[i].StringMessage = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
				ShortMessageQueue[i].bDrawing = ( ClassIsChildOf(Message, class'SayMessagePlus') || 
						 ClassIsChildOf(Message, class'TeamSayMessagePlus') );
				return;
			}

		}
		// No empty slots.  Force a message out.
		for (i=0; i<3; i++)
			CopyMessage(ShortMessageQueue[i], ShortMessageQueue[i+1]);

		ShortMessageQueue[3].Message = Message;
		ShortMessageQueue[3].Switch = Switch;
		ShortMessageQueue[3].RelatedPRI = RelatedPRI_1;
		ShortMessageQueue[3].OptionalObject = OptionalObject;
		ShortMessageQueue[3].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
		if ( Message.Default.bComplexString )
			ShortMessageQueue[3].StringMessage = CriticalString;
		else
			ShortMessageQueue[3].StringMessage = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		ShortMessageQueue[3].bDrawing = ( ClassIsChildOf(Message, class'SayMessagePlus') || 
				 ClassIsChildOf(Message, class'TeamSayMessagePlus') );
		return;
	} 
	else 
	{
		if ( CriticalString == "" )
			CriticalString = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		if ( Message.Default.bIsUnique )
		{
			for (i=0; i<10; i++)
			{
				if (LocalMessages[i].Message != None)
				{
					if ((LocalMessages[i].Message == Message) 
						|| (LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, 24, 640) 
								== Message.Static.GetOffset(Switch, 24, 640)) ) 
					{
						LocalMessages[i].Message = Message;
						LocalMessages[i].Switch = Switch;
						LocalMessages[i].RelatedPRI = RelatedPRI_1;
						LocalMessages[i].OptionalObject = OptionalObject;
						LocalMessages[i].LifeTime = Message.Default.Lifetime;
						LocalMessages[i].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
						LocalMessages[i].StringMessage = CriticalString;
						LocalMessages[i].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);				
						LocalMessages[i].XL = 0;
						return;
					}
				}
			}
		}
		for (i=0; i<10; i++)
		{
			if (LocalMessages[i].Message == None)
			{
				LocalMessages[i].Message = Message;
				LocalMessages[i].Switch = Switch;
				LocalMessages[i].RelatedPRI = RelatedPRI_1;
				LocalMessages[i].OptionalObject = OptionalObject;
				LocalMessages[i].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
				LocalMessages[i].StringMessage = CriticalString;
				LocalMessages[i].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);				
				LocalMessages[i].LifeTime = Message.Default.Lifetime;
				LocalMessages[i].XL = 0;
				return;
			}
		}

		// No empty slots.  Force a message out.
		for (i=0; i<9; i++)
			CopyMessage(LocalMessages[i],LocalMessages[i+1]);

		LocalMessages[9].Message = Message;
		LocalMessages[9].Switch = Switch;
		LocalMessages[9].RelatedPRI = RelatedPRI_1;
		LocalMessages[9].OptionalObject = OptionalObject;
		LocalMessages[9].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
		LocalMessages[9].StringMessage = CriticalString;
		LocalMessages[9].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);				
		LocalMessages[9].LifeTime = Message.Default.Lifetime;
		LocalMessages[9].XL = 0;
		return;
	}
}

defaultproperties
{
	bUseTeamColor=true
	FavoriteHUDColor=(R=0,G=0,B=16)
	CrosshairColor=(R=0,G=16,B=0)
	ScoreTime=-10000000.0
	CrosshairCount=9
	Crosshairs(0)="Botpack.CHair1"
	Crosshairs(1)="Botpack.CHair2"
	Crosshairs(2)="Botpack.CHair3"
	Crosshairs(3)="Botpack.CHair4"
	Crosshairs(4)="Botpack.CHair5"
	Crosshairs(5)="Botpack.CHair6"
	Crosshairs(6)="Botpack.CHair7"
	Crosshairs(7)="Botpack.CHair8"
	Crosshairs(8)="Botpack.CHair9"
	Style=3
	HudScale=+1.0
	Opacity=15
	IdentifyName="Name:"
	IdentifyHealth="Health:"
	VersionMessage="Version"
	bStartUpMessage=True
	IdentifyCallsign="Callsign:"
	PlayerCountString="Ideal Player Load:"
	WhiteColor=(R=255,G=255,B=255)
	RedColor=(R=255,G=0,B=0)
	BlueColor=(R=0,G=0,B=255)
	GreenColor=(R=0,G=255,B=0)
	GoldColor=(R=255,G=255,B=0)
	TurqColor=(R=0,G=128,B=255)
	GrayColor=(R=200,G=200,B=200)
	FaceColor=(R=50,G=50,B=50)
	CyanColor=(R=0,G=255,B=255)
	PurpleColor=(R=255,G=0,B=255)
	UnitColor=(R=1,G=1,B=1)
	MapTitleString="in"
	MapTitleString2="Map:"
	AuthorString="by"
	AuthorString2="Author:"
	GrayWeapons(1)=GreyMPact
	GrayWeapons(2)=GreyAutom
	GrayWeapons(3)=GreyBio
	GrayWeapons(4)=GreyASMD
	GrayWeapons(5)=GreyPulse
	GrayWeapons(6)=GreyRazJk
	GrayWeapons(7)=GreyMini
	GrayWeapons(8)=GreyFlak
	GrayWeapons(9)=GreyRockt
	GrayWeapons(10)=GreyRifle
	StatusScale=1.0
	WeaponScale=0.8
	HUDConfigWindowType="UTMenu.UTChallengeHUDConfig"
	LiveFeed="Live Feed from "
	RankString="Rank:"
	SpreadString="Spread:"
	ServerInfoClass=class'ServerInfo'
	FP1(0)=texture'FacePanel1'
	FP1(1)=texture'FacePanel1b'
	FP1(2)=texture'FacePanel1a'
	FP2(0)=texture'FacePanel2'
	FP2(1)=texture'FacePanel2b'
	FP2(2)=texture'FacePanel2a'
	FP3(0)=texture'FacePanel3'
	FP3(1)=texture'FacePanel3b'
	FP3(2)=texture'FacePanel3a'
}
