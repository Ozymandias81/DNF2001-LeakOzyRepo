/*-----------------------------------------------------------------------------
	Carcass

	"Their carcasses covered the valleys and the tops of the mountains. 
	 I cut off their heads. The battlements of their cities I made heaps of,
	 like mounds of earth, their movables, their wealth, and their valuables 
	 I plundered to a countless amount."
	   - excerpt, Inscription of Tiglath Pileser I of Assyria
-----------------------------------------------------------------------------*/
class Carcass extends Decoration
	native
	nativereplication;

#exec Texture Import File=Textures\Corpse.pcx Name=S_Corpse Mips=Off Flags=2

// General carcass stuff.
var   bool							bDecorative;
var   bool							bSlidingCarcass;
var() bool							bNoTakeOwnerProperties;
var   int							CumulativeDamage;
var   ZoneInfo						DeathZone;

// Bone manipulation variables.
var	transient int					TrashedBones[6];			// These are really pointers.  Do not save.
var    bool							bLeftFootTrashed, bRightFootTrashed;
var    bool							bLeftHandTrashed, bRightHandTrashed;
var    bool							bHeadBlownOff, bArmless, bSuffering, bStopSuffering;
var	   bool							bEyesShut, bNoPupils, bLostHead, bLyingStill, bBlastedToHell;
var    name							DamageBone;
var    bool							bDamageBoneShakeInit;
var    float						DamageBoneShakeFactor;
var    rotator						DamageBoneShakeBaseRotate, DamageBoneShakeAdjustRotate;

// Chunk switches.
var	   bool							bDamageProtect;
enum ChunkState
{
    CHS_Normal,						// Carcass is normal
    CHS_ChunkPartial,				// Carcass has been hit once by an explosive
    CHS_ChunkComplete,				// Carcass has been completely chunked up
};

// Client will detect a state change and blow up
var ChunkState     					ChunkCarcassState;     // This variable is incremented each time a carcass should be chunked
var ChunkState                   	OldChunkCarcassState;  // This keeps track of the last state of the carcass on the server
var	class<DamageType>				ChunkDamageType;
var bool			    		    bChunkUpFromBlast;
var vector		    				ChunkUpBlastLoc;

// Blood pool.
var   float							BloodPoolTime;
var unbound string					BloodHitDecalName;
var unbound class<Actor>			BloodHitDecal;
var unbound string					BloodPuffName;
var unbound class<Actor>			BloodPuff;
var unbound string					BloodPoolName;
var unbound class<Decal>			BloodPoolClass;
var unbound Decal					BloodPool;
var unbound bool					bBloodPool;

// Searchability :P
var()  bool							bCanHaveCash;
var    bool							bSearchable;
var    bool							bJustSearched;
var    int							AmmoClassAmount;
var    int							NPCAmmoMode;
var	   class<Ammo>					AmmoClass;

// Mounted decorations copied from a pawn.
var unbound Decoration				MountedDecorations[6];

// Gibby meat sounds to play when shot.
var unbound sound					GibbySound[3];

// Unused?
var unbound vector					BlastVelocity;

// Shrink counter.
var float							ShrinkCounter;

// Expand effect.
var name							ExpandedBones[6];
var float							ExpandedScales[6];
var bool							bExpandedCollision, bExpanding;
var float							ExpandTimeRemaining, ExpandTimeEnd;

replication
{
	// Things the server should send to the client.
	reliable if( Role==ROLE_Authority )
		ChunkDamageType, ChunkUpBlastLoc, bStopSuffering, DamageBone, 
		bSearchable, AmmoClass;
}

function ChunkCarcass( optional ChunkState forcestate );

/*-----------------------------------------------------------------------------
	Initialization & Object Methods
-----------------------------------------------------------------------------*/

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Only initialize for the owner if we have one.
	// This is so that unowned decorative corpses aren't initialized.
	if ( RenderActor( Owner ) != None )
		InitFor( RenderActor( Owner ) );	
}


function Destroyed()
{
	local int i;

	// Clear the mounted decorations out.
	for (i=0; i<6; i++)
	{
		if (MountedDecorations[i] != none)
			MountedDecorations[i].Destroy();
	}

	bHidden = true;
				
	Super.Destroyed();
}

simulated function PostNetInitial()
{
	local MeshDecal Decal;

	if ( Owner != None )
	{
		MeshDecalLink		= Owner.MeshDecalLink;
		Owner.MeshDecalLink = None;

		for ( Decal = MeshDecalLink; Decal != None; Decal = Decal.MeshDecalLink )
		{
			Decal.Actor = self;
		}

	}
}

function InitFor( RenderActor Other )
{
	local int i;

    local int bone;
	local vector newloc, v;
	local MeshInstance minst;
	local float OldCollisionHeight;	
	local MeshDecal Decal;

	// Initialize critical details based on the owner actor.
	SetLocation( Other.Location );
	SetCollisionSize( Other.CollisionRadius*2, Other.CollisionHeight );
	if( !bNoTakeOwnerProperties )
	{
		Mesh					= Other.Mesh;
		Skin					= Other.Skin;
		Texture					= Other.Texture;
		Fatness					= Other.Fatness;
		ScaleGlow				= Other.ScaleGlow;
		DrawScale				= Other.DrawScale;
	}
	DesiredRotation			= Other.Rotation;
	DesiredRotation.Roll	= 0;
	DesiredRotation.Pitch	= 0;
	AnimSequence			= Other.AnimSequence;
	AnimFrame				= Other.AnimFrame;
	AnimRate				= Other.AnimRate;
	TweenRate				= Other.TweenRate;
	AnimMinRate				= Other.AnimMinRate;
	AnimLast				= Other.AnimLast;
	AnimBlend               = Other.AnimBlend;
	bAnimLoop				= Other.bAnimLoop;
	SimAnim.X				= 10000 * AnimFrame;
	SimAnim.Y				= 5000  * AnimRate;
	SimAnim.Z				= 1000  * TweenRate;
	SimAnim.W				= 10000 * AnimLast;
	bAnimFinished			= Other.bAnimFinished;	

	// Pawn specific
	if ( Other.bIsPawn )
	{
		BlastVelocity		= Other.Velocity;
	}

	Mass					= Other.Mass;
	bMeshLowerByCollision	= Other.bMeshLowerByCollision;
	if ( Buoyancy < 0.8 * Mass )
		Buoyancy			= 0.9 * Mass;
	for ( i=0; i<4; i++ )
		Multiskins[i]		= Pawn(Other).MultiSkins[i];

	// Copy mounted decorations.
	if ( Other.bIsPawn )
	{
		for ( i=0; i<6; i++ )
		{
			if ( Pawn(Other).MountedDecorations[i] != None )
			{
				MountedDecorations[i] = Pawn(Other).MountedDecorations[i];
				Pawn(Other).MountedDecorations[i] = None;
				MountedDecorations[i].AttachActorToParent( self, true, true );
			}
			ExpandedBones[i] = Pawn(Other).ExpandedBones[i];
			ExpandedScales[i] = Pawn(Other).ExpandedScales[i];
		}
		bExpandedCollision = Pawn(Other).bExpandedCollision;
		bExpanding = Pawn(Other).bExpanding;
		ExpandTimeRemaining = Pawn(Other).ExpandTimeRemaining;
		ExpandTimeEnd = Pawn(Other).ExpandTimeEnd;
		ShrinkCounter = Pawn(Other).ShrinkCounter;
	}

	// Copy heat vision settings.
	if ( Other.bHeated )
	{
		bHeated				= true;
		HeatIntensity		= Other.HeatIntensity;
		HeatRadius			= Other.HeatRadius;
		HeatFalloff			= Other.HeatFalloff;
	}

	// Move effects.
	if ( Other.bIsPawn )
	{
		ImmolationClass = Pawn(Other).ImmolationClass;
		if ( (Pawn(Other).ImmolationActor != None) && !Pawn(Other).ImmolationActor.bDeleteMe )
		{
			ImmolationActor = spawn( class<ActorDamageEffect>(DynamicLoadObject( ImmolationClass, class'Class' )), Self );
			ImmolationActor.Initialize();
		}

		ShrinkClass = Pawn(Other).ShrinkClass;
		if ( (Pawn(Other).ShrinkActor != None) && !Pawn(Other).ShrinkActor.bDeleteMe )
		{
			ShrinkActor = spawn( class<ActorDamageEffect>(DynamicLoadObject( ShrinkClass, class'Class' )), Self );
			ShrinkActor.Initialize();
		}	

		self.MeshDecalLink  = Other.MeshDecalLink;
		Other.MeshDecalLink = None;		
		for ( Decal = MeshDecalLink; Decal != None; Decal = Decal.MeshDecalLink )
		{
			Decal.Actor = self;
		}
	}

	FixCollisionRadius();

	// Check to see if the damage type should do a blood pool.
	if ( ChunkDamageType != None && bBloodPool)
		bBloodPool = ChunkDamageType.default.bBloodPool;
}

function FixCollisionRadius()
{
	local Actor HitActor;
	local Vector HitNormal, HitLocation;
	local Vector StartTrace, EndTrace, X,Y,Z;
	local Rotator Rot;
	local float Rad, NewRadius;
	local int i;

	// Search around the carcass to try and not get the carcass stuck in the wall.
	StartTrace = Location;
	NewRadius  = CollisionRadius;

	for ( i=0; i<16; i++ )
	{
		GetAxes( Rot, X, Y, Z );

		EndTrace  = StartTrace + ( CollisionRadius * X );
		HitActor  = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );
				
		if ( HitActor == Level )
		{
			Rad = VSize(HitLocation - StartTrace);
			if ( Rad < NewRadius )
			{
				NewRadius = Rad;
			}
		}		
		Rot.Yaw += 65535/16;
	}

	if ( NewRadius < CollisionRadius )
	{		
		SetCollisionSize( NewRadius*0.9, CollisionHeight );
	}
}

simulated function Carcass GetChunk()
{
	return none;
}

simulated function bool IsChunk()
{
	return false;
}

/*-----------------------------------------------------------------------------
	Timing
-----------------------------------------------------------------------------*/

simulated function Tick(float DeltaTime)
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, TraceLocation;
	local MeshInstance minst;
	local int ChestBone;

	// Perform heat falloff.
	if (HeatRadius > 0.0)
		HeatRadius -= DeltaTime;
	else
		HeatRadius = 0;

	// Create a blood pool at the given time.
	if ((BloodPoolTime > 0.0) && bBloodPool)
	{
		BloodPoolTime -= DeltaTime;
		if (BloodPoolTime < 0.0)
		{
			if ( BloodPoolClass == None )
				BloodPoolClass = class<Decal>( DynamicLoadObject(BloodPoolName, class'Class') );

			minst = GetMeshInstance();
			if (minst == None)
				return;
			ChestBone = minst.BoneFindNamed('Chest');
			if (ChestBone == 0)
				TraceLocation = Location;
			else {
				TraceLocation = minst.BoneGetTranslate( ChestBone, true, false );
				TraceLocation = minst.MeshToWorldLocation( TraceLocation );
			}
			if (!Region.Zone.bWaterZone)
			{
				HitActor = Trace( HitLocation, HitNormal, TraceLocation - 100 * vect(0,0,1), TraceLocation, false );
				if (HitActor == Level)
					BloodPool = Spawn( BloodPoolClass,,, HitLocation, rotator(HitNormal) );
			}
		}
	}

	if ( ExpandTimeRemaining > 0.f )
	{
		ExpandTimeRemaining -= DeltaTime;
		if ( ExpandTimeRemaining < 0.f )
		{
			ExpandTimeRemaining = 0.f;
			ExpandTimeEnd = Level.TimeSeconds;
		}
	}
}



/*-----------------------------------------------------------------------------
	Damage Stubs
-----------------------------------------------------------------------------*/
function FlyCarcass() {}

simulated function ChunkUpComplete( optional vector BlastLocation, optional bool bFlyCarcass );
			
simulated function ChunkUp( int Damage )
{
	Destroy();
}
	
static simulated function bool AllowChunk(int N, name A)
{
	return true;
}

simulated function FakeDamage( int Damage, name BoneName, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, bool bNoCreationSounds );

simulated function HitEffect( vector HitLocation, class<DamageType> DamageType, vector Momentum, float DecoHealth, float HitDamage, bool bNoCreationSounds )
{
	local vector BloodOffset, Mo;
	local sound GibSound;

	if ( DamageType.default.bBloodEffect )
	{
		// Blood wall decal.
		BloodOffset   = 0.2 * CollisionRadius * Normal(HitLocation - Location);
		BloodOffset.Z = BloodOffset.Z * 0.5;		
		Mo = Momentum;
		if ( Mo.Z > 0 )
			Mo.Z *= 0.5;
		if ( BloodHitDecal == None )
			BloodHitDecal = class<Actor>( DynamicLoadObject(BloodHitDecalName, class'Class') );
		Spawn( BloodHitDecal, Self,, HitLocation + BloodOffset, rotator(Mo) );

		// Blood puff.
		if ( BloodPuff == None )
			BloodPuff = class<Actor>( DynamicLoadObject(BloodPuffName, class'Class') );
		Spawn( BloodPuff,,, HitLocation, rotator(Mo) );

		// Play a gibby sound.
		GibSound = GibbySound[Rand(3)];
		if ( !bNoCreationSounds && (GibSound != None) )
			PlaySound( GibSound, SLOT_Interact, 1.0, false, 800, 0.9+FRand()*0.2 );
	}
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bStatic=false
	DrawType=DT_Mesh
	Texture=S_Corpse
	bMeshCurvy=false
	bStasis=false
	CollisionRadius=+18.0
	CollisionHeight=+4.0
	bCollideActors=true
	bCollideWorld=true
	bProjTarget=true
	Physics=PHYS_Falling
	Mass=+180.0
	Buoyancy=+105.0
	LifeSpan=+180.0
	AnimSequence=Dead
	AnimFrame=+0.9
	BloodHitDecalName="dnGame.dnBloodHit"
	BloodPuffName="dnParticles.dnBloodFX"
	BloodPoolName="dnGame.dnBloodPool"
	BloodPoolTime=2.0
	bBloodPool=true
	bCollisionForRenderBox=true
	SpriteProjForward=0.0
	bUseViewportForZ=true
	bIgnoreBList=true
	bFlammable=true
}
