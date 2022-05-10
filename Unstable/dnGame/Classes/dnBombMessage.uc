class dnBombMessage expands CriticalEventMessage;

var localized string BombPlantedString;
var localized string BombDroppedString;
var localized string CantPlantBombString;
var localized string DroppedTheBombString;
var localized string PlantedTheBombString;
var localized string BombDetonatedMessage;
var localized string Detonate10SecondWarning;
var localized string CouldntPlantBombHere;

static function string GetString
(
	optional int					Switch,
	optional PlayerReplicationInfo	RelatedPRI_1, 
	optional PlayerReplicationInfo	RelatedPRI_2,
	optional Object					OptionalObject,
	optional class<Actor>			OptionalClass
)
{
	switch ( Switch )
	{
		case 0:
			if (RelatedPRI_1 == None)
				return default.BombPlantedString;
			else
				return RelatedPRI_1.PlayerName @ default.PlantedTheBombString;
			break;
		case 1:
			return default.CantPlantBombString;
			break;
		case 2:
			if (RelatedPRI_1 == None)
				return default.BombDroppedString;
			else
				return RelatedPRI_1.PlayerName @ default.DroppedTheBombString;
			break;
		case 3:
			return default.BombDetonatedMessage;
			break;
		case 4:
			return default.Detonate10SecondWarning;
			break;
		case 5:
			return default.CouldntPlantBombHere;
			break;
		default:
			return "";
			break;
	}
}

defaultproperties
{
	bBeep=true
	bIsConsoleMessage=true
	YPos=225
	DrawColor=(R=255,G=255,B=255)

	BombPlantedString="The bomb has been planted."
	CantPlantBombString="You can't plant the bomb here."	
	DroppedTheBombString="dropped the bomb."
	PlantedTheBombString="planted the bomb."	
	Detonate10SecondWarning="The bomb will go off in 10 seconds!"
	CouldntPlantBombHere="Couldn't plant the bomb here!"
}