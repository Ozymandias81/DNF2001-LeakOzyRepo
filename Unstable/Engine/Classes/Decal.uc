class Decal expands RenderActor
	native;

// properties
var () int MultiDecalLevel;
var float LastRenderedTime		?("Last time this decal was rendered.");

// native stuff.
var const array<int> SurfList;

var () float BehaviorArgument	?("Argument for behavior mode.");
var () enum EBehavior
{
	DB_Normal,								// Punt to default UT (inefficient) decal code.
	DB_Permanant,							// Decal Never goes away.
	DB_DestroyAfterArgumentSeconds,			
	DB_DestroyNotVisibleForArgumentSeconds,
} Behavior						?("How the decals behave.");

var() bool  FlipX				?("Flip this decal across it's X Axis.");
var() bool  FlipY				?("Flip this decal across it's Y Axis.");
var() bool  RandomRotation		?("Randomly rotate this decal on placement.");
var() rotator DecalRotation		?("Decal rotation if not random.");
var() float MinSpawnDistance	?("Closest that another decal can be to this one (0=ignore)");

var() float UScale				?("Independent scaling along the U direction.");
var() float VScale				?("Independent scaling along the V direction.");

var transient bool bInitialized;

simulated native final function bool AttachDecal( float TraceDistance, optional vector DecalDir, optional float ScaleX, optional float ScaleY ); // trace forward and attach this decal to surfaces.
simulated native final function DetachDecal(); // detach this decal from all surfaces.

simulated event PostBeginPlay()
{
	bInitialized = false;
	if ( Role == ROLE_Authority )
		Initialize();
}

simulated event PostNetInitial()
{
	bInitialized = false;
	if ( Role < ROLE_Authority )
		Initialize();
}

simulated event Initialize()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;
	if (bInitialized)
		return;
	bInitialized = true;

	if ( RandomRotation )
	{
		if(!AttachDecal(100))		// trace 100 units ahead in direction of current rotation
			Destroy();
	} else {
		if(!AttachDecal(100, vector(DecalRotation)))		// trace 100 units ahead in direction of current rotation
			Destroy();
	}

	if(Behavior!=DB_Normal) Destroy();	// Let the internal code take care of it.
}

simulated event Destroyed()
{
	if(Behavior==DB_Normal)	DetachDecal();
	Super.Destroyed();
}

event Update(Actor L);

defaultproperties
{
	DrawScale=1
	DrawType=DT_None
	MultiDecalLevel=4
	RemoteRole=ROLE_None
	bUnlit=true
    Physics=PHYS_None
	bNetTemporary=true
	bNetOptional=true
	bGameRelevant=true
	CollisionRadius=+0.00000
	CollisionHeight=+0.00000
	bStatic=false
	bStasis=false
	bHighDetail=true
	Style=STY_Modulated
	MinSpawnDistance=0.0000
	Behavior=DB_Normal
	BehaviorArgument=0.25
	RandomRotation=True
}