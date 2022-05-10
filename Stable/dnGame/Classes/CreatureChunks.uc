/*-----------------------------------------------------------------------------
	CreateChunks
	Author: Steve Polge
-----------------------------------------------------------------------------*/
class CreatureChunks extends Carcass;

#exec OBJ LOAD FILE=..\meshes\c_FX.dmx
#exec OBJ LOAD FILE=..\sounds\a_impact.dfx

var		Sound						HitSounds[4];
var		actor 						TrailReference; // Internal Spawned Trail Reference
var()   class<SoftParticleSystem>	TrailClass;		// Class of the trail to mount, or none.
var		class<dnBloodSplat>			bloodSplatClass;

replication
{
}

/*-----------------------------------------------------------------------------
	Initialization & Object Methods
-----------------------------------------------------------------------------*/

simulated function BeginPlay()
{
	if ( Region.Zone.bDestructive || ((Level.NetMode == NM_Standalone) && class'GameInfo'.Default.bLowGore) )
	{
		Destroy();
		return;
	}

	Super.BeginPlay();
}

simulated function PostBeginPlay()
{
	// Only initialize for the owner if we have one.
	// This is so that unowned decorative corpses aren't initialized.
	if ( RenderActor(Owner) != None )
		InitFor( RenderActor(Owner) );
}


simulated function InitFor( RenderActor Other )
{
	if ( Other.IsA('Carcass') )
	{
		BlastVelocity = Carcass(Other).BlastVelocity;
	}
	SetCollision(false,false,false);
	bProjTarget = false;
	bDecorative = false;
	DrawScale = Other.DrawScale;
	if ( DrawScale != 1.0 )
		SetCollisionSize(CollisionRadius * 0.5 * (1 + DrawScale), CollisionHeight * 0.5 * (1 + DrawScale));
	RotationRate.Yaw = Rand(200000) - 100000;
	RotationRate.Pitch = Rand(200000 - Abs(RotationRate.Yaw)) - 0.5 * (200000 - Abs(RotationRate.Yaw));
	InitVelocity(Other);

	// Mount blood trails - CTW
	if (TrailClass!=None) {
		TrailReference=Spawn(TrailClass,,NameForString(""$Tag$"Trail"));
		TrailReference.SetPhysics(PHYS_MovingBrush);
		TrailReference.AttachActorToParent(self,true,true);
		TrailReference.MountType=MOUNT_Actor;
		TrailReference.DrawScale = TrailReference.default.DrawScale * (DrawScale / default.DrawScale);
		if ( (Owner.Owner != None) && Owner.Owner.IsA('PlayerPawn') && TrailReference.IsA('SoftParticleSystem') )
		{
			SoftParticleSystem(TrailReference).SetOwner( Owner.Owner );
			SoftParticleSystem(TrailReference).SetOwnerNoSee( true );
			SoftParticleSystem(TrailReference).StartDrawScale = SoftParticleSystem(TrailReference).default.StartDrawScale * (DrawScale / default.DrawScale);
			SoftParticleSystem(TrailReference).EndDrawScale = SoftParticleSystem(TrailReference).default.EndDrawScale * (DrawScale / default.DrawScale);
			SoftParticleSystem(TrailReference).DrawScaleVariance = SoftParticleSystem(TrailReference).default.DrawScaleVariance * (DrawScale / default.DrawScale);
//			BroadcastMessage(SoftParticleSystem(TrailReference).StartDrawScale@SoftParticleSystem(TrailReference).default.StartDrawScale);
		}
	}

	if ( FRand() < 0.3 )
		Buoyancy = 1.06 * Mass; // float corpse
	else
		Buoyancy = 0.94 * Mass;

	SetTimer(1.0, false, 1);
	SetTimer(5.0, false, 2);
}

simulated function InitVelocity(Actor Other)
{
	local vector RandDir;

	RandDir = 400 * FRand() * VRand();
	RandDir.Z = 400 * FRand() - 50;
	if (Other.bIsPawn)
		Velocity = (0.2 + FRand()) * (other.Velocity + RandDir);
	else if (Other.IsA('Carcass'))
		Velocity = (0.2 + FRand()) * (BlastVelocity + RandDir);
	if (Region.Zone.bWaterZone)
		Velocity *= 0.5;
}

simulated function bool IsChunk()
{
	return true;
}

/*-----------------------------------------------------------------------------
	Timing
-----------------------------------------------------------------------------*/

simulated function Timer(optional int TimerNum)
{
	local bool bSeen;
	local Pawn aPawn;
	local float dist;

	if (TimerNum == 1)
	{
		SetCollision(true, false, false);
		return;
	}

	if (TimerNum == 2)
	{
		if ( !Level.bDropDetail && (Region.Zone.NumCarcasses > Region.Zone.MaxCarcasses) )
		{
			if ( !PlayerCanSeeMe() )
				Destroy();
			else
				SetTimer(2.0, false, 2);	
		}
		else
			Destroy();
	}
}

simulated function ClientExtraChunks();

simulated function ZoneChange( ZoneInfo NewZone )
{
	local float splashsize;
	local actor splash;

	if ( NewZone.bWaterZone )
	{
		if ( Mass <= Buoyancy )
			SetCollisionSize(0,0);
		if ( bSplash && !Region.Zone.bWaterZone && (Abs(Velocity.Z) < 80) )
			RotationRate *= 0.6;
		else if ( !Region.Zone.bWaterZone && (Velocity.Z < -200) )
		{
			// else play a splash
			splashSize = FClamp(0.0001 * Mass * (250 - 0.5 * FMax(-600,Velocity.Z)), 1.0, 2.0 );
			if ( NewZone.EntrySound != None )
				PlayOwnedSound(NewZone.EntrySound, SLOT_Interact, splashSize);
			if ( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor); 
				if ( splash != None )
					splash.DrawScale = splashSize;
			}
		}
		bSplash = true;
	}

	if ( NewZone.bDestructive || (NewZone.DOT_Type != DOT_None) )
		Destroy();
}

function ChunkUp(int Damage)
{
	local dnbloodhit hit;

	hit = spawn(class'dnBloodHit',,,,rot(16384,0,0));
	hit.DrawScale = hit.default.DrawScale * (DrawScale / default.DrawScale);

	Destroy();
}

simulated function Landed(vector HitNormal)
{
	local rotator finalRot;
	local dnBloodHit b;
	local actor a;
	local dnDecal_Delayed splat;

	finalRot = Rotation;
	finalRot.Roll = 0;
	finalRot.Pitch = 0;
	SetRotation(finalRot);
	if ( (Level.NetMode != NM_DedicatedServer) && !Level.bDropDetail )
	{
		if ( bloodSplatClass != None )
			splat = Spawn( bloodSplatClass,,,Location,rotator( HitNormal ) );

		splat.DrawScale = splat.default.DrawScale * (DrawScale / default.DrawScale);
		splat.Initialize();
	}
	SetPhysics(PHYS_None);
	if ( TrailReference != None )
		TrailReference.Trigger( Self, Self.Instigator );
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	local float speed, decision;
	local dnBloodHit b;
	local actor a;
	local dnDecal_Delayed splat;

	Velocity = 0.6 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	Velocity.Z = FMin(Velocity.Z * 0.4, 700);
	speed = VSize(Velocity);
	if ( speed <= 120 )
	{
		PlayAnim('land');
		bBounce = false;
		Disable('HitWall');
		TrailReference.Trigger(Self,Self.Instigator);
	}
	else if ( speed > 120 )
	{
		if ( speed > 700 )
			velocity *= 0.8;
		if (  (Level.NetMode != NM_DedicatedServer) && Level.bHighDetailMode && !Level.bDropDetail
			&& (LifeSpan < 19.3) )
			PlayOwnedSound(HitSounds[Rand(4)],,12);
	}
	if ( (Level.NetMode != NM_DedicatedServer) && !Level.bDropDetail )
	{
		if ( bloodSplatClass != None )		
			splat = Spawn( bloodSplatClass,,,Location,rotator(HitNormal));

		splat.DrawScale = splat.default.DrawScale * (DrawScale / default.DrawScale);
		splat.Initialize();
	}
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation, 
						Vector Momentum, class<DamageType> DamageType)
{
	SetPhysics(PHYS_Falling);
	bBobbing = false;
	Velocity += momentum/Mass;
	CumulativeDamage += Damage;
	if ( Damage > FMin(15, Mass) || (CumulativeDamage > Mass) )
		ChunkUp(Damage);
}

defaultproperties
{
	RemoteRole=ROLE_None
	LifeSpan=20.000000
	Mesh=DukeMesh'c_FX.Gib_FleshA'
	bCollideActors=false
	bBounce=true
	bFixedRotationDir=true
	bNetTemporary=true
	Mass=90.000000
	Buoyancy=27.000000
	RotationRate=(Pitch=30000,Roll=30000)
	HitSounds(0)=sound'a_impact.gib.gibP1' 
	HitSounds(1)=sound'a_impact.gib.gibP4' 
	HitSounds(2)=sound'a_impact.gib.gibP5' 
	HitSounds(3)=sound'a_impact.gib.gibP6'
	bBloodPool=false
	HitPackageClass=class'HitPackage_Flesh'
	bloodSplatClass=class'dnBloodSplat'
}
