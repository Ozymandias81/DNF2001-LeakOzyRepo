//=============================================================================
// SoftParticleSystem. (NJS)
//=============================================================================
class SoftParticleSystem expands ParticleSystem
	native;

var SoftParticleSystem NextSystem;
var SoftParticleSystem PreviousSystem;

var vector PreviousLocation					?("Previous Position of the particle system.");
var () bool Enabled 						?("Whether particle spawning is enabled.");
var    bool LastEnabled;                    // If the particle system was enabled in the previous frame
var () bool UpdateEnabled 					?("Whether or not to enable updating.");
var () bool BillboardHorizontal;
var () bool BillboardVertical;

var () bool  DestroyWhenEmpty 				?("Self destruct when no particles remain.");
var () bool  DestroyWhenEmptyAfterSpawn		?("Destroys the particle system when empty IF at least one particle has been spawned since it's creation.");
var () float DieOutsideRadius				?("Particles die when they leave this radius (when nonzero).");
var () int   GroupID  						?("ID of the group this particle system belongs to.");
var () int   CurrentSpawnNumber 			?("ID of next particle to be spawned.");

var () bool	 SaveParticles					?("Whether or not to save the particles in this system during a save game.");

// Particle friend info:
var (ParticleFriend) name SpawnFriendOnDeath		?("If I should spawn a corresponding friend particle on death (This is the friend system to spawn the particle in).");
var (ParticleFriend) name SpawnFriendOnBounce		?("If I should spawn a corresponding friend particle on bounce (This is the friend system to spawn the particle in).");
var SoftParticleSystem    SpawnFriendOnDeathActor	?("Actual friend actor.");
var SoftParticleSystem    SpawnFriendOnBounceActor	?("Actual bounce friend actor.");

// OBSOLETE: Would LIKE to get rid of, but can't:
var transient class<actor> AdditionalSpawns[8] 		?("OBSOLETE: Additional Classes to spawn.");

// Additional actors to spawn when particle system spawns:
var () struct native AdditionalSpawnStruct
{
	var () class<actor> SpawnClass		?("Class to spawn.");
	var () bool			TakeParentTag	?("Spawned actor will take the tagname of it's parent.");
	var () bool			Mount 			?("Mount actor to myself.");	
	var () vector       MountOrigin 	?("Origin if not on top of.");
	var () rotator		MountAngles		?("Angles if not on top of.");
	var    Actor		SpawnActor		?("Actual actor that was spawned.");
	var () name			AppendToTag		?("Append to the tag, dammit!");
	var () rotator		SpawnRotation	?("Range of rotation to give to this actor.");
	var () rotator		SpawnRotationVariance	?("The spawn rotation will vary by this amount.");
	var () bool			SpawnRotationNotRelative ?("The spawn rotation is not relative to this actor.");
	var () float		SpawnSpeed		?("Gives the spawned actor a velocity of this magnitude in the direction of it's rotation.");
	var () float		SpawnSpeedVariance ?("This amount times a random number from -1 to 1 will be added to the speed.");
} AdditionalSpawn[8];

var () unbound bool AdditionalSpawnTakesOwner	?("Spawned actors take my owner and owner related visibility.");

var () struct native SSpawnOnDestruction
{
	var () class<actor> SpawnClass;
	var () bool bTakeParentMountInfo;
} SpawnOnDestruction[8];

// Particle sound information:
var (ParticleSounds) sound CreationSound		 ?("Plays this sound when this particle system is created.");
var (ParticleSounds) sound CreationSounds[4]	 ?("Plays this sound when this particle system is created.");
var (ParticleSounds) float CreationSoundRadius;
var (ParticleSounds) float CreationSoundBasePitch;
var (ParticleSounds) float CreationSoundRandFactor;
var (ParticleSounds) bool  bDontAutoPlayCreationSounds;

var (ParticleSounds) sound DestructionSound		 ?("Plays this sound when this particle system is destroyed.");
var (ParticleSounds) float DestructionSoundRadius;
var (ParticleSounds) sound BounceSound 			 ?("Plays this sound when a particle bounces.");
var (ParticleSounds) float BounceSoundRadius;	 
var (ParticleSounds) sound DieSound				 ?("Plays this sound when a particle dies.");
var (ParticleSounds) float DieSoundRadius;
var (ParticleSounds) sound TurnedOffSound          ?("Play this sound when particle system turns off");
var (ParticleSounds) float TurnedOffSoundRadius;
var (ParticleSounds) float TurnedOffPitchVariance  ?("Maximum pitch variance for this sound (+ this amount)");
var (ParticleSounds) sound TurnedOnSound           ?("Play this sound when particle system turns on");
var (ParticleSounds) float TurnedOnSoundRadius;    
var (ParticleSounds) float TurnedOnPitchVariance   ?("Maximum pitch variance for this sound (+ this amount)");
var (ParticleSounds) sound TriggeredSound;
var (ParticleSounds) float TriggeredSoundRadius;
var (ParticleSounds) bool  bStopSoundsOnDestroy;
 

// Particle Spawn Count Information:
var (ParticleSpawn) int    SpawnNumber				?("Number of particles to spawn.");
var (ParticleSpawn) float  SpawnPeriod 				?("Period at which to spawn them.");
var					float  AbsoluteSpawnPeriod 		?("The absolute spawn period for individual particles.");
var (ParticleSpawn) int    PrimeCount 				?("Number of particles spawn immedietely when the particle system is created.");
var (ParticleSpawn) float  PrimeTime 				?("Amount of time to 'Prime' the texture with - note that priming works even when UpdateEnabled is false.");
var (ParticleSpawn) float  PrimeTimeIncrement 		?("Time increment for above  - note that priming works even when UpdateEnabled is false.");
var (ParticleSpawn) int    MaximumParticles 		?("Maximum particles that this system will allocate.");
var (ParticleSpawn) float  Lifetime 				?("Time to live in seconds, 0 if forever.");
var (ParticleSpawn) float  LifetimeVariance 		?("Lifetime varies by +/- this many.");
var (ParticleSpawn) bool   SpawnAtApex 				?("Particles will spawn at the apex.");
var (ParticleSpawn) bool   SpawnCanDestroyOldest	?("When a particle needs to be spawned, if there are no more particle slots left (ie. MaxParticles is set and there is no more room left),\n then the oldest particle will be destroyed, and it's slot used to spawn this particle.");
var (ParticleSpawn) bool   RelativeSpawn 			?("Particles all spawn relative to their parent's rotation, but behave independantly afterwards.");
var (ParticleSpawn) bool   SpawnAtRadius 			?("Particles will be spawned at the maximum radial extent (ie on the radius circle).");
var (ParticleSpawn) bool   SpawnAtHeight 			?("Particles will be spawned at the maximum height extent (ie on the box).");
var (ParticleSpawn) bool   SpawnAtExistingParticle	?("Randomly pick an existing particle and spawn on top of it.");
var (ParticleSpawn) bool   SmoothSpawn				?("Smoothly spawn particles across the time interval defined by the framerate");
var (ParticleSpawn) vector SpawnOffset 				?("Amount to offset all spawning physics from actor center.");
var (ParticleSpawn) bool   SpawnInALine				?("If true, particles will spawn in a line along the actor's direction.");
var (ParticleSpawn) float  SpawnInALineLength		?("Half the length of the line to spawn along.");

// Spawn Position/Velocity/Acceleration:
var (ParticlePhysics) bool	 RelativeLocation 			?("Particles all move relative to the parent ParticleSystemActor.");
var (ParticlePhysics) bool   RelativeRotation 			?("Particles all rotate relative to the parent ParticleSystemActor.");

var (ParticlePhysics) vector InitialVelocity 				?("Base initial velocity");
var (ParticlePhysics) vector InitialAcceleration 			?("Base initial acceleration.");
var (ParticlePhysics) vector MaxVelocityVariance 			?("Maximum initial Velocity variance (+/- this amount)");
var (ParticlePhysics) vector MaxAccelerationVariance 		?("Maximum acceleration variance (+/-) this amount.");
var (ParticlePhysics) vector RealtimeVelocityVariance 		?("Maximum velocity variance (+/-) this amount per second in realtime.");
var (ParticlePhysics) vector RealtimeAccelerationVariance 	?("Maximum acceleration variance (+/-) this amount per second in realtime.");

// Effect point information:
var (ParticlePhysics) vector Apex 					?("Apex. Relative offset from particle system location. Bounce uses relative Z of this."); 
var (ParticlePhysics) float  ApexInitialVelocity	?("When not 0, this is the initial velocity added towards the apex.");
var (ParticlePhysics) name   ApexActorTag			?("When not none, the apex will take it's position from this actor.");
var				      actor	 ApexActor;

// Inherit velocity.
var Actor					 InheritVelocityActor;		// hacked for the flamethower, bleh
		
// Particle Misc Physics:
var (ParticlePhysics) float  LocalFriction 				?("My own local friction, zero by default.");
var (ParticlePhysics) float  BounceElasticity 			?("How much energy is retained after each bounce.");
var (ParticlePhysics) vector BounceVelocityVariance		?("Amount by which bounce may randomly alter the velocity of bouncing things.");
var (ParticlePhysics) bool   Bounce 					?("If the particle should bounce at the control's Z-Height.");
var (ParticlePhysics) bool   DieOnBounce 				?("Destroys the particle when it hits the bounce plane.");
var (ParticlePhysics) bool   ParticlesCollideWithWorld 	?("If the particles actually collide with the world.");
var (ParticlePhysics) bool   ParticlesCollideWithActors ?("If the particles actually collide with actors.");

// Info to take from zone:
var (ParticleZoneInfo) bool  UseZoneGravity 		 ?("Whether to use the zone gravity in acceleration computations.");
var (ParticleZoneInfo) bool  UseZoneVelocity 		 ?("Whether to use zone velocity in acceleration computations.");
var (ParticleZoneInfo) bool  UseZoneGroundFriction 	 ?("Use Zone ground friction.");
var (ParticleZoneInfo) bool  UseZoneFluidFriction 	 ?("Use Zone fluid friction.");
var (ParticleZoneInfo) bool  UseZoneTerminalVelocity ?("Use Zone terminal velocity.");

// Flocking behavior:
var (ParticleFlocking) bool  FlockMountToCenter 		?("Mount particle system actor to the center of the flock.");
var (ParticleFlocking) bool  FlockMountToDirection 		?("Face particle system actor in the same direction as the flock.");
var (ParticleFlocking) float FlockToCenterVelocity 		?("Velocity with which particles will move towards center.");
var (ParticleFlocking) float FlockToCenterAcceleration 	?("Acceleration with which particles will move towards center.");
var (ParticleFlocking) float FlockToDirectionScale 		?("Scale towards average direction.");
var (ParticleFlocking) float FlockCenterWeight 			?("How many particles the particle system itself counts towards the center.");
var (ParticleFlocking) float FlockDirectionWeight 		?("How many particles the particle system itself counts towards the direction.");

// Particle Sine Wave:
var (ParticleSineWave) float  SineWaveFrequency			?("Sine wave motion frequency - 0 disables");
var (ParticleSineWave) vector VelocityAmplitude			?("Amount of sine wave to apply to each velocity component.");
var (ParticleSineWave) vector AccelerationAmplitude		?("Amount of sine wave to apply to each acceleration component.");

// Line Info:
var (ParticleLines) bool  UseLines 			?("True if use lines instead of textures/meshes.");
var (ParticleLines) bool  Connected 		?("True if lines are connected.");
var (ParticleLines) bool  ConstantLength	?("True if lines length is completely based off draw scale.  Doesn't work when connected is set.");
var (ParticleLines) color LineStartColor 	?("Color at the line's start.");
var (ParticleLines) color LineEndColor 		?("Color at the line's end.");
var (ParticleLines) float LineStartWidth 	?("Starting line width.");
var (ParticleLines) float LineEndWidth 		?("Ending line width.");

// Texture Info:
var (ParticleTextureInfo) texture Textures[16];					// Random textures to choose from.
var int TextureCount 											?("Computed in PostBeginPlay.");
var (ParticleTextureInfo) float TextureScaleX 					?("Additional amount to scale all particles in this system along the x texture axis.");
var (ParticleTextureInfo) float TextureScaleY					?("Additional amount to scale all particles in this system along the y texture axis.");
var (ParticleTextureInfo) bool  DieOnLastFrame 					?("If this particle dies on the last frame of the texture.");
var (ParticleTextureInfo) float DrawScaleVariance 				?("+/- this amount.");
var (ParticleTextureInfo) float StartDrawScale 					?("Initial Draw Scale.");
var (ParticleTextureInfo) float EndDrawScale 					?("Ending Draw Scale.");

// Toast when possible:
var (ParticleTextureInfo) float RotationInitial 				?("OBSOLETE: Base initial particle rotation.");
var (ParticleTextureInfo) float RotationVariance 				?("OBSOLETE: Base rotation variance.");
var (ParticleTextureInfo) float RotationVelocity  				?("OBSOLETE: Rotation velocity.");
var (ParticleTextureInfo) float RotationVelocityMaxVariance 	?("OBSOLETE: Rotation velocity variance.");
var (ParticleTextureInfo) float RotationAcceleration 			?("OBSOLETE: Rate of rotation acceleration.");
var (ParticleTextureInfo) float RotationAccelerationMaxVariance	?("OBSOLETE: Maximum rotation acceleration variance.");

// 3d Rotation:
var (ParticleTextureInfo) rotator RotationInitial3d 				?("Base initial particle rotation.");
var (ParticleTextureInfo) rotator RotationVariance3d 				?("Base rotation variance.");
var (ParticleTextureInfo) rotator RotationVelocity3d  				?("Rotation velocity.");
var (ParticleTextureInfo) rotator RotationVelocityMaxVariance3d 	?("Rotation velocity variance.");
var (ParticleTextureInfo) rotator RotationAcceleration3d 			?("Rate of rotation acceleration.");
var (ParticleTextureInfo) rotator RotationAccelerationMaxVariance3d	?("Maximum rotation acceleration variance.");
var (ParticleTextureInfo) rotator RotationVarianceOnBounce3d		?("Amount to vary rotation on bounce.");

// Spawn Info:
var (ParticleActorSpawn) float        SpawnOnBounceChance	?("Percentage chance to spawn the below class on bounce.");
var (ParticleActorSpawn) class<actor> SpawnOnBounce 		?("Spawn this class on bounce.");
var (ParticleActorSpawn) float		  SpawnOnDeathChance 	?("Percentage chance to spawn below actor on death.");
var (ParticleActorSpawn) class<actor> SpawnOnDeath 			?("Spawn this actor when the particle dies.");

// LOD:
var (ParticleLOD) bool  UpdateWhenNotVisible	?("Whether to draw particles even when the particle system actor is not visible.");
var (ParticleLOD) bool  DrawWhenNotVisible		?("Whether to update particles even when the particle system actor is not visible.");
var (ParticleLOD) float ParticleSpawnCutoff		?("Beyond this distance particles will not be drawn.");
var (ParticleLOD) float ParticleUpdateCutoff	?("Beyond this distance particles will not be updated.");
var (ParticleLOD) float ParticleDrawCutoff	    ?("Beyond this distance particles will not be drawn.");
var (ParticleLOD) float ParticleDrawLOD			?("Dynamically adjusts the draw rate based on player distance.  This is basically the distance to which the draw rate is halved");

var (ParticleLOD) enum EParticleDetail
{
	PD_High,						
	PD_Medium,						
	PD_Low							
} ParticleDetail								?("Under which detail levels is this particle system rendered?");


// Trigger Variables:
var (ParticleTrigger) bool  TriggerOnSpawn 		?("Trigger self when spawned.");
var (ParticleTrigger) bool  TriggerOnDismount	?("Trigger self once when I dismount from my parent.");
var (ParticleTrigger) float TriggerAfterSeconds ?("Trigger after this many seconds have elapsed.");

var (ParticleTrigger) enum ESoftParticleSystemTriggerType
{
	SPT_None,						// No trigger type
	SPT_Enable,						// Enable Spawning
	SPT_Disable,					// Disable Spawning
	SPT_Toggle,						// Toggle Spawning
	SPT_Pulse,						// Toggle System State One way for PulseSeconds and then back
	SPT_UpdateEnable,				// Enable particle updating
	SPT_UpdateDisable,				// Disable particle updating
	SPT_UpdateToggle,				// Toggle particle updating
	SPT_UpdatePulse,				// Pulse particle updating
	SPT_Prime,						// Spawns prime count particles instantaneously
	SPT_TimeWarpEnable,				// Sets particle system time warp setting to PulseMagnitude
	SPT_TimeWarpDisable,			// Sets particle system time warp setting to 1.0
	SPT_TimeWarpToggle,				// Toggles between above two states.
	SPT_TimeWarpPulse,				// Smoothly toggles time warp up to pulse magnitude.
	SPT_TimeWarpPulseUp,
} TriggerType;

var (ParticleTrigger) float PulseSeconds 			?("Seconds that the pulse is active for.");
var (ParticleTrigger) float PulseSecondsVariance 	?("Number of seconds to vary the pulse duration by.");
var (ParticleTrigger) float PulseMagnitude			?("Peak magnitude of the pulse.");
var float PulseStartTime,
          PulseEndTime;

var (ParticleTrigger) name BounceEvent				?("Trigger this event when a particle bounces.");
var (ParticleTrigger) name DieEvent					?("Trigger this event when a particle dies.");

// Damage on spawn (Explosion support)
var (ParticleDamage) float DamageAmount		?("Amount of damage to cause on spawn.");
var (ParticleDamage) float DamageRadius		?("Damage radius.");
var (ParticleDamage) class<DamageType> DamageName 	?("Damage category class.");
var (ParticleDamage) float MomentumTransfer	?("Amount of momentum transferred to victims of the blast.");
var (ParticleDamage) float DamagePeriod		?("Rate at which damage is applied. 0=only on startup");
var float DamagePeriodRemaining;

// Particle collision actors.
var (ParticleColActors) bool	UseParticleCollisionActors;
var (ParticleColActors) int		ParticlesPerCollision;
var (ParticleColActors) int		NumCollisionActors;
var (ParticleColActors) class<ParticleCollisionActor> CollisionActorClass;
var						int		ParticlesSinceCollision;
var						int		UsedCollisionActors;
var						array<ParticleCollisionActor> CollisionActors;
var						Pawn	CollisionInstigator;

// Internal structure of a particle:
struct native Particle
{
	var () float ActivationDelay;			// Number of seconds before this particle becomes active.

	// Particle Maintaince information:
	var () int   SpawnNumber;				// This particles spawn number (ie. ID)
	var () float SpawnTime;					// Particle's spawn time.
	var () float Lifetime;					// Total lifetime.
	var () float RemainingLifetime;			// Remaining lifetime.

	// Position Information:
	var () vector Location;					// Particle's location.
	var () vector PreviousLocation;			// Particle's previous location.

	// Transient info:
	var () vector WorldLocation;			// Particle's transformed world location.
	var () vector WorldPreviousLocation;	// Particle's transformed world previous location.

	// Physics Information:
	var () vector Velocity;					// Particle's velocity.
	var () vector Acceleration;				// Particle's Acceleration.

	// Visual Representation:
	var () texture Texture;					// Texture to use on this particle.
	var () float   NextFrameDelay;			// Delay to next texture frame.
	var () float   DrawScale;				// Current Draw Scale.
	var () float   Alpha;					// Current Alpha.

	// Note: Add full rotation - for mesh particle systems:
	var () float Rotation;					// Current Rotation in radians.
	var () float RotationVelocity;			// RotationVelocity in radians per second.
	var () float RotationAcceleration;		// RotationAcceleration in radians per second squared.

	// Full rotation stuff... Get rid of the above when I can.
	var () rotator Rotation3d;
	var () rotator RotationVelocity3d;
	var () rotator RotationAcceleration3d;

	// Collision tag.
	var bool HaveCollisionActor;

	// ZBias
	//var () float ZBias;
};

// Internal variables:
var float ElapsedTime 								?("Elapsed time to next spawn period.");
var transient int			HighestParticleNumber	?("Highest particle position number currently in use.");
var transient int			AllocatedParticles  	?("Total number of particles allocated.");
var transient int			ParticleSystemHandle 	?("Internal Handle to the particle system's allocated memory chunk.");
var transient bool			ParticleRecursing 	    ?("Internal transient indicating that the particle system is recursing.");
var transient vector		BoundingBoxMin			?("Minimum BSP bounding box coordinates.");
var transient vector		BoundingBoxMax			?("Maximum BSP bounding box coordinates.");
var transient bool			bPriming;

var bool bInitialized;

native final simulated function	   ForceTick( float DeltaSeconds );
native final simulated function	   ResetParticles();						// Reset the entire particle system.
native final simulated function  int AllocParticle();							// Simply allocates a single particle.  The allocated particle is only minimally initialized.
native final simulated function	   FreeParticle(int i);						// Free the particle specified by index 'i'.
native final simulated function bool GetParticle(int i, out Particle p);		// Gets a particle. Returns true if a valid particle was returned.
native final simulated function bool SetParticle(int i, out Particle p);		// Sets a particle. Returns true if the particle was able to be set.
native final simulated function  int SpawnParticle(int count);				// Spawns a particle and returns its index, uses all the spawn info.
native final simulated function      AffectParticles(SoftParticleAffector a);	// Affect a particle system.
native final simulated function	   GetParticleStats(out int Systems,out int Particles,out int UpdatedParticles); // Number of particle systems drawn since last call.
native final simulated function	   DrawParticles(Canvas c);
native final simulated function	   DestroyParticleCollisionActors();

// Normal Unreal BeginPlay:
simulated function BeginPlay()
{
	bHidden=false;				// NJS: Hack so mappers don't have to reset all by hand.
}

simulated function PostBeginPlay()
{
	local SoftParticleSystem p;
	Super.PostBeginPlay();

	if ( Role == ROLE_Authority )
		InitializeParticleSystem();

	if ( bBurning )
		SetCollision( true, bBlockActors, bBlockPlayers );

	// Hook myself up to the particle system list:
	PreviousSystem=none;
	NextSystem=Level.ParticleSystems;
	Level.ParticleSystems=self;

	if(SpawnNumber>0)
		AbsoluteSpawnPeriod=SpawnPeriod/SpawnNumber;
	else
		AbsoluteSpawnPeriod=0;
}

simulated function PostNetInitial()
{
	Super.PostNetInitial();

	if ( Role < ROLE_Authority )
		InitializeParticleSystem();
}

simulated function InitializeParticleSystem()
{
	local int i;
	local float t;
	local bool b, PreviousEnabled;
	local actor a,myOwner;
	local sound s;
	local rotator SpawnRotation;

	if (bInitialized)
		return;
	bInitialized = true;

	ResetParticles();			// Reset particle system.
//	Super.InitializeParticleSystem();		// Very nessecary for mounting.	

	// See if I have a friend:
	SpawnFriendOnDeathActor =SoftParticleSystem(FindActorTagged(class'SoftParticleSystem',SpawnFriendOnDeath));
	SpawnFriendOnBounceActor=SoftParticleSystem(FindActorTagged(class'SoftParticleSystem',SpawnFriendOnBounce));

	// See if we inherit a texture from our owner.
	if ((Owner != None) && Owner.IsA('Decoration'))
	{
		if ((DrawType == DT_Mesh) && Decoration(Owner).bSetFragSkin)
		{
			Skin = Decoration(Owner).FragSkin;
			SkinIndex = 0;
		}
		SetOwner(Owner.Owner);
	}

	// Compact textures:
	for(i=1;i<ArrayCount(Textures);i++)
		while((i>0)&&(Textures[i]!=none)&&(Textures[i-1]==none))
		{
			// Move this texture back one:
			Textures[i-1]=Textures[i];
			Textures[i]=none;
			i--;	// See if I need to move it back more.
		}

	// Count valid textures:
	for(TextureCount=0;TextureCount<ArrayCount(Textures);TextureCount++)
		if(Textures[TextureCount]==None)
			break;

	if(TriggerOnSpawn) 
		Trigger(self,none);
	
	if(CreationSound!=none) 
		PlaySound(CreationSound,,,,CreationSoundRadius);

	// CreationSounds[4]
	if ( !bDontAutoPlayCreationSounds )
		PlayCreationSounds();

	// Spawn any additional actors needed:
	for(i=0;i<ArrayCount(AdditionalSpawn);i++)
		if(AdditionalSpawn[i].SpawnClass!=none)
		{
			// Set owner correctly:
			if(AdditionalSpawnTakesOwner) myOwner=Owner;
			else						  myOwner=self;

			if(AdditionalSpawn[i].AppendToTag!='')
				a=Spawn(AdditionalSpawn[i].SpawnClass,myOwner,NameForString(""$Tag$""$AdditionalSpawn[i].AppendToTag));
			else if(AdditionalSpawn[i].TakeParentTag)
				a=Spawn(AdditionalSpawn[i].SpawnClass,myOwner,Tag);
			else
				a=Spawn(AdditionalSpawn[i].SpawnClass,myOwner);

			if ( a == None )
				continue;

			if ( AdditionalSpawn[i].SpawnRotationNotRelative )
				SpawnRotation = rot(0,0,0);
			else
				SpawnRotation = Rotation;

			SpawnRotation.Pitch += AdditionalSpawn[i].SpawnRotation.Pitch - (AdditionalSpawn[i].SpawnRotationVariance.Pitch/2) + AdditionalSpawn[i].SpawnRotationVariance.Pitch*FRand();
			SpawnRotation.Yaw += AdditionalSpawn[i].SpawnRotation.Yaw - (AdditionalSpawn[i].SpawnRotationVariance.Yaw/2) + AdditionalSpawn[i].SpawnRotationVariance.Yaw*FRand();
			SpawnRotation.Roll += AdditionalSpawn[i].SpawnRotation.Roll - (AdditionalSpawn[i].SpawnRotationVariance.Roll/2) + AdditionalSpawn[i].SpawnRotationVariance.Roll*FRand();
			a.SetRotation( SpawnRotation );

			if ( AdditionalSpawn[i].SpawnSpeed > 0 )
				a.Velocity = normal(vector(SpawnRotation))*(AdditionalSpawn[i].SpawnSpeed - (AdditionalSpawn[i].SpawnSpeedVariance/2) + AdditionalSpawn[i].SpawnSpeedVariance*FRand());

			if ( AdditionalSpawnTakesOwner && A.bIsRenderActor )
			{
				RenderActor(a).bOnlyOwnerSee=bOnlyOwnerSee;
				RenderActor(a).bOwnerNoSee=bOwnerNoSee;
			}

			if(AdditionalSpawn[i].Mount)
			{
				a.SetPhysics(PHYS_MovingBrush);
				a.AttachActorToParent(self,true,true);
				a.MountOrigin=AdditionalSpawn[i].MountOrigin;
				a.MountAngles=AdditionalSpawn[i].MountAngles;
			}

			AdditionalSpawn[i].SpawnActor = a;
		}

	// Do some damage:
	if(DamageAmount!=0)
		HurtRadius(DamageAmount,DamageRadius,DamageName,MomentumTransfer,Location,,,,true);
	DamagePeriodRemaining=DamagePeriod;
	
	// Prime the particle pump:
	if(PrimeCount!=0) SpawnParticle(PrimeCount);	// Pre-spawn some particles.

	if(PrimeTime!=0)	
	{
		b=UpdateEnabled;			UpdateEnabled=true;							
		PreviousEnabled=Enabled;	Enabled=true;
		
		bPriming=true;

		for(t=0;t<=PrimeTime;t+=PrimeTimeIncrement)
			ForceTick(PrimeTimeIncrement);
		
		bPriming=false;

		UpdateEnabled=b;
		Enabled=PreviousEnabled;
	}

	if(TriggerAfterSeconds!=0)
	{
		SetTimer(TriggerAfterSeconds,false);
		Disable('Trigger');
	}

	if(ApexActorTag!='')
	{
		ApexActor=FindActorTagged(class'actor',ApexActorTag);
		Apex=ApexActor.Location;
	}
}

simulated function PlayCreationSounds()
{
	local int i;
	local sound s;

	for( i=0; i<ArrayCount(CreationSounds); i++ )
	{
		if ( CreationSounds[i] != none )
		{
			s = none;
			while ( s == none )
				s = CreationSounds[Rand(ArrayCount(CreationSounds))];

			if ( CreationSoundBasePitch != -1.0 )
				PlaySound( s,,,,CreationSoundRadius, CreationSoundBasePitch + FRand() * CreationSoundRandFactor );
			else
				PlaySound( s,,,,CreationSoundRadius );
			break;
		}
	}
}

simulated function Destroyed()
{
	local int i;
	local Actor A;

	// Stop all sounds
	if ( bStopSoundsOnDestroy )
	{
		StopSound( SLOT_None );
		StopSound( SLOT_None );
		StopSound( SLOT_Misc );
		StopSound( SLOT_Pain );
		StopSound( SLOT_Interact );
		StopSound( SLOT_Ambient );
		StopSound( SLOT_Talk );
		StopSound( SLOT_Interface );
	}

	if ( DestructionSound != none )
		PlaySound( DestructionSound,,,, DestructionSoundRadius );
	
	// Spawn any additional actors needed:
	for ( i=0; i<ArrayCount(SpawnOnDestruction); i++ )
		if ( SpawnOnDestruction[i].SpawnClass != none )
		{
			A = Spawn( SpawnOnDestruction[i].SpawnClass );
			if ( SpawnOnDestruction[i].bTakeParentMountInfo )
			{
				A.MountParent			= MountParent;
				A.MountPreviousLocation	= MountPreviousLocation;
				A.MountPreviousRotation	= MountPreviousRotation;
				A.MountMeshSurfaceTri	= MountMeshSurfaceTri;
				A.MountMeshSurfaceBarys	= MountMeshSurfaceBarys;
				A.MountType				= MountType;
				A.MountParentTag		= MountParentTag;
				A.MountOrigin			= MountOrigin;
				A.MountAngles			= MountAngles;
				A.MountMeshItem			= MountMeshItem;
			}
		}

	// Clean up collision actors.
	if ( UseParticleCollisionActors )
		DestroyParticleCollisionActors();
	
	super.Destroyed();

	// Remove myself from the particle system list:
	if(Level.ParticleSystems==self) Level.ParticleSystems=NextSystem;
	if(NextSystem!=none)		{ NextSystem.PreviousSystem=PreviousSystem; }
	if(PreviousSystem!=none)	{ PreviousSystem.NextSystem=NextSystem; }
}


// Visibility controls.
simulated function SetOnlyOwnerSee(bool OnlyOwnerSee)
{
	local int i;

	bOnlyOwnerSee = OnlyOwnerSee;
	for(i=0;i<ArrayCount(AdditionalSpawn);i++)
	{
		if (RenderActor(AdditionalSpawn[i].SpawnActor) != None)
			RenderActor(AdditionalSpawn[i].SpawnActor).bOnlyOwnerSee = OnlyOwnerSee;
	}
}

simulated function SetOwnerSeeSpecial(bool OwnerSeeSpecial)
{
	local int i;

	bOwnerSeeSpecial = OwnerSeeSpecial;
	for(i=0;i<ArrayCount(AdditionalSpawn);i++)
	{
		if (RenderActor(AdditionalSpawn[i].SpawnActor) != None)
			RenderActor(AdditionalSpawn[i].SpawnActor).bOwnerSeeSpecial = OwnerSeeSpecial;
	}
}

simulated function SetOwnerNoSee(bool OwnerNoSee)
{
	local int i;

	bOwnerNoSee = OwnerNoSee;
	for(i=0;i<ArrayCount(AdditionalSpawn);i++)
	{
		if (RenderActor(AdditionalSpawn[i].SpawnActor) != None)
			RenderActor(AdditionalSpawn[i].SpawnActor).bOwnerNoSee = OwnerNoSee;
	}
}

simulated function SetDontReflect(bool DontReflect)
{
	local int i;

	bDontReflect = DontReflect;
	for(i=0;i<ArrayCount(AdditionalSpawn);i++)
	{
		if (AdditionalSpawn[i].SpawnActor != None)
			AdditionalSpawn[i].SpawnActor.bDontReflect = DontReflect;
	}
}

simulated function SetHidden(bool Hidden)
{
	local int i;

	bHidden = Hidden;
	for(i=0;i<ArrayCount(AdditionalSpawn);i++)
	{
		if (AdditionalSpawn[i].SpawnActor != None)
			AdditionalSpawn[i].SpawnActor.bHidden = Hidden;
	}
}

simulated function SetUpdateWhenNotVisible(bool inUpdateWhenNotVisible)
{
	local int i;

	UpdateWhenNotVisible = inUpdateWhenNotVisible;
	for(i=0;i<ArrayCount(AdditionalSpawn);i++)
	{
		if ((AdditionalSpawn[i].SpawnActor != None) && (AdditionalSpawn[i].SpawnActor.IsA('SoftParticleSystem')))
		{
			SoftParticleSystem(AdditionalSpawn[i].SpawnActor).UpdateWhenNotVisible = inUpdateWhenNotVisible;
		}
	}
}

simulated function SetScaleFactor(float Factor)
{
	local int i;

	StartDrawScale *= Factor;
	EndDrawScale *= Factor;
	InitialVelocity *= Factor;
	InitialAcceleration *= Factor;
	for(i=0;i<ArrayCount(AdditionalSpawn);i++)
	{
		if ((AdditionalSpawn[i].SpawnActor != None) && (AdditionalSpawn[i].SpawnActor.IsA('SoftParticleSystem')))
		{
			SoftParticleSystem(AdditionalSpawn[i].SpawnActor).StartDrawScale *= Factor;
			SoftParticleSystem(AdditionalSpawn[i].SpawnActor).EndDrawScale *= Factor;
			SoftParticleSystem(AdditionalSpawn[i].SpawnActor).InitialVelocity *= Factor;
			SoftParticleSystem(AdditionalSpawn[i].SpawnActor).InitialAcceleration *= Factor;
		}
	}
}

simulated function SetAllOwner(Actor NewOwner)
{
	local int i;

	SetOwner(NewOwner);
	for(i=0;i<ArrayCount(AdditionalSpawn);i++)
	{
		if (AdditionalSpawn[i].SpawnActor != None)
			AdditionalSpawn[i].SpawnActor.SetOwner(NewOwner);
	}
}

// Called from C++ to initiate a radius damage effect.
event ParticleHurtRadius()
{
	HurtRadius( DamageAmount, DamageRadius, DamageName, MomentumTransfer, Location,,,,true);
}

// Called from C++ when dismounted.
event ScriptTriggerOnDismount()
{
	Trigger( Self, None );
}

simulated function Timer(optional int TimerNum)
{
	Enable('Trigger');

	if(TriggerAfterSeconds!=0)
	{
		Trigger(self,none);
	} else
	{
		switch(TriggerType)
		{
			case SPT_Pulse:			PulseStartTime=0; PulseEndTime=0; Enabled=!Enabled;				break;
			case SPT_UpdatePulse:	PulseStartTime=0; PulseEndTime=0; UpdateEnabled=!UpdateEnabled;	break;
		}
	}
}

simulated function Trigger( actor Other, Pawn Instigator )
{
	local float f, Pitch;
	local bool InitialEnabled;
	InitialEnabled=Enabled;

	if(TriggeredSound!=none) PlaySound(TriggeredSound,,,,TriggeredSoundRadius);
	switch(TriggerType)
	{
		case SPT_None:          break;
		case SPT_Enable:		Enabled=true;     break;
		case SPT_Disable:		Enabled=false;	  break;
		case SPT_Toggle:		Enabled=!Enabled; break;
		case SPT_Pulse:			Enabled=!Enabled; 
								f=PulseSeconds+(PulseSecondsVariance*frand())-PulseSecondsVariance/2;
								if(f<0) f=0;
								PulseStartTime=Level.TimeSeconds;
								PulseEndTime=PulseStartTime+f;
								SetTimer(f,false); 
								Disable('Trigger'); 
								break;

		case SPT_UpdateEnable:	UpdateEnabled=true;  break;
		case SPT_UpdateDisable: UpdateEnabled=false; break;
		case SPT_UpdateToggle:	UpdateEnabled=!UpdateEnabled; break;

		case SPT_UpdatePulse:	UpdateEnabled=!UpdateEnabled; 
								f=PulseSeconds+(PulseSecondsVariance*frand())-PulseSecondsVariance/2;
								if(f<0) f=0;
								SetTimer(f,false); 
								PulseStartTime=Level.TimeSeconds;
								PulseEndTime=PulseStartTime+f;
								Disable('Trigger'); 
								break;	

		case SPT_Prime:			if(PrimeCount!=0) SpawnParticle(PrimeCount); break;

		case SPT_TimeWarpEnable:  TimeWarp=PulseMagnitude; break;
		case SPT_TimeWarpDisable: TimeWarp=1.0; break;
		case SPT_TimeWarpToggle:  if(TimeWarp==1.0) TimeWarp=PulseMagnitude; else TimeWarp=1.0; break;

		case SPT_TimeWarpPulseUp:
		case SPT_TimeWarpPulse: f=PulseSeconds+(PulseSecondsVariance*frand())-PulseSecondsVariance/2;
								if(f<0) f=0;
								TimeWarp=1.0;
								SetTimer(f,false); 
								PulseStartTime=Level.TimeSeconds;
								PulseEndTime=PulseStartTime+f;
								Disable('Trigger'); 
								break;

	}

	if(Enabled!=InitialEnabled)
	{		
		if(Enabled)
		{
			Pitch = 1.0 + FRand() * TurnedOnPitchVariance;			
			if(TurnedOnSound!=none) 
				PlaySound(TurnedOnSound,,,,TurnedOnSoundRadius,Pitch);
		} 
		else
		{
			Pitch = 1.0 + FRand() * TurnedOffPitchVariance;
			if(TurnedOffSound!=none) 
				PlaySound(TurnedOffSound,,,,TurnedOffSoundRadius,Pitch);
		}
	}
}

simulated function bool CanBurn( class<DamageType> DamageType )
{
	if ( !Enabled )
		return false;

	return Super.CanBurn( DamageType );
}

simulated event EnabledStateChange()
{
	local float Pitch;

	if ( Enabled == true )
	{
		Pitch = Frand() * TurnedOnPitchVariance;

		if ( TurnedOnSound != None )
			PlaySound( TurnedOnSound, SLOT_Misc,,,TurnedOnSoundRadius,Pitch );
		if ( TurnedOffSound != None )
			StopSound( Slot_Misc );
	}
	else
	{
		Pitch = Frand() * TurnedOffPitchVariance;
		if ( TurnedOffSound != None )
			PlaySound( TurnedOffSound, SLOT_Misc,,,TurnedOffSoundRadius,Pitch );
		if ( TurnedOnSound != None )
			StopSound( Slot_Misc );
	}
}

defaultproperties
{
	 PrimeTimeIncrement=0.05
     Enabled=True
	 UpdateEnabled=True
     SpawnNumber=1
     SpawnPeriod=0.100000
     Lifetime=1.100000
     InitialVelocity=(Z=475.000000)
     MaxVelocityVariance=(X=180.000000,Y=180.000000)
     UseZoneGravity=True
     UseZoneVelocity=True
     BounceElasticity=1.000000
     LineStartWidth=1.000000
     LineEndWidth=1.000000
     StartDrawScale=1.000000
     EndDrawScale=1.000000
     TriggerType=SPT_Toggle
     PulseSeconds=1.000000
	 FlockToCenterVelocity=0.0			
	 FlockToCenterAcceleration=0.0
	 FlockToDirectionScale=0.0
	 SpawnOnBounceChance=1.0
	 SpawnOnDeathChance=1.0
	 DamageRadius=200.0
	 DamageName=Detonated
	 MomentumTransfer=100000.000
	 CurrentSpawnNumber=0
	 DrawWhenNotVisible=true
	 SineWaveFrequency=0.0
	 AdditionalSpawnTakesOwner=True
	 UpdateWhenNotVisible=False
	 MaxDesiredActorLights=1
	 CurrentDesiredActorLights=1
	 RemoteRole=ROLE_None
	 SpriteProjForward=0.0
	 BillboardHorizontal=true
	 BillboardVertical=true
	 CreationSoundBasePitch=-1.0
	 CreationSoundRandFactor=0.2
	 TextureScaleX=1.0
	 TextureScaleY=1.0
	 DamageName=class'CrushingDamage'
	 ParticleDetail=PD_Low
	 SaveParticles=false
	 bStopSoundsOnDestroy=false
	 TurnedOnPitchVariance=0
	 TurnedOffPitchVariance=0
}

