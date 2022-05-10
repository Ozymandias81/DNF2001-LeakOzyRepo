//=============================================================================
// dnHTorpedo2.
//=============================================================================
class dnHTorpedo2 expands dnHomingRocket;

var () class<SoftParticleSystem> SplashEffect;

function PostBeginPlay()
{
	super.PostBeginPlay();
}

function Timer(optional int TimerNum)
{

	// If I'm in a water zone, I've got full control:
	if(Region.Zone.bWaterZone)
	{
		super.Timer();
	} else
	{
		// Otherwise, just let normal physics take over
		if(ApplyGravity)
		{
			Acceleration=Region.Zone.ZoneGravity;
		}
	}
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	// Am I entereing or leaving water?
	if(Region.Zone.bWaterZone!=NewZone.bWaterZone)
		if(SplashEffect!=none)
			Spawn(SplashEffect,,,,rot(0,0,0));
}

defaultproperties
{
     TurnScaler=3.000000
     TrailClass=Class'dnParticles.dnHTorpedo1trail'
     ApplyGravity=True
     LodMode=LOD_StopMinimum
     LifeSpan=30.000000
     Texture=None
     Mesh=DukeMesh'c_dnWeapon.missle_jetski'
     bUnlit=False
     DrawScale=1.500000
}
