//=============================================================================
// Translocator.
//=============================================================================
class Translocator extends TournamentWeapon;

#exec MESH  IMPORT MESH=Transloc ANIVFILE=MODELS\Translocator_a.3D DATAFILE=MODELS\Translocator_d.3D UNMIRROR=1
#exec MESH ORIGIN MESH=Transloc X=0 Y=0 Z=0 YAW=-61 PITCH=0 ROLL=-5
#exec MESH SEQUENCE MESH=Transloc SEQ=All	 	 STARTFRAME=0  NUMFRAMES=110
#exec MESH SEQUENCE MESH=Transloc SEQ=Throw     STARTFRAME=32 NUMFRAMES=19
#exec MESH SEQUENCE MESH=Transloc SEQ=PreReset  STARTFRAME=46 NUMFRAMES=5
#exec MESH SEQUENCE MESH=Transloc SEQ=Idle      STARTFRAME=51 NUMFRAMES=2 RATE=3
#exec MESH SEQUENCE MESH=Transloc SEQ=Still     STARTFRAME=51 NUMFRAMES=2 RATE=3
#exec MESH SEQUENCE MESH=Transloc SEQ=Down 		STARTFRAME=66 NUMFRAMES=7
#exec MESH SEQUENCE MESH=Transloc SEQ=Select	 STARTFRAME=18 NUMFRAMES=12
#exec MESH SEQUENCE MESH=Transloc SEQ=Thrown	 STARTFRAME=53 NUMFRAMES=12
#exec MESH SEQUENCE MESH=Transloc SEQ=ThrownFrame	STARTFRAME=52 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Transloc SEQ=Down2 	STARTFRAME=77 NUMFRAMES=7
#exec MESH SEQUENCE MESH=Transloc SEQ=Idle2	STARTFRAME=88 NUMFRAMES=19

#exec TEXTURE IMPORT NAME=tloc1 FILE=MODELS\tran1.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=tloc2 FILE=MODELS\tran2.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=tloc3 FILE=MODELS\tran3.PCX GROUP="Skins" LODSET=2
#exec TEXTURE IMPORT NAME=tloc4 FILE=MODELS\tran4.PCX GROUP="Skins" LODSET=2

#exec MESHMAP SCALE MESHMAP=Transloc X=0.0065 Y=0.0045 Z=0.011
#exec MESHMAP SETTEXTURE MESHMAP=Transloc NUM=0 TEXTURE=tloc1
#exec MESHMAP SETTEXTURE MESHMAP=Transloc NUM=1 TEXTURE=tloc2
#exec MESHMAP SETTEXTURE MESHMAP=Transloc NUM=2 TEXTURE=tloc3
#exec MESHMAP SETTEXTURE MESHMAP=Transloc NUM=3 TEXTURE=tloc4

// Right handed version
#exec MESH  IMPORT MESH=TranslocR ANIVFILE=MODELS\Translocator_a.3D DATAFILE=MODELS\Translocator_d.3D
#exec MESH ORIGIN MESH=TranslocR X=0 Y=0 Z=0 YAW=-64 PITCH=0 ROLL=5
#exec MESH SEQUENCE MESH=TranslocR SEQ=All	 	 STARTFRAME=0  NUMFRAMES=110
#exec MESH SEQUENCE MESH=TranslocR SEQ=Throw     STARTFRAME=32 NUMFRAMES=19
#exec MESH SEQUENCE MESH=TranslocR SEQ=PreReset  STARTFRAME=46 NUMFRAMES=5
#exec MESH SEQUENCE MESH=TranslocR SEQ=Idle      STARTFRAME=51 NUMFRAMES=2 RATE=3
#exec MESH SEQUENCE MESH=TranslocR SEQ=Still     STARTFRAME=51 NUMFRAMES=2 RATE=3
#exec MESH SEQUENCE MESH=TranslocR SEQ=Down 	 STARTFRAME=66 NUMFRAMES=7
#exec MESH SEQUENCE MESH=TranslocR SEQ=Select	 STARTFRAME=18 NUMFRAMES=12
#exec MESH SEQUENCE MESH=TranslocR SEQ=Thrown	 STARTFRAME=53 NUMFRAMES=12
#exec MESH SEQUENCE MESH=TranslocR SEQ=ThrownFrame	STARTFRAME=52 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TranslocR SEQ=Down2 	STARTFRAME=77 NUMFRAMES=7
#exec MESH SEQUENCE MESH=TranslocR SEQ=Idle2	STARTFRAME=88 NUMFRAMES=19

#exec MESHMAP SCALE MESHMAP=TranslocR X=0.0065 Y=0.0045 Z=0.011
#exec MESHMAP SETTEXTURE MESHMAP=TranslocR NUM=0 TEXTURE=tloc1
#exec MESHMAP SETTEXTURE MESHMAP=TranslocR NUM=1 TEXTURE=tloc2
#exec MESHMAP SETTEXTURE MESHMAP=TranslocR NUM=2 TEXTURE=tloc3
#exec MESHMAP SETTEXTURE MESHMAP=TranslocR NUM=3 TEXTURE=tloc4

#exec MESH  IMPORT MESH=Trans3loc ANIVFILE=MODELS\Tran3rd_a.3D DATAFILE=MODELS\Tran3rd_d.3D X=0 Y=0 Z=0 
#exec MESH ORIGIN MESH=Trans3loc X=0 Y=0 Z=-75 YAW=-64 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=Trans3loc SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Trans3loc X=0.023 Y=0.023 Z=0.046
#exec MESHMAP SETTEXTURE MESHMAP=Trans3loc NUM=0 TEXTURE=tloc1
#exec MESHMAP SETTEXTURE MESHMAP=Trans3loc NUM=1 TEXTURE=tloc2

#exec AUDIO IMPORT FILE="Sounds\translocator\tranfire2.wav" NAME="ThrowTarget" GROUP="Translocator"
#exec AUDIO IMPORT FILE="Sounds\translocator\tranreturn.wav" NAME="ReturnTarget" GROUP="Translocator"

#exec TEXTURE IMPORT NAME=IconTrans FILE=TEXTURES\HUD\WpnTrans.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=UseTrans FILE=TEXTURES\HUD\UseTrans.PCX GROUP="Icons" MIPS=OFF

var TranslocatorTarget TTarget;
var float TossForce, FireDelay;
var Weapon PreviousWeapon;
var Actor DesiredTarget;
var float MaxTossForce;
var bool bBotMoveFire, bTTargetOut;

replication
{
	reliable if ( bNetOwner && (Role == ROLE_Authority) )
		bTTargetOut;
}

function setHand(float Hand)
{
	if ( Hand != 2 )
	{
		if ( Hand == 0 )
			Hand = 1;
		else
			Hand *= -1;

		if ( Hand == -1 )
			Mesh = mesh(DynamicLoadObject("Botpack.TranslocR", class'Mesh'));
		else
			Mesh = mesh'Botpack.Transloc';
	}
	Super.SetHand(Hand);
}

function float RateSelf( out int bUseAltMode )
{
	return -2; 
}

function BringUp()
{
	PreviousWeapon = None;
	Super.BringUp();
}

function RaiseUp(Weapon OldWeapon)
{
	if ( OldWeapon == self )
		PreviousWeapon = None;
	else
		PreviousWeapon = OldWeapon;
	Super.BringUp();
}

// return delta to combat style
function float SuggestAttackStyle()
{
	local float EnemyDist;

	if ( bTTargetOut )
		return -0.6;

	EnemyDist = VSize(Pawn(Owner).Enemy.Location - Owner.Location);
	if ( EnemyDist < 700 )
		return 1.0;
	else
		return -0.2;
}

function float SuggestDefenseStyle()
{	
	if ( bTTargetOut )
		return 0;

	return -0.6;
}
	
function bool HandlePickupQuery( inventory Item )
{
	if ( Item.IsA('TranslocatorTarget') && (item == TTarget) )
	{
		TTarget.Destroy();
		TTarget = None;
		bTTargetOut = false;
		return true;
	}
	else
		return Super.HandlePickupQuery(Item);
}

function Destroyed()
{
	Super.Destroyed();
	if ( TTarget != None )
		TTarget.Destroy();
}

function SetSwitchPriority(pawn Other)
{
	AutoSwitchPriority = 0;
}

simulated function ClientWeaponEvent(name EventType)
{
	if ( EventType == 'TouchTarget' )
		PlayIdleAnim();
}

function Fire( float Value )
{
	if ( bBotMoveFire )
		return;
	if (  TTarget == None )
	{
		if ( Level.TimeSeconds - 0.5 > FireDelay )
		{
			bPointing=True;
			bCanClientFire = true;
			ClientFire(value);
			Pawn(Owner).PlayRecoil(FiringSpeed);
			ThrowTarget();
		}
	}
	else if ( TTarget.SpawnTime < Level.TimeSeconds - 0.8 )
	{
		if ( TTarget.Disrupted() )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_None, 4.0);
			Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_Misc, 4.0);
			Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_Interact, 4.0);
			Pawn(Owner).gibbedBy(TTarget.disruptor);
			return;
		}
		Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		bTTargetOut = false;
		TTarget.Destroy();
		TTarget = None;
		FireDelay = Level.TimeSeconds;
	}

	GotoState('NormalFire');
}

simulated function bool ClientFire(float Value)
{
	if ( !bTTargetOut && bCanClientFire )
	{
		PlayFiring();
		return true;
	}
	return false;
}

simulated function bool ClientAltFire( float Value )
{
	return true;
}

function SpawnEffect(vector Start, vector Dest)
{
	local actor e;

	e = Spawn(class'TranslocOutEffect',,,start, Owner.Rotation);
	e.Mesh = Owner.Mesh;
	e.Animframe = Owner.Animframe;
	e.Animsequence = Owner.Animsequence;
	e.Velocity = 900 * Normal(Dest - Start);
}

function Translocate()
{
	local vector Dest, Start;
	local Bot B;
	local Pawn P;

	bBotMoveFire = false;
	PlayAnim('Thrown', 1.2,0.1);
	Dest = TTarget.Location;
	if ( TTarget.Physics == PHYS_None )
		Dest += vect(0,0,40);
		
	if ( Level.Game.IsA('DeathMatchPlus') 
		&& !DeathMatchPlus(Level.Game).AllowTranslocation(Pawn(Owner), Dest) )
		return;

	Start = Pawn(Owner).Location;
	TTarget.SetCollision(false,false,false);
	if ( Pawn(Owner).SetLocation(Dest) )
	{
		if ( !Owner.Region.Zone.bWaterZone )
			Owner.SetPhysics(PHYS_Falling);
		if ( TTarget.Disrupted() )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			SpawnEffect(Start, Dest);
			Pawn(Owner).gibbedBy(TTarget.disruptor);
			return;
		}

		if ( !FastTrace(Pawn(Owner).Location, TTarget.Location) )
		{
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			Pawn(Owner).SetLocation(Start);
			Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		}	
		else 
		{ 
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogSpecialEvent("translocate", Pawn(Owner).PlayerReplicationInfo.PlayerID);
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogSpecialEvent("translocate", Pawn(Owner).PlayerReplicationInfo.PlayerID);

			Owner.Velocity.X = 0;
			Owner.Velocity.Y = 0;
			B = Bot(Owner);
			if ( B != None )
			{
				if ( TTarget.DesiredTarget.IsA('NavigationPoint') )
					B.MoveTarget = TTarget.DesiredTarget;
				B.bJumpOffPawn = true;
				if ( !Owner.Region.Zone.bWaterZone )
					B.SetFall();
			}
			else
			{
				// bots must re-acquire this player
				for ( P=Level.PawnList; P!=None; P=P.NextPawn )
					if ( (P.Enemy == Owner) && P.IsA('Bot') )
						Bot(P).LastAcquireTime = Level.TimeSeconds;
			}

			Level.Game.PlayTeleportEffect(Owner, true, true);
			SpawnEffect(Start, Dest);
		}
	} 
	else 
	{
		Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogSpecialEvent("translocate_fail", Pawn(Owner).PlayerReplicationInfo.PlayerID);
	}

	if ( TTarget != None )
	{
		bTTargetOut = false;
		TTarget.Destroy();
		TTarget = None;
	}
	bPointing=True;
}

function AltFire( float Value )
{
	if ( bBotMoveFire )
		return;

	GotoState('NormalFire');

	if ( TTarget != None )
		Translocate();
}

function ReturnToPreviousWeapon()
{
	if ( (PreviousWeapon == None)
		|| ((PreviousWeapon.AmmoType != None) && (PreviousWeapon.AmmoType.AmmoAmount <=0)) )
		Pawn(Owner).SwitchToBestWeapon();
	else
	{
		Pawn(Owner).PendingWeapon = PreviousWeapon;
		PutDown();
	}
}

simulated function PlayFiring()
{
	PlayOwnedSound(FireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);	
	PlayAnim('Throw',1.0,0.1);
}

function ThrowTarget()
{
	local Vector Start, X,Y,Z;	

	if (Level.Game.LocalLog != None)
		Level.Game.LocalLog.LogSpecialEvent("throw_translocator", Pawn(Owner).PlayerReplicationInfo.PlayerID);
	if (Level.Game.WorldLog != None)
		Level.Game.WorldLog.LogSpecialEvent("throw_translocator", Pawn(Owner).PlayerReplicationInfo.PlayerID);

	if ( Owner.IsA('Bot') )
		bBotMoveFire = true;
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 		
	Pawn(Owner).ViewRotation = Pawn(Owner).AdjustToss(TossForce, Start, 0, true, true); 
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);		
	TTarget = Spawn(class'TranslocatorTarget',,, Start);
	if (TTarget!=None)
	{
		bTTargetOut = true;
		TTarget.Master = self;
		if ( Owner.IsA('Bot') )
			TTarget.SetCollisionSize(0,0); 
		TTarget.Throw(Pawn(Owner), MaxTossForce, Start);
	}
	else GotoState('Idle');
}

state NormalFire
{
	ignores fire, altfire, AnimEnd;

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	if ( Owner.IsA('Bot') )
		Bot(Owner).SwitchToBestWeapon();
	Sleep(0.1);
	if ( (Pawn(Owner).bFire != 0) && (Pawn(Owner).bAltFire != 0) )
	 	ReturnToPreviousWeapon();
	GotoState('Idle');
}

state Idle
{
	function AnimEnd()
	{
		PlayIdleAnim();
	}

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}

Begin:
	bPointing=False;
	if ( Pawn(Owner).bFire!=0 ) Fire(0.0);
	if ( Pawn(Owner).bAltFire!=0 ) AltFire(0.0);	
	Disable('AnimEnd');
	FinishAnim();
	PlayIdleAnim();
}


///////////////////////////////////////////////////////////
simulated function PlayIdleAnim()
{
	if ( Mesh == PickupViewMesh )
		return;
	if ( bTTargetOut )
		LoopAnim('Idle', 0.4);
	else  
		LoopAnim('Idle2',0.2,0.1);
	Enable('AnimEnd');
}

simulated function PlaySelect()
{
	bForceFire = false;
	bForceAltFire = false;
	if ( bTTargetOut )
		TweenAnim('ThrownFrame', 0.27);
	else
		PlayAnim('Select',1.1, 0.0);
	PlaySound(SelectSound, SLOT_Misc,Pawn(Owner).SoundDampening);		
}


simulated function TweenDown()
{
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.36 );
	else
	{
		if ( bTTargetOut ) PlayAnim('Down2', 1.1, 0.05);
		else PlayAnim('Down', 1.1, 0.05);
	}
}

simulated function PlayPostSelect()
{
	local actor RealTarget;

	if ( Level.NetMode == NM_Client )
	{
		Super.PlayPostSelect();
		return;
	}

	// If Bot is wanting a specific target fired at, do it
	if ( DesiredTarget != None )
	{
		TossForce = MaxTossForce;
		RealTarget = Owner.Target;
		Owner.Target = DesiredTarget;
		ThrowTarget();
		PlayFiring();
		Owner.Target = RealTarget;
		TTarget.DesiredTarget = DesiredTarget;
		DesiredTarget = None;
	}	
}

defaultproperties
{
     ItemName="Translocator"
     MaxTossForce=830.000000
     PickupAmmoCount=1
     bCanThrow=False
     FiringSpeed=1.000000
     FireOffset=(X=15.000000,Y=-13.000000,Z=-7.000000)
     AIRating=-1.000000
     FireSound=Sound'Botpack.Translocator.ThrowTarget'
     AltFireSound=Sound'Botpack.Translocator.ReturnTarget'
     DeathMessage="%k telefragged %o!"
     AutoSwitchPriority=0
     PickupMessage="You got the Translocator Source Module."
     RespawnTime=0.000000
     PlayerViewOffset=(X=5.000000,Y=-4.200000,Z=-7.000000)
     PlayerViewMesh=Mesh'Botpack.Transloc'
     PickupViewMesh=Mesh'Botpack.Trans3loc'
     ThirdPersonMesh=Mesh'Botpack.Trans3loc'
     StatusIcon=Texture'Botpack.Icons.UseTrans'
     Icon=Texture'Botpack.Icons.UseTrans'
     Mesh=Mesh'Botpack.Trans3loc'
     bNoSmooth=False
     CollisionRadius=8.000000
     CollisionHeight=3.000000
     Mass=10.000000
     WeaponDescription="Classification: Personal Teleportation Device\\n\\nPrimary Fire: Launches the destination module.  Throw the module to the location you would like to teleport to.\\n\\nSecondary Fire: Activates the translocator and teleports the user to the destination module.\\n\\nTechniques: Throw your destination module at another player and then activate the secondary fire, and you will telefrag your opponent!  If you press your primary fire button when activating your translocator with the secondary fire, the last weapon you had selected will automatically return once you have translocated."
}
