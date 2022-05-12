//=============================================================================
// JumpSpot.
// specifies positions that can be reached in jumpmatch or with jumpboots or translocator
//=============================================================================
class JumpSpot extends LiftCenter;

var() bool bImpactJump, bAlwaysAccel;
var Bot PendingBot;

event int SpecialCost(Pawn Seeker)
{
	local Bot B;

	B = Bot(Seeker);
	if ( B == None )
		return 100000000;
		
	if ( B.bCanTranslocate || (B.JumpZ > 1.5 * B.Default.JumpZ) 
		|| (B.Region.Zone.ZoneGravity.Z >= 0.8 * B.Region.Zone.Default.ZoneGravity.Z) )
		return 300;

	if ( bImpactJump && B.bHasImpactHammer && (B.Health > 85) && (!B.bNovice || (B.Skill > 2.5)) 
		&& (B.DamageScaling < 1.4) )
		return 1100;

	return 100000000;
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
	if ( (Other.JumpZ <= 1.5 * Other.Default.JumpZ) && (B.Region.Zone.ZoneGravity.Z < 0.8 * B.Region.Zone.Default.ZoneGravity.Z) )
	{
		if ( (B.MyTranslocator == None) || (B.MyTranslocator.TTarget != None) 
			|| (Level.Game.IsA('DeathMatchPlus') && !DeathMatchPlus(Level.Game).CanTranslocate(B)) )
		{
			if ( bImpactJump && B.CanImpactJump() )
			{
				PendingBot = B;
				GotoState('PendingImpact');
				Return self;
			}
			return None;
		}
		B.TranslocateToTarget(self);
		return self;	
	}

	PendingBot = B;
	GotoState('PendingJump');

	return self;
}


// don't do jumps right away because a state change here could be dangerous during navigation
State PendingJump
{
	function Actor SpecialHandling(Pawn Other)
	{
		if ( PendingBot != None )
		{
			PendingBot.BigJump(self);
			PendingBot = None;
		}
		return Super.SpecialHandling(Other);
	}

	function Tick(float DeltaTime)
	{
		if ( PendingBot != None )
		{
			PendingBot.BigJump(self);
			PendingBot = None;
		}
		GotoState('');
	}
}

State PendingImpact
{
	function Actor SpecialHandling(Pawn Other)
	{
		if ( PendingBot != None )
		{
			PendingBot.ImpactJump(self);
			PendingBot = None;
		}
		return Super.SpecialHandling(Other);
	}

	function Tick(float DeltaTime)
	{
		if ( PendingBot != None )
		{
			PendingBot.ImpactJump(self);
			PendingBot = None;
		}
		GotoState('');
	}
}

defaultproperties
{
	bNoDelete=true
	bStatic=false
	bSpecialCost=true
}