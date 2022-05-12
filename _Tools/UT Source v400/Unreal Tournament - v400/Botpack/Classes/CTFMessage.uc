//
// CTF Messages
//
// Switch 0: Capture Message
//	RelatedPRI_1 is the scorer.
//	OptionalObject is the flag.
//
// Switch 1: Return Message
//	RelatedPRI_1 is the scorer.
//	OptionalObject is the flag.
//
// Switch 2: Dropped Message
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.
//	
// Switch 3: Was Returned Message
//	OptionalObject is the flag's team teaminfo.
//
// Switch 4: Has the flag.
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 5: Auto Send Home.
//	OptionalObject is the flag's team teaminfo.
//
// Switch 6: Pickup stray.
//	RelatedPRI_1 is the holder.
//	OptionalObject is the flag's team teaminfo.

class CTFMessage extends CriticalEventPlus;

var localized string ReturnBlue, ReturnRed;
var localized string ReturnedBlue, ReturnedRed;
var localized string CaptureBlue, CaptureRed;
var localized string DroppedBlue, DroppedRed;
var localized string HasBlue,HasRed;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch (Switch)
	{
		// Captured the flag.
		case 0:
			if (RelatedPRI_1 == None)
				return "";
			if ( CTFFlag(OptionalObject) == None )
				return "";

			if ( CTFFlag(OptionalObject).Team == 0 )
				return RelatedPRI_1.PlayerName@Default.CaptureRed;
			else
				return RelatedPRI_1.PlayerName@Default.CaptureBlue;
			break;

		// Returned the flag.
		case 1:
			if ( CTFFlag(OptionalObject) == None )
				return "";
			if (RelatedPRI_1 == None)
			{
				if ( CTFFlag(OptionalObject).Team == 0 )
					return Default.ReturnedRed;
				else
					return Default.ReturnedBlue;
			}
			if ( CTFFlag(OptionalObject).Team == 0 )
				return RelatedPRI_1.PlayerName@Default.ReturnRed;
			else
				return RelatedPRI_1.PlayerName@Default.ReturnBlue;
			break;

		// Dropped the flag.
		case 2:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return RelatedPRI_1.PlayerName@Default.DroppedRed;
			else
				return RelatedPRI_1.PlayerName@Default.DroppedBlue;
			break;

		// Was returned.
		case 3:
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return Default.ReturnedRed;
			else
				return Default.ReturnedBlue;
			break;

		// Has the flag.
		case 4:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return RelatedPRI_1.PlayerName@Default.HasRed;
			else
				return RelatedPRI_1.PlayerName@Default.HasBlue;
			break;

		// Auto send home.
		case 5:
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return Default.ReturnedRed;
			else
				return Default.ReturnedBlue;
			break;

		// Pickup
		case 6:
			if (RelatedPRI_1 == None)
				return "";
			if ( TeamInfo(OptionalObject) == None )
				return "";

			if ( TeamInfo(OptionalObject).TeamIndex == 0 )
				return RelatedPRI_1.PlayerName@Default.HasRed;
			else
				return RelatedPRI_1.PlayerName@Default.HasBlue;
			break;
	}
	return "";
}

defaultproperties
{
	ReturnBlue="returns the blue flag!" 
	ReturnRed="returns the red flag!"
	ReturnedBlue="The blue flag was returned!"
	ReturnedRed="The red flag was returned!"
	CaptureBlue="captured the blue flag!  The red team scores!"
	CaptureRed="captured the red flag!  The blue team scores!"
	DroppedBlue="dropped the blue flag!"
	DroppedRed="dropped the red flag!"
	HasRed="has the red flag!"
	HasBlue="has the blue flag!"
}