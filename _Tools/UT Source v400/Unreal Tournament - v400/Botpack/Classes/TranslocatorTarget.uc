//=============================================================================
// TranslocatorTarget.
//=============================================================================
class TranslocatorTarget extends Projectile;

#exec MESH  IMPORT MESH=Module ANIVFILE=MODELS\Transobj_a.3D DATAFILE=MODELS\Transobj_d.3D X=0 Y=0 Z=0 UNMIRROR=1
#exec MESH ORIGIN MESH=Module X=0 Y=0 Z=-150 YAW=0 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=Module SEQ=All		STARTFRAME=0  NUMFRAMES=3
#exec MESH SEQUENCE MESH=Module SEQ=Open	STARTFRAME=0  NUMFRAMES=3
#exec TEXTURE IMPORT NAME=tloc2 FILE=MODELS\tran2.PCX GROUP="Skins" LODSET=2
#exec MESHMAP SCALE MESHMAP=Module X=0.028 Y=0.028 Z=0.056
#exec MESHMAP SETTEXTURE MESHMAP=Module NUM=1 TEXTURE=tloc2

#exec AUDIO IMPORT FILE="..\unreali\Sounds\Krall\krasht2.wav" NAME="TDisrupt" GROUP="translocator"
#exec AUDIO IMPORT FILE="Sounds\Pickups\ambhum3.wav" NAME="targethum" GROUP="translocator"

var float Disruption, SpawnTime;
var() float DisruptionThreshold;
var pawn Disruptor;
var translocator Master;
var Actor DesiredTarget;
var bool bAlreadyHit, bTempDamage;
var vector RealLocation;
var TranslocGlow Glow;
var class<TranslocGlow> GlowColor[4];
var Decal Shadow;

Replication
{
	UnReliable if ( Role == ROLE_Authority )
		RealLocation, Glow;
}

simulated function Destroyed()
{
	if ( Shadow != None )
		Shadow.Destroy();
	if ( Glow != None )
		Glow.Destroy();
	Super.Destroyed();
}

function bool Disrupted()
{
	return ( Disruption > DisruptionThreshold );
}

function DropFrom(vector StartLocation)
{
	if ( !SetLocation(StartLocation) )
		return; 

	SetPhysics(PHYS_Falling);
	GotoState('PickUp');
}

simulated singular function ZoneChange( ZoneInfo NewZone )
{
	local float splashsize;
	local actor splash;

	if( NewZone.bWaterZone )
	{
		if( !Region.Zone.bWaterZone && (Velocity.Z < -200) )
		{
			// Else play a splash.
			splashSize = FClamp(0.0001 * Mass * (250 - 0.5 * FMax(-600,Velocity.Z)), 1.0, 3.0 );
			if( NewZone.EntrySound != None )
				PlaySound(NewZone.EntrySound, SLOT_Interact, splashSize);
			if( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor); 
				if ( splash != None )
				{
					splash.DrawScale = splashSize;
					splash.RemoteRole = ROLE_None;
				}
			}
		}
	}
}

function Throw(Pawn Thrower, float force, vector StartPosition)
{
	local vector dir;

	dir = vector(Thrower.ViewRotation);
	if ( Thrower.IsA('Bot') )
		Velocity = force * dir + vect(0,0,200);
	else
	{
		dir.Z = dir.Z + 0.35 * (1 - Abs(dir.Z));
		Velocity = FMin(force,  Master.MaxTossForce) * Normal(dir);
	}
	bBounce = true;
	DropFrom(StartPosition);
}

////////////////////////////////////////////////////////
auto state Pickup
{
	simulated function Timer()
	{
		local Pawn P;

		if ( (Physics == PHYS_None) && (Role != ROLE_Authority)
			&& (RealLocation != Location) && (RealLocation != vect(0,0,0)) )
				SetLocation(RealLocation);

		//disruption effect
		if ( Disrupted() )
		{
			Spawn(class'Electricity',,,Location + Vect(0,0,6));
			PlaySound(sound'TDisrupt', SLOT_None, 4.0);
		}
		else
		{
			// tell local bots about self
			for ( P=Level.PawnList; P!=None; P=P.NextPawn )
				if ( P.IsA('Bot') && (P.Weapon != None) && !P.Weapon.bMeleeWeapon
					&& (!Level.Game.bTeamGame || (P.PlayerReplicationInfo.Team != Pawn(Master.Owner).PlayerReplicationInfo.Team)) )
				{
					if ( (VSize(P.Location - Location) < 500) && P.LineOfSightTo(self) )
					{
						Bot(P).ShootTarget(self);
						break;
					}
					else if ( P.IsInState('Roaming') && Bot(P).bCamping
								&& Level.Game.IsA('DeathMatchPlus') && DeathMatchPlus(Level.Game).CheckThisTranslocator(Bot(P), self) )
					{
						Bot(P).SetPeripheralVision();
						Bot(P).TweenToRunning(0.1);
						Bot(P).bCamping = false;
						Bot(P).GotoState('Roaming', 'SpecialNavig');
						break;
					}
				}
		}
		AnimEnd();
		SetTimer(1 + 2 * FRand(), false);
	}

	simulated event Landed( vector HitNormal )
	{
		local rotator newRot;

		SetTimer(2.5, false);
		newRot = Rotation;
		newRot.Pitch = 0;
		newRot.Roll = 0;
		SetRotation(newRot);
		PlayAnim('Open',0.1);
		if ( Role == ROLE_Authority )
		{
			RemoteRole = ROLE_DumbProxy;
			RealLocation = Location;
			if ( Master.Owner.IsA('Bot') )
			{
				if ( Pawn(Master.Owner).Weapon == Master )
					Bot(Master.Owner).SwitchToBestWeapon();
				LifeSpan = 10;
			}
			Disable('Tick');
		}
	}		

	function AnimEnd()
	{
		local int glownum;

		if ( (Physics != PHYS_None) || (Glow != None) || (Instigator.PlayerReplicationInfo == None) || Disrupted() )
			return;

		glownum = Instigator.PlayerReplicationInfo.Team;
		if ( glownum > 3 )
			glownum = 0;
			
		Glow = spawn(GlowColor[glownum], self);
	}

	event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		SetPhysics(PHYS_Falling);
		Velocity = Momentum/Mass;
		Velocity.Z = FMax(Velocity.Z, 0.7 * VSize(Velocity));

		if ( Level.Game.bTeamGame && (EventInstigator != None)
			&& (EventInstigator.PlayerReplicationInfo != None)
			&& (EventInstigator.PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team) )
			return;

		Disruption += Damage;
		Disruptor = EventInstigator;
		if ( !Disrupted() )
			SetTimer(0.3, false);
		else if ( Glow != None )
			Glow.Destroy();
	}

	singular function Touch( Actor Other )
	{
		local bool bMasterTouch;
		local vector NewPos;

		if ( !Other.bIsPawn )
		{
			if ( (Physics == PHYS_Falling) && !Other.IsA('Inventory') && !Other.IsA('Triggers') && !Other.IsA('NavigationPoint') )
				HitWall(-1 * Normal(Velocity), Other);
			return;
		}
		bMasterTouch = ( Other == Instigator );
		
		if ( Physics == PHYS_None )
		{
			if ( bMasterTouch )
			{
				PlaySound(Sound'Botpack.Pickups.AmmoPick',,2.0);
				Master.TTarget = None;
				Master.bTTargetOut = false;
				if ( Other.IsA('PlayerPawn') )
					PlayerPawn(Other).ClientWeaponEvent('TouchTarget');
				destroy();
			}
			return;
		}
		if ( bMasterTouch ) 
			return;
		NewPos = Other.Location;
		NewPos.Z = Location.Z;
		SetLocation(NewPos);
		Velocity = vect(0,0,0);
		if ( Level.Game.bTeamGame
			&& (Instigator.PlayerReplicationInfo.Team == Pawn(Other).PlayerReplicationInfo.Team) )
			return;

		if ( Instigator.IsA('Bot') )
			Master.Translocate();
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		if ( bAlreadyHit )
		{
			bBounce = false;
			return;
		}
		bAlreadyHit = ( HitNormal.Z > 0.7 );
		PlaySound(ImpactSound, SLOT_Misc);	  // hit wall sound
		Velocity = 0.3*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
		speed = VSize(Velocity);
	}

	simulated function Tick(float DeltaTime)
	{
		if ( Level.bHighDetailMode && (Shadow == None)
			&& (PlayerPawn(Instigator) != None) && (ViewPort(PlayerPawn(Instigator).Player) != None) )
			Shadow = spawn(class'TargetShadow',self,,,rot(16384,0,0));

		if ( Role != ROLE_Authority )
		{
			Disable('Tick');
			return;
		}
		if ( (DesiredTarget == None) || (Master == None) )
		{
			Disable('Tick');
			if ( Master.Owner.IsA('Bot') && (Pawn(Master.Owner).Weapon == Master) )
				Bot(Master.Owner).SwitchToBestWeapon();
			return;
		}

		if ( (Abs(Location.X - DesiredTarget.Location.X) < Master.Owner.CollisionRadius)
			&& (Abs(Location.Y - DesiredTarget.Location.Y) < Master.Owner.CollisionRadius) )
		{
			if ( !FastTrace(DesiredTarget.Location, Location) )
				return;	

			Pawn(Master.Owner).StopWaiting();
			Master.Translocate();
			if ( Master.Owner.IsA('Bot') && (Pawn(Master.Owner).Weapon == Master) )
				Bot(Master.Owner).SwitchToBestWeapon();
			Disable('Tick');
		}
	}

	simulated function BeginState()
	{
		SpawnTime = Level.TimeSeconds;
		TweenAnim('Open', 0.1);
	}

	function EndState()
	{
		DesiredTarget = None;
		if ( (Master != None) && (Master.Owner != None)
			&& Master.Owner.IsA('Bot') && (Pawn(Master.Owner).Weapon == Master) )
			Bot(Master.Owner).SwitchToBestWeapon();
	}
}

defaultproperties
{
	 GlowColor(0)=class'Botpack.TranslocGlow'
	 GlowColor(1)=class'Botpack.TranslocBlue'
	 GlowColor(2)=class'Botpack.TranslocGreen'
	 GlowColor(3)=class'Botpack.TranslocGold'
	 RemoteRole=ROLE_SimulatedProxy
	 DisruptionThreshold=65
     ImpactSound=Sound'UnrealShare.Eightball.GrenadeFloor'
     Mesh=Mesh'Botpack.Module'
     SoundRadius=20
	 SoundVolume=100
     AmbientSound=Sound'Botpack.Translocator.targethum'
     CollisionRadius=10.000000
	 CollisionHeight=3.00000
     bCollideWorld=True
	 bBounce=True
	 bProjTarget=true
     Mass=50.000000
	 bNetTemporary=false
     LifeSpan=+000.000000
}
