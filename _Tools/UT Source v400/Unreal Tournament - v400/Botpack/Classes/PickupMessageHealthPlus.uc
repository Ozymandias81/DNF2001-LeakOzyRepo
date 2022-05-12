//
// OptionalObject is an Inventory
//
class PickupMessageHealthPlus expands PickupMessagePlus;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return ClipY - YL - (64.0/768)*ClipY;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (OptionalObject != None)
	{
		if (Class<TournamentHealth>(OptionalObject) != None)
			return Class<Inventory>(OptionalObject).Default.PickupMessage$Class<TournamentHealth>(OptionalObject).Default.HealingAmount;
		else
			return Class<Inventory>(OptionalObject).Default.PickupMessage;
	}
}

