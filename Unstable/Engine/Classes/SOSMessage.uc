/*-----------------------------------------------------------------------------
	SOSMessage
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class SOSMessage extends LocalMessage;

var localized string Message;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject,
	optional class<Actor> OptionalClass
	)
{
	return Default.Message;
}

defaultproperties
{
	Message="Incoming S.O.S Transmission..."
	DrawColor=(R=0,G=255,B=0)
}