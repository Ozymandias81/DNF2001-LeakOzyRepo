class TeamSayMessagePlus expands StringMessagePlus;

static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional string MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string LocationName;

	if (RelatedPRI_1 == None)
		return;

	Canvas.DrawColor = Default.GreenColor;
	Canvas.DrawText( RelatedPRI_1.PlayerName$" ", False );
	Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
	if ( RelatedPRI_1.PlayerLocation != None )
		LocationName = RelatedPRI_1.PlayerLocation.LocationName;
	else if ( RelatedPRI_1.PlayerZone != None )
		Locationname = RelatedPRI_1.PlayerZone.ZoneName;

	if (LocationName != "")
	{
		Canvas.DrawColor = Default.CyanColor;
		Canvas.DrawText( " ("$LocationName$"):", False );
	}
	else
		Canvas.DrawText( ": ", False );
	Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
	Canvas.DrawColor = Default.LightGreenColor;
	Canvas.DrawText( MessageString, False );
}

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	local string LocationName;

	if (RelatedPRI_1 == None)
		return "";
	if ( RelatedPRI_1.PlayerLocation != None )
		LocationName = RelatedPRI_1.PlayerLocation.LocationName;
	else if ( RelatedPRI_1.PlayerZone != None )
		Locationname = RelatedPRI_1.PlayerZone.ZoneName;
	if ( Locationname == "" )
		return RelatedPRI_1.PlayerName$" "$": "$MessageString;
	else
		return RelatedPRI_1.PlayerName$"  ("$LocationName$"): "$MessageString;
}

defaultproperties
{
	bComplexString=True
	DrawColor=(R=0,G=255,B=0)
}