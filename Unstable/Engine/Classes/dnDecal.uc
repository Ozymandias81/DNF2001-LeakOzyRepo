//=============================================================================
// dnDecal
//=============================================================================
class dnDecal expands Decal;

var bool bAttached, bStartedLife, bImportant;
var () texture Decals[16];
var int DecalCount;

simulated event Initialize()
{
	if (bInitialized)
		return;

	// Ignore superclass beginplay.
	for(DecalCount=0;DecalCount<ArrayCount(Decals);DecalCount++)
		if(Decals[DecalCount]==none) 
			break;

	if(DecalCount==0) 
	{
		Destroy();
		return;
	}

	Texture=Decals[Rand(DecalCount)];

	SetTimer(1.0, false);	// Set destruction timer.
	Super.Initialize();
}

simulated function Timer(optional int TimerNum)
{
	// Check for nearby players, if none then destroy self

	if ( !bAttached )
	{
		Destroy();
		return;
	}

	if ( !bStartedLife )
	{
		RemoteRole = ROLE_None;
		bStartedLife = true;
		if ( Level.bDropDetail )
			SetTimer(5.0 + 2 * FRand(), false);
		else
			SetTimer(18.0 + 5 * FRand(), false);
		return;
	}
	if ( Level.bDropDetail && (MultiDecalLevel < 6) )
	{
		if ( (Level.TimeSeconds - LastRenderedTime > 0.35)
			|| (!bImportant && (FRand() < 0.2)) )
			Destroy();
		else
		{
			SetTimer(1.0, true);
			return;
		}
	}
	else if ( Level.TimeSeconds - LastRenderedTime < 1 )
	{
		SetTimer(5.0, true);
		return;
	}
	Destroy();
}

defaultproperties
{
	 MultiDecalLevel=1
     bStatic=False
     bStasis=False
	 bAttached=True
	 bImportant=False
	 DrawScale=+0.35
	 RemoteRole=ROLE_None
}
