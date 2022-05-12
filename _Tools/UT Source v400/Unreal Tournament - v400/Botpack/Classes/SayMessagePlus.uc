class SayMessagePlus expands StringMessagePlus;

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
	if (RelatedPRI_1 == None)
		return;

	Canvas.DrawColor = Default.GreenColor;
	Canvas.DrawText( RelatedPRI_1.PlayerName$": ", False );
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
	if ( RelatedPRI_1 == None )
		return "";
	if ( RelatedPRI_1.PlayerName == "" )
		return "";
	return RelatedPRI_1.PlayerName$": "@MessageString;
}

defaultproperties
{
	bComplexString=True
	DrawColor=(R=0,G=255,B=0)
}