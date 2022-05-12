//=============================================================================
// TranslocDest.
//=============================================================================
class TranslocDest extends LiftCenter;

function PostBeginPlay()
{
	local Actor Start, End;
	local NavigationPoint N;
	local int distance, reachFlags, i, j;
	local bool bFound;

	Super.PostBeginPlay();

	if ( Level.Game.IsA('DeathMatchPlus') && DeathMatchPlus(Level.Game).bUseTranslocator && (Region.Zone.ZoneGravity.Z < 0.9 * Region.Zone.Default.ZoneGravity.Z) )
		return;

	// if this game type doesn't include translocator, then get rid of paths through this node
	bSpecialCost = false;
	for ( i=0; i<16; i++ )
	{
		Paths[i] = -1;
		if ( UpstreamPaths[i] != -1 )
		{
			DescribeSpec(UpstreamPaths[i], Start, End, reachFlags, distance);
			bFound = false;
			N = NavigationPoint(Start);
			if ( N != None )
			{
				for ( j=0; j<15; j++ )
				{
					if ( !bFound )
					{
						DescribeSpec(N.Paths[j], Start, End, reachFlags, distance);
						bFound = ( End == self );
					}
					if ( bFound )
						N.Paths[j] = N.Paths[j+1];
				}
				N.Paths[15] = -1;
			}
			UpstreamPaths[i] = -1;
		}
	}
}

event int SpecialCost(Pawn Seeker)
{
	if ( !Seeker.IsA('Bot') || !Bot(Seeker).bCanTranslocate )
		return 10000000;
	return 300;
}

/* SpecialHandling is called by the navigation code when the next path has been found.  
It gives that path an opportunity to modify the result based on any special considerations
*/
function Actor SpecialHandling(Pawn Other)
{
	local Bot B;

	if ( !Other.IsA('Bot') )
		return None;

	if ( (VSize(Location - Other.Location) < 200) 
		 && (Abs(Location.Z - Other.Location.Z) < Other.CollisionHeight) )
		return self;
	B = Bot(Other);

	if ( (B.MyTranslocator == None) || (B.MyTranslocator.TTarget != None) )
		return None;

	B.TranslocateToTarget(self);	
	return self;
}

defaultproperties
{
	bStatic=false
	bNoDelete=true
	bSpecialCost=true
}