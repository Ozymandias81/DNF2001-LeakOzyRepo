/*-----------------------------------------------------------------------------
dnCarcass
Author: Brandon Reinhart

This is the root of all Duke Forever carcasses.

Information on DNF carcasses:

- When a pawn is killed then a dnCarcass is spawned.  If this death
  is caused by explosive damage, then the carcass might be partially 
  chunked (CHS_ChunkPartial) if enough damage has been done to it.  Otherwise
  it just becomes a regular corpse.

- If an existing dnCarcass is hit by bullet damage, then the bones on the 
  corpse will be jiggled.  If enough damage is accumulated on the bone, then 
  the limb will be destroyed.

- If an existing dnCarcass is hit by explosive damage:
	+ If the carcass is in state CHS_Normal will be set to CHS_ChunkPartial (I.e. partially blown)
	+ A carcass in state CHS_ChunkPartial will be set to CHS_ChunkComplete (I.e. fully blown)

	( !!! Only in Single Player !!! )
	+ When a corpse goes to CHS_ChunkPartial, there is a 20% chance that a Chunk will be spawned
	  If this happens, then a HumanMeshChunk will be created, and there will be 2 different pieces to the 
	  carcass.

-----------------------------------------------------------------------------*/
class dnCarcass extends Carcass
	abstract;

// General carcass stuff.
var		class<MasterCreatureChunk>	MasterReplacement;

var		bool						bThumped;
var()	sound						LandedSound;
var()	sound						GibSounds[4];
var		bool						bSliding;
var		dnDecoration				MyHeldItem;
var		actor 						TrailReference; // Internal Spawned Trail Reference
var()	class<SoftParticleSystem>	TrailClass;		// Class of the trail to mount, or none.
var()	class<Inventory>			SearchableItems[5];
var		CreatureChunks				TrackChunk;
var     class<SoftParticleSystem>	BigChunksClass;
var     class<SoftParticleSystem>	BloodHazeClass;
var		class<SoftParticleSystem>	SmallChunksClass;
var		class<SoftParticleSystem>	SmallBloodHazeClass;
var		class<HumanMeshChunk>		ChunkClass;
var     class<PlayerChunks>			TrashBoneChunk1;
var     class<PlayerChunks>			TrashBoneChunk2;
var     class<PlayerChunks>			TrashBoneChunk3;
var     name						TrashedBoneNames[6]; // Sent over the net so we can trash 
														 // those bones on the client when we 
                                                         // first see the carcass

replication
{
	reliable if ( Role == ROLE_Authority )
		SearchableItems;
	reliable toall if ( ROLE == ROLE_Authority )
		ClientChunkUpComplete;
	reliable if ( ROLE == ROLE_Authority && bNetInitial )
		TrashedBoneNames;
}

/*-----------------------------------------------------------------------------
	Initialization & Object Methods 
-----------------------------------------------------------------------------*/


//=============================================================================
//PostNetInitial
//=============================================================================
simulated event PostNetInitial()
{
	local int i;

	Super.PostNetInitial();
	
	// Trash all the bones that we are told to
	for ( i=0; i<6; i++ )
	{
		if ( TrashedBoneNames[i] != '' )
		{
			TrashBone( i, TrashedBoneNames[i], false );
		}
	}
}

//=============================================================================
//PostBeginPlay
//=============================================================================
function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Increment the death zone's carcass count.
	if ( !bDecorative )
	{
		DeathZone = Region.Zone;
		if ( DeathZone != None )
			DeathZone.NumCarcasses++;
	}

	// This sets the collision on decorative carcasses?
	//if ( Physics == PHYS_None )
	//	SetCollision(bCollideActors, false, false);

	// Set our life span.
	if ( bDecorative )
	{
		LifeSpan = 0.0;
	}
	else
	{
		SetTimer( 10.0, false );
	}
}

//=============================================================================
//Destroyed
//=============================================================================
simulated function Destroyed()
{
	// Reduce the death zone's carcass count.
	if ( !bDecorative && ( DeathZone != None ) )
	{
		DeathZone.NumCarcasses--;
	}

	Super.Destroyed();
}

//=============================================================================
//InitFor
//=============================================================================
function InitFor( RenderActor Other )
{
	local int i, j;
	local vector NeckLoc, DamLoc;

	// Set up information about ourself.
	DamageBone  = Pawn(Other).DamageBone;

	// Reset the trashed bones list to zero.
	for ( i=0; i<6; i++ )
	{
		TrashedBones[i] = 0;
	}

	// Call the core initialization function.
	Super.InitFor( Other );

	// If our owner is a player set special properties.
	if ( Other.IsA('PlayerPawn') && Level.Game.bSearchBodies )
	{
		bUseTriggered		= true;
		bSearchable			= true;
		SearchableItems[0]	= PlayerPawn(Other).Weapon.Class;
		ItemName			= PlayerPawn(Other).PlayerReplicationInfo.PlayerName;
	}

	// Determine whether or not our eyes are shut.
	if ( ( AnimSequence == 'A_Suffer_ChestFall' ) ||
		 ( AnimSequence == 'A_Suffer_RLegFall' ) )
	{
		bEyesShut = false;
	} 
	else if ( FRand() < 0.8 )
	{
		bEyesShut = true;
	}

	// Set the armless bone to trashed.
	GetMeshInstance();
	if ( bArmless )
		TrashBone( j++, 'Forearm_L', false );

	// Set the headless bone to trashed.
	if ( bHeadBlownOff )
	{
		// Chunk the head.
		SetDamageBone('Neck');
		ChunkUpMore();

		// Create the decal bomb.
		if ( Pawn(Other) != None )
		{
			NeckLoc  = MeshInstance.BoneGetTranslate( MeshInstance.BoneFindNamed('Neck'), true, false );
			NeckLoc  = MeshInstance.MeshToWorldLocation( NeckLoc );
			DamLoc   = Pawn(Other).DamageLocation;
			DamLoc.Z = 0;
			spawn( class'HeadBomb',,, NeckLoc, rotator( DamLoc ) );
		}
	}

	for ( i=0; i<6; i++ )
	{
		if ( ExpandedScales[i] == 2.0 )
		{
			SetDamageBone( ExpandedBones[i] );
			ChunkUpExpanded();
		}
	}
}


/*-----------------------------------------------------------------------------
	Interaction / Searching
-----------------------------------------------------------------------------*/

//=============================================================================
//HasQuestItem
//=============================================================================
function bool HasQuestItem() { return false; }

//=============================================================================
//DropQuestItems
//=============================================================================
function DropQuestItems();

//=============================================================================
//SpecialLook
//=============================================================================
function RenderActor SpecialLook( PlayerPawn LookPlayer )
{
	if( MyHeldItem != None )
		return MyHeldItem;
}

//=============================================================================
//Used
//=============================================================================
function Used( Actor Other, Pawn EventInstigator )
{
	local Ammo				A;
	local int				i, CashFound, ItemsLeft;
	local Money				Cash;
	local PlayerPawn		aPlayer;
	local Inventory			Inv;
	local class<Inventory>	InvClass;

	if( bSpecialLook )
	{
		aPlayer = PlayerPawn( EventInstigator );
		aPlayer.WeaponDown( false, true, true );
		aPlayer.GrabDecoration( MyHeldItem );
		return;
	}

	if ( !bSearchable )
		return;
	
	// Search for ammo.
	if ( AmmoClassAmount > 0 )
	{
		if ( AmmoClass.static.CanPickup( Pawn(Other), AmmoClass, Inv ) )
		{
			A = Spawn( AmmoClass );
			A.SetModeAmount( i, AmmoClassAmount );
			A.Touch( Other );
			A.Destroy();

			AmmoClassAmount = 0;
			NPCAmmoMode		= 0;
			AmmoClass		= none;
		} else
			ItemsLeft++;
	}

	// Search for items.
	for ( i=0; i<5; i++ )
	{
		InvClass = SearchableItems[i];
		if ( ( InvClass != None ) && InvClass.static.CanPickup( EventInstigator, InvClass, Inv ) )
		{
			Inv = spawn( SearchableItems[i] );
			Inv.Touch( EventInstigator );
			Inv.Destroy();
			SearchableItems[i] = None;
		} else if ( InvClass != None )
			ItemsLeft++;
	}

	// No longer searchable if everything is taken.
	if ( ItemsLeft == 0 )
	{
		bSearchable = false;
		bNotTargetable = true;
	}

	// Search for cash.
	if( FRand() < 0.8 && bCanHaveCash && EventInstigator.IsA('PlayerPawn') )
	{
		CashFound = Rand(100);
		
		if ( CashFound > 60 )
			Cash = spawn(class'DollarSingle');
		else if (CashFound > 40)
			Cash = spawn(class'DollarWad_Three');
		else if (CashFound > 20)
			Cash = spawn(class'DollarWad_Five');
		else if (CashFound > 10)
			Cash = spawn(class'DollarWad');
		else
			Cash = spawn(class'DollarWad_TwentyFive');
		
		Cash.Touch( EventInstigator );
		Cash.Destroy();
	}
	
	bCanHaveCash = false;
	bJustSearched = true;
}

/*-----------------------------------------------------------------------------
	Damage
-----------------------------------------------------------------------------*/

//=============================================================================
//ChunkCarcass - Called on a server when a carcass has been damaged. 
//Responsible for calling ChunkUpComplete for listen server and will
//broadcast it to the client
//=============================================================================
function ChunkCarcass( optional ChunkState forcestate )
{
	bDamageProtect = true; // Already chunked this frame.  Can't rechunk from damage.

    if ( forcestate != 0 )
    {
		ChunkCarcassState    = forcestate;
    }
    else
    {
		// Advance the carcass to the next state only if we received gibbing damage
        if ( ChunkCarcassState == CHS_Normal && ChunkDamageType.default.bGibDamage )
            ChunkCarcassState = CHS_ChunkPartial;
        else if ( ChunkCarcassState == CHS_ChunkPartial && ChunkDamageType.default.bGibDamage )
            ChunkCarcassState = CHS_ChunkComplete;
    }

	// Spawn gib effects based on the state (Listen server)
	ChunkUpComplete( ChunkUpBlastLoc, ChunkDamageType.default.bFlyCarcass );
	
	// this is multicast to all connected relevant clients and will spawn effects on them
	ClientChunkUpComplete( ChunkCarcassState, ChunkUpBlastLoc );
}

//=============================================================================
//FakeDamage
//Is applied to carcasses and chunks. This will give the effect of a carcass 
//getting shot up.
//=============================================================================
simulated function FakeDamage( int Damage, name BoneName, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, bool bNoCreationSounds )
{
	// Spawn a hit effect at the location
	HitEffect( HitLocation, DamageType, Momentum, 0, 0, bNoCreationSounds );

	if ( ClassIsChildOf( DamageType, class'BulletDamage') )
	{
		// Apply the damage.
		SetDamageBone( BoneName );
		CumulativeDamage += Damage;
		if ( ( Damage > 30 ) || ( CumulativeDamage > 30 ) )
		{
			// We've done enough damage to chunk off this piece...
			if ( ( DamageBone != 'Chest' ) && ( DamageBone != 'Abdomen' ) && ( DamageBone != 'Pelvis' ) )
			{
				// Only chunk up limbs/extremeties
				ChunkUpMore();
			}
		}
		Velocity = vect(0,0,0);
	}
}

//=============================================================================
//TakeDamage
//=============================================================================
function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType )
{
	local int i;

	// If the damage is a fire damage and we aren't on fire, set us on fire!
	if ( CanBurn( DamageType ) )
	{
		ImmolationActor = spawn( class<ActorDamageEffect>(DynamicLoadObject( ImmolationClass, class'Class' )), Self );
		ImmolationActor.Initialize();

		// Update the trashed bones.
		for ( i=0; i<6; i++ )
		{
			if  ( TrashedBones[i] != 0 )
				ImmolationActor.TrashBoneByIndex( TrashedBones[i] );
		}
	}

	if ( !bDamageProtect && DamageType.default.bGibDamage )
	{
		ChunkDamageType = DamageType;
		BlastVelocity	= Momentum / 100;
		ChunkUpBlastLoc = HitLocation;
		ChunkCarcass();
	}

	// Stop suffering. (Command to client through replicated variable.)
	if ( bSuffering )
		bStopSuffering = true;
}

//=============================================================================
//SetDamageBone
//Set up a bone that has been damaged, so we can shake it
//=============================================================================
simulated function SetDamageBone( name BoneName )
{
    if ( BoneName=='None' )
		return;

	DamageBone				= BoneName;
	DamageBoneShakeFactor	= 1.0;
	bDamageBoneShakeInit	= false;
}

//=============================================================================
//GibSound
//=============================================================================
simulated function GibSound()
{
	local int r;

	r = Rand( 4 );
	PlayOwnedSound( GibSounds[r], SLOT_Interact, 16 );
}

//=============================================================================
//GetChunk
//=============================================================================
simulated function Carcass GetChunk()
{
	return TrackChunk;
}

//=============================================================================
//SpawnGibShower
//Used for spawning off a MasterReplacement which will spawn a bunch of gibs (usually)
//=============================================================================
simulated function SpawnGibShower( vector Location )
{	
	local MasterCreatureChunk carc;
	
	if ( bHidden )
		return;

	carc = Spawn( MasterReplacement, Self,, Location + CollisionHeight * vect(0,0,0.5) ); 

	if ( carc != None )
	{
		carc.SetLocation( Location );
		carc.Velocity.Z += 400;
		carc.LifeSpan	= 10;
		TrackChunk		= carc;
	}	
}

//=============================================================================
//TrashBone
//Simulates the effect of a limb getting shot off
//=============================================================================
simulated function TrashBone( int Index, name BoneName, bool SpawnGibs )
{
	local carcass carc;
	local vector v;

	GetMeshInstance();

	if ( MeshInstance == None )
		return;
	
	if( BoneName == 'Head' )
		bHeadBlownOff = true;

	TrashedBones[Index] = MeshInstance.BoneFindNamed( BoneName );
	
	TrashedBoneNames[Index] = BoneName;

	v = MeshInstance.BoneGetTranslate( TrashedBones[Index], true, false );
	v = MeshInstance.MeshToWorldLocation( v, false );

	if ( !bSteelSkin && SpawnGibs )
	{
		carc = spawn( TrashBoneChunk1, Self,, v );
		
		if ( FRand() < 0.5 )
			carc = spawn( TrashBoneChunk2, Self,, v );
		else
			carc = spawn( TrashBoneChunk3, Self,, v );
	}

	if ( ImmolationActor != None )
	{
		ImmolationActor.TrashBone( BoneName );
	}
}

//=============================================================================
//ChunkUpExpanded
//Called when the body dies from being expanded.
//=============================================================================
simulated function ChunkUpExpanded()
{
	local SoftParticleSystem	p;
	local int					expandedbone;
	local vector				boneloc;

	GetMeshInstance();

	if ( MeshInstance == None )
		return;

	expandedbone	= MeshInstance.BoneFindNamed( DamageBone );
	boneloc			= MeshInstance.BoneGetTranslate( expandedbone, true, false );
	boneloc			= MeshInstance.MeshToWorldLocation( boneloc );

	TrashBone( 5, DamageBone, false );

	// Play the gib sound.
	GibSound();

	// Create a shower of gibs.
	if ( DrawScale > 0.3 )
		SpawnGibShower( boneloc );

	// Create a blood haze.
	p = spawn( class'dnParticles.dnBloodFX_BloodHaze', Owner, , boneloc );
	
	p.SetOwnerSeeSpecial( true ); // Allow the owner to see the blood
	p.DrawScale			= p.default.DrawScale * (DrawScale / default.DrawScale);
	p.StartDrawScale	= p.default.StartDrawScale * (DrawScale / default.DrawScale);
	p.EndDrawScale		= p.default.EndDrawScale * (DrawScale / default.DrawScale);
	p.DrawScaleVariance = p.default.DrawScaleVariance * (DrawScale / default.DrawScale);

	bBlastedToHell		= true;
}

//=============================================================================
//SpawnHaze
//=============================================================================
simulated function SpawnHaze()
{
	local SoftParticleSystem	p;
	local float					s;

	if ( BloodHazeClass == None )
		return;

	s = DrawScale / default.DrawScale;	

	p = spawn( BloodHazeClass, Owner );

	p.SetOwnerSeeSpecial( true );
	p.DrawScale			= p.default.DrawScale			* s;
	p.StartDrawScale	= p.default.StartDrawScale		* s;
	p.EndDrawScale		= p.default.EndDrawScale		* s;
	p.DrawScaleVariance = p.default.DrawScaleVariance	* s;
}

//=============================================================================
//SpawnBigChunks
//=============================================================================
simulated function SpawnBigChunks()
{
	local SoftParticleSystem	p;
	local float					s;

	if ( BigChunksClass == None )
		return;

	s = DrawScale / default.DrawScale;	

	p = spawn( BigChunksClass, Owner );

	p.SetOwnerSeeSpecial( true );
	p.DrawScale			= p.default.DrawScale			* s;
	p.StartDrawScale	= p.default.StartDrawScale		* s;
	p.EndDrawScale		= p.default.EndDrawScale		* s;
	p.DrawScaleVariance = p.default.DrawScaleVariance	* s;
}

//=============================================================================
//SpawnSmallHazeAndChunks
//=============================================================================
simulated function SpawnSmallHazeAndChunks( optional vector v )
{
	local SoftParticleSystem	p;
	local float                 s;

	s = DrawScale / default.DrawScale;

	if ( SmallBloodHazeClass != None )
	{
		p = spawn( SmallBloodHazeClass, self, , v );
		p.SetOwnerSeeSpecial( true );
		p.DrawScale			= p.default.DrawScale			* s;
		p.StartDrawScale	= p.default.StartDrawScale		* s;
		p.EndDrawScale		= p.default.EndDrawScale		* s;
		p.DrawScaleVariance = p.default.DrawScaleVariance	* s;
	}

	if ( SmallChunksClass != None )
	{
		p = spawn( SmallChunksClass, self, , v );
		p.SetOwnerSeeSpecial( true );
		p.DrawScale			= p.default.DrawScale			* s;
		p.StartDrawScale	= p.default.StartDrawScale		* s;
		p.EndDrawScale		= p.default.EndDrawScale		* s;
		p.DrawScaleVariance = p.default.DrawScaleVariance	* s;
	}
}

//====================================================================
//DoBasicEffects
//Called on the listen server, and on the client.  This spawns basic effects
//for the gibbing.
//====================================================================
simulated function DoBasicEffects()
{
	local SoftParticleSystem	p;

	if ( DrawScale > 0.3 )
	{
		SpawnHaze();
		SpawnBigChunks();	
		GibSound();
		SpawnGibShower( Location );
	}
	else
	{
		SpawnSmallHazeAndChunks( Location );
	}	
}

//====================================================================
//FlyCarcass
//Not simulated because we don't want the client flinging around the 
//carcass.
//====================================================================
function FlyCarcass()
{
	local vector RandDir;

	// Carcass fly!!
	RandDir		= 400 * FRand() * VRand();
	RandDir.Z	= ( FRand()+0.2 );
	Velocity	= ( 0.2 + FRand() ) * ( BlastVelocity + RandDir );
	Velocity	= ( BlastVelocity + RandDir );

	if ( Region.Zone.bWaterZone )
		Velocity *= 0.5;

	SetPhysics( PHYS_Falling );
	bCollideWorld = true;
}

//=================================================================
//MakeTrail - spawn a trail to be attached
//=================================================================
simulated function MakeTrail()
{
	if ( TrailClass!=None )
	{
		TrailReference = Spawn( TrailClass,,NameForString( ""$Tag$"Trail" ) );
		TrailReference.SetPhysics( PHYS_MovingBrush );
		TrailReference.AttachActorToParent( self, true, true );
		TrailReference.MountType=MOUNT_Actor;
		TrailReference.RemoteRole=ROLE_None;
	}
}

//=================================================================
//DoChestLegsSeparation - This may split the carcass into 2 pieces.
//One of the pieces is a chunk, and the other will be the original
//dnCarcass.  No Chunks will be spawned in multiplayer
//=================================================================
simulated function DoChestLegsSeparation( optional vector BlastLocation )
{
    local int				chestbone, pelvisbone;
	local name				bonename;
	local vector			chestloc;
	local bool				BlastChest;
	local HumanMeshChunk	hmc;
	local dnCarcass         subCarcass;

	GetMeshInstance();

	if ( MeshInstance == none )
		return;

	chestbone  = MeshInstance.BoneFindNamed( 'Chest' );
	pelvisbone = MeshInstance.BoneFindNamed( 'Pelvis' );

	// If the blast is above our chest, always blow the top half off.
	chestloc = MeshInstance.BoneGetTranslate( chestbone, true, false );
	chestloc = MeshInstance.MeshToWorldLocation( chestloc );

	if ( BlastLocation.Z > chestloc.Z )
	{
		BlastChest = true;
	}
	else
	{
		if ( FRand() > 0.5 )
		{
			BlastChest = true;
		}
	}

	if ( BlastChest ) // Blast away the chest area
	{		
		// Hide the chest on this carcass
		TrashBone( 5, 'Chest', false );
		
		if ( ( FRand() < 0.2 ) && ( Level.netMode == NM_Standalone ) )		
		{
			hmc = spawn( ChunkClass, self );
			hmc.SetMainTrash( 'Pelvis', 0 ); // Hide the legs on this chunk			
		}
	} 
	else // Blast away the legs
	{
		// Hide the legs on this carcass
		TrashBone( 5, 'Pelvis', false );

		if ( ( FRand() < 0.2 ) && ( Level.NetMode == NM_Standalone ) )		
		{
			// Hide the chest on this chunk
			hmc = spawn( ChunkClass, self );
			hmc.SetMainTrash( 'Chest', 0 ); 
		}
	}
}

//=================================================================================
//ClientChunkUpComplete
//Multicast RPC - All relevant clients will get this function call
//=================================================================================

simulated function ClientChunkUpComplete
	(
	ChunkState		cs, 
	optional vector BlastLocation 
	)
{
	// Only do this stuff on MP clients
	if ( Level.NetMode != NM_Client )
		return;

	ChunkCarcassState = cs;	// Set the new state of the carcass 
	ChunkUpComplete( BlastLocation ); // Chunk it on the client
}

//=================================================================================
//ChunkUpComplete
//Called when the body takes massive damage from a blast or is 
//utterly annihilated. This is called on the client and on listen servers.  
//
//The client will only do the basic effects -  it will not fly the original carcass.
//=================================================================================
simulated function ChunkUpComplete( optional vector BlastLocation, optional bool bFlyCarcass )
{
	local bool					bTotalChunks, BlastChest;
	local float					chestdist, pelvisdist;
	local vector				v, RandDir;
	local SoftParticleSystem	p;
	local name					bonename;

	if ( Level.NetMode != NM_DedicatedServer ) // Don't do effects on dedicated server
	{
		// Always do basic effects
		DoBasicEffects();

		if ( bFlyCarcass )
		{
			FlyCarcass(); // Only on server
		}

		if ( ChunkCarcassState == CHS_ChunkPartial ) // Hit by an explosive blast
		{
			// Send the carcass flying			
			MakeTrail();
			DoChestLegsSeparation( BlastLocation ); 
		}
	}

	// Destroy the carcass if needed
	if ( ChunkCarcassState == CHS_ChunkComplete )
	{		
		// Take this carcass out of play
		SetPhysics(PHYS_None);
		bHidden = true;
		SetCollision( false,false,false );
		bProjTarget = false;	
	}
}		

//================================================================
//ChunkUpMore
//For taking little chunks off.
//================================================================
simulated function ChunkUpMore()
{
	local int					bone, i, j, minigibs;
	local CreatureChunks		chunk;
	local vector				v;
	local SoftParticleSystem	p;
	local name					bonename;

	CumulativeDamage = 0;

	GetMeshInstance();

	if (MeshInstance == none)
		return;

	// Blow up this bone.
	bone		= MeshInstance.BoneFindNamed( DamageBone );
	bonename	= DamageBone;
	
	// Check for damaged bones already
	if ( ( DamageBone == 'Thigh_L') && !bLeftFootTrashed )
		return;
	else if ( ( DamageBone == 'Thigh_R') && !bRightFootTrashed )
		return;
	else if ( ( DamageBone == 'Bicep_L') && !bLeftHandTrashed )
		return;
	else if ( ( DamageBone == 'Bicep_R') && !bRightHandTrashed )
		return;

	if ( bone != 0 )
	{
		for ( i=0; i<5; i++ )
		{
			if ( TrashedBones[i] == 0 )
			{
				// Mark which body part is trashed
				if ( (bone == MeshInstance.BoneFindNamed('Foot_L')) || (bone == MeshInstance.BoneFindNamed('Shin_L')) )
					bLeftFootTrashed = true;
				else if ( (bone == MeshInstance.BoneFindNamed('Foot_R')) || (bone == MeshInstance.BoneFindNamed('Shin_R')) )
					bRightFootTrashed = true;
				else if ( (bone == MeshInstance.BoneFindNamed('Hand_L')) || (bone == MeshInstance.BoneFindNamed('Forearm_L')) )
					bLeftHandTrashed = true;
				else if ( (bone == MeshInstance.BoneFindNamed('Hand_R')) || (bone == MeshInstance.BoneFindNamed('Forearm_R')) )
					bRightHandTrashed = true;

				v = MeshInstance.BoneGetTranslate(bone, true, false);
				v = MeshInstance.MeshToWorldLocation(v, false);

				SpawnSmallHazeAndChunks( v );

				TrashBone( i, bonename, false );
				return;
			}
		}
	}
}

//=============================================================================
//HitEffect
//=============================================================================
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
			BloodHitDecal = class<Actor>( DynamicLoadObject( BloodHitDecalName, class'Class' ) );
		Spawn( BloodHitDecal, Self,, HitLocation + BloodOffset, rotator(Mo) );

		// Blood puff.
		if ( BloodPuffName != "" )
		{
			if ( BloodPuff == None )
				BloodPuff = class<Actor>( DynamicLoadObject(BloodPuffName, class'Class') );
		
			Spawn( BloodPuff,,, HitLocation, rotator(Mo) );
		}

		// Play a gibby sound.
		GibSound = GibbySound[Rand(3)];
		if ( !bNoCreationSounds && (GibSound != None) )
			PlaySound( GibSound, SLOT_Interact, 1.0, false, 800, 0.9+FRand()*0.2 );
	}
}


/*-----------------------------------------------------------------------------
	Bone Manipulation
-----------------------------------------------------------------------------*/

//=============================================================================
//OnEvalBones
//=============================================================================
simulated function bool OnEvalBones(int Channel)
{
	// OnEvalBones should do nothing on a dedicated server.
	if ( Level.NetMode == NM_DedicatedServer )
		return false;
	
	// Perform client-side bone manipulation.
	if( bNoPupils || bSteelSkin )
		EvalNoPupils();

	if ( bEyesShut )
		EvalEyesShut();

	if ( Channel==3 )
	{
		EvalBodyDamage();

		if ( DamageBoneShakeFactor > 0.0 )
			EvalShakeDamageBone();

		if ( bExpanding )
		{
			if ( ExpandTimeRemaining > 0.f )
				EvalExpandedBones();
			else
				EvalExpandedRestore();
		}

		if ( ShrinkCounter > 0.0 )
			EvalShrinkRay();
		
		return true;
	}	
}

//=============================================================================
//EvalBodyDamage
//=============================================================================
simulated function bool EvalBodyDamage()
{
    local int bone, i;

	GetMeshInstance();

	if ( MeshInstance==None )
		return false;

	// Shrink trashed bones to zero.
	for ( i=0; i<6; i++ )
	{
		if ( TrashedBones[i] != 0 )
			MeshInstance.BoneSetScale( TrashedBones[i], vect(0,0,0), true );
	}

	return true;
}

//=============================================================================
//EvalNoPupils
//=============================================================================
simulated function bool EvalNoPupils()
{
	local int bone;
	local MeshInstance minst;
	local rotator r;

	Minst = GetMeshInstance();
	bone = minst.BoneFindNamed('Pupil_L');
	if (bone!=0)
	{			
		minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
	}
	bone = minst.BoneFindNamed('Pupil_R');
	if (bone!=0)
	{
		minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
	}
}

//=============================================================================
//EvalEyesShut
//=============================================================================
simulated function bool EvalEyesShut()
{
	local int bone;
	local vector BlinkEyelidPosition;
	local vector t;

	BlinkEyelidPosition.X = 1.2;
	BlinkEyelidPosition.Y = -0.1;
	BlinkEyelidPosition.Z = 0.0;

	GetMeshInstance();
	if( MeshInstance==None)
		return false;

	bone = MeshInstance.BoneFindNamed( 'Eyelid_L' );
	if( Bone!=0 )
	{
		t = MeshInstance.BoneGetTranslate( bone, false, true );
		t -= BlinkEyelidPosition * 1.0;
		MeshInstance.BoneSetTranslate( bone, t, false );
	}

	bone = MeshInstance.BoneFindNamed( 'Eyelid_R' );
	if( Bone!=0 )
	{
		t = MeshInstance.BoneGetTranslate( bone, false, true );
		t -= BlinkEyelidPosition*1.0;
		MeshInstance.BoneSetTranslate( bone, t, false );
	}
}

//=============================================================================
//EvalShakeDamageBone
//=============================================================================
simulated function bool EvalShakeDamageBone()
{
	local int bone;
	local rotator r;

	if (DamageBone=='None')
		return false;
	GetMeshInstance();
	if (MeshInstance==None)
		return false;

	if (!bDamageBoneShakeInit)
	{
		bone = MeshInstance.BoneFindNamed(DamageBone);
		if (bone!=0)
			DamageBoneShakeBaseRotate = MeshInstance.BoneGetRotate(bone, false);
		DamageBoneShakeAdjustRotate.Pitch = int(FRand()*2000.0);
		DamageBoneShakeAdjustRotate.Yaw = int(FRand()*2000.0);
		bDamageBoneShakeInit = true;
	}
	bone = MeshInstance.BoneFindNamed(DamageBone);
	if (bone!=0)
	{
		r = Slerp(sin((1.0 - DamageBoneShakeFactor)*pi), DamageBoneShakeBaseRotate, DamageBoneShakeBaseRotate+DamageBoneShakeAdjustRotate);
		MeshInstance.BoneSetRotate(bone, r, false);
	}
	return true;
}

//=============================================================================
//EvalExpandedBones
//=============================================================================
simulated function bool EvalExpandedBones()
{
	local int i, bone, footbone, rootbone;
    local MeshInstance minst;
	local vector bonescale, newloc, boneloc, newboneloc, rootloc;
	local bool bSomethingExpanded;
	local float footdelta;

	minst = GetMeshInstance();
    if (minst==None)
        return false;

	for ( i=0; i<6; i++ )
	{
		if ( ExpandedScales[i] > 0.0 )
		{
			// Apply the new scale.
			bone = minst.BoneFindNamed( ExpandedBones[i] );
			bonescale = minst.BoneGetScale( bone, false, false );

			if ( ExpandedScales[i] == 0.3 )
				bonescale *= 1.0 + ExpandedScales[i] + sin(Level.TimeSeconds)/10;
			else
				bonescale *= 1.0 + ExpandedScales[i];
			
			minst.BoneSetScale( bone, bonescale, false );
			
			if ( i != 0 )
				EvalExpandedChildren( minst, bone );
		}
	}
}

//=============================================================================
//EvalExpandedChildren
//=============================================================================
simulated function bool EvalExpandedChildren( MeshInstance minst, int bone )
{
	local int children, j, child, childdir;
	local vector childscale;
	local name childname;

	children = minst.BoneGetChildCount( bone );
	for ( j=0; j<children; j++ )
	{
		child = minst.BoneGetChild( bone, j );
		childname = minst.BoneGetName( child );
		if ( (childname == 'eyelid_l') || (childname == 'eyelid_r') ||
			 (childname == 'pupil_l')  || (childname == 'pupil_r') )
			continue;
		if ( j%2 == 0 )
			childdir = 1;
		else
			childdir = -1;
		childscale = minst.BoneGetScale( child, false, false );
		childscale *= 1.0 - (sin(Level.TimeSeconds+(j*(PI/4)))/5 * childdir);
		minst.BoneSetScale( child, childscale, false );

		EvalExpandedChildren( minst, child );
	}
}

//=============================================================================
//EvalExpandedRestore
//=============================================================================
simulated function bool EvalExpandedRestore()
{
	local int bone, i;
	local float expandfactor, alpha;
	local vector bonescale;
	local MeshInstance minst;

	minst = GetMeshInstance();
    if (minst==None)
        return false;

	for ( i=0; i<6; i++ )
	{
		if ( ExpandedScales[i] > 0.0 )
		{
			// Get the un expando scaled foot location.
			if ( i == 0 )
			{
//				footbone = minst.BoneFindNamed( 'foot_l' );
//				boneloc = minst.BoneGetTranslate( footbone, true, false );
//				boneloc = minst.MeshToWorldLocation( boneloc );
			}

			// Get the bone.
			bone = minst.BoneFindNamed( ExpandedBones[i] );

			// Get the current scale.
			bonescale = minst.BoneGetScale( bone, false, false );

			// Find and set the alpha to restore.
			if ( ExpandedScales[i] == 0.3 )
				expandfactor = ExpandedScales[i] + sin(ExpandTimeEnd)/10;
			else
				expandfactor = ExpandedScales[i];
			alpha = FClamp( (Level.TimeSeconds - ExpandTimeEnd) / 3.0, 0.0, 1.0 );
			expandfactor = Lerp( alpha, expandfactor, 0.0 );
			bonescale *= 1.0 + expandfactor;
			minst.BoneSetScale( bone, bonescale, false );

			// Restore warped children.
			if ( i != 0 )
				EvalExpandedChildrenRestore( minst, bone, alpha );

			if ( alpha == 1.f )
				bExpanding = false;
		}
	}
}

//=============================================================================
//EvalExpandedChildrenRestore
//=============================================================================
simulated function bool EvalExpandedChildrenRestore( MeshInstance minst, int bone, float alpha )
{
	local int children, j, child, childdir;
	local vector childscale;
	local name childname;
	local float expandfactor;

	children = minst.BoneGetChildCount( bone );
	for ( j=0; j<children; j++ )
	{
		child = minst.BoneGetChild( bone, j );
		childname = minst.BoneGetName( child );
		if ( (childname == 'eyelid_l') || (childname == 'eyelid_r') ||
			 (childname == 'pupil_l')  || (childname == 'pupil_r') )
			continue;
		if ( j%2 == 0 )
			childdir = 1;
		else
			childdir = -1;
		childscale = minst.BoneGetScale( child, false, false );
		expandfactor = (sin(ExpandTimeEnd+(j*(PI/4)))/5 * childdir);
		expandfactor = Lerp( alpha, expandfactor, 0.0 );
		childscale *= 1.0 - expandfactor;
		minst.BoneSetScale( child, childscale, false );

		EvalExpandedChildrenRestore( minst, child, alpha );
	}
}

//=============================================================================
//Shrunken
//=============================================================================
simulated function bool Shrunken()
{
	if ( ShrinkCounter > 0.0 )
		return true;
	else
		return false;
}

//=============================================================================
//EvalShrinkRay
//=============================================================================
simulated function bool EvalShrinkRay()
{
    local MeshInstance minst;
	local int bone, footbone, rootbone, pelvisbone;
	local vector s, footboneloc, pelvisboneloc, newboneloc, rootloc, ResizeLoc, pelvisbonedelta;
	local float ShrinkAmount, ArmScale, HeadScale, LegScale, ChestScale, RootScale, footdelta, SegmentTime;

	if ( Shrunken() && (DrawScale == 0.25) )
		return true;

	// Do nothing if unshrunken.
	if ( ShrinkCounter == 0.f )
		return true;

    minst = GetMeshInstance();
    if ( minst == None )
        return false;

	// 4 segments: Arms, head, root, legs.
	SegmentTime = class'Pawn'.default.ShrinkTime / 4;

	// Get the foot location before shrinking.
	if ( ShrinkCounter > SegmentTime*2 )
	{
		footbone = minst.BoneFindNamed( 'foot_l' );
		footboneloc = minst.BoneGetTranslate( footbone, true, false );
		footboneloc = minst.MeshToWorldLocation( footboneloc );
	}

	// Get the head location before shrinking.
	if ( ShrinkCounter > SegmentTime*2 )
	{
		pelvisbone = minst.BoneFindNamed( 'pelvis' );
		pelvisboneloc = minst.BoneGetTranslate( pelvisbone, true, false );
		pelvisboneloc = minst.MeshToWorldLocation( pelvisboneloc );
	}

	ShrinkAmount = ShrinkCounter;
	if ( ShrinkCounter < SegmentTime )
		HeadScale = 1.0 - ((ShrinkAmount/SegmentTime) * 0.75);
	else
		HeadScale = 0.25;

	ShrinkAmount -= SegmentTime;
	if ( (ShrinkCounter < SegmentTime*2) && (ShrinkCounter > SegmentTime) )
		ArmScale = 1.0 - ((ShrinkAmount/SegmentTime) * 0.75);
	else if ( ShrinkCounter >= SegmentTime*2 )
		ArmScale = 0.25;
	else
		ArmScale = 1.0;

	ShrinkAmount -= SegmentTime;
	if ( (ShrinkCounter < SegmentTime*3) && (ShrinkCounter > SegmentTime*2) )
		RootScale = 1.0 - ((ShrinkAmount/SegmentTime) * 0.75);
	else if ( ShrinkCounter >= SegmentTime*3 )
		RootScale = 0.25;
	else
		RootScale = 1.0;
	ArmScale  *= 1.0 / RootScale;
	HeadScale *= 1.0 / RootScale;

	ShrinkAmount -= SegmentTime;
	if ( (ShrinkCounter < SegmentTime*4) && (ShrinkCounter > SegmentTime*3) )
		LegScale = 1.0 - ((ShrinkAmount/SegmentTime) * 0.75);
	else if ( ShrinkCounter >= SegmentTime*4 )
		LegScale = 0.25;
	else
		LegScale = 1.0;
	LegScale *= 1.0 / RootScale;

	// Shrink Head
	bone = minst.BoneFindNamed('Head');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= HeadScale;
		minst.BoneSetScale( bone, s, false );
	}

	// Shrink Arms
	bone = minst.BoneFindNamed('Bicep_L');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= ArmScale;
		minst.BoneSetScale( bone, s, false );
	}
	bone = minst.BoneFindNamed('Bicep_R');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= ArmScale;
		minst.BoneSetScale( bone, s, false );
	}

	// Shrink Root
	bone = minst.BoneFindNamed('Root');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= RootScale;
		minst.BoneSetScale( bone, s, false );

	}

	// Shrink Leg
	bone = minst.BoneFindNamed('Thigh_L');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= LegScale;
		minst.BoneSetScale( bone, s, false );
	}
	bone = minst.BoneFindNamed('Thigh_R');
	if ( bone != 0 )
	{
		s = minst.BoneGetScale( bone, false, true );
		s *= LegScale;
		minst.BoneSetScale( bone, s, false );
	}

	// If we changed the root, the mesh will drift.
	// This isn't perfect, you have to set the drawscale to 0.25 at the end
	// otherwise you see the problems given the current leg animation.
	if ( ShrinkCounter > SegmentTime*2 )
	{
		// Get pelvis difference without z and modify prepivot.
		// This corrects non-z drift.
		newboneloc = minst.BoneGetTranslate( pelvisbone, true, false );
		newboneloc = minst.MeshToWorldLocation( newboneloc );
		pelvisbonedelta = newboneloc - pelvisboneloc;
		pelvisbonedelta.z = 0;
		PrePivot = -pelvisbonedelta;

		// Adjust prepivot a bit more to account for change in distance from shoe bottom to foot bone.
		// This just looks nicer.
		PrePivot.z -= 5.0 * (1.0 - (((LegScale*RootScale) - 0.25) / 0.75));

		// Get current foot location change in z.
		// This will correct from drift due to shrunken legs that shrink towards the root.
		newboneloc = minst.BoneGetTranslate( footbone, true, false );
		newboneloc = minst.MeshToWorldLocation( newboneloc );
		footdelta = newboneloc.z - footboneloc.z;

		// Get root bone location.
		rootbone = minst.BoneFindNamed( 'root' );
		rootloc = minst.BoneGetTranslate( rootbone, true, false );

		// Apply the mods and set the new location.
		rootloc.z -= footdelta;
		minst.BoneSetTranslate( rootbone, rootloc, true );

	}

	return true;
}

/*-----------------------------------------------------------------------------
	Timing
-----------------------------------------------------------------------------*/

//=============================================================================
//Tick
//=============================================================================
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	bDamageProtect = false;

    // Shake the bones! (Need a cooler effect than this.)
	if ( DamageBoneShakeFactor > 0.0 )
	{
		DamageBoneShakeFactor -= DeltaTime*4.0;
		if ( DamageBoneShakeFactor < 0.0 )
			DamageBoneShakeFactor = 0.0;
	}

    // Stop suffering...
	if ( bStopSuffering && bSuffering )
	{
		if ( AnimSequence == 'A_Suffer_RLeg' )
		{
			PlayAnim( 'A_Suffer_RLegDie', 1.0, 0.2 );
			bSuffering = false;
			bEyesShut  = true;
		}
		else if ( AnimSequence == 'A_Suffer_Chest' )
		{
			PlayAnim( 'A_Suffer_ChestDie', 1.0, 0.2 );
			bSuffering = false;
			bEyesShut  = true;
		}
	}
}

//=============================================================================
//Timer
//=============================================================================
function Timer(optional int TimerNum)
{
	local bool bSeen;
	local Pawn aPawn;
	local float dist;

	// Suffer timer.
	if ( TimerNum == 2 )
	{
		// Stop suffering.
		if ( bSuffering )
			bStopSuffering = true;
		return; 
	}

	// Reset the chunk carcass state on the server
    if ( TimerNum == 3 )
    {
        OldChunkCarcassState = ChunkCarcassState;
    }

	// Check to see if we should be destroyed.
	if ( bHidden )
	{
		Destroy();
	}
	else if ( Region.Zone.NumCarcasses > Region.Zone.MaxCarcasses )
	{
		if ( !PlayerCanSeeMe() && !bSearchable )
			Destroy();
		else
			SetTimer( 2.0, false );
	}
	else
	{
		SetTimer( 2.0, false );
	}
}


/*-----------------------------------------------------------------------------
	Physics
-----------------------------------------------------------------------------*/

//=============================================================================
//Landed
//=============================================================================
simulated function Landed(vector HitNormal)
{
	local rotator FinalRot;

    if ( TrailReference != None )
    	TrailReference.Trigger(Self,Self.Instigator);

	if ( Velocity.Z < -1000 )
	{
		ChunkUpComplete();
		return;
	}
	if( ( !bSliding ) && ( AnimSequence == 'A_FlyAir_B' || AnimSequence == 'A_FlyAir_F' ) )
	{
		PrePivot.Y = Default.PrePivot.Y;
		PlayAnim( 'A_Death_FallOnGround', 1.0, 0.2 );
	}

	FinalRot		= Rotation;
	FinalRot.Roll	= 0;
	FinalRot.Pitch	= 0;
	SetRotation( FinalRot );
	SetPhysics( PHYS_None );
	SetCollision( bCollideActors, false, false );
	
	if ( !IsAnimating() )
		LieStill();
}

//=============================================================================
//HitWall
//=============================================================================
simulated function HitWall(vector HitNormal, actor Wall)
{
	Velocity	= 0.7 * ( Velocity - 2 * HitNormal * ( Velocity Dot HitNormal ) );
	Velocity.Z *= 0.9;

	if( AnimSequence == 'A_FlyAir_F' || AnimSequence == 'A_FlyAir_B' )
	{
		SetPhysics( PHYS_Falling );
		
		if ( Velocity.Z > 0 )
			Velocity.Z = -96;

		if ( AnimSequence == 'A_FlyAir_B' )
		{
			PlayAnim( 'A_Death_HitWall1', 1.0, 0.1 );
		}
		else
		{
			PlayAnim( 'A_Death_HitWall_F', 1.0, 0.1 );
		}

		PrePivot.Y = -8;
		bSliding = true;
		Disable( 'HitWall' );
	}

	if ( Abs(Velocity.Z) < 120 )
	{
		bBounce = false;
		Disable( 'HitWall' );
	}
}


/*-----------------------------------------------------------------------------
	Animation
-----------------------------------------------------------------------------*/

//=============================================================================
//AnimEnd
//=============================================================================
simulated function AnimEnd()
{
	// If we are not lying still, do so.
	if ( !bLyingStill )
	{
		if ( Physics == PHYS_None )
		{
			LieStill();
		}
		else if ( Region.Zone.bWaterZone )
		{
			bThumped = true;
			LieStill();
		}
		bLyingStill = true;
	}

	// If we are suffering, continue the animation.
	if ( AnimSequence == 'A_Suffer_ChestFall' )
	{
		if ( !bLostHead )
		{
			bSuffering = true;
			SetTimer( 10.0 + FRand()*5.0, false, 2 );
			FinishAnim( 0 );
			LoopAnim( 'A_Suffer_Chest', 1.0, 0.2 );
		}
		else 
		{ 
			PlayAnim( 'A_Suffer_ChestDie', 1.0, 0.2 );
			if ( FRand() < 0.8 )
				bEyesShut = true;
		}
	}
	else if ( AnimSequence == 'A_Suffer_RLegFall' )
	{
		if ( !bLostHead )
		{
			bSuffering = true;
			SetTimer( 10.0 + FRand()*5.0, false, 2 );
			FinishAnim( 0 );
			LoopAnim( 'A_Suffer_RLeg', 1.0, 0.2 );
		} 
		else
		{ 
			PlayAnim( 'A_Suffer_RLegDie', 1.0, 0.2 );
			if ( FRand() < 0.8 )
				bEyesShut = true;
		}
	}
}

//=============================================================================
//LieStill
//=============================================================================
function LieStill()
{
    local int bone;
	local vector newloc, v;
	local float OldCollisionHeight;

	GetMeshInstance();

	if ( MeshInstance == none )
		return;

	// Adjust the corpse so that it is centered in its collision cylinder.
	bCollideWorld = false;

	// Get the abdomen's location, ignore Z.
    bone	= MeshInstance.BoneFindNamed('Shin_L');
	v		= MeshInstance.BoneGetTranslate(bone, true, false);
	v		= MeshInstance.MeshToWorldLocation(v);
	v		= Location - v;
	v.z		= 0;

	// Offset the prepivot by the abdomen's location.
	PrePivot += v;

	// Adjust our collision width to the previous height.
	OldCollisionHeight = CollisionHeight;
	SetCollisionSize( CollisionHeight + CollisionHeight*0.25, 10 );
	
	FixCollisionRadius();

	// Adjust the location for the change.
	newloc		= Location;
	newloc.Z	-= OldCollisionHeight - 10;
	newloc		-= v;
	SetLocation( newloc );

	// Play a landed sound.
	if ( !bThumped && !bDecorative )
		LandThump();
}

//=============================================================================
//LandThump
//=============================================================================
simulated function LandThump()
{
	local float impact;

	if ( Physics == PHYS_None )
	{
		bThumped = true;
		if ( Role == ROLE_Authority )
		{
			impact = 0.75 + Velocity.Z * 0.004;
			impact = Mass * impact * impact * 0.015;
			PlayOwnedSound( LandedSound,, impact );
		}
	}
}

defaultproperties
{
	//PrePivot=(X=0.000000,Y=0.000000,Z=-40.000000)
	bUpdateSimAnim=true   // Force update animation to the client
	CollisionHeight=13.0
	CollisionRadius=27.0
	bBlockActors=false
	bBlockPlayers=false
	bSlidingCarcass=true
	TransientSoundVolume=3.000000
	NetPriority=+2.50000
	RemoteRole=ROLE_SimulatedProxy
	LandedSound=sound'a_impact.gib.bthump1'
	GibSounds(0)=Sound'a_impact.gib.biggib1'
	GibSounds(1)=Sound'a_impact.gib.biggib2'
	GibSounds(2)=Sound'a_impact.gib.biggib3'
	GibSounds(3)=Sound'a_impact.gib.biggib1'
	GibbySound(0)=sound'a_impact.body.ImpactBody15a'
	GibbySound(1)=sound'a_impact.body.ImpactBody18a'
	GibbySound(2)=sound'a_impact.body.ImpactBody19a'
	bForceCollisionRep=true
	TrailClass=Class'dnParticles.dnBloodFX_BloodTrail'
	//bAlwaysRelevant=true
	HitPackageClass=class'HitPackage_Flesh'	
	BigChunksClass=class'dnParticles.dnBloodFX_BloodChunks'
	BloodHazeClass=class'dnParticles.dnBloodFX_BloodHaze'
	SmallChunksClass=class'dnParticles.dnBloodFX_BloodChunksSmall'
	SmallBloodHazeClass=class'dnParticles.dnBloodFX_BloodHazeSmall'		
	ChunkClass=class'HumanMeshChunk'
	TrashBoneChunk1=class'Chunk_FleshC'
	TrashBoneChunk2=class'Chunk_FleshB'
	TrashBoneChunk3=class'Chunk_FleshA'
}