//=============================================================================
// TeamCannon.
//=============================================================================
class TeamCannon extends StationaryPawn;

#exec MESH IMPORT MESH=cdgunmainM ANIVFILE=MODELS\cdgunmain_a.3D DATAFILE=MODELS\cdgunmain_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=cdgunmainM X=0 Y=150 Z=0 PITCH=0 YAW=-64 ROLL=-64
#exec MESH SEQUENCE MESH=cdgunmainM SEQ=All    STARTFRAME=0   NUMFRAMES=44
#exec MESH SEQUENCE MESH=cdgunmainM SEQ=Error  STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=cdgunmainM SEQ=Activate   STARTFRAME=2   NUMFRAMES=18
#exec MESH SEQUENCE MESH=cdgunmainM SEQ=Fire1  STARTFRAME=21   NUMFRAMES=4
#exec MESH SEQUENCE MESH=cdgunmainM SEQ=Fire2  STARTFRAME=25   NUMFRAMES=4
#exec MESH SEQUENCE MESH=cdgunmainM SEQ=Fire3  STARTFRAME=29   NUMFRAMES=4
#exec MESH SEQUENCE MESH=cdgunmainM SEQ=Fire4  STARTFRAME=33   NUMFRAMES=4
#exec MESH SEQUENCE MESH=cdgunmainM SEQ=Fire5  STARTFRAME=37   NUMFRAMES=4
#exec MESH SEQUENCE MESH=cdgunmainM SEQ=Fire6  STARTFRAME=41   NUMFRAMES=4
#exec TEXTURE IMPORT NAME=jcdgunmain FILE=MODELS\cdgunmain.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=cdgunmainM X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=cdgunmainM NUM=1 TEXTURE=jcdgunmain

var() sound FireSound;
var() sound ActivateSound;
var() sound DeActivateSound;
var float SampleTime; 			// How often we sample Instigator's location
var int   TrackingRate;			// How fast Cannon tracks Instigator
var float Drop;					// How far down to drop spawning of projectile
var() bool bLeadTarget;
var bool bShoot; 
var() Class<Projectile> ProjectileType;
var rotator StartingRotation;
var() int MyTeam;
var Actor GunBase;

function PostBeginPlay()
{
	SpawnBase();
	Super.PostBeginPlay();
	StartingRotation = Rotation;
}

simulated function Destroyed()
{
	Super.Destroyed();
	if ( GunBase != None )
		GunBase.Destroy();
}

simulated function Tick(float DeltaTime)
{
	if ( GunBase == None )
		SpawnBase();
	Disable('Tick');
}

simulated function SpawnBase()
{
	GunBase = Spawn(class'CeilingGunBase', self);
}

function SetTeam(int TeamNum)
{
	MyTeam = TeamNum;
}

function bool SameTeamAs(int TeamNum)
{
	return (MyTeam == TeamNum);
}

function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, name damageType)
{
	MakeNoise(1.0);
	Health -= NDamage;
	if (Health <0) 
	{
		PlaySound(DeActivateSound, SLOT_None,5.0);
		NextState = 'Idle';
		Enemy = None;
		Spawn(class'UT_BlackSmoke');
		GotoState('DamagedState');
	}
	else if ( instigatedBy == None )
		return;
	else if ( (Enemy == None) && (!instigatedBy.bIsPlayer || !Level.Game.bTeamGame || !SameTeamAs(instigatedBy.PlayerReplicationInfo.Team)) )
	{	
		Enemy = instigatedBy;
		GotoState('ActiveCannon');
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	GotoState('DeActivated');
}

function StartDeactivate()
{
	SetPhysics(PHYS_Rotating);
	DesiredRotation = StartingRotation;
}

function PlayDeactivate()
{
	PlaySound(ActivateSound, SLOT_None,5.0);
	TweenAnim('Activate', 1.5);
}

function PlayActivate()
{
	PlayAnim(AnimSequence);
	PlaySound(ActivateSound, SLOT_None, 2.0);
}

function ActivateComplete();

function Name PickAnim()
{
	if (DesiredRotation.Pitch < -13400 )
	{
		Drop = 35;
		return 'Fire6';
	}
	else if (DesiredRotation.Pitch < -10600 ) 
	{
		Drop = 30;
		return 'Fire5';
	}
	else if (DesiredRotation.Pitch < -7400 ) 
	{
		Drop = 25;
		return 'Fire4';
	}
	else if (DesiredRotation.Pitch < -4200 ) 
	{
		Drop = 20;
		return 'Fire3';
	}
	else if (DesiredRotation.Pitch < -1000 ) 
	{
		Drop = 15;
		return 'Fire2';
	}
	else 
	{
		Drop = 10;
		return 'Fire1';
	}
}
	
function Shoot()
{
	local Vector FireSpot, ProjStart;
	local Projectile p;

	if (DesiredRotation.Pitch < -20000) Return;
	PlaySound(FireSound, SLOT_None,5.0);
	PlayAnim(PickAnim());

	ProjStart = Location+Vector(DesiredRotation)*100 - Vect(0,0,1)*Drop;
	if ( bLeadTarget )
	{
		FireSpot = Target.Location + FMin(1, 0.7 + 0.6 * FRand()) * (Target.Velocity * VSize(Target.Location - ProjStart)/ProjectileType.Default.Speed);
		if ( !FastTrace(FireSpot, ProjStart) )
			FireSpot = 0.5 * (FireSpot + Target.Location);
		DesiredRotation = Rotator(FireSpot - ProjStart);
	}
	p = Spawn (ProjectileType,,,ProjStart,DesiredRotation);
	if ( DeathMatchPlus(Level.Game).bNoviceMode )
		P.Damage *= (0.4 + 0.15 * Level.game.Difficulty);
	if ( Target.IsA('WarShell') )
		p.speed *= 2;
	bShoot=False;
	SetTimer(0.05,True);
}	

auto state Idle
{
	ignores EnemyNotVisible;

	function SeePlayer(Actor SeenPlayer)
	{
        if ( SeenPlayer.bCollideActors 
			&& ((Pawn(SeenPlayer).PlayerReplicationInfo.Team != MyTeam) || !Level.Game.bTeamGame) )
		{
			Enemy = Pawn(SeenPlayer);
			GotoState('ActiveCannon');
		}
	}

	function BeginState()
	{
		Enemy = None;
	}

Begin:
	TweenAnim(AnimSequence, 0.25);
	Sleep(5.0);
	StartDeactivate();
	Sleep(0.0);
	PlayDeactivate();
	Sleep(2.0);
	SetPhysics(PHYS_None);
}

state DeActivated
{
	ignores SeePlayer, EnemyNotVisible, TakeDamage;

Begin:
	Health = -1; 
	Enemy = None;
	StartDeactivate();
	Sleep(0.0);
	PlayDeactivate();
	FinishAnim();
	Sleep(6.0);
	SetPhysics(PHYS_None);
}

state DamagedState
{
	ignores TakeDamage, SeePlayer, EnemyNotVisible;

Begin:
	Enemy = None;
	StartDeactivate();
	Sleep(0.0);
	PlayDeactivate();
	FinishAnim();
	Spawn(class'UT_BlackSmoke');
	Sleep(1.0);
	Spawn(class'UT_BlackSmoke');
	Sleep(1.0);
	Spawn(class'UT_BlackSmoke');
	Sleep(13.0);
	Health = Default.Health;
	GotoState(NextState);
}

state ActiveCannon
{
	ignores SeePlayer;

	function EnemyNotVisible()
	{
		local Pawn P;

		Enemy = None;
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
               if ( P.bCollideActors && P.bIsPlayer && (!Level.Game.bTeamGame || !SameTeamAs(P.PlayerReplicationInfo.Team))
				&& (P.Health > 0) && !P.IsA('TeamCannon')
				&& LineOfSightTo(P) )
			{
				Enemy = P;
				return;
			}
		GotoState('Idle');
	}
	
	function Killed(pawn Killer, pawn Other, name damageType)
	{
		if ( Other == Enemy )
			EnemyNotVisible();
	}

	function Timer()
	{
		local Pawn P;

		DesiredRotation = rotator(Enemy.Location - Location);
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
		if ( bShoot && (DesiredRotation.Pitch < 2000)
			&& ((Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) < 1000)
			|| (Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) > 64535)) )
			Shoot();
		else 
		{
			TweenAnim(PickAnim(), 0.25);
			bShoot=True;			
			SetTimer(SampleTime,True);
		}
	}

	function BeginState()
	{
		Target = Enemy;
	}

Begin:
	Disable('Timer');
	FinishAnim();
	PlayActivate();
	FinishAnim();
	ActivateComplete();
	Enable('Timer');
	SetTimer(SampleTime,True);
	RotationRate.Yaw = TrackingRate;
	SetPhysics(PHYS_Rotating);
	bShoot=True;

FaceEnemy:
	TurnToward(Enemy);
	Goto('FaceEnemy');
}


state TrackWarhead
{
	ignores SeePlayer, EnemyNotVisible;

	function Timer()
	{
		local Pawn P;

		if ( (Target == None) || Target.bDeleteme )
		{
			FindEnemy();
			return;
		}

		DesiredRotation = rotator(Target.Location - Location);
		DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
		if ( bShoot && (DesiredRotation.Pitch < 2000)
			&& ((Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) < 2000)
			|| (Abs(DesiredRotation.Yaw - (Rotation.Yaw & 65535)) > 63535)) )
			Shoot();
		else 
		{
			TweenAnim(PickAnim(), 0.25);
			bShoot=True;			
		}
		SetTimer(SampleTime,True);
	}
	
	function FindEnemy()
	{
		local Pawn P;

		Target = None;
		Enemy = None;
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
            if ( P.bCollideActors && P.bIsPlayer && ((P.PlayerReplicationInfo.Team != MyTeam) || !Level.Game.bTeamGame)
				&& (P.Health > 0) && !P.IsA('TeamCannon') && LineOfSightTo(P) )
			{
				Enemy = P;
				GotoState('ActiveCannon');
			}
		GotoState('Idle');
	}

Begin:
	Disable('Timer');
	FinishAnim();
	PlayActivate();
	FinishAnim();
	ActivateComplete();
	Enable('Timer');
	SetTimer(SampleTime,True);
	RotationRate.Yaw = TrackingRate;
	SetPhysics(PHYS_Rotating);
	bShoot=True;

FaceEnemy:
	if ( (Target == None) || Target.bDeleteme )
		FindEnemy();
	TurnToward(Target);
	Goto('FaceEnemy');
}


state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, TakeDamage, WarnTarget, Died;

	function BeginState()
	{
		Destroy();
	}
}

defaultproperties
{
	 RemoteRole=ROLE_SimulatedProxy
	 NameArticle="an "
	 MenuName="automatic cannon!"
     FovAngle=90
     SightRadius=3000
 	 ProjectileType=CannonShot
	 SampleTime=+00000.330000
     Drop=+00060.000000
 	 Health=220
	 TrackingRate=25000
     FireSound=UnrealI.CannonShot
     ActivateSound=UnrealI.CannonActivate
	 AnimSequence=Activate
     Mesh=Botpack.cdgunmainM
     CollisionRadius=+00028.000000
     CollisionHeight=+00022.000000
     bCollideWorld=True
     RotationRate=(Yaw=25000)
     bRotateToDesired=True
	 bProjTarget=true
}
