//=============================================================================
// UnrealTeamHUD
//=============================================================================
class UnrealTeamHUD extends UnrealHUD;

#exec TEXTURE IMPORT NAME=BlueSkull FILE=TEXTURES\HUD\i_skullb.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=GreenSkull FILE=TEXTURES\HUD\i_skullg.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=RedSkull FILE=TEXTURES\HUD\i_skullr.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=YellowSkull FILE=TEXTURES\HUD\i_skully.PCX GROUP="Icons" MIPS=OFF

simulated function DrawFragCount(Canvas Canvas, int X, int Y)
{
	local texture SkullTexture;

	SkullTexture = texture'IconSkull';

	if ( Pawn(Owner).PlayerReplicationInfo.TeamName ~= "red" )
		SkullTexture = texture'RedSkull';
	else if ( Pawn(Owner).PlayerReplicationInfo.TeamName ~= "blue" )
		SkullTexture = texture'BlueSkull';
	else if ( Pawn(Owner).PlayerReplicationInfo.TeamName ~= "green" )
		SkullTexture = texture'GreenSkull';
	else if ( Pawn(Owner).PlayerReplicationInfo.TeamName ~= "yellow" )
		SkullTexture = texture'YellowSkull';

	DrawSkull(Canvas, X, Y, SkullTexture);
}

function DrawSkull(Canvas Canvas, int X, int Y, texture SkullTexture)
{ 
	Canvas.SetPos(X,Y);
	Canvas.DrawIcon(SkullTexture, 1.0);	
	Canvas.CurX -= 19;
	Canvas.CurY += 23;
	Canvas.Font = Font'TinyWhiteFont';	
	if (Pawn(Owner).PlayerReplicationInfo.Score<100) Canvas.CurX+=6;
	if (Pawn(Owner).PlayerReplicationInfo.Score<10) Canvas.CurX+=6;	
	if (Pawn(Owner).PlayerReplicationInfo.Score<0) Canvas.CurX-=6;
	if (Pawn(Owner).PlayerReplicationInfo.Score<-9) Canvas.CurX-=6;
	Canvas.DrawText(int(Pawn(Owner).PlayerReplicationInfo.Score),False);
				
}

simulated function DrawIdentifyInfo(canvas Canvas, float PosX, float PosY)
{
	local float XL, YL, XOffset;

	if (!TraceIdentify(Canvas))
		return;

	if(IdentifyTarget.IsA('PlayerPawn'))
		if(PlayerPawn(IdentifyTarget).PlayerReplicationInfo.bFeigningDeath)
			return;

	Canvas.Font = Font'WhiteFont';
	Canvas.Style = 3;

	XOffset = 0.0;
	Canvas.StrLen(IdentifyName$": "$IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
	XOffset = Canvas.ClipX/2 - XL/2;
	Canvas.SetPos(XOffset, Canvas.ClipY - 74);

	if(IdentifyTarget.PlayerReplicationInfo.PlayerName != "")
	{
		Canvas.DrawColor = AltTeamColor[IdentifyTarget.PlayerReplicationInfo.Team];
		Canvas.DrawColor.R = Canvas.DrawColor.R * IdentifyFadeTime / 3.0; 
		Canvas.DrawColor.G = Canvas.DrawColor.G * IdentifyFadeTime / 3.0; 
		Canvas.DrawColor.B = Canvas.DrawColor.B * IdentifyFadeTime / 3.0; 
		Canvas.StrLen(IdentifyName$": ", XL, YL);
		XOffset += XL;
		Canvas.DrawText(IdentifyName$": ");
		Canvas.SetPos(XOffset, Canvas.ClipY - 74);
		Canvas.DrawColor = TeamColor[IdentifyTarget.PlayerReplicationInfo.Team]; 
		Canvas.DrawColor.R = Canvas.DrawColor.R * IdentifyFadeTime / 3.0; 
		Canvas.DrawColor.G = Canvas.DrawColor.G * IdentifyFadeTime / 3.0; 
		Canvas.DrawColor.B = Canvas.DrawColor.B * IdentifyFadeTime / 3.0; 
		Canvas.StrLen(IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
		Canvas.DrawText(IdentifyTarget.PlayerReplicationInfo.PlayerName);
	}

	XOffset = 0.0;
	Canvas.StrLen(IdentifyHealth$": "$IdentifyTarget.Health, XL, YL);
	XOffset = Canvas.ClipX/2 - XL/2;
	Canvas.SetPos(XOffset, Canvas.ClipY - 64);

	if(Pawn(Owner).PlayerReplicationInfo.Team == IdentifyTarget.PlayerReplicationInfo.Team)
	{
		Canvas.DrawColor = AltTeamColor[IdentifyTarget.PlayerReplicationInfo.Team]; 
		Canvas.DrawColor.R = Canvas.DrawColor.R * IdentifyFadeTime / 3.0; 
		Canvas.DrawColor.G = Canvas.DrawColor.G * IdentifyFadeTime / 3.0; 
		Canvas.DrawColor.B = Canvas.DrawColor.B * IdentifyFadeTime / 3.0; 
		Canvas.StrLen(IdentifyHealth$": ", XL, YL);
		XOffset += XL;
		Canvas.DrawText(IdentifyHealth$": ");
		Canvas.SetPos(XOffset, Canvas.ClipY - 64);
		Canvas.DrawColor = TeamColor[IdentifyTarget.PlayerReplicationInfo.Team]; 
		Canvas.DrawColor.R = Canvas.DrawColor.R * IdentifyFadeTime / 3.0; 
		Canvas.DrawColor.G = Canvas.DrawColor.G * IdentifyFadeTime / 3.0; 
		Canvas.DrawColor.B = Canvas.DrawColor.B * IdentifyFadeTime / 3.0; 
		Canvas.StrLen(IdentifyTarget.Health, XL, YL);
		Canvas.DrawText(IdentifyTarget.Health);
	}

	Canvas.Style = 1;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

defaultproperties
{
}
