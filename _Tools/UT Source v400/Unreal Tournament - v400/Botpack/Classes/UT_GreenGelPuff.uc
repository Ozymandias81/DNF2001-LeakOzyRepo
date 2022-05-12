//=============================================================================
// ut_GreenGelPuff.
//=============================================================================
class UT_GreenGelPuff expands UT_SpriteSmokePuff;

#exec OBJ LOAD FILE=textures\Goopex.utx PACKAGE=Botpack.GoopEx

var int numBlobs;
var vector SurfaceNormal;

replication
{
	unreliable if( Role==ROLE_Authority )
		numBlobs, SurfaceNormal;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.01, false);
}

simulated function Timer()
{
	Local GreenBlob GB;
	local int j;

	if ( (Level.NetMode != NM_DedicatedServer) && (numBlobs > 0) && Level.bHighDetailMode && !Level.bDropDetail )
	{
		numBlobs = FMin(numBlobs, 5);
		for (j=0; j<numBlobs; j++) 
		{
			GB = Spawn(class'GreenBlob',,,Location+SurfaceNormal*(FRand()*8-4));
			if (GB != None)
			{
				GB.SetUp(SurfaceNormal);
				GB.RemoteRole = ROLE_None;
			}
		}
	}
}

defaultproperties
{
	 NumSets=3
     numBlobs=3
     SSprites(0)=Texture'Botpack.GoopEx.g1r_a00'
     SSprites(1)=Texture'Botpack.GoopEx.g2r_a00'
     SSprites(2)=Texture'Botpack.GoopEx.g3r_a00'
     SSprites(3)=None
     RisingRate=20.000000
     Texture=Texture'Botpack.GoopEx.g1r_a00'
     DrawScale=1.400000
	 LifeSpan=1.000
	 bHighDetail=false
     Pause=0.070000
}

