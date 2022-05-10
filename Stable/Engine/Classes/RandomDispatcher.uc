//=============================================================================
// RandomDispatcher.
// When triggered, picks and triggers a random event from 'OutEvents'.
//
// If 'OnlyPickOnce' is set, then it will only pick each valid event once, until
// no more events are left.  When this condition is reached, if 'ResetOnEmpty'
// is set the process will start over, otherwise further triggers will have no
// effect.
//
// 'EnieMenieMinyMoe' is silly but could be useful when used with 'OnlyPickOnce'.  
// It will cause the RandomDispatcher to pick a random choice each trigger, but 
// when reset it will choose the same choices in the same (seemingly random) 
// order.
//=============================================================================
class RandomDispatcher expands Triggers;

#exec Texture Import File=Textures\RandomDispatch.pcx Name=S_RandomDispatch Mips=Off Flags=2

var () name OutEvents[16];				// Random events to pick from.
var    byte OutEventAlreadyPicked[16];	// Internal use.

var () bool OnlyPickOnce;				// Only pick each event once.
var () bool ResetOnEmpty;				// Reset when all triggers have been picked once.

// Enie Menie Miney Moe; 
// Catch a tiger by the toe; 
// if it hollers, make it pay; 
// 50 dollars every day. 		(20 Words)
var () bool EnieMenieMinyMoe;

// My mother told me to pick the very best one, and you are not it (15 Words)
var () bool MyMotherClause;

function name PickOutEvent()
{
	local int ValidEventCount, AlreadyPickedValidEventCount, i, PickedEvent, PrePickIndex;

	// Count the number of valid events:
	ValidEventCount=0; AlreadyPickedValidEventCount=0;
	for(i=0;i<ArrayCount(OutEvents);i++)
	{
		if(OutEvents[i]!='')
		{
			if(!OnlyPickOnce||!bool(OutEventAlreadyPicked[i]))
			{
				ValidEventCount++;
			}
			
			if(bool(OutEventAlreadyPicked[i]))
			{
				AlreadyPickedValidEventCount++;
			}
		}
	}	
	
	// Are there any valid events ripe for the picking?
	if(ValidEventCount==0)	// No, can we reset?
	{
		// Would it be beneficial to clear the already picked tags and retry?
		if(OnlyPickOnce&&ResetOnEmpty&&bool(AlreadyPickedValidEventCount))
		{
			// Clear them out:
			for(i=0;i<ArrayCount(OutEventAlreadyPicked);i++)
			{
				OutEventAlreadyPicked[i]=0;	
			}
		
			return PickOutEvent(); // Return the new result
		} else
			return '';			   // Hopeless, no valid events and no possibility for reset.
	}
	
	// Randomly select the index of the event to be picked.	
	if(EnieMenieMinyMoe) // Pick modulo 20 :^)
	{
		i=20;	
		if(MyMotherClause) i+=15; 
		
		PrePickIndex=i%ValidEventCount;		// Enie Menie Miney Moe optimization 
	} else
		PrePickIndex=Rand(ValidEventCount); // Just Pick normally :^)

	// Convert PrePickIndex to PickedEventIndex:
	ValidEventCount=0;
	for(i=0;i<ArrayCount(OutEvents);i++)
	{
	
		if(OutEvents[i]!='')
		{
			if(!OnlyPickOnce||!bool(OutEventAlreadyPicked[i]))
			{
				// Is this it?
				if(ValidEventCount==PrePickIndex)
				{
					OutEventAlreadyPicked[i]=1;
					return OutEvents[i];	// Outta here!
				}	
				ValidEventCount++;
			}
		}	
	
	}
	return '';
}

// Check to see if I've been triggered:
function Trigger( actor Other, pawn EventInstigator )
{
	GlobalTrigger(PickOutEvent(),EventInstigator);
}

defaultproperties
{
     Texture=Texture'Engine.S_RandomDispatch'
}
