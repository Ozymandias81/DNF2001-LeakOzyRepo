//=============================================================================
// RandomSpawn.
//=============================================================================
class RandomSpawn expands Triggers;

//#exec Texture Import File=Textures\TriggerSpawn.pcx Name=S_TriggerSpawn Mips=Off Flags=2

var () class<actor> actorType;	// Actor type to spawn

var () bool AssignNewMesh;		// Should I assign new mesh to new actor?.
var () mesh NewMesh[7];			// Assign new mesh to spawned actor.

var () bool    AssignNewSkin;	
var () texture NewSkin[7];			

var () bool    AssignNewSkinIndex;
var () byte    NewSkinIndex[7];

// Sound related parameters:
var () bool AssignNewSoundPitch;	
var () int	NewSoundPitch[7];
var () int	NewSoundRadius;

var () bool   UseVelocity;
var () vector NewVelocity;
var () float  NewSpeed;

var () int LifeSpany;

var () bool  Periodic;				// If the trigger periodically spawns stuff.
var () float SpawnPeriod;			// Rate at which the trigger will attempt to spawn something
var () float SpawnChance;			// Percent chance that the trigger will spawn something.
var () bool  TriggerTogglePeriodic;	// Triggering toggles periodic state.

var () struct EAttachTo
{
	var () class<actor> actorType;
	var () EMountType MountType;
	var () EPhysics DismountPhysics;	// Physics to set when this object detaches.
	var () vector   MountOrigin;		// Origin offset for attachment.
	var () rotator  MountAngles;		// Rotation angles for attachment.
	var () name	    MountMeshItem;      // Parent mesh item name (SurfaceMount or Bone model object) to mount to.
									    // Must be non-None Bone Name for MeshBone mounts, or SurfaceMount name for MeshSurface mounts.
									    // MeshSurface mounts may use a None item, in which case the dynamic surface mount members above are used.

} AttachTo[8];

function PostBeginPlay()
{
	if(Periodic)
	{
		Enable('Timer');
		SetTimer(SpawnPeriod,true);
	}
}

function actor SpawnRandom()
{
	local actor a, b;
	local int i;

	if(bool(actorType))		// If the actor is real..
	{	
		a = Spawn(actorType);
		i = Rand(ArrayCount(NewMesh));
		if(AssignNewMesh) 				a.Mesh=NewMesh[i];
		if(AssignNewSkinIndex)			a.SkinIndex=NewSkinIndex[i];
		if(AssignNewSoundPitch)			a.SoundPitch=NewSoundPitch[i];

		i=Rand(ArrayCount(NewSkin));
		if(AssignNewSkin)				a.Skin=NewSkin[i];
		
		a.SoundRadius=NewSoundRadius;
		if(UseVelocity)
		{
			a.Velocity=NewVelocity;
		} else
		{
			a.Velocity=NewSpeed*Normal(vector(a.Rotation));
		}

		a.LifeSpan=LifeSpany;	
		
		// Attach mounted actors:
		for(i=0;i<ArrayCount(AttachTo);i++)
			if(bool(AttachTo[i].actorType))
			{
				b=Spawn(AttachTo[i].actorType);
				b.MountParent=a;
				b.MountParentTag=a.tag;
				b.MountType=AttachTo[i].MountType;
				b.DismountPhysics=AttachTo[i].DismountPhysics;
				b.MountOrigin=AttachTo[i].MountOrigin;
				b.MountAngles=AttachTo[i].MountAngles;
				b.MountMeshItem=AttachTo[i].MountMeshItem;	
				b.LifeSpan=LifeSpany;				
			}
	}

}

function Timer(optional int TimerNum)
{
	if(frand()<=SpawnChance)
		SpawnRandom();
}

function TogglePeriodic()
{
	if(Periodic)
	{
		SetTimer(0,false);
		Disable('Timer');
		Periodic=false;
	} else
	{
		Enable('Timer');
		SetTimer(SpawnPeriod,true);
		Periodic=true;
	} 

}

function Trigger(actor Other, pawn EventInstigator)
{
	if(TriggerTogglePeriodic) TogglePeriodic();
	else					  Timer(); //SpawnRandom();
}

defaultproperties
{
	UseVelocity=True
	//TriggerPeroid=0.0000000
	//TriggerChance=1.0000000
}
