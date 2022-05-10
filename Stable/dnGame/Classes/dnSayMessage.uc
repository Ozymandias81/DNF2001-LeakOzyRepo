/*-----------------------------------------------------------------------------
	dnSayMessage
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnSayMessage expands LocalMessage;

static function string AssembleString(
	HUD MyHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	if ( RelatedPRI_1.bSquelch )
		return "";
	
	if ( RelatedPRI_1 == None )
		return "";
	
	if ( RelatedPRI_1.PlayerName == "" )
		return "";
	
	return RelatedPRI_1.PlayerName$": "@MessageString;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return Default.YPos/768 * ClipY;
}

defaultproperties
{
	DrawColor=(R=255,G=255,B=255)
}