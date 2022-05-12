//=============================================================================
// BioGlob
//=============================================================================
class BioGlob extends UT_BioGel;

var int NumSplash;
var vector SpawnPoint;

auto state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation) 
	{ 
		if ( Other.IsA('BioSplash') )
			return;
		if ( Pawn(Other)!=Instigator || bOnGround) 
			Global.Timer(); 
	}
	simulated function HitWall( vector HitNormal, actor Wall )
	{

		SetPhysics(PHYS_None);		
		MakeNoise(1);	
		bOnGround = True;
		PlaySound(ImpactSound);	
		SetWall(HitNormal, Wall);
		if ( DrawScale > 1 )
			NumSplash = int(2 * DrawScale) - 1;
		SpawnPoint = Location + 5 * HitNormal;
		DrawScale= FMin(DrawScale, 3.0);
		if ( NumSplash > 0 )
		{
			SpawnSplash();
			if ( NumSplash > 0 )
				SpawnSplash();
		}
		GoToState('OnSurface');
	}
}

function SpawnSplash()
{
	local vector Start;

	NumSplash--;
	Start = SpawnPoint + 4 * VRand(); 
	Spawn(class'BioSplash',,,Start,Rotator(Start - Location));
}

state OnSurface
{
	function Tick(float DeltaTime)
	{
		if ( NumSplash > 0 )
		{
			SpawnSplash();
			if ( NumSplash > 0 )
				SpawnSplash();
			else
				Disable('Tick');
		}
		else
			Disable('Tick');
	}

	function ProcessTouch (Actor Other, vector HitLocation)
	{
		if ( Other.IsA('BioSplash') )
			return;
		GotoState('Exploding');
	}
}

defaultproperties
{
     speed=+00700.000000
     Damage=+00075.000000
     MomentumTransfer=30000
}
