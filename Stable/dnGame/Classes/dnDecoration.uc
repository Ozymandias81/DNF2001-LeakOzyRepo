/*-----------------------------------------------------------------------------
	dnDecoration
	Author: Nick Shaffner and Brandon Reinhart and Charlie Weiderhold and Charlie's Mom
-----------------------------------------------------------------------------*/

class dnDecoration expands Decoration;

#exec OBJ LOAD FILE=..\Textures\m_generic.dtx
#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx

#exec OBJ LOAD FILE=..\Textures\m_zone1_vegas.dtx
#exec OBJ LOAD FILE=..\Meshes\c_zone1_vegas.dmx

#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

// Spawn related information:
var () struct SMountOnSpawn
{
	var() class<actor>	ActorClass;				// Class of the actor to mount, or none.
	var actor			ActorReference;			// Internal reference to mounted actor 
	var() bool			SetMountOrigin;			// If the mount origin should be set for this actor.
	var() vector		MountOrigin;			// Mount origin offset from center of actor
	var() bool			SetMountAngles;			// If the mount angles should be set for this actor.
	var() rotator		MountAngles;			// Mount angles offset from parent.
	var() bool			SurviveDismount;		// If actors can live through a dismount.
	var() EMountType	MountType;
	var() name			MountMeshItem;
	var() name			AppendToTag;			// If non none, additional name to append to objects current tag.
	var() bool			TakeParentTag;
	var() bool			TakeEvents;
	var() name			SuccessEvent;			// Event to be passed to a special spawn.
	var() name			FailEvent;				// Event to be passed to a special spawn.
} MountOnSpawn[12];

// Health and damage related:
var () bool			   DontDie 					?("Object takes damage, but can't drop below 1 health.");
var () int 			   DamageThreshold 			?("Minimum amount of damage to recognize.  If below, then the damage is ignored.");
var () float		   DamageFromImpactScaler 	?("Scales amount of damage object takes from an impact.");
var () float		   DamageToImpactScaler 	?("Scales amount of damage object give on an impact.");
var	   float           BounceElasticity;

struct HealthMarker								// Events that occur whenever health drops below a certain threshold.
{
	var () int     		Threshold;				// When my health crosses this threashold.
	var () name    		PlaySequence;			// Play this anim sequence.
	var () bool			LoopSequence;			// Whether or not to loop the above sequence instead of just playing it once.
	var () bool			PrefixTagToEvent;		// Will prefix the tag name of this actor to the event it calls in TriggerEvent.
	var () name    		TriggerEvent;			// Trigger this event.
	var () sound   		StartSound;				// Start this sound.
	var () mesh    		ChangeMesh;				// Change the mesh to this.
	var () texture 		ChangeSkin;				// Change the skin to this.
	var () class<actor> SpawnActor;				// Spawn this actor.
};

var (HealthMarkers) HealthMarker HealthMarkers[4];		// Differing levels of health.
var (HealthMarkers) sound HealthMarkerAmbientSound[4];	// Ambient sound to start at this health marker
var (HealthMarkers) int HealthMarkerSpawnFrags[4];		// Number of frags to spawn at each damage level
var (HealthMarkers) bool bUseLastMarkerAnim				?("Uses the last Health marker animation for when the object is shot from then on");

var () bool	 FallingPhysicsOnDamage 				?("Whether I should fall when damaged.");
var () float DelayedDamageTime 						?("Time till delayed damage acts.");
var () int   DelayedDamageAmount 					?("Amount of delayed damage.");

// Fragging related:
var () class<SoftParticleSystem> FragType[8]		?("The type of object to create when the object frags. If none, the object simply disappears when destroyed.");

var () texture		   FragSkin 			 	?("Skin to use on the frag. (If none, then uses object's default skin)");
var () int 			   NumberFragPieces 	 	?("Number of pieces to spawn.");
var () float		   FragBaseScale 		 	?("(Defaults to 1.0)");
var () bool 		   AlertAIOnDestruction  	?("Alert's the AI when the player destroys this object.");

// Idle animation information:
var () name 				IdleAnimations[8];	// Animations to play randomly while idle.

// Use Creation Information:
var () float 		        TriggerRadius 				?("Radius of use.");
var () float		   		TriggerHeight 				?("Height of use.");
var () Trigger.ETriggerType	TriggerType 				?("Type of trigger to create.");
var () float  				TriggerRetriggerDelay 		?("Same as trigger.");
var () bool					TriggerMountToDecoration  	?("Whether to mount to this decoration or not.");
var float				    LastTriggerTime;

// Health based on events:
var () int		HealOnTrigger;			// Heal the player this amount
var () bool		bDrinkSoundOnHeal;
var () sound	DrinkSound;

// Damage based on events: (Damage that the item takes)
var () int		DamageOnTouch;			// Amount of damage caused by collision with other objects.
var () int		DamageOnPlayerTouch;	// Amount of damage caused by collision with player.
var () int		DamageOnTrigger;		// Damage is incurred when I'm triggered.  0 means none.
var () int		DamageOnUntrigger;		// Damage is incurred when I'm untriggered. 0 means none.
var () int      DamageOnHitWall;		// Whether the object is damaged when it hits a wall.
var () int		DamageOnHitWater;		// Amount of damage to apply when object hits water zone.
var () int      DamageOnEMP;            // Amount of damage to give self when hit by EMP blast.

// Damage to other: 
var () int      DamageOtherOnTouch;			// Damage other by this much when it touches me.	
var () int      DamageOtherOnPlayerTouch;	// Damage players by this much when it touches me
var () int		DamageOtherOnHitWall;		// Damage other on wall hit

// Assorted event excitement:
var () name		DamageEvent;			// Triggered whenever the object is damaged.
var () name  	DestroyedEvent;			// Triggered whenever the object is destroyed.
var () name		TouchedEvent;			// Event to be triggered when the object is touched by anything
var () name		TouchedByPlayerEvent;	// Event to fire when touched by player
var () name		BumpedEvent;			// Event to be triggered when the object is touched by anything
var () name		BumpedByPlayerEvent;	// Event to fire when touched by player
var () name     UntouchedEvent;			// Event to be triggered when the object is untouched.
var () name		UntouchedByPlayerEvent; // Event to fire when untouched by player.
var () name 	TriggerEvent;			// Event to fire when triggered.
var () name		UntriggerEvent;			// Event to fire when untriggered.
var () name		HitWallEvent;			// Event that occurs when the decoration hits a wall.
var () name		EMPEvent;	    		// Event to fire when EMP blasted.
var () name     EMPunEvent;             // Event to fire when after EMP expires
var () class<Actor>	SpawnOnHit;			// Actor to spawn when I get hit.
var () class<Actor> SpawnOnEMP;         // Actor to spawn when I get EMP blasted

// Sequences based on events:
var () name		DamageSequence;				// Played whenever the object is damaged and bSequenceToggle is ON.
var () name		DamageSequenceOff;			// Played whenever the object is damaged and bSequenceToggle is OFF.
var () name     TouchedSequence;			// Played whenever the object is touched.
var () name		TouchedByPlayerSequence;	// Played whenever the object is touched by the player.
var () name     UntouchedSequence;			// Played whenever the object is untouched.
var () name     UntouchedByPlayerSequence;	// Played whenever the object is untouched by the player.
var () name		TriggeredSequence;			// Played whenever the object is triggered.
var () name		UntriggeredSequence;		// Played whenever the object is untriggered
var () name 	HitWallSequence;		    // Played whenever the object hits a wall.
var () name     BumpedSequence;				// Played whenever the object is touched.
var () name		BumpedByPlayerSequence;		// Played whenever the object is touched by the player.

// Spawns
var () struct STriggeredSpawn
{
	var() class<actor>	ActorClass;
	var() name			MountMeshItem;
	var() bool			SpawnOnce;
	var() bool			TriggerWhenTriggered;
	var	  Actor			SpawnActor;
} TriggeredSpawn[4];

// Sound excitement:
var () sound 	DamageSound;			// Played whenever the object is damaged.
var () sound	DestroyedSound;			// Played whenever the object is destroyed.
var () sound	TouchedSound;			// Played whenever the object is touched.
var () sound	TouchedByPlayerSound;	// Played whenever the object is touched by a player.
var () sound	BumpedSound;			// Played whenever the object is touched.
var () sound	BumpedByPlayerSound;	// Played whenever the object is touched by a player.
var () sound	UntouchedSound;			// Played whenever the object is untouched.
var () sound	UntouchedByPlayerSound;	// Played whenever the object is untouched by a player.
var () sound	TriggeredSound;			// Sound to play when triggered.
var () sound	UntriggeredSound;		// Sound to play when untriggered
var () sound	HitWallSound;			// Sound when hits a wall.

// Bump event time.
var () float	BumpAgainTime;
var	   float	LastBumpTime;

// Ambient sound parameters:
var () sound    DamageAmbientSound;				// Ambient to switchto when damaged
var () sound    TouchAmbientSound;				// Ambient to switch to when touched
var () sound	TouchedByPlayerAmbientSound;	// Ambient to switch to when touched by player.
var () sound 	TriggeredAmbientSound;			// Ambient sound when object is triggered
var () sound	UntriggeredAmbientSound;		// Sound to play when untriggered
var () sound	UntouchedAmbientSound;			// Ambient sound when player is untouched
var () sound	HitWallAmbientSound;			// Ambient sound when a wall is hit.

// Spawning:
var () struct SSpawnOnDestroyed
{
	var () class<actor> SpawnClass;				// Class to spawn
	var () mesh		    ChangeMesh;				// Mesh to change to
	var () bool			NoCollision;			// If spawned actor has no collision
	var () rotator		RotationVariance;		// Amount of rotation variance.
	var () vector			VelocityVariance;		// Amount to vary velocity.
	var () bool			bTossDecoration;
	var () bool			bUseAlternateMotion;
	var () struct SAlternateMotion
	{
		var () rotator		SpawnRotation	?("Range of rotation to give to this actor.");
		var () rotator		SpawnRotationVariance	?("The spawn rotation will vary by this amount.");
		var () bool			SpawnRotationNotRelative ?("The spawn rotation is not relative to this actor.");
		var () float			SpawnSpeed		?("Gives the spawned actor a velocity of this magnitude in the direction of it's rotation.");
		var () float			SpawnSpeedVariance ?("This amount times a random number from -1 to 1 will be added to the speed.");
	} AlternateMotion;
} SpawnOnDestroyed[8];

// Management of pending sequences:
struct PendingSequence
{
	var () name	PlaySequence;	// A pending sequence to be played once the current sequence completes.
	var () bool Loop;			// Whether to loop the pending sequence until further notice
	var () name Event;			// Event that's triggered when the pending sequence is triggered
	var () sound Noise;			// Sound to play when this pending sequence is triggered.
	var () bool NoiseIsAmbient; // Whether or not to play the noise as an ambient sound.
	var () float Radius;		// Radius of the sound to play.
};

var (PendingSequences) travel PendingSequence   PendingSequences[8];		// The sequence stack.
var (PendingSequences) travel int			    CurrentPendingSequence;	// Number of sequences on the stack
var travel bool									LoopingSequence;

// Sequence Toggle
var (SequenceToggle) bool						bSequenceToggle;
var (SequenceToggle) PendingSequence			ToggleOnSequences[8];
var (SequenceToggle) PendingSequence			ToggleOffSequences[8];
var					 travel bool				bSequenceToggleOn;

var () bool bTumble;
var () enum EMassPrefab
{
	MASS_Ultralight,
	MASS_Light,
	MASS_Medium,
	MASS_Heavy,
	MASS_Rubber,
} MassPrefab;
var () enum EHealthPrefab
{
	HEALTH_NeverBreak,
	HEALTH_Easy,
	HEALTH_Medium,
	HEALTH_SortaHard,
	HEALTH_Hard,
	HEALTH_UseHealthVar,
} HealthPrefab;

// Tumble Settings
var () bool bLandForward;
var () bool bLandBackwards;
var () bool bLandLeft;
var () bool bLandRight;
var () bool bLandUpright;
var () bool bLandUpsideDown;
var enum ELandDirection
{
	LAND_Forward,
    LAND_Backwards,
	LAND_Upright,
    LAND_UpsideDown,
    LAND_Left,
    LAND_Right,
} LandDirection;

var float LandUpCollisionRadius;
var float LandUpCollisionHeight;
var () float LandFrontCollisionRadius;
var () float LandFrontCollisionHeight;
var () float LandSideCollisionRadius;
var () float LandSideCollisionHeight;

var travel bool bDoneTumbling;
var travel bool bCanTumble;
var travel bool bWaterLogged;
var travel bool bDamageFromToss;

var trigger TriggerActor;
var travel float BaseTumbleRate;
var () bool bNotPushableAfterTumble;

var travel bool bDropped;

var () bool bNoDamage;

// AI Related
var () bool bTelekineticable;	// Flag that determines if this can be moved by an Octabrain.
var	 bool	bTakeImpactDamage;	// Flag temporarily set by Octabrain

// Used by puzzles.
var() name SuccessEvent;
var() name FailEvent;

// JEP...
var BreakableGlass			LastGlass;
// ...JEP

event FellOutOfWorld()
{
	// The decoration fell out of the world.
	if (CarriedBy != None)
		return;
	else
		Super.FellOutOfWorld();
}	

function ClearPendingSequences()
{
	CurrentPendingSequence=-1;
}

function DiscardSequence()
{
	local int i;

	for (i=0; i<7; i++)
	{
		PendingSequences[i].PlaySequence	= PendingSequences[i+1].PlaySequence;
		PendingSequences[i].Loop			= PendingSequences[i+1].Loop;
		PendingSequences[i].Event			= PendingSequences[i+1].Event;
		PendingSequences[i].Noise			= PendingSequences[i+1].Noise;
		PendingSequences[i].NoiseIsAmbient	= PendingSequences[i+1].NoiseIsAmbient;
		PendingSequences[i].Radius			= PendingSequences[i+1].Radius;
	}
}

function PushPendingSequenceByComponent(name inPlaySequence, bool inLoop, name inEvent, sound inNoise, bool inNoiseIsAmbient, float inRadius, bool SnapFromCurrentSequence)
{
	local PendingSequence ps;

	ps.PlaySequence = inPlaySequence;
	ps.Loop = inLoop;
	ps.Event = inEvent;
	ps.Noise = inNoise;
	ps.NoiseIsAmbient = inNoiseIsAmbient;
	ps.Radius = inRadius;

	if(CurrentPendingSequence>=ArrayCount(PendingSequences))
		return;

	CurrentPendingSequence++;
	PendingSequences[CurrentPendingSequence]=ps;

	if(IsAnimating())
	{
		if(SnapFromCurrentSequence)
			AnimEnd();
	} else
		AnimEnd();
}

function PushPendingSequence(PendingSequence ps, bool SnapFromCurrentSequence)
{
	if(CurrentPendingSequence>=ArrayCount(PendingSequences))
		return;

	CurrentPendingSequence++;
	PendingSequences[CurrentPendingSequence]=ps;

	if(IsAnimating())
	{
		if(SnapFromCurrentSequence)
			AnimEnd();
	} else
		AnimEnd();
}

function ResetMassProperties()
{
	switch (MassPrefab)
	{
	case MASS_Ultralight:
		Mass = 5;
		BounceElasticity = 0.7;
		Buoyancy = Mass * 2;
		break;
	case MASS_Light:
		Mass = 100;
		BounceElasticity = 0.55;
		Buoyancy = Mass * 2;
		break;
	case MASS_Medium:
		Mass = 300;
		BounceElasticity = 0.5;
		Buoyancy = 7*(Mass / 8);
		break;
	case MASS_Heavy:
		Mass = 700;
		BounceElasticity = 0.4;
		Buoyancy = 7*(Mass / 8);
		break;
	case MASS_Rubber:
		Mass = 5;
		BounceElasticity = 0.75;
		Buoyancy = Mass * 2;
		break;
	}
}

function PostBeginPlay()
{
	local Trigger t;
	local int i;
	local actor a;
	
	super.postBeginPlay();						// Harass my super class.
	
	ResetMassProperties();
	switch (HealthPrefab)
	{
	case HEALTH_NeverBreak:
		Health = 0;
		break;
	case HEALTH_Easy:
		Health = 1;
		break;
	case HEALTH_Medium:
		Health = 12;
		break;
	case HEALTH_SortaHard:
		Health = 45;
		break;
	case HEALTH_Hard:
		Health = 100;
		break;
	}

	// Set Landing Upward Collision Radius/Height
	LandUpCollisionRadius = CollisionRadius;
	LandUpCollisionHeight = CollisionHeight;
	
	if (!((TriggerRadius==0)&&(TriggerHeight==0)))	// Am I to use the use trigger?
	{	
		t=Spawn(class'Engine.Trigger');				// Create the use trigger
		if(t==none) 								// Verify it.
		{
			log("Failed to spawn trigger!");		// Couldn't create it!
			return;
		}
		TriggerActor=t;

		t.event=tag; t.LookUseTags[0]=tag; t.LookUseEvents[0]=tag; 	// Set it to point to me.
		t.SetCollisionSize(TriggerRadius,TriggerHeight);			// Set collision info.
		t.TriggerType=TriggerType;									// Set the triggers type
		t.ReTriggerDelay=TriggerReTriggerDelay;

		if(TriggerMountToDecoration)	// Should I mount this trigger to myself?
		{
			// Mount the trigger to the object:
			t.MountParentTag=tag;
			t.AttachToParent(tag);
			t.SetPhysics(PHYS_MovingBrush);
		}
	}

	// Spawn any attached items:
	for(i=0;i<ArrayCount(MountOnSpawn);i++)
	{
		if(MountOnSpawn[i].ActorClass==none) continue;
		
		if(MountOnSpawn[i].AppendToTag!='')
			MountOnSpawn[i].ActorReference=Spawn(MountOnSpawn[i].ActorClass,Owner,NameForString(""$Tag$""$MountOnSpawn[i].AppendToTag));
		else if (MountOnSpawn[i].TakeParentTag)
			MountOnSpawn[i].ActorReference=Spawn(MountOnSpawn[i].ActorClass,Owner,Tag);
		else
			MountOnSpawn[i].ActorReference=Spawn(MountOnSpawn[i].ActorClass,Owner);
	
		MountOnSpawn[i].ActorReference.SetPhysics(PHYS_MovingBrush);
		MountOnSpawn[i].ActorReference.AttachActorToParent(self,true,true);
		MountOnSpawn[i].ActorReference.MountType=MountOnSpawn[i].MountType;
		MountOnSpawn[i].ActorReference.MountMeshItem=MountOnSpawn[i].MountMeshItem;
		if(MountOnSpawn[i].SetMountOrigin) MountOnSpawn[i].ActorReference.MountOrigin=MountOnSpawn[i].MountOrigin;
		if(MountOnSpawn[i].SetMountAngles) MountOnSpawn[i].ActorReference.MountAngles=MountOnSpawn[i].MountAngles;

		if( MountOnSpawn[i].TakeEvents )
		{
			dnDecoration(MountOnSpawn[i].ActorReference).SuccessEvent = MountOnSpawn[i].SuccessEvent;
			dnDecoration(MountOnSpawn[i].ActorReference).FailEvent = MountOnSpawn[i].FailEvent;
		}
	}

	// Start idle anims if I have any:

	// Look for idle animations - if I have at least one, than choose a random idle anim:
	AnimEnd();

	bCanTumble = false;
}

function Tossed(optional bool Dropped)
{
	local int UpsideDirection, RandDir;
	local bool FoundDir;

	if (LastGlass != None)		// JEP
		ResetLastGlass();

	CarriedBy = None;
	bDropped = Dropped;
	bWaterLogged = false;
	bBobbing = false;
	bDoneTumbling = false;
	if (Dropped)
	{
		bRotateByQuat = false;
		bRotateToDesired = false;
		bFixedRotationDir = false;
		bCanTumble = false;
		bDamageFromToss = false;
		SetRotation(rot(0,Rotation.Yaw,Rotation.Roll));
		OrigCollisionRadius = LandUpCollisionRadius;
		OrigCollisionHeight = LandUpCollisionHeight;
		Super.Tossed(Dropped);
		return;
	}

	// Pick a random side to land on.
	while(!FoundDir)
	{
		RandDir = Rand(6);

		if ((RandDir == 0) && (bLandForward))
		{
			FoundDir = true;
			LandDirection = LAND_Forward;
			OrigCollisionRadius = LandFrontCollisionRadius;
			OrigCollisionHeight = LandFrontCollisionHeight;
		} 
		else if ((RandDir == 1) && (bLandBackwards))
		{
			FoundDir = true;
			LandDirection = LAND_Backwards;
			OrigCollisionRadius = LandFrontCollisionRadius;
			OrigCollisionHeight = LandFrontCollisionHeight;
		}
		else if ((RandDir == 2) && (bLandLeft))
		{
			FoundDir = true;
			LandDirection = LAND_Left;
			OrigCollisionRadius = LandSideCollisionRadius;
			OrigCollisionHeight = LandSideCollisionHeight;
		}
		else if ((RandDir == 3) && (bLandRight))
		{
			FoundDir = true;
			LandDirection = LAND_Right;
			OrigCollisionRadius = LandSideCollisionRadius;
			OrigCollisionHeight = LandSideCollisionHeight;
		}
		else if ((RandDir == 4) && (bLandUpright))
		{
			FoundDir = true;
			LandDirection = LAND_Upright;
			OrigCollisionRadius = LandUpCollisionRadius;
			OrigCollisionHeight = LandUpCollisionHeight;
		}
		else if ((RandDir == 5) && (bLandUpsideDown))
		{
			FoundDir = true;
			LandDirection = LAND_UpsideDown;
			OrigCollisionRadius = LandUpCollisionRadius;
			OrigCollisionHeight = LandUpCollisionHeight;
		}
		
		if ((!bLandForward) && (!bLandBackwards) && (!bLandLeft) && (!bLandRight) && (!bLandUpright) && (!bLandUpsideDown))
		{
			FoundDir = true;
			LandDirection = LAND_Upright;
			OrigCollisionRadius = LandUpCollisionRadius;
			OrigCollisionHeight = LandUpCollisionHeight;
		}
	}

	ResetMassProperties();
	bRotateByQuat = true;
	bRotateToDesired = false;
	bFixedRotationDir = true;
	if (LandDirection != LAND_Backwards)
		RotationRate.Pitch = BaseTumbleRate;
	else
		RotationRate.Pitch = -BaseTumbleRate;
	bCanTumble = true;
	bDamageFromToss = true;

	Super.Tossed();
}

function BaseChange()
{
	if ((CarriedBy != None) && (Base != CarriedBy))
		SetBase(CarriedBy);

	bWaterLogged = false;
	bDoneTumbling = false;

	if ((MassPrefab == MASS_Heavy) && (dnDecoration(Base) != None) && (dnDecoration(Base).MassPrefab != MASS_Heavy))
	{
		Base.TakeDamage( 1000, None, vect(0,0,0), vect(0,0,0), class'ExplosionDamage' );
		SetBase(None);
		return;
	}

	Super.BaseChange();
}

function float GetForceScale()
{
	local float WaterFactor;

	if (Region.Zone.bWaterZone)
		WaterFactor = 0.75;
	else
		WaterFactor = 1.0;

	switch (MassPrefab)
	{
	case MASS_Ultralight:
		return 0.8*WaterFactor;
	case MASS_Light:
		return 0.7*WaterFactor;
	case MASS_Medium:
		return 0.6*WaterFactor;
	case MASS_Heavy:
		return 0.6*WaterFactor;
	case MASS_Rubber:
		return 1.0*WaterFactor;
	}
}

function float GetJumpZScale()
{
	switch (MassPrefab)
	{
	case MASS_Ultralight:
		return 1.0;
	case MASS_Light:
		return 1.0;
	case MASS_Medium:
		return 1.0;
	case MASS_Heavy:
		return 0.8;
	case MASS_Rubber:
		return 1.0;
	}
}

function AnimEnd()	// Animation has ended, possibly start a new one.
{
	local int i;
	local name NewAnimation;
	local pendingSequence ps;
	
	// Do I have another sequence pending?
	if (CurrentPendingSequence >= 0)
	{
		ps = PendingSequences[0];

		if (ps.PlaySequence != '')
		{
			if (bool(ps.Noise))
			{
				if (ps.NoiseIsAmbient)
				{
					AmbientSound = ps.Noise;
					SoundRadius = ps.Radius;
				} else {
					AmbientSound = None;
					PlaySound(ps.Noise,,,,ps.Radius);
				}
			}

			if (ps.Loop)
			{
				if (ps.PlaySequence != AnimSequence)
				{
					LoopingSequence = true;
					LoopAnim(ps.PlaySequence);
				}
			}
			else
			{
				LoopingSequence = false;
				PlayAnim(ps.PlaySequence);
			}

			if(ps.Event!='')			
				GlobalTrigger(ps.Event);
		}

		CurrentPendingSequence--;
		DiscardSequence();

		return;
	} else if (LoopingSequence)
		return;

	// Look for idle animations:
	for(i=0;i<ArrayCount(IdleAnimations);i++)
		if(IdleAnimations[i]!='') 
			break;

	if(i<ArrayCount(IdleAnimations))
	{
		NewAnimation='';
		do NewAnimation=IdleAnimations[Rand(ArrayCount(IdleAnimations))];
		until(NewAnimation!='');
		
		if(NewAnimation!=AnimSequence)
			LoopAnim(NewAnimation);		
	}		
}

function Used( Actor Other, Pawn EventInstigator )
{
	if ((Level.TimeSeconds > TriggerReTriggerDelay) && (Level.TimeSeconds - LastTriggerTime < TriggerReTriggerDelay))
		return;
	Trigger( Other, EventInstigator );
	LastTriggerTime = Level.TimeSeconds;
}

function UnUsed( Actor Other, Pawn EventInstigator )
{
	local int i;

	// Toggle off.
	bSequenceToggleOn = false;
	for (i=0; i<4; i++)
	{
		if (ToggleOffSequences[i].PlaySequence != '')
			PushPendingSequence(ToggleOffSequences[i], false);
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	local int i;

	Instigator = EventInstigator;

	// Handle trigger spawn.
	for (i=0; i<4; i++)
	{
		if (TriggeredSpawn[i].ActorClass != None)
		{
			if ( (!TriggeredSpawn[i].SpawnOnce) || (TriggeredSpawn[i].SpawnActor == None) )
			{
				TriggeredSpawn[i].SpawnActor = Spawn(TriggeredSpawn[i].ActorClass);
				SetToMount( TriggeredSpawn[i].MountMeshItem, Self, TriggeredSpawn[i].SpawnActor );
			}
			if ( (TriggeredSpawn[i].SpawnActor != None) && (TriggeredSpawn[i].TriggerWhenTriggered) )
				TriggeredSpawn[i].SpawnActor.Trigger( Self, EventInstigator );
		}
	}

	// Handle sequence toggle.
	if (bSequenceToggle)
	{
//		CurrentPendingSequence = -1;
		if (bSequenceToggleOn)
		{
			bSequenceToggleOn = false;
			for (i=0; i<8; i++)
			{
				if (ToggleOffSequences[i].PlaySequence != '')
					PushPendingSequence(ToggleOffSequences[i], false);
			}
		} else {
			bSequenceToggleOn = true;
			for (i=0; i<8; i++)
			{
				if (ToggleOnSequences[i].PlaySequence != '')
					PushPendingSequence(ToggleOnSequences[i], false);
			}
		}
	}

	// Do I have a valid event?
	if(TriggerEvent!='') GlobalTrigger(TriggerEvent,EventInstigator);
	
	if(TriggeredSequence!='') 			PlayAnim(TriggeredSequence); 		// Play related sequence.
	if(TriggeredSound!=none)  			PlaySound(TriggeredSound);   		// Play related sound.	
	if(TriggeredAmbientSound!=none) 	AmbientSound=TriggeredAmbientSound;	// Start ambient sound when triggered.

	// Do I take damage when triggered?
	if(bool(DamageOnTrigger))
		TakeDamage( DamageOnTrigger, Instigator, Location, Vect(0,0,1)*900,class'ExplosionDamage' );
		
	if(bool(HealOnTrigger))
		if(EventInstigator!=none)
			if((EventInstigator.Health<100)||(HealOnTrigger<0))
			{
				EventInstigator.Health+=HealOnTrigger;
			
				// Did I go over my max health limit?
				if((EventInstigator.Health>100)&&(HealOnTrigger>0)) 
					EventInstigator.Health=100;

				// Play a drink sound.
				if ( bDrinkSoundOnHeal )
					EventInstigator.PlaySound( DrinkSound, SLOT_Talk, 1.0, false, 800 );
			}
}

function UnTrigger( Actor Other, Pawn EventInstigator )
{
	Instigator=EventInstigator;

	// Do I have a valid event?
	if(UntriggerEvent!='') GlobalTrigger(UntriggerEvent,EventInstigator);

	// Do I have a sequence to play?
	if(UntriggeredSequence!='')			PlayAnim(UntriggeredSequence); 		  // Play related sequence.
	if(UntriggeredSound!=none)  		PlaySound(UntriggeredSound);   		  // Play related sound.	
	if(UntriggeredAmbientSound!=none) 	AmbientSound=UntriggeredAmbientSound; // Start ambient sound when triggered.

	// Do I take damage when triggered?
	if(bool(DamageOnUntrigger))
		TakeDamage( DamageOnUntrigger, Instigator, Location, Vect(0,0,1)*900,class'ExplosionDamage' );

}

event Falling()
{
	local rotator r;
	local float Temp;

	if (!bCanTumble && !bDropped)
	{
		bRotateByQuat = false;
		RotationRate.Pitch = 0; 
		RotationRate.Yaw   = 0; 
		RotationRate.Roll  = 0; 

		DesiredRotation.Pitch = 0;
		DesiredRotation.Yaw   = 0;
		DesiredRotation.Roll  = 0;

		GetCharlieAngle(r);

		switch (MassPrefab)
		{
			case MASS_Ultralight:
			case MASS_Light:
				Temp = 0.25;
				break;
			case MASS_Medium:
			case MASS_Heavy:
				Temp = 0.5;
				break;
			case MASS_Rubber:
				Temp = 1.0;
				break;
		}
		RotateTo( r, false, Temp );
		bCanTumble = true;
	}
}

function Landed(vector HitNormal)
{
	Super.Landed( HitNormal );

	bDropped = false;
	SetPhysics( PHYS_None );
	
	if (LastGlass != None)		// JEP
		ResetLastGlass();
}

function WaterPush()
{
	// A pawn jumped on us.
	Velocity.X += Rand(50) + 100;
	Velocity.Y += Rand(50) + 100;
	SetCollision( false, false, false );
	SetTimer(0.3, false, 1);
}

function ResetLastGlass()
{
	if (LastGlass != None)
	{
		LastGlass.bBlockPlayers = true;
		LastGlass = None;
	}
}

function HitWall(vector HitNormal, actor Wall)
{
	local vector NewVelocity, landspot, TempVect, X, Y, Z;
	local float  VelocitySize, Temp, ComputedVelocitySize;
	local dnDecoration OtherDecoration;
	local rotator r;
	local BreakableGlass	Glass;				// JEP

	// Don't bounce if waterlogged.
	if (bWaterLogged)
		return;

	// Compute velocity magnitude:
	VelocitySize = VSize(Velocity);

	// JEP...
	if (VelocitySize > 100.0f && Wall.IsA('BreakableGlass'))
	{
		Glass = BreakableGlass(Wall);

		if (Glass != LastGlass)
			ResetLastGlass();
			
		//if (MassPrefab == MASS_Rubber)
		//if (MassPrefab == MASS_Ultralight:

		if (MassPrefab == MASS_Light)
		{
			if (Glass.GlassBreakCount > 0)
			{
				Glass.ReplicateBreakGlassDir( Location, Velocity, VelocitySize/5 );
				return;
			}
			else
			{
				Glass.ReplicateBreakGlass( Location );
				// Kind of a hack.  I have to do this so the decoration 
				// will not keep hitting the glass.  Notice on the Toss code, that we reset the last glass back to colliding again.
				// This works because if the glass is shattered, then it will ignore all collisions anyhow, so it's ok
				// to just set it back to normal
				Glass.bBlockPlayers = false;		
				LastGlass = Glass;
				return;
			}
		}

		if (MassPrefab == MASS_Medium)
		{
			Glass.ReplicateBreakGlassDir( Location, Velocity, VelocitySize/4 );
			return;
		}

		if (MassPrefab == MASS_Heavy)
		{
			Glass.ReplicateBreakGlassDir( Location, Velocity, VelocitySize/3 );
			return;
		}
	}
	else if (LastGlass != None)		// JEP
		ResetLastGlass();

	if (VelocitySize > 200.0f && Wall == Level)
		EnumSurfsInRadius(Location, Max(CollisionHeight, CollisionRadius)+1);		// Trigger all surfaces in radius of this impact point
	// ...JEP

	if (VelocitySize < 10)
		Landed(HitNormal);

	// Compute damage from impact with wall:
	if (DamageFromImpactScaler != 0)	// Don't bother if zero.
	{
		Temp = VelocitySize * Mass;
		if (Temp > 0)
		{
			Temp = Sqrt(Temp) * DamageFromImpactScaler;
			TakeDamage( Temp,Pawn(Owner), HitNormal, HitNormal * Temp, class'CrushingDamage' );

			OtherDecoration = dnDecoration(Wall);
			if (OtherDecoration != none)
			{
				Temp = Sqrt(VelocitySize * Mass) * OtherDecoration.DamageFromImpactScaler;
				OtherDecoration.TakeDamage(Temp, Pawn(Owner), HitNormal, HitNormal * Temp, class'CrushingDamage' );	
			}
		}
	}

	// Damage the thing we hit.
	if ( (Wall != None) && (Wall != Level) && bDamageFromToss && (!Wall.bIsPawn || !Pawn(Wall).NoDecorationPain) )
	{
		switch (MassPrefab)
		{
		case MASS_Ultralight:
			Wall.TakeDamage(0, Instigator, HitNormal, Sqrt(VelocitySize * Mass) * HitNormal, class'CrushingDamage');	
			break;
		case MASS_Light:
			Wall.TakeDamage(5, Instigator, HitNormal, Sqrt(VelocitySize * Mass) * HitNormal, class'CrushingDamage');	
			break;
		case MASS_Medium:
			Wall.TakeDamage(10, Instigator, HitNormal, Sqrt(VelocitySize * Mass) * HitNormal, class'CrushingDamage');	
			break;
		case MASS_Heavy:
			Wall.TakeDamage(25, Instigator, HitNormal, Sqrt(VelocitySize * Mass) * HitNormal, class'CrushingDamage');	
			break;
		case MASS_Rubber:
			Wall.TakeDamage(0, Instigator, HitNormal, Sqrt(VelocitySize * Mass) * HitNormal, class'CrushingDamage');	
			break;
		}
	}
	bDamageFromToss = false;

	if (HitWallEvent != '')				GlobalTrigger(HitWallEvent); 	  // Trigger event if I've got one.
	if (HitWallSequence != '')			PlayAnim(HitWallSequence);    	  // Play related sequence.
	if (HitWallSound != none)	  		PlaySound(HitWallSound);		  // Play related sound.
	if (HitWallAmbientSound != none)	AmbientSound = HitWallAmbientSound; // Change ambient sound if desired

	if(bBounce && bCanTumble)
	{
		if (!bTumble && (VelocitySize <= 100.0) && (Wall == Level))
		{ 
			//Landed(HitNormal); 				
			//return; 
		}
				
		NewVelocity = MirrorVectorByNormal(Velocity,HitNormal);
		Temp = Mass / 700; if (Temp < 1.0) Temp = 1.0;
		Velocity = Normal(NewVelocity) * (VelocitySize / Temp) * BounceElasticity; 
		VelocitySize = VSize(Velocity);

		if ((Wall != None) && (Wall.bIsPawn))
		{
			// If we land on a pawn, bounce us clear.
			Velocity.X += Rand(50) + 100;
			Velocity.Y += Rand(50) + 100;
		}

		if (bTumble && !bDoneTumbling)
		{
			if (VelocitySize > 200)
			{
				bRotateByQuat = true;
				bRotateToDesired = false;
				bFixedRotationDir = true;
	
				if (LandDirection == LAND_Forward) {
					RotationRate.Pitch = (Rand(120000)-60000) * (VelocitySize / (400 + Mass));
					RotationRate.Yaw = (Rand(120000)-60000) * (VelocitySize / (400 + Mass)); 
					RotationRate.Roll = (Rand(120000)-60000) * (VelocitySize / (400 + Mass));
				}
				if (LandDirection == LAND_Backwards) {
					RotationRate.Pitch = (Rand(-120000)+60000) * (VelocitySize / (400 + Mass));
					RotationRate.Yaw = (Rand(120000)-60000) * (VelocitySize / (400 + Mass)); 
					RotationRate.Roll = (Rand(120000)-60000) * (VelocitySize / (400 + Mass));
				}
				if (LandDirection == LAND_Left) {
					RotationRate.Pitch = (Rand(120000)-60000) * (VelocitySize / (400 + Mass));
					RotationRate.Yaw = (Rand(120000)-60000) * (VelocitySize / (400 + Mass)); 
					RotationRate.Roll = (Rand(-120000)+60000) * (VelocitySize / (400 + Mass));
				}
				if (LandDirection == LAND_Right) {
					RotationRate.Pitch = (Rand(120000)-60000) * (VelocitySize / (400 + Mass));
					RotationRate.Yaw = (Rand(120000)-60000) * (VelocitySize / (400 + Mass)); 
					RotationRate.Roll = (Rand(-120000)+60000) * (VelocitySize / (400 + Mass));
				}
				if (LandDirection == LAND_Upright) {
					RotationRate.Pitch = (Rand(120000)-60000) * (VelocitySize / (400 + Mass));
					RotationRate.Yaw = (Rand(120000)-60000) * (VelocitySize / (400 + Mass)); 
					RotationRate.Roll = (Rand(120000)-60000) * (VelocitySize / (400 + Mass));
				}
				if (LandDirection == LAND_UpsideDown) {
					r.Pitch = -32767;
					r.Yaw = Rand(65535);
					r.Roll = 0;
					RotateTo( r, false, Temp );
				}

				Velocity.X += ((Rand(VelocitySize / 3.0)) * (Rand(3) - 1));
				Velocity.Y += ((Rand(VelocitySize / 3.0)) * (Rand(3) - 1));
			} else {
				if (bNotPushableAfterTumble)
					bPushable = false;

				bDoneTumbling = true;

				bRotateByQuat = false;

				RotationRate.Pitch = 0; 
				RotationRate.Yaw   = 0; 
				RotationRate.Roll  = 0;

				DesiredRotation.Pitch = 0;
				DesiredRotation.Yaw   = 0;
				DesiredRotation.Roll  = 0;

				GetCharlieAngle(r);

				switch (MassPrefab)
				{
				case MASS_Ultralight:
				case MASS_Light:
					Temp = 0.25;
					break;
				case MASS_Medium:
				case MASS_Heavy:
					Temp = 0.5;
					break;
				case MASS_Rubber:
					Temp = 1.0;
					break;
				}
				RotateTo( r, false, Temp );
			}
		} else if (bTumble && bDoneTumbling && (Wall == Level) && (VelocitySize <= 100.0)) {
			//Landed(HitNormal);
		}
	} 
	else
	{	
		// Original Code:
		Velocity = vect(0,0,0);
	}
}

function bool IsWaterLogged()
{
	return bWaterLogged;
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	local rotator r;
	local float Temp;

	// Am I entereing or leaving water?
	if ((NewZone.bWaterZone) && (!bWaterLogged))
	{
		// Now we are water logged.
		bWaterLogged = true;

		bDoneTumbling = true;
		bRotateByQuat = false;
		RotationRate.Pitch = 0;
		RotationRate.Yaw   = 0;
		RotationRate.Roll  = 0;
		DesiredRotation.Pitch = 0;
		DesiredRotation.Yaw   = 0;
		DesiredRotation.Roll  = 0;

		GetCharlieAngle(r);
		RotateTo( r, false, 2.0 );

		Spawn(WaterSplashClass);

		// Handle water damage.
		if ( DamageOnHitWater != 0 )
			TakeDamage( DamageOnHitWater, Instigator, Location, Vect(0,0,1)*900, class'CrushingDamage' );
	}

	Super.ZoneChange( NewZone );
}

function GetCharlieAngle( out rotator r ) // BR: Haha get it? Charlie's Angel? Angle? Haha! I'm so funny.
{
	if (LandDirection == LAND_Forward) {
		r.Pitch = -16383;
		r.Yaw = Rotation.Yaw;
		r.Roll = 0;
	} else if (LandDirection == LAND_Backwards) {
		r.Pitch = 16383;
		r.Yaw = Rotation.Yaw;
		r.Roll = 0;
	} else if (LandDirection == LAND_Left) {
		r.Pitch = 0;
		r.Yaw = Rotation.Yaw;
		r.Roll = -16383;
	} else if (LandDirection == LAND_Right) {
		r.Pitch = 0;			
		r.Yaw = Rotation.Yaw;
		r.Roll = 16383;
	} else if(LandDirection == LAND_Upright) {
		r.Pitch = 0;
		r.Yaw = Rotation.Yaw;
		r.Roll = 0;
	} else if(LandDirection == LAND_UpsideDown) {
		r.Pitch = -32767;
		r.Yaw = Rand(65535);
		r.Roll = 0;
	}
}

function Topple( Pawn instigatedBy, vector HitLocation, vector momentum, optional int Damage )
{
	SetPhysics(PHYS_Falling);
	Velocity = Momentum/Mass;
	Velocity.Z = Momentum.Z + 100 + 100*FRand();
	Tossed();
	if( Damage > 0 )
		TakeDamage( Damage, instigatedBy, HitLocation, momentum, class'CrushingDamage' );
}

// Have the decoration take damage:
function TakeDamage( int NDamage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	local int i,j,k;
	local int PreviousHealth;						// Mark my previous health.
	local float speed;
	local vector v;

	if (bNoDamage)
		return;	

	// Check to see if we can set it on fire.
	if ( CanBurn( DamageType ) )
	{
		ImmolationActor = spawn( class<ActorDamageEffect>(DynamicLoadObject( ImmolationClass, class'Class' )), Self );
		ImmolationActor.Initialize();
	}

	if ((Physics != PHYS_Falling) && bTakeMomentum && !IsWaterLogged() && (MassPrefab != MASS_Heavy) && !ClassIsChildOf(DamageType, class'FireDamage') )
	{
		if (FRand() < 0.7)
		{
			SetPhysics(PHYS_Rolling);
			v = (Momentum*100)/Mass;
			v.Z = 0;
			speed = VSize(v);
			Velocity = v * FMin(120.0, 20 + speed)/speed;
			SetTimer(0.5,true);
		} else {
			SetPhysics(PHYS_Falling);
			Velocity = Momentum/Mass;
			Velocity.Z = 100 + 100*FRand();
			Tossed();
		}
	}

	if(NDamage<DamageThreshold)						// Is this under my damage threshold?
		return;										// Yep, ignore it.
		
	PreviousHealth=Health;							// Initialize previous health.
	
	GlobalTrigger(DamageEvent, instigatedBy);   	// Fire my damaged event

	if (bSequenceToggleOn && (DamageSequence!=''))  
			PlayAnim(DamageSequence); 					// Play related sequence
	else if (!bSequenceToggleOn && (DamageSequenceOff!='')) 
			PlayAnim(DamageSequenceOff);			// Play related sequence
	else if (!bSequenceToggleOn && (DamageSequence!='')) 
			PlayAnim(DamageSequence); 					// Play related sequence

	if(DamageSound!=none) 	 		PlaySound(DamageSound);   	// Play my damaged sound.
	if(DamageAmbientSound!=none) 	AmbientSound=DamageAmbientSound;	

	Instigator = InstigatedBy;						// Who did this dastardly deed?
	bBobbing = false;
	
    // I'm already dead (or indestructable).
	if ( Health<=0 ) 
        return;

    // Alert the nearby AI's
	if ( ( Instigator != None ) && ( AlertAIOnDestruction ) )  
		MakeNoise(1.0);			

    // Actually take the damage:
	Health -= NDamage; 								

    // Make sure I don't die if I drop below 0 and flag is set.
	if ( ( Health <= 0 ) && DontDie ) 
        Health=1;
	
	for( i=0; i<ArrayCount(HealthMarkers); i++ )
	{
		// Did I cross this threshold?
		if ( (PreviousHealth >= HealthMarkers[i].Threshold) && (Health < HealthMarkers[i].Threshold) )
		{
			// If I have a sound, play it:	
			if ( HealthMarkers[i].StartSound != none )
				PlaySound( HealthMarkers[i].StartSound );

			// If I have an ambient sound, set it:
			if( HealthMarkerAmbientSound[i] != none )
				AmbientSound = HealthMarkerAmbientSound[i];

			// If I have a trigger, trigger it:				
			if ( (HealthMarkers[i].PrefixTagToEvent) && (HealthMarkers[i].TriggerEvent != '') )
				GlobalTrigger( NameForString(""$Tag$""$HealthMarkers[i].TriggerEvent), instigatedBy );
			else if ( HealthMarkers[i].TriggerEvent != '' )
				GlobalTrigger( HealthMarkers[i].TriggerEvent, instigatedBy );
						
			// If I am to change to a new mesh, do it:
			if ( HealthMarkers[i].ChangeMesh != none )
				Mesh = HealthMarkers[i].ChangeMesh;
			
			// If I am to change to a new skin, do so:	
			if ( HealthMarkers[i].ChangeSkin != none )
				Skin = HealthMarkers[i].ChangeSkin;

			// If I have an actor to spawn, then spawn it:
			if ( HealthMarkers[i].SpawnActor != none )
				Spawn( HealthMarkers[i].SpawnActor );

			// I crossed the threshold, Play the sequence:
			if ( HealthMarkers[i].PlaySequence != '' )
			{
				if ( HealthMarkers[i].LoopSequence )
					 LoopAnim( HealthMarkers[i].PlaySequence,1.0,0.0 );
				else PlayAnim( HealthMarkers[i].PlaySequence,1.0,0.0 );

				if (( i < 3) && ( bUseLastMarkerAnim )) {
					if ( HealthMarkers[i+1].PlaySequence == '' ) {
						DamageSequence = HealthMarkers[i].PlaySequence;
					}
				}
				else {
					DamageSequence = HealthMarkers[i].PlaySequence;
				}
			
			}
		}
	}
	
	// See if I just died:
	if (Health <= 0)
	{
		if ( ImmolationActor != None )
			ImmolationActor.Destroy(); // Make sure fire goes away.
    	Destroy();
	}
    else 
	{
		if ( FallingPhysicsOnDamage )
		{
			SetPhysics( PHYS_Falling );
			bInterpolating = false;
			Velocity = (Location-OldLocation) / Level.TimeDeltaSeconds;
		}

		if ( (DelayedDamageTime != 0) && (DelayedDamageAmount != 0) )
		{
			SetTimer( DelayedDamageTime, false, 2 );
		}
	}
}

simulated function HitEffect( vector HitLocation, class<DamageType> DamageType, vector Momentum, float DecoHealth, float HitDamage, bool bNoCreationSounds )
{
	local int i, j, k;
	local float PreviousHealth;
	local actor s;

	PreviousHealth = DecoHealth - HitDamage;

	// Do I have a damage actor to spawn?
	if ( SpawnOnHit != none )
	{
		s = Spawn( SpawnOnHit, Self, '', HitLocation, rotator(HitLocation - Location) );
		if ( !bNoCreationSounds && (SoftParticleSystem(s) != None) )
			SoftParticleSystem(s).PlayCreationSounds();
	}

	for( i=0; i<ArrayCount(HealthMarkers); i++ )
	{
		// Did I cross this threshold?
		if( (PreviousHealth >= HealthMarkers[i].Threshold) && (DecoHealth < HealthMarkers[i].Threshold) )
		{
			// If I have an actor to spawn, then spawn it:
			// if ( HealthMarkers[i].SpawnActor != none )
			//		Spawn( HealthMarkers[i].SpawnActor );
			/*
			// Do I need to spawn frags?			
			if(HealthMarkerSpawnFrags[i]!=0)
				for(j=0;j<HealthMarkerSpawnFrags[i];j++)
				{
					for(k=0;k<8;k++)
					{
						if(FragType[k]!=none)
							SpawnFrag(FragType[k]);
						else
							Destroy(); 
					}
				}
				*/
		}
	}

	Super.HitEffect( HitLocation, DamageType, Momentum, DecoHealth, HitDamage, bNoCreationSounds );
}

function Timer(optional int TimerNum)
{
    if (TimerNum == 3) // EMP Done
    {
        bEMPulsed = false;
       GlobalTrigger(EMPunEvent);
    }
	else if (TimerNum == 2)
	{
		if ( (DelayedDamageTime != 0) && (DelayedDamageAmount != 0) )
			TakeDamage( DelayedDamageAmount, Instigator, Location, Vect(0,0,1) * 900, class'CrushingDamage' );
	} else
		Super.Timer(TimerNum);
}

simulated function Destroyed()
{	
	local int i;
	local actor a;
	local rotator SpawnRotation;

	GlobalTrigger(DestroyedEvent);						// Trigger destruction event.
	if ( DestroyedSound!=none )
        PlaySound(DestroyedSound);	// Play my destroyed sound.
	
	// Destroy kiddies:	
	for( i=0; i<ArrayCount( MountOnSpawn ); i++ )
    {
		if ( MountOnSpawn[i].ActorReference != none )
        {
			if ( !MountOnSpawn[i].SurviveDismount )
			{
				MountOnSpawn[i].ActorReference.Destroy();
				MountOnSpawn[i].ActorReference=none;
			}
        }
    }

	// Clear out collision so stuff that gets spawned on me doesn't die immedietely:
	SetCollision( false, false, false );
	bCollideWorld = false;
    // Spawn the frag types
    for ( i=0; i < ArrayCount(FragType); i++ )
	{
		if( FragType[i] != none )
        {
			SpawnFrag( FragType[i] );
        }
    }

	// Spawn some more fun.
	for ( i=0; i < ArrayCount(SpawnOnDestroyed); i++ )
    {
		if ( SpawnOnDestroyed[i].SpawnClass != none )
		{
			a=Spawn( SpawnOnDestroyed[i].SpawnClass );

			if( SpawnOnDestroyed[i].ChangeMesh!=none )
                a.Mesh = SpawnOnDestroyed[i].ChangeMesh;

			if ( SpawnOnDestroyed[i].bUseAlternateMotion )
			{
				if ( SpawnOnDestroyed[i].AlternateMotion.SpawnRotationNotRelative )
					SpawnRotation = rot(0,0,0);
				else
					SpawnRotation = Rotation;

				SpawnRotation.Pitch += SpawnOnDestroyed[i].AlternateMotion.SpawnRotation.Pitch - (SpawnOnDestroyed[i].AlternateMotion.SpawnRotationVariance.Pitch/2) + SpawnOnDestroyed[i].AlternateMotion.SpawnRotationVariance.Pitch*FRand();
				SpawnRotation.Yaw += SpawnOnDestroyed[i].AlternateMotion.SpawnRotation.Yaw - (SpawnOnDestroyed[i].AlternateMotion.SpawnRotationVariance.Yaw/2) + SpawnOnDestroyed[i].AlternateMotion.SpawnRotationVariance.Yaw*FRand();
				SpawnRotation.Roll += SpawnOnDestroyed[i].AlternateMotion.SpawnRotation.Roll - (SpawnOnDestroyed[i].AlternateMotion.SpawnRotationVariance.Roll/2) + SpawnOnDestroyed[i].AlternateMotion.SpawnRotationVariance.Roll*FRand();
				a.SetRotation( SpawnRotation );

				if ( SpawnOnDestroyed[i].AlternateMotion.SpawnSpeed > 0 )
					a.Velocity = normal(vector(SpawnRotation))*(SpawnOnDestroyed[i].AlternateMotion.SpawnSpeed - (SpawnOnDestroyed[i].AlternateMotion.SpawnSpeedVariance/2) + SpawnOnDestroyed[i].AlternateMotion.SpawnSpeedVariance*FRand());
			} else
			{
				a.Velocity=Velocity;
				a.Velocity.X+=frand()*SpawnOnDestroyed[i].VelocityVariance.X-SpawnOnDestroyed[i].VelocityVariance.X/2;
				a.Velocity.Y+=frand()*SpawnOnDestroyed[i].VelocityVariance.Y-SpawnOnDestroyed[i].VelocityVariance.Y/2;
				a.Velocity.Z+=frand()*SpawnOnDestroyed[i].VelocityVariance.Z-SpawnOnDestroyed[i].VelocityVariance.Z/2;

				if ( ( SpawnOnDestroyed[i].RotationVariance.yaw   != 0 ) ||
	                 ( SpawnOnDestroyed[i].RotationVariance.pitch != 0 ) ||
	                 ( SpawnOnDestroyed[i].RotationVariance.roll  != 0 ) 
	               )
				{
					a.bFixedRotationDir=true;
					a.RotationRate.yaw+=frand()*SpawnOnDestroyed[i].RotationVariance.yaw-SpawnOnDestroyed[i].RotationVariance.yaw/2;
					a.RotationRate.pitch+=frand()*SpawnOnDestroyed[i].RotationVariance.pitch-SpawnOnDestroyed[i].RotationVariance.pitch/2;
					a.RotationRate.roll+=frand()*SpawnOnDestroyed[i].RotationVariance.roll-SpawnOnDestroyed[i].RotationVariance.roll/2;
				}
			}

			if (SpawnOnDestroyed[i].bTossDecoration && a.IsA('Decoration'))
				Decoration(a).Tossed();

			if ( SpawnOnDestroyed[i].NoCollision )
			{
				SetCollision( false,false,false );
				bCollideWorld = false;
			}
		}
    }

	// Punt to superclass.
	super.Destroyed();
}

function Bump( actor Other )
{
	local float ImpactMomentum;

	Super.Bump( Other );

	if (bTakeImpactDamage && PlayerPawn(Other) != None && VSize(Velocity) > 500)
	{
		TakeDamage( 30, none, vect(0,0,0), vect(0,0,0), class'CrushingDamage' );
		bTakeImpactDamage = false;
		if (MassPrefab == MASS_Medium)
			ImpactMomentum = 100;
		else if (MassPrefab == MASS_Heavy)
			ImpactMomentum = 180;
		if (ImpactMomentum > 0)
			PlayerPawn(Other).AddVelocity((Velocity * 0.75) + (vect( 0,0,1 ) * ImpactMomentum));
	}

	if (Level.TimeSeconds < LastBumpTime + BumpAgainTime)
		return;
	LastBumpTime = Level.TimeSeconds;

	if(BumpedSequence!='')			PlayAnim(BumpedSequence);  		// Play related sequence.
	if(BumpedSound!=none)	 		PlaySound(BumpedSound);			// Play my touched sound
	
	// Was it a player that just touched me?
	if(PlayerPawn(Other)!=none)
	{
		GlobalTrigger(BumpedByPlayerEvent,Pawn(Other));
		if(BumpedByPlayerSequence!='') PlayAnim(BumpedByPlayerSequence);  // Play related sequence.
		if(BumpedByPlayerSound!=none)  PlaySound(BumpedByPlayerSound); 	 // Touched by player sound.
	}
}

function Touch( actor Other )
{
	local vector ZeroVector;
	local float temp;
	
	ZeroVector.x=0; ZeroVector.y=0; ZeroVector.z=0; // Make the zero vector zero.
	
	GlobalTrigger(TouchedEvent);					// Send my touched trigger notification.
	if(TouchedSequence!='') 		PlayAnim(TouchedSequence);  		// Play related sequence.
	if(TouchedSound!=none)  		PlaySound(TouchedSound);			// Play my touche sound
	if(TouchAmbientSound!=none)		AmbientSound=TouchAmbientSound;		// Ambient sound to play on touch
	
	// Am I sensitive to touch?
	if ( DamageOnTouch != 0 )
		TakeDamage( DamageOnTouch, none, ZeroVector, ZeroVector, class'CrushingDamage' );

	if(DamageOtherOnTouch!=0)
	{
		if ( !Other.bIsPawn || !Pawn(Other).NoDecorationPain )
			Other.TakeDamage(DamageOtherOnTouch,none,ZeroVector,ZeroVector,class'CrushingDamage');
	}

	// Was it a player that just touched me?
	if(PlayerPawn(Other)!=none)
	{
		GlobalTrigger(TouchedByPlayerEvent,Pawn(Other));
		if(TouchedByPlayerSequence!='') PlayAnim(TouchedByPlayerSequence);  // Play related sequence.
		if(TouchedByPlayerSound!=none)  PlaySound(TouchedByPlayerSound); 	 // Touched by player sound.
		if(TouchedByPlayerAmbientSound!=none) AmbientSound=TouchedByPlayerAmbientSound;

		// Am I sensitive to player touch?
		if(DamageOnPlayerTouch!=0)
			TakeDamage(DamageOnPlayerTouch,none,ZeroVector,ZeroVector,class'CrushingDamage');

		if(DamageOtherOnPlayerTouch!=0)
		{
			if ( !Other.bIsPawn || !Pawn(Other).NoDecorationPain )
				Other.TakeDamage(DamageOtherOnPlayerTouch,none,ZeroVector,ZeroVector,class'CrushingDamage');
		}
	}
}

function UnTouch( actor Other )
{
	GlobalTrigger(UntouchedEvent);							// Don't touch me! :^)
	if(UntouchedSequence!='') PlayAnim(UntouchedSequence);  // Play related sequence.
	if(UntouchedSound!=none)  PlaySound(UntouchedSound);	// Play my untouched sound
	
	// Was I just untouched by a player?
	if(PlayerPawn(Other) != none)
	{
		GlobalTrigger(UntouchedByPlayerEvent,Pawn(Other));
		if(UntouchedByPlayerSequence!='') PlayAnim(UntouchedByPlayerSequence);    // Play related sequence.
		if(UntouchedByPlayerSound!=none)  PlaySound(UntouchedByPlayerSound);	// Play my untouched sound
		if(UntouchedAmbientSound!=none) AmbientSound=UntouchedAmbientSound;	// Play ambient sound when untouched

	}
}

function EMPBlast( float EMPtime, optional Pawn Instigator )
{
    local Actor A;
    local vector ZeroVector;

    if( bEMPulsed ) // already pulsed
    {
        return;
    }

    bEMPulsed = true;

    // Spawn EMP Hit Effect
    if( SpawnOnEMP != none )
    {
		A = Spawn( SpawnOnEMP );
        A.AttachActorToParent( self, true, true );
    }

    // Damage from EMP
	if ( DamageOnEMP != 0 )
		TakeDamage( DamageOnEMP, None, ZeroVector, ZeroVector, class'CrushingDamage' );

    // Fire off EMPEvent
	if ( EMPEvent != '' )
	    GlobalTrigger( EMPEvent );

    // Set a Timer for unEMP event
    SetTimer( EMPtime, false, 3 );
}

defaultproperties
{
     DamageToImpactScaler=1.000000
     BounceElasticity=0.750000
     NumberFragPieces=12
     FragBaseScale=1.000000
     TriggerType=TT_PlayerProximityAndUse
     TriggerMountToDecoration=True
     DrinkSound=Sound'a_dukevoice.Food.Drink03'
     SpawnOnHit=Class'dnParticles.dnBulletFX_MetalSpawners'
     CurrentPendingSequence=-1
     bTumble=True
     MassPrefab=MASS_Medium
     HealthPrefab=HEALTH_Medium
     LandFrontCollisionRadius=24.000000
     LandFrontCollisionHeight=29.000000
     LandSideCollisionRadius=24.000000
     LandSideCollisionHeight=29.000000
     BaseTumbleRate=-16384.000000
     bSetFragSkin=True
     Health=100
     ItemName="Unnamed Decoration"
     CollisionRadius=24.000000
     CollisionHeight=29.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bBounce=True
     Mass=5.000000
     HitPackageLevelClass=Class'dnGame.HitPackage_DukeLevel'
     WaterSplashClass=Class'dnParticles.dnWallWaterSplash'
     DrawType=DT_Mesh
     Mesh=DukeMesh'c_generic.Barrel2'
	 ImmolationClass="dnGame.dnMeshImmolation"
    
	TraceHitCategory=TH_Decoration
}
  