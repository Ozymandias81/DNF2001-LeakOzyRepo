//=============================================================================
// Eightball2.
//=============================================================================
class Eightball2 expands Weapon;
#forceexec MESH IMPORT MESH=Eightm ANIVFILE=MODELS\Eightball2_a.3D  DATAFILE=MODELS\Eightball2_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=Eightm X=0 Y=0 Z=0 YAW=-64 ROLL=0
#forceexec MESH SEQUENCE MESH=Eightm SEQ=All      STARTFRAME=0   NUMFRAMES=169
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Select   STARTFRAME=0   NUMFRAMES=20 RATE=24 GROUP=Select
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Fire1    STARTFRAME=20  NUMFRAMES=8
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Load1    STARTFRAME=28  NUMFRAMES=7
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Rotate1  STARTFRAME=35  NUMFRAMES=7
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Load2    STARTFRAME=42  NUMFRAMES=7
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Fire2    STARTFRAME=49  NUMFRAMES=9
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Rotate2  STARTFRAME=59  NUMFRAMES=7
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Load3    STARTFRAME=66  NUMFRAMES=7
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Fire3    STARTFRAME=73  NUMFRAMES=10
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Rotate3  STARTFRAME=83  NUMFRAMES=7
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Load4    STARTFRAME=90  NUMFRAMES=7
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Fire4    STARTFRAME=97  NUMFRAMES=11
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Rotate4  STARTFRAME=108 NUMFRAMES=7
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Fire5    STARTFRAME=115 NUMFRAMES=13
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Fire6    STARTFRAME=129 NUMFRAMES=16
#forceexec MESH SEQUENCE MESH=Eightm SEQ=Down     STARTFRAME=145  NUMFRAMES=23
#forceexec TEXTURE IMPORT NAME=Eight_t FILE=MODELS\eight.PCX GROUP="Skins"
#forceexec TEXTURE IMPORT NAME=Eight_t1 FILE=MODELS\eight1.PCX GROUP="Skins"
#forceexec TEXTURE IMPORT NAME=Eight_t2 FILE=MODELS\eight2.PCX GROUP="Skins"
#forceexec TEXTURE IMPORT NAME=Eight_t3 FILE=MODELS\eight3.PCX GROUP="Skins"
#forceexec TEXTURE IMPORT NAME=Eight_t4 FILE=MODELS\eight4.PCX GROUP="Skins"
#forceexec MESHMAP SCALE MESHMAP=Eightm X=0.005 Y=0.005 Z=0.01
#forceexec MESHMAP SETTEXTURE MESHMAP=Eightm NUM=0 TEXTURE=eight_t1
#forceexec MESHMAP SETTEXTURE MESHMAP=Eightm NUM=1 TEXTURE=eight_t2
#forceexec MESHMAP SETTEXTURE MESHMAP=Eightm NUM=2 TEXTURE=eight_t3
#forceexec MESHMAP SETTEXTURE MESHMAP=Eightm NUM=3 TEXTURE=eight_t4

#forceexec MESH IMPORT MESH=EightPick ANIVFILE=MODELS\Eightball2_a.3D DATAFILE=MODELS\Eightball2_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=EightPick X=0 Y=170 Z=0 YAW=64
#forceexec MESH SEQUENCE MESH=eightpick SEQ=All    STARTFRAME=0   NUMFRAMES=1
#forceexec MESH SEQUENCE MESH=eightpick SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#forceexec MESHMAP SCALE MESHMAP=eightpick X=0.04 Y=0.04 Z=0.08
#forceexec MESHMAP SETTEXTURE MESHMAP=eightpick NUM=1 TEXTURE=Eight_t

// 3rd person perspective version
#forceexec MESH IMPORT MESH=8Ball3rd ANIVFILE=MODELS\Eightball2_a.3D DATAFILE=MODELS\Eightball2_d.3D X=0 Y=0 Z=0
#forceexec MESH ORIGIN MESH=8Ball3rd X=0 Y=-430 Z=-45 YAW=-64 ROLL=9
#forceexec MESH SEQUENCE MESH=8Ball3rd SEQ=All  STARTFRAME=0  NUMFRAMES=10
#forceexec MESH SEQUENCE MESH=8Ball3rd SEQ=Idle  STARTFRAME=0  NUMFRAMES=1
#forceexec MESH SEQUENCE MESH=8Ball3rd SEQ=Fire  STARTFRAME=1  NUMFRAMES=9
#forceexec MESHMAP SCALE MESHMAP=8Ball3rd X=0.065 Y=0.065 Z=0.13
#forceexec MESHMAP SETTEXTURE MESHMAP=8Ball3rd NUM=1 TEXTURE=JEightm1

//#forceexec AUDIO IMPORT FILE="Sounds\eightbal\8ALTF1.WAV" NAME="EightAltFire" GROUP="eightball"
//#forceexec AUDIO IMPORT FILE="Sounds\eightbal\Barrelm1.WAV" NAME="BarrelMove" GROUP="eightball"
//#forceexec AUDIO IMPORT FILE="Sounds\eightbal\Eload1.WAV" NAME="Loading" GROUP="eightball"
//#forceexec AUDIO IMPORT FILE="Sounds\eightbal\Lock1.WAV" NAME="SeekLock" GROUP="eightball"
//#forceexec AUDIO IMPORT FILE="Sounds\eightbal\SeekLost.WAV" NAME="SeekLost" GROUP="eightball"
//#forceexec AUDIO IMPORT FILE="Sounds\eightbal\Select.WAV" NAME="Selecting" GROUP="eightball"

#forceexec MESH NOTIFY MESH=Eightm SEQ=Loading TIME=0.45 FUNCTION=BarrelTurn

//#forceexec TEXTURE IMPORT NAME=Crosshair6 FILE=Textures\Hud\chair6.PCX GROUP="Icons" FLAGS=2 MIPS=OFF

var int RocketsLoaded, RocketRad;
var bool bFireLoad,bTightWad;
var Actor LockedTarget, NewTarget, OldTarget;

simulated function PostRender( canvas Canvas )
{
	Super.PostRender(Canvas);
	bOwnsCrossHair = bLockedOn;
	if ( bOwnsCrossHair )
	{
		// if locked on, draw special crosshair
		Canvas.SetPos(0.5 * Canvas.ClipX - 8, 0.5 * Canvas.ClipY - 8 );
		Canvas.Style = 2;
		Canvas.DrawIcon(Texture'Crosshair6', 1.0);
		Canvas.Style = 1;	
	}
}
		
function float RateSelf( out int bUseAltMode )
{
	local float EnemyDist;
	local bool bRetreating;
	local vector EnemyDir;

	if ( AmmoType.AmmoAmount <=0 )
		return -2;

	bUseAltMode = 0;
	if ( Pawn(Owner).Enemy == None )
		return AIRating;

	EnemyDir = Pawn(Owner).Enemy.Location - Owner.Location; 
	EnemyDist = VSize(EnemyDir);
	if ( EnemyDist < 370 )
		return -0.1;

	if ( Owner.Physics == PHYS_Falling )
		bUseAltMode = 0;
	else if ( EnemyDist < -1.5 * EnemyDir.Z )
		bUseAltMode = int( FRand() < 0.5 );
	else
	{
		bRetreating = ( ((EnemyDir/EnemyDist) Dot Owner.Velocity) < -0.7 );
		bUseAltMode = 0;
		if ( bRetreating && (EnemyDist < 800) && (FRand() < 0.4) )
			bUseAltMode = 1;
	}
	return AIRating;
}

// return delta to combat style
function float SuggestAttackStyle()
{
	local float EnemyDist;

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist < 600 )
		return -0.6;
	else
		return -0.2;
}

function BarrelTurn()
{
	Owner.PlaySound(Misc3Sound, SLOT_None, 0.1*Pawn(Owner).SoundDampening);
}

function Fire( float Value )
{
	//bFireMem = false;
	//bAltFireMem = false;
	bPointing=True;
	CheckVisibility();
	if ( AmmoType.UseAmmo(1) )
		GoToState('NormalFire');
}

function AltFire( float Value )
{
	//bFireMem = false;
	//bAltFireMem = false;
	bPointing=True;
	CheckVisibility();
	if ( AmmoType.UseAmmo(1) )
		GoToState('AltFiring');
}

function Actor CheckTarget()
{
	local Actor ETarget;
	local Vector Start, X,Y,Z;
	local float bestDist, bestAim;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	if ( !PawnOwner.bIsPlayer && (PawnOwner.Enemy == None) )
		return None; 
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
	bestAim = 0.93;
	ETarget = PawnOwner.PickTarget(bestAim, bestDist, X, Start);
	if ( !PawnOwner.bIsPlayer && (PawnOwner.Enemy != ETarget) )
		return None; 
	bPointing = (ETarget != None);
	Return ETarget;
}

//////////////////////////////////////////////////////
state AltFiring
{
	function Tick( float DeltaTime )
	{
		if( (pawn(Owner).bAltFire==0) || (RocketsLoaded > 5) )  // If if Fire button down, load up another
 			GoToState('FireRockets');
	}

	function BeginState()
	{
		RocketsLoaded = 1;
		bFireLoad = False;
	}

Begin:
	bLockedOn = False;
	While ( RocketsLoaded < 6 )
	{
		if (AmmoType.AmmoAmount<=0) GoToState('FireRockets');		
		Owner.PlaySound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);		
		if (RocketsLoaded==1)PlayAnim( 'Loading1', 0.6, 0.05);
		else if (RocketsLoaded==2)PlayAnim( 'Loading2', 0.6, 0.05);
		else if (RocketsLoaded==3)PlayAnim( 'Loading3', 0.6, 0.05);
		else if (RocketsLoaded==4)PlayAnim( 'Loading4', 0.6, 0.05);
		else if (RocketsLoaded==5)PlayAnim( 'Loading2', 0.6, 0.05);
		else if (RocketsLoaded==6)PlayAnim( 'Loading3', 0.6, 0.05);
		FinishAnim();
		if (RocketsLoaded==1)PlayAnim( 'Rotate1', 0.6, 0.05);
		else if (RocketsLoaded==2)PlayAnim( 'Rotate2', 0.6, 0.05);
		else if (RocketsLoaded==3)PlayAnim( 'Rotate3', 0.6, 0.05);
		else if (RocketsLoaded==4)PlayAnim( 'Rotate4', 0.6, 0.05);
		else if (RocketsLoaded==5)PlayAnim( 'Rotate2', 0.6, 0.05);
		else if (RocketsLoaded==6)PlayAnim( 'Rotate3', 0.6, 0.05);
		FinishAnim();
		RocketsLoaded++;
		AmmoType.UseAmmo(1);		
		if ( (PlayerPawn(Owner) == None) && ((FRand() > 0.5) || (Pawn(Owner).Enemy == None)) )
			Pawn(Owner).bAltFire = 0;
		if ( Level.Game.Difficulty > 0 )
			Owner.MakeNoise(0.15 * Level.Game.Difficulty * Pawn(Owner).SoundDampening);		
	}
}

///////////////////////////////////////////////////////
state NormalFire
{
	function Tick( float DeltaTime )
	{
		if ( (PlayerPawn(Owner) == None) 
			&& ((Pawn(Owner).MoveTarget != Pawn(Owner).Target) 
				|| (Pawn(Owner).Enemy == None)
				|| ( Mover(Owner.Base) != None )
				|| ((Owner.Physics == PHYS_Falling) && (Owner.Velocity.Z < 15))
				|| (VSize(Owner.Location - Pawn(Owner).Target.Location) < 400)
				|| !Pawn(Owner).CheckFutureSight(0.15)) )
			Pawn(Owner).bFire = 0;

		if( pawn(Owner).bFire==0 || RocketsLoaded > 5)  // If Fire button down, load up another
 			GoToState('FireRockets');
	}

	function BeginState()
	{
		bFireLoad = True;
		RocketsLoaded = 1;
		Super.BeginState();
	}

Begin:
	While ( RocketsLoaded < 6 )
	{
		if ( PlayerPawn(Owner) == None )
		{
			if ( FRand() > 0.33 )
				Pawn(Owner).bFire = 0;
			if ( Pawn(Owner).bFire == 0 )
	 			GoToState('FireRockets');
		}
		if (AmmoType.AmmoAmount<=0) GoToState('FireRockets');			
		Owner.PlaySound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);	

		if (RocketsLoaded==1)PlayAnim( 'Loading1', 0.6, 0.05);
		else if (RocketsLoaded==2)PlayAnim( 'Loading2', 0.6, 0.05);
		else if (RocketsLoaded==3)PlayAnim( 'Loading3', 0.6, 0.05);
		else if (RocketsLoaded==4)PlayAnim( 'Loading4', 0.6, 0.05);
		else if (RocketsLoaded==5)PlayAnim( 'Loading2', 0.6, 0.05);
		else if (RocketsLoaded==6)PlayAnim( 'Loading3', 0.6, 0.05);
		FinishAnim();
		if (RocketsLoaded==1)PlayAnim( 'Rotate1', 0.6, 0.05);
		else if (RocketsLoaded==2)PlayAnim( 'Rotate2', 0.6, 0.05);
		else if (RocketsLoaded==3)PlayAnim( 'Rotate3', 0.6, 0.05);
		else if (RocketsLoaded==4)PlayAnim( 'Rotate4', 0.6, 0.05);
		else if (RocketsLoaded==5)PlayAnim( 'Rotate2', 0.6, 0.05);
		else if (RocketsLoaded==6)PlayAnim( 'Rotate3', 0.6, 0.05);
		if (pawn(Owner).bAltFire!=0) bTightWad=True;
		NewTarget = CheckTarget();
		if ( Pawn(NewTarget) != None )
			Pawn(NewTarget).WarnTarget(Pawn(Owner), ProjectileSpeed, vector(Pawn(Owner).ViewRotation));	
		If ( (LockedTarget != None) && (NewTarget != LockedTarget) ) 
		{
			LockedTarget = None;
			Owner.PlaySound(Misc2Sound, SLOT_None, Pawn(Owner).SoundDampening);
			bLockedOn=False;
		}
		else if (LockedTarget != None)
 			Owner.PlaySound(Misc1Sound, SLOT_None, Pawn(Owner).SoundDampening);
		bPointing = true;
		if ( Level.Game.Difficulty > 0 )
			Owner.MakeNoise(0.15 * Level.Game.Difficulty * Pawn(Owner).SoundDampening);		
		RocketsLoaded++;
		AmmoType.UseAmmo(1);
	}
}

///////////////////////////////////////////////////////
state Idle
{
	function Timer()
	{
		NewTarget = CheckTarget();
		if ( NewTarget == OldTarget )
		{
			LockedTarget = NewTarget;
			If (LockedTarget != None) 
			{
				bLockedOn=True;			
				Owner.MakeNoise(Pawn(Owner).SoundDampening);
				Owner.PlaySound(Misc1Sound, SLOT_None,Pawn(Owner).SoundDampening);
				if ( (Pawn(LockedTarget) != None) && (FRand() < 0.7) )
					Pawn(LockedTarget).WarnTarget(Pawn(Owner), ProjectileSpeed, vector(Pawn(Owner).ViewRotation));	
			}
		}
		else if( (OldTarget != None) && (NewTarget == None) ) 
		{
			Owner.PlaySound(Misc2Sound, SLOT_None,Pawn(Owner).SoundDampening);
			bLockedOn = False;
		}
		else 
		{
			LockedTarget = None;
			bLockedOn = False;
		}
		OldTarget = NewTarget;
	}
Begin:
	if (Pawn(Owner).bFire!=0) Fire(0.0);
	if (Pawn(Owner).bAltFire!=0) AltFire(0.0);	
	bPointing=False;
	if (AmmoType.AmmoAmount<=0) 
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	LoopAnim('Idle', 0.01,0.4);
	OldTarget = CheckTarget();
	SetTimer(1.25,True);
	LockedTarget = None;
	bLockedOn = False;
}

///////////////////////////////////////////////////////
state FireRockets
{
	function Fire(float F) {}
	function AltFire(float F) {}

	function BeginState()
	{
		local vector FireLocation, StartLoc, X,Y,Z;
		local rotator FireRot;
		local rocket r;
		local grenade g;
		local float Angle;
		local pawn BestTarget;
		local int DupRockets;

		Angle = 0;
		DupRockets = RocketsLoaded - 1;
		if (DupRockets < 0) DupRockets = 0;
		if ( PlayerPawn(Owner) != None )
		{
			PlayerPawn(Owner).shakeview(ShakeTime, ShakeMag*RocketsLoaded, ShakeVert); //shake player view
			PlayerPawn(Owner).ClientInstantFlash( -0.4, vect(650, 450, 190));
		}
		else
			bTightWad = ( FRand() * 4 < Pawn(Owner).skill );

		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		StartLoc = Owner.Location + CalcDrawOffset(); 
		FireLocation = StartLoc + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
		if ( bFireLoad ) 		
			AdjustedAim = pawn(owner).AdjustAim(ProjectileSpeed, FireLocation, AimError, True, bWarnTarget);
		else 
			AdjustedAim = pawn(owner).AdjustToss(AltProjectileSpeed, FireLocation, AimError, True, bAltWarnTarget);	
			
		if ( PlayerPawn(Owner) != None )
			AdjustedAim = Pawn(Owner).ViewRotation;
			
		if (RocketsLoaded==1)PlayAnim( 'Fire1', 0.6, 0.05);
		else if (RocketsLoaded==2)PlayAnim( 'Fire2', 0.6, 0.05);
		else if (RocketsLoaded==3)PlayAnim( 'Fire3', 0.6, 0.05);
		else if (RocketsLoaded==4)PlayAnim( 'Fire4', 0.6, 0.05);
		else if (RocketsLoaded==5)PlayAnim( 'Fire5', 0.6, 0.05);
		else if (RocketsLoaded==6)PlayAnim( 'Fire6', 0.6, 0.05);
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		if ( (LockedTarget!=None) || !bFireLoad )
		{
			BestTarget = Pawn(CheckTarget());
			if ( (LockedTarget!=None) && (LockedTarget != BestTarget) ) 
			{
				LockedTarget = None;
				bLockedOn=False;
			}
		}
		else 
			BestTarget = None;
		bPointing = true;
		FireRot = AdjustedAim;
		RocketRad = 4;
		if (bTightWad || !bFireLoad) RocketRad=7;
		While ( RocketsLoaded > 0 )
		{
			Firelocation = StartLoc - Sin(Angle)*Y*RocketRad + (Cos(Angle)*RocketRad - 10.78)*Z + X * (10 + 8 * FRand());
			if (bFireLoad)
			{
				if ( Angle > 0 )
				{
					if ( Angle < 3 && !bTightWad)
						FireRot.Yaw = AdjustedAim.Yaw - Angle * 600;
					else if ( Angle > 3.5 && !bTightWad)
						FireRot.Yaw = AdjustedAim.Yaw + (Angle - 3)  * 600;
					else
						FireRot.Yaw = AdjustedAim.Yaw;
				}
				if ( LockedTarget!=None )
				{
					r = Spawn( class 'SeekingRocket',, '', FireLocation,FireRot);	
					r.Seeking = LockedTarget;
					r.NumExtraRockets = DupRockets;					
				}
				else 
				{
					r = Spawn( class 'Rocket',, '', FireLocation,FireRot);
					r.NumExtraRockets = DupRockets;
					if (RocketsLoaded>5 && bTightWad) r.bRing=True;
				}
				if ( Angle > 0 )
					r.Velocity *= (0.9 + 0.2 * FRand());			
			}
			else 
			{
				g = Spawn( class 'Grenade',, '', FireLocation,AdjustedAim);
				g.WarnTarget = ScriptedPawn(BestTarget);
				g.NumExtraGrenades = DupRockets;
				Owner.PlaySound(AltFireSound, SLOT_None, 3.0*Pawn(Owner).SoundDampening);				
			}

			Angle += 1.0484; //2*3.1415/6;
			RocketsLoaded--;
		}
		bTightWad=False;
		//bFireMem = false;
		//bAltFireMem = false;		
	}

Begin:
	FinishAnim();
	if (AmmoType.AmmoAmount > 0) 
	{	
		Owner.PlaySound(CockingSound, SLOT_None,Pawn(Owner).SoundDampening);		
		PlayAnim('Loading', 1.5,0.0);	
		FinishAnim();		
		RocketsLoaded = 1;
	}
	LockedTarget = None;
	Finish();	
}

defaultproperties
{
     AmmoName=Class'UnrealShare.RocketCan'
     PickupAmmoCount=6
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     bRecommendSplashDamage=True
     ProjectileClass=Class'UnrealShare.Rocket'
     AltProjectileClass=Class'UnrealShare.Grenade'
     shakemag=350.000000
     shaketime=0.200000
     shakevert=7.500000
     AIRating=0.700000
     RefireRate=0.250000
     AltRefireRate=0.250000
     AltFireSound=Sound'UnrealShare.Eightball.EightAltFire'
     CockingSound=Sound'UnrealShare.Eightball.Loading'
     SelectSound=Sound'UnrealShare.Eightball.Selecting'
     Misc1Sound=Sound'UnrealShare.Eightball.SeekLock'
     Misc2Sound=Sound'UnrealShare.Eightball.SeekLost'
     Misc3Sound=Sound'UnrealShare.Eightball.BarrelMove'
     DeathMessage="%o was smacked down multiple times by %k's %w."
     AutoSwitchPriority=5
     InventoryGroup=5
     PickupMessage="You got the eightball gun"
     ItemName="eightball"
     PlayerViewOffset=(X=1.200000,Y=-0.500000,Z=-0.900000)
     PlayerViewMesh=Mesh'Pack.Eightm'
     BobDamping=0.985000
     PickupViewMesh=Mesh'UnrealShare.EightPick'
     ThirdPersonMesh=Mesh'UnrealShare.8Ball3rd'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=Mesh'UnrealShare.EightPick'
     bNoSmooth=False
     bMeshCurvy=False
     CollisionHeight=10.000000
}
