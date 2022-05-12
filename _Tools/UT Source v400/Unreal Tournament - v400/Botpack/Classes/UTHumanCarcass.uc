//=============================================================================
// UTHumanCarcass.
//=============================================================================
class UTHumanCarcass extends Carcass
	abstract;

#exec AUDIO IMPORT FILE="Sounds\Male\gib01.WAV" NAME="NewGib" GROUP="Male"

var class<UTMasterCreatureChunk> MasterReplacement;
var() bool bGreenBlood;
var	  bool bThumped;
var	  bool bPermanent;
var	  bool bCorroding;
var   ZoneInfo DeathZone;
var	  float	ReducedHeightFactor;
var   float ExistTime;
var() sound LandedSound;
var() sound GibSounds[4];
var Decal Pool;

function PostBeginPlay()
{
	if ( !bDecorative )
	{
		DeathZone = Region.Zone;
		DeathZone.NumCarcasses++;
	}
	Super.PostBeginPlay();
	if ( Physics == PHYS_None )
		SetCollision(bCollideActors, false, false);
}

function GibSound()
{
	local int r;

	r = Rand(4);
	PlaySound(GibSounds[r], SLOT_Interact, 16);
	PlaySound(GibSounds[r], SLOT_Misc, 12);
}

simulated function Destroyed()
{
	if ( Pool != None )
		Pool.Destroy();
	if ( !bDecorative )
		DeathZone.NumCarcasses--;
	Super.Destroyed();
}

function CreateReplacement()
{
	local UTMasterCreatureChunk carc;
	local UT_BloodBurst b;
	
	if (bHidden)
		return;

	b = Spawn(class'UT_BigBloodHit',,,Location, rot(-16384,0,0));
	if ( bGreenBlood )
		b.GreenBlood();		

	carc = Spawn(MasterReplacement,,, Location + CollisionHeight * vect(0,0,0.5)); 
	if (carc != None)
	{
		carc.PlayerRep = PlayerOwner;
		carc.Initfor(self);
		carc.Bugs = Bugs;
		if ( Bugs != None )
			Bugs.SetBase(carc);
		Bugs = None;
	}
	else if ( Bugs != None )
		Bugs.Destroy();
}

function SpawnHead()
{
}

function Initfor(actor Other)
{
	local int i;
	local rotator carcRotation;

	PlayerOwner = Pawn(Other).PlayerReplicationInfo;
	bReducedHeight = false;
	PrePivot = vect(0,0,3);
	for ( i=0; i<4; i++ )
		Multiskins[i] = Pawn(Other).MultiSkins[i];	

	if ( bDecorative )
	{
		DeathZone = Region.Zone;
		DeathZone.NumCarcasses++;
	}
	bDecorative = false;
	bMeshCurvy = Other.bMeshCurvy;	
	bMeshEnviroMap = Other.bMeshEnviroMap;	
	Mesh = Other.Mesh;
	Skin = Other.Skin;
	Texture = Other.Texture;
	Fatness = Other.Fatness;
	DrawScale = Other.DrawScale;
	SetCollisionSize(Other.CollisionRadius + 4, Other.CollisionHeight);
	if ( !SetLocation(Location) )
		SetCollisionSize(CollisionRadius - 4, CollisionHeight);

	DesiredRotation = other.Rotation;
	DesiredRotation.Roll = 0;
	DesiredRotation.Pitch = 0;
	AnimSequence = Other.AnimSequence;
	AnimFrame = Other.AnimFrame;
	AnimRate = Other.AnimRate;
	TweenRate = Other.TweenRate;
	AnimMinRate = Other.AnimMinRate;
	AnimLast = Other.AnimLast;
	bAnimLoop = Other.bAnimLoop;
	SimAnim.X = 10000 * AnimFrame;
	SimAnim.Y = 5000 * AnimRate;
	SimAnim.Z = 1000 * TweenRate;
	SimAnim.W = 10000 * AnimLast;
	bAnimFinished = Other.bAnimFinished;
	Velocity = other.Velocity;
	Mass = Other.Mass;
	if ( Buoyancy < 0.8 * Mass )
		Buoyancy = 0.9 * Mass;
}


function ReduceCylinder()
{
	local float OldHeight;
	local vector OldLocation;

	RemoteRole=ROLE_DumbProxy;
	bReducedHeight = true;
	SetCollision(bCollideActors,False,False);
	OldHeight = CollisionHeight;
	if ( ReducedHeightFactor < Default.ReducedHeightFactor )
		SetCollisionSize(CollisionRadius, CollisionHeight * ReducedHeightFactor);
	else
		SetCollisionSize(CollisionRadius + 4, CollisionHeight * ReducedHeightFactor);
	PrePivot = vect(0,0,1) * (OldHeight - CollisionHeight); 
	OldLocation = Location;
	if ( !SetLocation(OldLocation - PrePivot) )
	{
		SetCollisionSize(CollisionRadius - 4, CollisionHeight);
		if ( !SetLocation(OldLocation - PrePivot) )
		{
			SetCollisionSize(CollisionRadius, OldHeight);
			SetCollision(false, false, false);
			PrePivot = vect(0,0,0);
			if ( !SetLocation(OldLocation) )
				ChunkUp(200);
		}
	}
	PrePivot = PrePivot + vect(0,0,3);
	Mass = Mass * 0.8;
	Buoyancy = Buoyancy * 0.8;
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, 
						Vector Momentum, name DamageType)
{	
	local UT_BloodBurst b;

	b = Spawn(class'UT_BloodHit',,,HitLocation, rotator(Momentum));
	if ( bGreenBlood )
		b.GreenBlood();		
	if ( !bPermanent )
	{
		if ( (DamageType == 'Corroded') && (Damage >= 100) )
		{
			bCorroding = true;
			GotoState('Corroding');
		}
		else
		{
			if ( !bDecorative )
			{
				bBobbing = false;
				SetPhysics(PHYS_Falling);
			}
			if ( (Physics == PHYS_None) && (Momentum.Z < 0) )
				Momentum.Z *= -1;
			Velocity += 3 * momentum/(Mass + 200);
			if ( DamageType == 'shot' )
				Damage *= 0.4;
			CumulativeDamage += Damage;
			if ( (((Damage > 30) || !IsAnimating()) && (CumulativeDamage > 0.8 * Mass)) || (Damage > 0.4 * Mass) 
				|| ((Velocity.Z > 150) && !IsAnimating()) )
				ChunkUp(Damage);
			if ( bDecorative )
				Velocity = vect(0,0,0);
		}
	}
}

function ChunkUp(int Damage)
{
	if ( bPermanent )
		return;
	if ( Region.Zone.bPainZone && (Region.Zone.DamagePerSec > 0) )
	{
		if ( Bugs != None )
			Bugs.Destroy();
	}
	else
		CreateReplacement();
	SetPhysics(PHYS_None);
	bHidden = true;
	SetCollision(false,false,false);
	bProjTarget = false;
	GotoState('Gibbing');
}

simulated function Landed(vector HitNormal)
{
	local rotator finalRot;
	local float OldHeight;

	if ( (Velocity.Z < -1000) && !bPermanent )
	{
		ChunkUp(200);
		return;
	}

	finalRot = Rotation;
	finalRot.Roll = 0;
	finalRot.Pitch = 0;
	setRotation(finalRot);
	SetPhysics(PHYS_None);
	SetCollision(bCollideActors, false, false);
	if ( HitNormal.Z < 0.99 )
		ReducedHeightFactor = 0.1;
	if ( HitNormal.Z < 0.93 )
		ReducedHeightFactor = 0.0;
	if ( !IsAnimating() )
		LieStill();

	if ( Pool == None )
		Pool = Spawn(class'UTBloodPool2',,,Location, rotator(HitNormal));
	else
		Spawn(class'BloodSplat',,,Location, rotator(HitNormal + 0.5 * VRand()));
}

function AnimEnd()
{
	if ( Physics == PHYS_None )
		LieStill();
	else if ( Region.Zone.bWaterZone )
	{
		bThumped = true;
		LieStill();
	}
}

function LieStill()
{
	SimAnim.X = 10000 * AnimFrame;
	SimAnim.Y = 5000 * AnimRate;
	if ( !bThumped && !bDecorative )
		LandThump();
	if ( !bReducedHeight )
		ReduceCylinder();
}

function LandThump()
{
	local float impact;

	if ( Physics == PHYS_None)
	{
		bThumped = true;
		if ( Role == ROLE_Authority )
		{
			impact = 0.75 + Velocity.Z * 0.004;
			impact = Mass * impact * impact * 0.015;
			PlaySound(LandedSound,, impact);
		}
	}
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	local UT_BloodBurst b;

	b = Spawn(class 'UT_BloodBurst');
	if ( bGreenBlood )	
		b.GreenBlood();
	b.RemoteRole = ROLE_None;		
	Velocity = 0.7 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	Velocity.Z *= 0.9;
	if ( Abs(Velocity.Z) < 120 )
	{
		bBounce = false;
		Disable('HitWall');
	}
}

auto state Dying
{
	ignores TakeDamage;

	simulated function BeginState()
	{
		Super.BeginState();
		if ( (PlayerOwner != None) && PlayerOwner.Owner.IsA('PlayerPawn')
			&& PlayerOwner.Owner.IsInState('Dying') )
			PlayerOwner.Owner.bHidden = true;
	}

Begin:
	if ( bCorroding )
		GotoState('Corroding');
	if ( bDecorative && !bReducedHeight )
	{
		ReduceCylinder();
		SetPhysics(PHYS_None);
	}
	Sleep(0.2);
	if ( bCorroding )
		GotoState('Corroding');
	GotoState('Dead');
}

state Dead 
{
	function AddFliesAndRats()
	{
	}

	function CheckZoneCarcasses()
	{
		local UTHumanCarcass C, Best;

		if ( !bDecorative && (DeathZone.NumCarcasses > DeathZone.MaxCarcasses) )
		{
			Best = self;
			ForEach AllActors(class'UTHumanCarcass', C)
				if ( (C != Self) && !C.bDecorative && (C.DeathZone == DeathZone) && !C.IsAnimating() )
				{
					if ( Best == self )
						Best = C;
					else if ( !C.PlayerCanSeeMe() )
					{
						Best = C;
						break;
					}
				}
			Best.Destroy();
		}
	}

	function Timer()
	{
		if ( ExistTime <= 0 )
			Super.Timer();
		else
		{
			SetPhysics(Phys_Falling);
			ExistTime -= 3.0;
		}
	}

	singular event BaseChange()
	{
		if ( Pawn(Base) != None )
		{
			ChunkUp(200);
			return;
		}

		if ( (Mover(Base) != None) && (ExistTime == 0) )
		{
			ExistTime = FClamp(30.0 - 2 * DeathZone.NumCarcasses, 5, 12);
			SetTimer(3.0, true);
		}

		Super.BaseChange();
	}

	function BeginState()
	{
		if ( bDecorative || bPermanent 
			|| ((Level.NetMode == NM_Standalone) && Level.Game.IsA('SinglePlayer')) )
			lifespan = 0.0;
		else
		{
			if ( Mover(Base) != None )
			{
				ExistTime = FMax(12.0, 30.0 - 2 * DeathZone.NumCarcasses);
				SetTimer(3.0, true);
			}
			else
				SetTimer(FMax(12.0, 30.0 - 2 * DeathZone.NumCarcasses), false); 
		}
	}

}

state Gibbing
{
	ignores Landed, HitWall, AnimEnd, TakeDamage, ZoneChange;

Begin:
	Sleep(0.25);
	GibSound();
	if ( !bPlayerCarcass )
		Destroy();
}

state Corroding
{
	ignores Landed, HitWall, AnimEnd, TakeDamage, ZoneChange;

	function Tick( float DeltaTime )
	{
		local int NewFatness; 
		local float splashSize;
		local actor splash;

		NewFatness = fatness - 80 * DeltaTime;
		if ( NewFatness < 85 )
		{
			if ( Region.Zone.bWaterZone && Region.Zone.bDestructive )
			{
				splashSize = FClamp(0.0002 * Mass * (250 - 0.5 * FMax(-600,Velocity.Z)), 1.0, 4.0 );
				if ( Region.Zone.ExitSound != None )
					PlaySound(Region.Zone.ExitSound, SLOT_Interact, splashSize);
				if ( Region.Zone.ExitActor != None )
				{
					splash = Spawn(Region.Zone.ExitActor); 
					if ( splash != None )
						splash.DrawScale = splashSize;
				}
			}			
			Destroy();
		}
		fatness = Clamp(NewFatness, 0, 255);
	}
	
	function BeginState()
	{
		Disable('Tick');
	}
	
Begin:
	Sleep(0.5);
	Enable('Tick');	
}

defaultproperties
{
	  bReducedHeight=true	
      PrePivot=(X=0.000000,Y=0.000000,Z=28.000000)
      CollisionHeight=+00013.000000
	  CollisionRadius=+00027.000000
	  bBlockActors=false
	  bBlockPlayers=false
      flies=0
 	  bSlidingCarcass=True
	  TransientSoundVolume=3.000000
	  NetPriority=+2.50000
	  RemoteRole=ROLE_SimulatedProxy
      LandedSound=Sound'UnrealShare.Gibs.Thump'
      ReducedHeightFactor=0.300000
	  GibSounds(0)=Sound'UnrealShare.Gibs.Gib1'
	  GibSounds(1)=NewGib
	  GibSounds(2)=Sound'UnrealShare.Gibs.Gib4'
	  GibSounds(3)=Sound'UnrealShare.Gibs.Gib5'
}

