/*-----------------------------------------------------------------------------
	Shotgun
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Shotgun expands dnWeapon;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

var()			int			PelletCount;
var()			float		PelletRandHoriz;
var()			float		PelletRandVert;
var				int			Pellet;
var				float		ShotHoriz[10], ShotVert[10];

// The current hitpackage, only valid during TraceFire;
var				HitPackage_Shotgun MetaHit;
var				int			MetaHitIndex;

var				bool		ClientInterruptReload;



/*-----------------------------------------------------------------------------
	Shell Cases
-----------------------------------------------------------------------------*/
/*
simulated function SpawnShell(vector Loc, vector Vel)
{
	local int pIndex;
	local SoftParticleSystem.Particle p;
	local vector X,Y,Z;

	if (ShellMaster==None)
	{
		ShellMaster = spawn(class'dnShellCaseMaster', Pawn(Owner), '', Owner.Location);
		ShellMaster.Mesh = Mesh'ShotgunShell';
        ShellMaster.BounceSound = Sound'dnsWeapn.shotgun.ShotgunShDrop03';
	}
	pIndex = ShellMaster.SpawnParticle(1);
	if (pIndex!=-1)
	{
		ShellMaster.GetParticle(pIndex, p);
		p.Location = Loc;
		p.Velocity = Vel;
		p.RotationVelocity3D = RotRand();
		p.RotationVelocity3D.Pitch = FRand()*200000.0 - 100000.0;
		p.RotationVelocity3D.Yaw = FRand()*200000.0 - 100000.0;
		p.RotationVelocity3D.Roll = FRand()*200000.0 - 100000.0;
		ShellMaster.SetParticle(pIndex, p);
	}
}

simulated function PlayNotifySound0()
{
	local shotgunshell s;
	local vector realLoc;
	local vector X,Y,Z;

	Super.PlayNotifySound0();
	*/
/*
	if (GetStateName() == 'Reloading')
		return;

	realLoc = Owner.Location + CalcDrawOffset();
	GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
	if (ActiveWAMIndex == 0)
	{
		SpawnShell(
			realLoc + (FireOffset.X+15)*X + (FireOffset.Y+6.5)*Y + (FireOffset.Z-14)*Z,
			((FRand()*0.2+0.3)*X + (FRand()*0.3+0.3)*Y + (FRand()*0.4+0.7) * Z)*160
		);
	}
	else if (ActiveWAMIndex == 1)
	{
		SpawnShell(
			realLoc + (FireOffset.X+10)*X + (FireOffset.Y+7.5)*Y + (FireOffset.Z-10)*Z, 
			((FRand()*0.1+0.0)*X + (FRand()*0.2+0.5)*Y + (FRand()*0.3+0.8) * Z)*160
		);
	}
	else if (ActiveWAMIndex == 2)
	{
		SpawnShell(
			realLoc + (FireOffset.X+10)*X + (FireOffset.Y-4.0)*Y + (FireOffset.Z-15)*Z,
			((FRand()*0.1+0.0)*X + (FRand()*0.2+0.3)*Y + (FRand()*0.3+1.1) * Z)*160
		);
	}
*/
/*
}
*/


/*-----------------------------------------------------------------------------
	Damage & Tracing
-----------------------------------------------------------------------------*/

// Returns the damage for this hit.
simulated function int GetHitDamage( actor Victim, name BoneName )
{
	local int Dmg;

	// Damage is 10.0, but 40% less for acid rounds.
    Dmg = 10.0;
	if ( AmmoType.AmmoMode == 1 )
		Dmg = float(Dmg) * 0.4;

	// Multiply by weapon third person scale for the shrinkray effect.
	Dmg *= ThirdPersonScale;

	return Max( Dmg, 1 ) ;
}

// Creates the hit package.  Shotgun uses metahits.
function SpawnHitPackage( out HitPackage hit, Actor HitOwner, vector HitLocation )
{
	MetaHit.SetOwner(HitOwner);
}

// Fills the meta hit.
function FillHitPackage( HitPackage hit, float HitDamage, Pawn HitInstigator, vector StartTrace, vector BeamStart )
{
	// Set the stats.
	MetaHit.ShotOriginX				= StartTrace.X;
	MetaHit.ShotOriginY				= StartTrace.Y;
	MetaHit.ShotOriginZ				= StartTrace.Z;
	MetaHit.Instigator				= Pawn(Owner);

	if ( AmmoType.AmmoMode == 1 )
		MetaHit.bAcidShot = true;

	// Increment the hit index.
	MetaHitIndex++;
}

function DeliverHitPackage( HitPackage hit )
{
}

// Overrides TraceFire, multiple pellets with dispersal.
simulated function TraceFire( Actor HitInstigator, 
				    optional float HorizError, optional float VertError, 
					optional bool bDontPenetrate, optional bool bEffectsOnly,
					optional bool bNoActors, optional bool bNoMeshAccurate,
					optional bool bNoCreationSounds )
{
	local int ISeed;

	MetaHit = spawn(class'HitPackage_Shotgun');
	MetaHitIndex = 0;

	// Randoms
	MetaHit.HitSeed = Level.TimeSeconds * 1000;
	Seed( MetaHit.HitSeed );
	for ( Pellet=0; Pellet<PelletCount; Pellet++ )
	{
		ShotHoriz[Pellet] = FRand();
		ShotVert[Pellet]  = FRand();
	}
	for ( Pellet=0; Pellet<PelletCount; Pellet++ )
	{
		if ( (Pellet==0) || (Pellet%3!=0) )
			bNoCreationSounds = true;
		else
			bNoCreationSounds = false;

		Super(Actor).TraceFire( HitInstigator, HorizError+PelletRandHoriz, VertError+PelletRandVert, true, bEffectsOnly, bNoActors, bNoMeshAccurate, bNoCreationSounds );
	}

	// Deliver the package right away on the authortative side.
	if ( Role == ROLE_Authority )
		MetaHit.Deliver();
}

// Gets the trace start and end with error.
simulated function GetTraceFireSegment( out vector Start, out vector End, out vector BeamStart, optional float HorizError, optional float VertError )
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local rotator AdjustedAim;

	PawnOwner = Pawn(Owner);
	GetAxes( PawnOwner.ViewRotation, X, Y, Z );
	Start = Owner.Location + PawnOwner.BaseEyeHeight * vect(0,0,1);
	AdjustedAim = PawnOwner.AdjustAim( 1000000, Start, 2*AimError, false, false );	
	End = Start + HorizError * (ShotHoriz[Pellet] - 0.5) * Y * 3000 + VertError * (ShotVert[Pellet] - 0.5) * Z * 3000;
	X = vector(AdjustedAim);
	End += (3000 * X);
}

// Does acid logic in addition to calling parent tracehit.
function TraceHit( vector StartTrace, vector EndTrace, Actor HitActor, vector HitLocation, 
				   vector HitNormal, int HitMeshTri, vector HitMeshBarys, name HitMeshBone, 
				   texture HitMeshTex, Actor HitInstigator, vector BeamStart )
{
	local dnAcidRoundFX AcidFX;

	Super.TraceHit( StartTrace, EndTrace, HitActor, HitLocation, HitNormal, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitInstigator, BeamStart );

	// Attach the acid effect.
	if ( AmmoType.AmmoMode == 1 )
	{
		if ( Level.NetMode != NM_DedicatedServer )
		{
			AcidFX = spawn( class'dnAcidRoundFX',,, HitLocation, Rotator(HitNormal) );
			if ( (HitActor != None) && (HitActor != Level) )
			{
				AcidFX.SetPhysics( PHYS_MovingBrush );
				AcidFX.AttachActorToParent( HitActor, false, false );
			}
		}
		if ( (HitActor != None) && (HitActor != Level) )
		{
			if ( HitActor.bIsPawn )
				Pawn(HitActor).AddDOT( DOT_Biochemical, 3.0, 1.0, 5.0, Instigator );
		}
	}
}



defaultproperties
{
    PelletCount=10
    PelletRandHoriz=0.13
    PelletRandVert=0.13
    SAnimActivate(0)=(AnimSound=Sound'dnsWeapn.shotgun.SGCocking1')
    SAnimFire(0)=(AnimSeq=FireA,AnimRate=1.200000,AnimSound=Sound'dnsWeapn.shotgun.ShotGFire28',AnimChance=0.4)
	SAnimFire(1)=(AnimSeq=FireB,AnimRate=1.200000,AnimSound=Sound'dnsWeapn.shotgun.ShotGFire28',AnimChance=0.4)
	SAnimFire(2)=(AnimSeq=FireC,AnimRate=1.150000,AnimSound=Sound'dnsWeapn.shotgun.ShotGFire28',AnimChance=0.2)
    SAnimIdleSmall(0)=(AnimSeq=IdleA,AnimRate=0.800000,AnimTween=0.000000,AnimChance=0.500000)
	SAnimIdleSmall(1)=(AnimSeq=IdleB,AnimRate=0.800000,AnimTween=0.000000,AnimChance=0.500000)
    SAnimIdleLarge(0)=(AnimSeq=IdleC,AnimRate=0.900000,AnimTween=0.000000,AnimChance=1.000000)
    SAnimReload(0)=(AnimSeq=ReloadShell,AnimRate=1.600000,AnimTween=0.000000)
    SAnimReloadStart(0)=(AnimSeq=ReloadUp,AnimRate=1.300000,AnimTween=0.000000,AnimChance=1.000000)
    SAnimReloadStop(0)=(AnimSeq=ReloadCock,AnimRate=1.300000,AnimTween=0.000000,AnimChance=1.000000)
    NotifySounds(0)=Sound'dnsWeapn.shotgun.SGCocking1'
	NotifySounds(1)=Sound'dnsWeapn.shotgun.SGShellLoad'
	ReloadCount=7;
	ReloadClipAmmo=1;
    AmmoName=Class'dnGame.shotgunAmmo'
    PickupAmmoCount(0)=14
    bInstantHit=True
    FireOffset=(X=2.0,Y=-1.2,Z=-8.5)
    AIRating=0.900000
    AutoSwitchPriority=4
	ItemName="Shotgun"
	PlayerViewScale=0.1
    PlayerViewOffset=(X=0.63,Y=0.66,Z=-8.5)
    PlayerViewMesh=Mesh'c_dnWeapon.shotgun'
    PickupViewMesh=Mesh'c_dnWeapon.w_shotgun'
    ThirdPersonMesh=Mesh'c_dnWeapon.w_shotgun'
    PickupSound=Sound'dnGame.Pickups.WeaponPickup'
	PickupIcon=texture'hud_effects.am_shotgun'
    Icon=Texture'hud_effects.mitem_shotgun'
    Mesh=Mesh'c_dnWeapon.w_shotgun'
    SoundRadius=128
    SoundVolume=250
    CollisionHeight=6.0
    CollisionRadius=19.0
	AltAmmoItemClass=class'HUDIndexItem_ShotgunAlt'
	AmmoItemClass=class'HUDIndexItem_Shotgun'
	bMultiMode=true

	RunAnim=(AnimSeq=A_Run_ShotGun,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    FireAnim=(AnimSeq=T_SGFire,AnimChan=WAC_Top,AnimRate=2.0,AnimTween=0.1,AnimLoop=false)
    AltFireAnim=(AnimSeq=T_M16AltFire,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    IdleAnim=(AnimSeq=T_SGIdle,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    ReloadStartAnim=(AnimSeq=T_SGReloadRaise,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    ReloadLoopAnim=(AnimSeq=T_SGReloadLoop,AnimChan=WAC_Top,AnimRate=0.8,AnimTween=0.1,AnimLoop=true)
    ReloadStopAnim=(AnimSeq=T_SGReloadCock,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchIdleAnim=(AnimSeq=T_CrchIdle_Shotgun,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchWalkAnim=(AnimSeq=A_CrchWalk_Shotgun,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchFireAnim=(AnimSeq=T_CrchFire_Shtgun,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)

    ReloadLoops=true

	MuzzleFlashOrigin=(X=0,Y=0,Z=8)
	MuzzleFlashClass=class'ShotgunFlash'
	MuzzleFlashSprites(0)=texture'm_dnWeapon.shtgunflash1aRC'
	MuzzleFlashSprites(1)=texture'm_dnWeapon.shtgunflash1bRC'
	MuzzleFlashSprites(2)=texture'm_dnWeapon.shtgunflash1cRC'
	MuzzleFlashSprites(3)=texture'm_dnWeapon.shtgunflash1dRC'
	MuzzleFlashSprites(4)=texture'm_dnWeapon.shtgunflash1eRC'
	MuzzleFlashSprites(5)=texture'm_dnWeapon.shtgunflash1fRC'
	NumFlashSprites=6
	SpriteFlashX=440.0
	SpriteFlashY=360.0
	MuzzleFlashScale=2.5
	UseSpriteFlash=true

	bBoneDamage=true
	bDecapitates=true

	dnInventoryCategory=1
	dnCategoryPriority=1

	LodMode=LOD_Disabled

	bReloadStart=true
	bReloadStop=true

	CrosshairIndex=4
	bWeaponPenetrates=false
	TraceDamageType=class'ShotgunDamage'

	bFireIgnites=true
	bUseMuzzleAnchor=true
	bInterruptableReload=true
}
