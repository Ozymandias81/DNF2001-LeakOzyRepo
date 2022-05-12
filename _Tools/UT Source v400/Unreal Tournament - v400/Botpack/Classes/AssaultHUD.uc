//=============================================================================
// AssaultHUD
//=============================================================================
class AssaultHUD extends ChallengeTeamHUD;

var localized string IdentifyAssault;

simulated function DrawFragCount(Canvas Canvas)
{
	local float Y;

	if ( bHideAllWeapons || (HudScale * WeaponScale * Canvas.ClipX <= Canvas.ClipX - 256 * Scale) )
		Y = Canvas.ClipY - 128 * Scale;
	else
		Y = Canvas.ClipY - 192 * Scale;

	DrawTimeAt(Canvas, 2, Y);

	Super.DrawFragCount(Canvas);
}

simulated function DrawGameSynopsis(Canvas Canvas)
{
}

simulated function DrawTimeAt(Canvas Canvas, float X, float Y)
{
	local int Minutes, Seconds, d;

	if ( PlayerOwner.GameReplicationInfo == None )
		return;

	Canvas.DrawColor = RedColor;
	Canvas.CurX = X;
	Canvas.CurY = Y;
	Canvas.Style = Style;

	if ( PlayerOwner.GameReplicationInfo.RemainingTime > 0 )
	{
		Minutes = PlayerOwner.GameReplicationInfo.RemainingTime/60;
		Seconds = PlayerOwner.GameReplicationInfo.RemainingTime % 60;
	}
	else
	{
		Minutes = 0;
		Seconds = 0;
	}
	
	if ( Minutes > 0 )
	{
		if ( Minutes >= 10 )
		{
			d = Minutes/10;
			Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, d*25, 0, 25.0, 64.0);
			Canvas.CurX += 7*Scale;
			Minutes= Minutes - 10 * d;
		}
		else
		{
			Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 0, 0, 25.0, 64.0);
			Canvas.CurX += 7*Scale;
		}

		Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, Minutes*25, 0, 25.0, 64.0);
		Canvas.CurX += 7*Scale;
	} else {
		Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 0, 0, 25.0, 64.0);
		Canvas.CurX += 7*Scale;
	}
	Canvas.CurX -= 4 * Scale;
	Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 32, 64, 25.0, 64.0);
	Canvas.CurX += 3 * Scale;

	d = Seconds/10;
	Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 25*d, 0, 25.0, 64.0);
	Canvas.CurX += 7*Scale;

	Seconds = Seconds - 10 * d;
	Canvas.DrawTile(Texture'BotPack.HudElements1', Scale*25, 64*Scale, 25*Seconds, 0, 25.0, 64.0);
	Canvas.CurX += 7*Scale;
}

simulated function bool SpecialIdentify(Canvas Canvas, Actor Other )
{
	local float XL, YL;

	if ( !Other.IsA('FortStandard') )
		return false;

	Canvas.Font = MyFonts.GetSmallFont( Canvas.ClipX );
	Canvas.DrawColor = RedColor * IdentifyFadeTime * 0.333;
	Canvas.StrLen(IdentifyAssault, XL, YL);
	Canvas.SetPos(Canvas.ClipX/2 - XL/2, Canvas.ClipY - 74);
	Canvas.DrawText(IdentifyAssault);

	return true;
}

defaultproperties
{
	IdentifyAssault=" !! Assault Target !! "
	ServerInfoClass=class'ServerInfoAS'
}