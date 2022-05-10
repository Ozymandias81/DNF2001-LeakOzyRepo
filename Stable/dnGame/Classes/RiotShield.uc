/*-----------------------------------------------------------------------------
	RiotShield
	Author: Brandon Reinhart

    Shield Rules:
		- The shield is lowest use priority.
		- Can't even use the shield in bUse zones.
		- Can't bring the shield up when you are carrying something.
		- Can't switch weapons when the shield is up.
		- Can't fire when the shield is up.
-----------------------------------------------------------------------------*/
class RiotShield extends Inventory;

#exec OBJ LOAD FILE=..\Meshes\c_hands.dmx
#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx
#exec OBJ LOAD FILE=..\Textures\m_characters.dtx
#exec OBJ LOAD FILE=..\Textures\m_hands.dtx

var bool bFirstTime, bDrawShield;
var name LastHitAnim;

// 3rd person animations
var name IdleAnim;  
var name FireAnim;  
var name UpAnim;    
var name DownAnim;  

var texture GlassPainSkins[6];

var float LastCharge;

simulated event PostNetInitial()
{
	if ( !bNetOwner )
		return;

	PlayerPawn(Owner).ClientActivateShield( Self );
}

simulated function Destroyed()
{
	if ( PlayerPawn(Owner) != None )
	{
		PlayerPawn( Owner ).bDukeHandUp = false;

		if ( DukeHUD( PlayerPawn( Owner ).MyHUD ) != None ) 
			DukeHUD(PlayerPawn(Owner).MyHUD).RemoveShieldItem();
	}

	if ( (Owner != None) && Owner.bIsPawn )
	{
		Pawn(Owner).ShieldItem = None;
	}

	Super.Destroyed();
}

simulated event RenderOverlays( canvas Canvas )
{
	if ( !bDrawShield )
		return;

	Super.RenderOverlays( Canvas );
}

function PickupFunction( Pawn Other )
{
	// Give a 3rd person shield to a player
	if ( DukePlayer( Other ) != None )
	{
		DukePlayer( Other ).SpawnThirdPersonShield();
	}

	Super.PickupFunction( Other );
}

function BecomePickup()
{
	Super.BecomePickup();

	SetPhysics( PHYS_None );
}

function bool HandlePickupQuery( inventory Item )
{
	// Is this a shield like us?
	if ( (Item.class == class) || ClassIsChildOf(Item.class, class) )
	{
		// Don't pick up the other shield if we have full health.
		if ( Charge == 100 )
			return true;

		// Display a pickup event.
		DisplayPickupEvent( Item, Owner );

		// Refresh our health.
		Charge = 100;
		MultiSkins[4] = None;

		// Set the respawn state.
		Item.SetRespawn();
		return true;
	}

	// If there's nothing in our inventory after this one, do default behavior.
	if ( Inventory == None )
		return false;

	// Ask the next item to try.
	return Inventory.HandlePickupQuery( Item );
}

simulated function bool CapturesUse()
{
	return true;
}

function TakeDamage( int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	if ( PlayerPawn(Owner) == None )
		return;

	Charge -= Damage;

	if ( Charge <= 0 )
	{
		PlayerPawn(Owner).ShieldProtection = false;
		PlayerPawn(Owner).ClientShieldDestroyed();
	}
}

simulated function HitEffect( vector HitLocation, class<DamageType> DamageType, vector Momentum, float DecoHealth, float HitDamage, bool bNoCreationSounds )
{
}

simulated function WeaponUp()
{
	PlayerPawn(Owner).bDukeHandUp = false;

	if ( Level.NetMode == NM_Client )
		PlayerPawn(Owner).WeaponUp( false, true, true );
	else
		PlayerPawn(Owner).WeaponUp( false, true );
}

simulated function WeaponDown()
{
	if ( PlayerPawn(Owner).Weapon != None )
	{
		PlayerPawn(Owner).bFire = 0;
		PlayerPawn(Owner).Weapon.bCantSendFire = true;
		PlayerPawn(Owner).Weapon.bDontAllowFire = true;
		if ( Level.NetMode == NM_Client )
			PlayerPawn(Owner).WeaponDown( false, true, true, true );
		else
			PlayerPawn(Owner).WeaponDown( false, true, true, true );
		PlayerPawn(Owner).bDukeHandUp = true;
	}
}

simulated function Activate()
{
	if ( Viewport(PlayerPawn(Owner).Player) != None )
		GotoState('Activated');
	else
		PlayerPawn(Owner).ShieldItem = Self;
}

state Activated
{
	simulated function BeginState()
	{
		DukeHUD(PlayerPawn(Owner).MyHUD).RegisterShieldItem(spawn(class'HUDIndexItem_RiotShield'));
		if ( (Owner != None) && Owner.bIsPawn )
			Pawn(Owner).ShieldItem = Self;
		bFirstTime = true;
		GotoState('ShieldDown');
	}
}

state ShieldDown
{
	simulated function AnimEnd()
	{
		bDrawShield = false;
		WeaponUp();
	}

	simulated function BeginState()
	{
		if ( !bFirstTime )
			PlayAnim('deactivate', 1.0, 0.0);
		bFirstTime = false;
		Disable( 'Tick' );
	}

	simulated function UseDown()
	{
		if ( PlayerPawn(Owner).CarriedDecoration == None )
			GotoState('ShieldUp');
	}

	simulated function Activate()
	{
	}
}

state ShieldUp
{
	simulated function AnimEnd()
	{
		if ( FRand() < 0.5 )
			PlayAnim( 'IdleA', 1.0, 0.0 );
		else
			PlayAnim( 'IdleB', 1.0, 0.0 );
	}

	simulated function BeginState()
	{
		bDrawShield = true;
		WeaponDown();
		Owner.PlaySound( sound'dnsWeapn.Shield.ShieldUp1' );
		PlayAnim('activate', 1.0, 0.0);
		Enable( 'Tick' );
	}

	simulated function UseDown()
	{
		GotoState('ShieldDown');
	}

	simulated function Activate()
	{
	}

	simulated function Tick( float Delta )
	{
		if ( Charge < LastCharge )
		{
			if ( (AnimSequence != 'HitA') && (AnimSequence != 'HitB') && (AnimSequence != 'HitC') )
				PlayHitAnim();
			LastCharge = Charge;
		}
		SetShieldSkin();
	}

	simulated function PlayHitAnim()
	{
		local float f;
		local name HitAnim;

		Owner.PlaySound( sound'a_impact.Bullet.ImpBGlass05' );

		f = FRand();
		if ( (f < 0.33) && (LastHitAnim != 'HitA') )
			HitAnim = 'HitA';
		else if ( ( f < 0.66 ) && (LastHitAnim != 'HitB') )
			HitAnim = 'HitB';
		else if ( LastHitAnim == 'HitC' )
			HitAnim = 'HitB';
		else
			HitAnim = 'HitC';
		if ( AnimSequence != 'break' )
			PlayAnim( HitAnim, 1.0, 0.0 );
		LastHitAnim = HitAnim;
	}

	simulated function SetShieldSkin()
	{
		if ( Charge < 90 )
		{
			if ( Charge > 80 )
			{
				if ( MultiSkins[4] != GlassPainSkins[0] )
					MultiSkins[4] = GlassPainSkins[0];
			}
			else if ( Charge > 50 )
			{
				if ( MultiSkins[4] != GlassPainSkins[1] )
					MultiSkins[4] = GlassPainSkins[1];
			}
			else if ( Charge > 30 )
			{
				if ( MultiSkins[4] != GlassPainSkins[2] )
					MultiSkins[4] = GlassPainSkins[2];
			}
			else if ( Charge > 10 )
			{
				if ( MultiSkins[4] != GlassPainSkins[3] )
					MultiSkins[4] = GlassPainSkins[3];
			}
			else if ( Charge > 0 )
			{
				if ( MultiSkins[4] != GlassPainSkins[4] )
					MultiSkins[4] = GlassPainSkins[4];
			}
		}
	}
}

state ShieldDestroyed
{
	simulated function AnimEnd()
	{
		if ( AnimSequence == 'break' )
		{
			WeaponUp();
			if ( (Owner != None) && Owner.bIsPawn )
				Pawn(Owner).ShieldItem = None;
			DukeHUD(PlayerPawn(Owner).MyHUD).RemoveShieldItem();
			PlayerPawn(Owner).ServerDestroyShield();
			Destroy();
		}
	}

	simulated function BeginState()
	{
		MultiSkins[4] = GlassPainSkins[5];
		MultiSkins[6] = texture'BlackTexture';
		PlayerPawn(Owner).ShieldProtection = false;
		PlayAnim('break', 1.0, 0.0);
	}

	simulated function Activate()
	{
	}
}

defaultproperties
{
	dnInventoryCategory=5
	dnCategoryPriority=4
	bActivatable=true
	bAutoActivate=true

	ItemName="Riot Shield"
	PickupIcon=texture'hud_effects.am_shield'
    Icon=Texture'hud_effects.mitem_shield'
    PickupSound=Sound'dnGame.Pickups.AmmoSnd'

	Mesh=DukeMesh'c_characters.EDFshield'
	PlayerViewMesh=DukeMesh'c_hands.FPshield'
    PickupViewMesh=DukeMesh'c_characters.EDFshield'
	Texture=Texture'm_characters.edfshieldglassR'
	PlayerViewScale=0.1
	PlayerViewOffset=(X=125,Y=0.0,Z=520)
	LODMode=LOD_Disabled
	AnimSequence=activate
    
    IdleAnim=T_ShieldIdle
    FireAnim=T_ShieldFire
    UpAnim=T_ShieldActivate
    DownAnim=T_ShieldDeactivate

	CollisionRadius=27
//	CollisionHeight=2
	CollisionHeight=8

	LastCharge=100
	Charge=100
	LightDetail=LTD_Normal

	GlassPainSkins(0)=texture'm_hands.edfshield_break1tile'
	GlassPainSkins(1)=texture'm_hands.edfshield_break2tile'
	GlassPainSkins(2)=texture'm_hands.edfshield_break3tile'
	GlassPainSkins(3)=texture'm_hands.edfshield_break4tile'
	GlassPainSkins(4)=texture'm_hands.edfshield_break5tile'
	GlassPainSkins(5)=texture'm_hands.edfshield_break6tile'

	RespawnTime=30.0
	bDrawShield=false

	HitPackageClass=class'HitPackage_Shield'
}