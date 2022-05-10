//=============================================================================
// FactoryChanger.
//=============================================================================
class FactoryTrigger expands Triggers;

var() float NewMaxItems;
var() float NewCapacity;
var() bool	UseNewMaxItems;
var() bool	UseNewCapacity;
var() Name	MatchTag;

function Trigger( actor Other, pawn EventInstigator )
{
	local ThingFactory Factory;

	if( Event != '' )
	{
		foreach allactors( class'ThingFactory', Factory, MatchTag )
		{
			if( !UseNewMaxItems )
			{
				Factory.MaxItems = NewMaxItems;
			}

			if( !UseNewCapacity )
			{
				Factory.Capacity = NewCapacity;
			}
		}
	}
}

defaultproperties
{
}
