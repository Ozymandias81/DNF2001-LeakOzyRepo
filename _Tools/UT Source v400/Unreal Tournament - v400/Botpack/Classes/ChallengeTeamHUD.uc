//=============================================================================
// ChallengeTeamHUD
//=============================================================================
class ChallengeTeamHUD extends ChallengeHUD;

#exec TEXTURE IMPORT NAME=I_TeamB FILE=TEXTURES\HUD\TabBluTm.PCX GROUP="Icons" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=I_TeamN FILE=TEXTURES\HUD\TabWhiteTm.PCX GROUP="Icons" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=I_TeamR FILE=TEXTURES\HUD\TabRedTm.PCX GROUP="Icons" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=I_TeamG FILE=TEXTURES\HUD\TabGrnTm.PCX GROUP="Icons" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=I_TeamY FILE=TEXTURES\HUD\TabYloTm.PCX GROUP="Icons" MIPS=OFF FLAGS=2

#exec TEXTURE IMPORT NAME=Static1 FILE=TEXTURES\HUD\Static1.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=Static2 FILE=TEXTURES\HUD\Static2.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=Static3 FILE=TEXTURES\HUD\Static3.PCX GROUP="Icons" MIPS=OFF

var Texture TeamIcon[4];
var() color TeamColor[4];
var() color AltTeamColor[4];

var() localized name OrderNames[16];
var() int NumOrders;

simulated function HUDSetup(canvas canvas)
{
	Super.HUDSetup(canvas);
	if ( bUseTeamColor && (PawnOwner.PlayerReplicationInfo != None)
		&& (PawnOwner.PlayerReplicationInfo.Team < 4) )
	{
		HUDColor = TeamColor[PawnOwner.PlayerReplicationInfo.Team];
		SolidHUDColor = HUDColor;
		if ( Level.bHighDetailMode )
			HUDColor = Opacity * 0.0625 * HUDColor;
	}
}

simulated function DrawGameSynopsis(Canvas Canvas)
{
	local TournamentGameReplicationInfo GRI;
	local int i;

	GRI = TournamentGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	if ( GRI != None )
		for ( i=0 ;i<4; i++ )
			DrawTeam(Canvas, GRI.Teams[i]);
}

simulated function DrawTeam(Canvas Canvas, TeamInfo TI)
{
	local float XL, YL;

	if ( (TI != None) && (TI.Size > 0) )
	{
		Canvas.Font = MyFonts.GetHugeFont( Canvas.ClipX );
		Canvas.DrawColor = TeamColor[TI.TeamIndex];
		Canvas.SetPos(Canvas.ClipX - 64 * Scale, Canvas.ClipY - (336 + 128 * TI.TeamIndex) * Scale);
		Canvas.DrawIcon(TeamIcon[TI.TeamIndex], Scale);
		Canvas.StrLen(int(TI.Score), XL, YL);
		Canvas.SetPos(Canvas.ClipX - XL - 66 * Scale, Canvas.ClipY - (336 + 128 * TI.TeamIndex) * Scale + ((64 * Scale) - YL)/2 );
		Canvas.DrawText(int(TI.Score), false);
	}
}

// Entry point for string messages.
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local int i;
	local Class<LocalMessage> MessageClass;

	switch (MsgType)
	{
		case 'Say':
			MessageClass = class'SayMessagePlus';
			break;
		case 'TeamSay':
			MessageClass = class'TeamSayMessagePlus';
			break;
		case 'CriticalEvent':
			MessageClass = class'CriticalStringPlus';
			LocalizedMessage( MessageClass, 0, None, None, None, Msg );
			return;
		default:
			MessageClass= class'StringMessagePlus';
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
		CopyMessage(ShortMessageQueue[i],ShortMessageQueue[i+1]);

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

simulated function SetIDColor( Canvas Canvas, int type )
{
	if ( type == 0 )
		Canvas.DrawColor = AltTeamColor[IdentifyTarget.Team] * 0.333 * IdentifyFadeTime;
	else
		Canvas.DrawColor = TeamColor[IdentifyTarget.Team] * 0.333 * IdentifyFadeTime;

}

simulated function bool DrawIdentifyInfo(canvas Canvas)
{
	local float XL, YL, XOffset, X1;
	local Pawn P;

	if ( !Super.DrawIdentifyInfo(Canvas) )
		return false;

	Canvas.StrLen("TEST", XL, YL);
	if( PawnOwner.PlayerReplicationInfo.Team == IdentifyTarget.Team )
	{
		P = Pawn(IdentifyTarget.Owner);
		Canvas.Font = MyFonts.GetSmallFont(Canvas.ClipX);
		if ( P != None )
			DrawTwoColorID(Canvas,IdentifyHealth,string(P.Health), (Canvas.ClipY - 256 * Scale) + 1.5 * YL);
	}
	return true;
}

function DrawTalkFace(Canvas Canvas, int i, float YPos)
{
	if ( !bHideHUD && (PawnOwner.PlayerReplicationInfo != None) && !PawnOwner.PlayerReplicationInfo.bIsSpectator )
	{
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(FaceAreaOffset, 0);
		Canvas.DrawColor = TeamColor[ShortMessageQueue[i].RelatedPRI.Team];
		Canvas.DrawTile(texture'LadrStatic.Static_a00', YPos + 7*Scale, YPos + 7*Scale, 0, 0, texture'FacePanel1'.USize, texture'FacePanel1'.VSize);
		Canvas.DrawColor = WhiteColor;
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(FaceAreaOffset + 4*Scale, 4*Scale);
		if ( ( ShortMessageQueue[i].RelatedPRI != None )
			&& ( ShortMessageQueue[i].RelatedPRI.TalkTexture != None ) )
				Canvas.DrawTile(ShortMessageQueue[i].RelatedPRI.TalkTexture, YPos - 1*Scale, YPos - 1*Scale, 0, 0, ShortMessageQueue[i].RelatedPRI.TalkTexture.USize, ShortMessageQueue[i].RelatedPRI.TalkTexture.VSize);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = FaceColor;
		Canvas.SetPos(FaceAreaOffset, 0);
		Canvas.DrawTile(texture'LadrStatic.Static_a00', YPos + 7*Scale, YPos + 7*Scale, 0, 0, texture'LadrStatic.Static_a00'.USize, texture'LadrStatic.Static_a00'.VSize);
		Canvas.DrawColor = WhiteColor;
	}
}

defaultproperties
{
	 TeamIcon(0)=texture'I_TeamR'
	 TeamIcon(1)=texture'I_TeamB'
	 TeamIcon(2)=texture'I_TeamG'
	 TeamIcon(3)=texture'I_TeamY'
	 TeamColor(0)=(R=255,G=0,B=0)
	 TeamColor(1)=(R=0,G=128,B=255)
	 TeamColor(2)=(R=0,G=255,B=0)
	 TeamColor(3)=(R=255,G=255,B=0)
	 AltTeamColor(0)=(R=200,G=0,B=0)
	 AltTeamColor(1)=(R=0,G=94,B=187)
	 AltTeamColor(2)=(R=0,G=128,B=0)
	 AltTeamColor(3)=(R=255,G=255,B=128)
     OrderNames(0)=Defend
     OrderNames(1)=Hold
     OrderNames(2)=Attack
     OrderNames(3)=Follow
     OrderNames(4)=FreeLance
	 OrderNames(5)=Point
     OrderNames(10)=Attack
     OrderNames(11)=FreeLance
     NumOrders=5
	 ServerInfoClass=class'ServerInfoTeam'
}