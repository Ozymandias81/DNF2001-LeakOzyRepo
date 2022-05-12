//=============================================================================
// UTCreatureChunks.
//=============================================================================
class UTCreatureChunks extends Carcass;

var		UT_Bloodtrail		trail;
var		float			TrailSize;
var		bool			bGreenBlood;
var		class<UTHumanCarcass>	CarcassClass;
var		name			CarcassAnim;	   	
var		Vector			CarcLocation;
var		float			CarcHeight;
var		Sound	HitSounds[4];

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		bGreenBlood, CarcassClass, CarcassAnim, CarcLocation, CarcHeight;
}

simulated function BeginPlay()
{
	if ( Region.Zone.bDestructive 
		|| ((Level.NetMode == NM_Standalone) && class'GameInfo'.Default.bLowGore) )
	{
		Destroy();
		return;
	}

	Super.BeginPlay();
}

simulated function ClientExtraChunks()
{
	local UT_BloodBurst b;

	If ( Level.NetMode == NM_DedicatedServer )
		return;

	b = Spawn(class 'UT_BloodBurst',,,,rot(16384,0,0));
	if ( bGreenBlood )
		b.GreenBlood();
	b.RemoteRole = ROLE_None;
}

simulated function ZoneChange( ZoneInfo NewZone )
{
	local float splashsize;
	local actor splash;

	if ( NewZone.bWaterZone )
	{
		if ( trail != None )
		{
			if ( Level.bHighDetailMode && !Level.bDropDetail )
				bUnlit = false;
			trail.Destroy();
		}
		if ( Mass <= Buoyancy )
			SetCollisionSize(0,0);
		if ( bSplash && !Region.Zone.bWaterZone && (Abs(Velocity.Z) < 80) )
			RotationRate *= 0.6;
		else if ( !Region.Zone.bWaterZone && (Velocity.Z < -200) )
		{
			// else play a splash
			splashSize = FClamp(0.0001 * Mass * (250 - 0.5 * FMax(-600,Velocity.Z)), 1.0, 2.0 );
			if ( NewZone.EntrySound != None )
				PlaySound(NewZone.EntrySound, SLOT_Interact, splashSize);
			if ( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor); 
				if ( splash != None )
					splash.DrawScale = splashSize;
			}
		}
		bSplash = true;
	}

	if ( NewZone.bDestructive || (NewZone.bPainZone  && (NewZone.DamagePerSec > 0)) )
		Destroy();
}
	
simulated function Destroyed()
{
	if ( trail != None )
		trail.Destroy();
	Super.Destroyed();
}

function InitVelocity(Actor Other)
{
	local vector RandDir;

	RandDir = 700 * FRand() * VRand();
	RandDir.Z = 200 * FRand() - 50;
	Velocity = (0.2 + FRand()) * (other.Velocity + RandDir);
	If (Region.Zone.bWaterZone)
		Velocity *= 0.5;
}

function Initfor(actor Other)
{
	if ( Other.IsA('Carcass') )
		PlayerOwner = Carcass(Other).PlayerOwner;
	bDecorative = false;
	DrawScale = Other.DrawScale;
	if ( DrawScale != 1.0 )
		SetCollisionSize(CollisionRadius * 0.5 * (1 + DrawScale), CollisionHeight * 0.5 * (1 + DrawScale));
	RotationRate.Yaw = Rand(200000) - 100000;
	RotationRate.Pitch = Rand(200000 - Abs(RotationRate.Yaw)) - 0.5 * (200000 - Abs(RotationRate.Yaw));
	InitVelocity(Other);
	if ( TrailSize > 0 )
	{
		if ( UTHumanCarcass(Other) != None )
			bGreenBlood = UTHumanCarcass(Other).bGreenBlood;
		else if ( (UTCreatureChunks(Other) != None) )
			bGreenBlood = UTCreatureChunks(Other).bGreenBlood;
	}
			
	if ( FRand() < 0.3 )
		Buoyancy = 1.06 * Mass; // float corpse
	else
		Buoyancy = 0.94 * Mass;
}

function ChunkUp(int Damage)
{
	local UT_BloodBurst b;

	if (bHidden)
		return;
	b = Spawn(class 'UT_BloodBurst',,,,rot(16384,0,0));
	if ( bGreenBlood )		
		b.GreenBlood();	
	if (bPlayerCarcass)
	{
		bHidden = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		bProjTarget = false;
		if ( Trail != None )
			Trail.Destroy();
	}
	else
		destroy();
}

simulated function Landed(vector HitNormal)
{
	local rotator finalRot;
	local UT_BloodBurst b;
	local actor a;

	if ( trail != None )
	{
		if ( Level.bHighDetailMode && !Level.bDropDetail )
			bUnlit = false;
		trail.Destroy();
		trail = None;
	}
	finalRot = Rotation;
	finalRot.Roll = 0;
	finalRot.Pitch = 0;
	setRotation(finalRot);
	if ( (Level.NetMode != NM_DedicatedServer) && !Level.bDropDetail )
	{
		b = Spawn(class 'UT_BloodBurst',,,,rot(0,0,0));
		if ( bGreenBlood )
			b.GreenBlood();		
		b.RemoteRole = ROLE_None;
		if ( !bGreenBlood )
			Spawn(class'BloodSplat',,,Location,rotator(HitNormal));
	}
	SetPhysics(PHYS_None);
	SetCollision(true, false, false);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	local float speed, decision;
	local UT_BloodBurst b;
	local actor a;

	Velocity = 0.8 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	Velocity.Z = FMin(Velocity.Z * 0.8, 700);
	speed = VSize(Velocity);
	if ( speed < 350 )
	{
		if ( trail != None )
		{
			if ( Level.bHighDetailMode && !Level.bDropDetail )
				bUnlit = false;
			trail.Destroy();
			trail = None;
		}
		if ( speed < 120 )
		{
			bBounce = false;
			Disable('HitWall');
		}
	}
	else if ( speed > 150 )
	{
		if ( speed > 700 )
			velocity *= 0.8;
		if (  (Level.NetMode != NM_DedicatedServer) && Level.bHighDetailMode && !Level.bDropDetail
			&& (LifeSpan < 19.3) )
			PlaySound(HitSounds[Rand(4)],,12);
	}
	if ( (Level.NetMode != NM_DedicatedServer) )
	{
		if ( (trail == None) && !Level.bDropDetail )
		{ 
			b = Spawn(class 'UT_BloodBurst',,,,Rot(0,0,0));
			if ( bGreenBlood )
				b.GreenBlood();		
			b.RemoteRole = ROLE_None;
		}
		if ( !bGreenBlood && (!Level.bDropDetail || (FRand() < 0.65)) )
			Spawn(class'BloodSplat',,,Location,rotator(HitNormal));
	}
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, name damageType)
{
	SetPhysics(PHYS_Falling);
	bBobbing = false;
	Velocity += momentum/Mass;
	CumulativeDamage += Damage;
	If ( Damage > FMin(15, Mass) || (CumulativeDamage > Mass) )
		ChunkUp(Damage);
}
			
auto state Dying
{
	ignores TakeDamage;

Begin:
	if ( bDecorative )
		SetPhysics(PHYS_None);
	else if ( (TrailSize > 0) && !Region.Zone.bWaterZone )
	{
		trail = Spawn(class'UT_BloodTrail',self);
		if ( bGreenBlood )
			trail.GreenBlood();
	}
	Sleep(0.35);
	SetCollision(true, false, false);
	GotoState('Dead');
}	

state Dead 
{
	function Timer()
	{
		local bool bSeen;
		local Pawn aPawn;
		local float dist;

		if ( !Level.bDropDetail && (Region.Zone.NumCarcasses <= Region.Zone.MaxCarcasses) )
		{
			if ( !PlayerCanSeeMe() )
				Destroy();
			else
				SetTimer(2.0, false);	
		}
		else
			Destroy();
	}

	function BeginState()
	{
		if ( bDecorative )
			lifespan = 0.0;
		else
			SetTimer(5.0, false);
	}
}

defaultproperties
{
     TrailSize=3.000000
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=20.000000
     Mesh=Mesh'UnrealShare.CowBody1'
     bCollideActors=False
     bBounce=True
     bFixedRotationDir=True
	 bUnlit=True
	 bNetTemporary=true
     Mass=90.000000
     Buoyancy=27.000000
     RotationRate=(Pitch=30000,Roll=30000)
	 HitSounds(0)=sound'UnrealShare.Gibs.gibP1' 
	 HitSounds(1)=sound'UnrealShare.Gibs.gibP4' 
	 HitSounds(2)=sound'UnrealShare.Gibs.gibP5' 
	 HitSounds(3)=sound'UnrealShare.Gibs.gibP6' 
}
