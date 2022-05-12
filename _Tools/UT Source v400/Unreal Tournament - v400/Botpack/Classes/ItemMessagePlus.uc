// Switch 0: Expire Message
//	OptionalObject is a Pickup
class ItemMessagePlus expands LocalMessagePlus;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		case 0:
			if (OptionalObject != None)
			{
				return Class<Pickup>(OptionalObject).Default.ExpireMessage;
			}
			break;
	}
	return "";
}

defaultproperties
{
	Lifetime=3

	DrawColor=(R=255,G=255,B=255)
	bCenter=True
}