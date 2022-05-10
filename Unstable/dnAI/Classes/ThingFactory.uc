/*=============================================================================
	ThingFactory
	Author: Jess Crable/Steven Polge

	Use these to spawn things.
=============================================================================*/
class ThingFactory extends Keypoint;

var() class<actor> prototype	?("The template class that you will be spawning."); 	// the template class
var() int	maxitems			?("Maximum number of items fromthis factory at any time.");	// max number of items from this factory at any time
var() int	capacity			?("Maximum number of items ever buildable (-1 = no limit).");		// max number of items ever buildable (-1 = no limit)
var() float interval			?("Average time interval between spawnings.");	// average time interval between spawnings
var() name	itemtag				?("Tag given to items produced at this factory.");	// tag given to items produced at this factory
var() bool	bFalling			?("Non-Pawn items spawned should be set to falling.");	// non-pawn items spawned should be set to falling
var() bool	bOnlyPlayerTouched	?("If this flag is true only the player can trigger this factory."); //only player can trigger it
var() bool	bCovert				?("Factory will only spawn from places that the player cannot see.");		//only do hidden spawns
var() bool	bStoppable			?("Factory will stop producing when it is untouched.");	//stops producing when untouched

var	  int	numitems;	// current number of items from this factory
var	  int	numspots;	// number of spawnspots

var() enum EDistribution
{
	DIST_Constant,
	DIST_Uniform,
	DIST_Gaussian
}
timeDistribution;

var Spawnpoint spawnspot[16]; //possible start locations

function PostBeginPlay()
{
	local Spawnpoint newspot;
	
	Super.PostBeginPlay();
	numspots = 0;
	numitems = 0;
	foreach AllActors( class 'Spawnpoint', newspot, tag )
	{
		if (numspots < 16)
		{
			spawnspot[numspots] = newspot;
			newspot.factory = self;
			numspots += 1;
		}
	}
	if (itemtag == '')
		itemtag = 'MadeInUSA';
}	


function StartBuilding()
{
}

auto State Waiting
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local Actor A;

		if ( Event != '' )
			ForEach AllActors( class 'Actor', A, Event)
			if( A != Self )
				A.Trigger(self, EventInstigator);
		GotoState('Spawning');
	}
		
	function Touch(Actor Other)
	{
		local pawn otherpawn;
	
		otherpawn = Pawn(Other);
		if ( (otherpawn != None) && (!bOnlyPlayerTouched || ( otherpawn.bIsPlayer && !otherPawn.IsA( 'HumanNPC' ) ) ) )
			Trigger(other, otherPawn);
	}
}

State Spawning
{
	function UnTouch(Actor Other)
	{
		//local int i;
		local Pawn P;

		if (bStoppable)
		{
//			//check if some other pawn still touching
//			for (i=0;i<4;i++)
//				if ( (pawn(Touching[i]) != None) && (!bOnlyPlayerTouched || ( pawn(Touching[i]).bIsPlayer) && !pawn( Touching[ i ] ).IsA( 'HumanNPC' ) ) )
//					return;
			foreach TouchingActors( class'Pawn', P )
			{
				if( !bOnlyPlayerTouched || P.bIsPlayer && !P.IsA( 'HumanNPC' ) )
					return;
			}
			GotoState('Waiting');
		}
	}

	function Trigger(actor Other, pawn EventInstigator)
	{
		//only if Other is from this factory
		if ( Other.class != prototype )
			return;
			
		numitems--;
		if (numitems < maxitems)
			StartBuilding();
	}

	function bool trySpawn(int start, int end)
	{
		local int i;
		local bool done;

		done = false;
		i = start;
		while (i < end)
		{
			if (spawnspot[i].Create())
			{
				done = true;
				i = end;
				capacity--;
				numitems++;
				if (capacity == 0)
					GotoState('Finished');
			}
			i++;
		}
		
		return done;
	}
		
	function Timer( optional int TimerNum )
	{
		local int start;
		
		if (numitems < maxitems)
		{
			//pick a spawn point
			start = Rand(numspots);
			if ( !trySpawn(start, numspots) )
				trySpawn(0, start);
		}
			
		if (numitems < maxitems)
			StartBuilding();
	}

	Function StartBuilding()
	{
		local float nextTime;
		if (timeDistribution == DIST_Constant)
			nextTime = interval;
		else if (timeDistribution == DIST_Uniform)
			nextTime = 2 * FRand() * interval;
		else //timeDistribution is gaussian
			nextTime = 0.5 * (FRand() + FRand() + FRand() + FRand()) * interval;
			
		if (capacity > 0)
			SetTimer(nextTime, false);
	}

	function BeginState()
	{
		if ( !bStoppable )
			Disable('UnTouch');
	}

Begin:
	Timer();
}

state Finished
{
}	

defaultproperties
{
      maxitems=1
      capacity=1000000
      interval=+00001.000000
	  bFalling=true
      bStatic=False
      bCollideActors=True
}
