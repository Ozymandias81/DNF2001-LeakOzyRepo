//=============================================================================
// FactoryKiller.
//=============================================================================
class FactoryKiller expands Triggers;

var() bool		bKillFactoryPawns;
var() name		MatchTag;

function Trigger( actor Other, pawn EventInstigator )
{
	local ThingFactory Factory;
	local Pawn KilledPawn;
	local CreatureFactory CF;

	if( MatchTag == '' && Event != '' )
	{
		MatchTag = Event;
	}

	if( bKillFactoryPawns )
	{
		for( KilledPawn = Level.PawnList; KilledPawn != None; KilledPawn = KilledPawn.NextPawn )
		{
			if( KilledPawn.Owner.IsA( 'ThingFactory' ) ) 
			{
				if( ThingFactory( KilledPawn.Owner ).Tag == MatchTag )
					KilledPawn.Destroy();
				else
				{
					CF = CreatureFactory( KilledPawn.Owner );
					if( CF != None )	
					{
						if( CF.bUseCreatureTag )
						{
							if( MatchTag == CF.CreatureTag )
							{
								KilledPawn.Destroy();
							}
						}	
					}
				}
			}
		}
	}
	foreach allactors( class'ThingFactory', Factory, MatchTag )
	{
		Factory.Destroy();				
	}
}

defaultproperties
{
}
