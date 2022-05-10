/*-----------------------------------------------------------------------------
	Pistol
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Pistol expands dnWeapon;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx
#exec OBJ LOAD FILE=..\Textures\m_dnWeapon.dtx

var()			float				SustainedRefireTime;
var transient	bool				bReFireState;
var transient	bool				bReFireReady;
var transient	bool				bReFireDone;
var				actor				FireOffsetMarker;
var				float				LastRefireTime;

var				texture				PistolClips[3];

var(Animation) WAMEntry				SAnimFireHP[4];
var(Animation) WAMEntry				SAnimFireAP[4];



/*-----------------------------------------------------------------------------
	Initialization
-----------------------------------------------------------------------------*/

// Eh.  Eh...,makes the weapon gold if yer Duke.
function MakeDesertEagle()
{
    if ( PlayerPawn(Instigator) != None )
    {
        PickupViewMesh = DukeMesh'c_dnWeapon.w_pistol';
        ThirdPersonMesh = DukeMesh'c_dnWeapon.w_pistol';
    }
}

function BecomePickup()
{
    MakeDesertEagle();
    Super.BecomePickup();
}

function BecomeItem()
{
    MakeDesertEagle();
    Super.BecomeItem();
}



/*-----------------------------------------------------------------------------
	Damage & Tracing
-----------------------------------------------------------------------------*/

// Returns the damage values for this hit.
simulated function int GetHitDamage( actor Victim, name BoneName )
{
    local Pawn.EPawnBodyPart BodyPart;
	local float Dmg;
    
    BodyPart = BODYPART_Default;
    if (Pawn(Victim)!=None)
		BodyPart = Pawn(Victim).GetPartForBone( BoneName );

	switch(BodyPart)
	{
	case BODYPART_Head:
		if (PlayerPawn(Owner)!=None)
			Dmg = 20.0;
		else 
			Dmg = 10.0;
		break;
	case BODYPART_Chest:
	case BODYPART_Stomach:
		Dmg = 8.0;
		break;
	case BODYPART_Crotch:
	case BODYPART_ShoulderLeft:
	case BODYPART_ShoulderRight:
	case BODYPART_KneeLeft:
	case BODYPART_KneeRight:
	case BODYPART_Default:
	case BODYPART_HandLeft:
	case BODYPART_HandRight:
	case BODYPART_FootLeft:
	case BODYPART_FootRight:
		Dmg = 6.0;
		break;
	}

	// Mutliply by ammo type multiplier.
	Dmg *= AmmoType.GetModeDamageMultiplier();

	// Multiply by weapon third person scale for the shrinkray effect.
	Dmg *= ThirdPersonScale;
	
	// JC: Temp
	if (PlayerPawn( Owner ) != None)
		return Max( int(Dmg), 1 );
	else
		return Max( int(Dmg * 1.33), 1 );
}

// Does tracefire, but adds some error.
simulated function TraceFire( Actor HitInstigator, 
				    optional float HorizError, optional float VertError, 
					optional bool bDontPenetrate, optional bool bEffectsOnly,
					optional bool bNoActors, optional bool bNoMeshAccurate,
					optional bool bNoCreationSounds )
{
	local float AccMod;

	AccMod = 0.02 + AmmoType.GetModeAccuracyModifier();
	Super.TraceFire( HitInstigator, HorizError+AccMod, VertError+AccMod, bDontPenetrate, bEffectsOnly, bNoActors, bNoMeshAccurate, bNoCreationSounds );
}



/*-----------------------------------------------------------------------------
	Animation Events
-----------------------------------------------------------------------------*/

// Modified so that we have different skins depending on what kind of clip we are using.
simulated function WpnFire( optional bool noWait )
{
	local WAMEntry entry;

	// Play the animation.
	if ( AmmoType.AmmoMode == 2 )
		ActiveWAMIndex = GetRandomWAMEntry( SAnimFireAP, entry );
	else if ( AmmoType.AmmoMode == 1 )
		ActiveWAMIndex = GetRandomWAMEntry( SAnimFireHP, entry );
	else
		ActiveWAMIndex = GetRandomWAMEntry( SAnimFire, entry );
	PlayWAMEntry( entry, false, 'None' );

    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayFire();

    WeaponState = WS_FIRE;

	// Increment the fire Impulse so the clients know that this weapon has fired
    WeaponFireImpulse++;

	// Do client side effects that are animation driven.
	ClientSideEffects();

    bDontPlayOwnerAnimation = false;
}

// Modified so that we have different skins depending on what kind of clip we are using.
simulated function WpnReload( optional bool noWait )
{
	MultiSkins[3] = PistolClips[AmmoType.AmmoMode];

	Super.WpnReload(noWait);
}



defaultproperties
{
	SAnimActivate(0)=(AnimSound=Sound'dnsWeapn.pistol.PActivate1')
	SAnimFire(0)=(AnimChance=1.000000,animSeq=FireA,AnimRate=0.900000,AnimSound=Sound'dnsWeapn.pistol.GunFire055')
	SAnimFireHP(0)=(AnimChance=1.000000,animSeq=FireA,AnimRate=0.900000,AnimSound=Sound'dnsWeapn.pistol.HPFire')
	SAnimFireAP(0)=(AnimChance=1.000000,animSeq=FireA,AnimRate=0.900000,AnimSound=Sound'dnsWeapn.pistol.ArmorPierceFire01')
	SAnimFireStop(0)=(AnimChance=1.000000,animSeq=FireEndA,AnimRate=1.000000,AnimTween=0.070000)
	SAnimReload(0)=(AnimChance=0.900000,animSeq=Reload,AnimRate=1.3)
	SAnimReload(1)=(AnimChance=0.100000,animSeq=ReloadB,AnimRate=1.3)
	SAnimIdleSmall(0)=(AnimChance=0.500000,animSeq=IdleA,AnimRate=0.750000,AnimTween=0.100000)
	SAnimIdleSmall(1)=(AnimChance=0.500000,animSeq=IdleB,AnimRate=0.750000,AnimTween=0.100000)
	SAnimIdleLarge(0)=(AnimChance=0.500000,animSeq=IdleC,AnimRate=1.000000)
	SAnimIdleLarge(1)=(AnimChance=0.500000,animSeq=IdleD,AnimRate=1.000000)

	PistolClips(0)=texture'm_dnWeapon.goldclip1BC'
	PistolClips(1)=texture'm_dnWeapon.goldclip_blue1B'
	PistolClips(2)=texture'm_dnWeapon.goldclip_red1BC'

	SustainedRefireTime=5.000000
	AmmoName=Class'dnGame.pistolClip'
	AmmoLoaded=15
	ReloadCount=15
	PickupAmmoCount=45
	bInstantHit=True
	bAltInstantHit=True
	FireOffset=(X=0.0,Y=-0.83,Z=-5.6)
	AIRating=0.900000
	AutoSwitchPriority=3
	PlayerViewOffset=(X=2.0,Y=0.225,Z=-9.0)
	PlayerViewScale=0.1
	PlayerViewMesh=DukeMesh'c_dnWeapon.pistol'
	PickupViewMesh=DukeMesh'c_dnWeapon.w_pistol_black'
	ThirdPersonMesh=DukeMesh'c_dnWeapon.w_pistol_black'
	PickupSound=Sound'dnGame.Pickups.WeaponPickup'
	Icon=Texture'hud_effects.mitem_deagle'
	PickupIcon=Texture'hud_effects.am_deserteagle'
	AnimRate=4.000000
	Mesh=DukeMesh'c_dnWeapon.w_pistol_black'
	SoundRadius=64
	SoundVolume=200
	CollisionHeight=6.0
	CollisionRadius=18.0
	Mass=1.000000

	AltAmmoItemClass=class'HUDIndexItem_PistolAlt'
	AmmoItemClass=class'HUDIndexItem_Pistol'
	bMultiMode=true

    RunAnim=(AnimSeq=A_Run,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    FireAnim=(AnimSeq=T_Pistol2HandFire,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    IdleAnim=(AnimSeq=T_Pistol2HandIdle,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    ReloadStartAnim=(AnimSeq=T_Pistol2HandReload,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    CrouchIdleAnim=(AnimSeq=T_CrchIdle_Pistol,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchWalkAnim=(AnimSeq=A_CrchWalk_Pistol,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    CrouchFireAnim=(AnimSeq=T_CrchFire_Pistol,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)

	MuzzleFlashOrigin=(X=0,Y=0,Z=-9)
	MuzzleFlashClass=class'PistolFlash'
	MuzzleFlashSprites(0)=texture'm_dnWeapon.pistolflash1aRC'
	MuzzleFlashSprites(1)=texture'm_dnWeapon.pistolflash1bRC'
	MuzzleFlashSprites(2)=texture'm_dnWeapon.pistolflash1cRC'
	MuzzleFlashSprites(3)=texture'm_dnWeapon.pistolflash1dRC'
	MuzzleFlashSprites(4)=texture'm_dnWeapon.pistolflash1eRC'
	MuzzleFlashSprites(5)=texture'm_dnWeapon.pistolflash1fRC'
	NumFlashSprites=6
	SpriteFlashX=530.0
	SpriteFlashY=430.0
	MuzzleFlashScale=2.0
	UseSpriteFlash=true

	NotifySounds(0)=sound'dnsWeapn.pistol.PClipEject1'
	NotifySounds(1)=sound'dnsWeapn.pistol.PClipIns1'
	NotifySounds(2)=sound'dnsWeapn.pistol.PSlideBack1'
	ShellBounceSound=sound'dnsWeapn.pistol.PShellPing1'

	bDropShell=true
	ShellOffset=(X=15.0,Y=6.5,Z=-10.0)
	ShellVelocity=(X=0.3,Y=0.6,Z=0.6)
	bBoneDamage=true

	ItemName="Desert Eagle"

	dnInventoryCategory=1
	dnCategoryPriority=0

	LodMode=LOD_Disabled

	bTraceHitRicochets=true
	bBeamTraceHit=true

	bFireStart=false
	bFireStop=true
	bInterruptFire=true

	CrosshairIndex=11

	bFireIgnites=true
	TraceDamageType=class'PistolDamage'
	bUseMuzzleAnchor=true
}
