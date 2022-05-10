/*-----------------------------------------------------------------------------
	dnWeapon
	Author: Brandon Reinhart

	Containts dnGame package scope code for:
		- Destruction and cleanup.
		- Handling weapon mode change.
		- Rendering quick kick.
		- Handling particles.
		- Installing / Removing HUD interfaces.
-----------------------------------------------------------------------------*/
class dnWeapon expands Weapon;

#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

// HUD Interface
var bool							bAmmoItem;
var HUDIndexItem_Ammo				AmmoItem;
var class<HUDIndexItem_Ammo>		AmmoItemClass;
var bool							bAltAmmoItem;
var HUDIndexItem_AltAmmo			AltAmmoItem;
var class<HUDIndexItem_AltAmmo>		AltAmmoItemClass;

// Quick Kick support.
var MightyFoot						DukeFoot;

// Shells
var dnShellCaseMaster				ShellMaster;
var dnShellCaseMaster				ShellMaster3rd;

var int								CrosshairIndex;
var bool							bReloadOnModeChange;


/*-----------------------------------------------------------------------------
	Object
-----------------------------------------------------------------------------*/

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		// Create an ammo item if we need one.
		if ( bAmmoItem && (AmmoItem == None) )
			AmmoItem = spawn(AmmoItemClass);

		// Create an altfire ammo item if we need one.
		if ( bAltAmmoItem && (AltAmmoItem == None) )
			AltAmmoItem = spawn(AltAmmoItemClass);
	}
}

// Clean up when the weapon is destroyed.
simulated function Destroyed()
{
	Super.Destroyed();

	if ( AmmoItem != None )
		AmmoItem.Destroy();

	if ( AltAmmoItem != None )
		AltAmmoItem.Destroy();

	if ( ShellMaster != None )
		ShellMaster.Destroy();

	if ( ShellMaster3rd != None )
		ShellMaster3rd.Destroy();
}


// Per-frame object update notification.
simulated event Tick(float Delta)
{
	Super.Tick( Delta );

	// Update the location of the shell master.
	// FIXME: Could be done faster with mounting.
	if ( (ShellMaster != None) && (ShellMaster.Location != Location) )
		ShellMaster.SetLocation( Location );
	if ( (ShellMaster3rd != None) && (ShellMaster3rd.Location != Location) )
		ShellMaster3rd.SetLocation( Location );
}



/*-----------------------------------------------------------------------------
	Inventory Behavior
-----------------------------------------------------------------------------*/

// Switches through the available ammo modes to find the next ammo mode.
// Also tells the server we've changed ammo modes.
simulated function CycleAmmoMode( optional bool bFast )
{
	local int OldAmmoMode;

	// Keep our old ammo mode.
	OldAmmoMode = AmmoType.AmmoMode;

	// Cycle to the next mode.
	AmmoType.NextAmmoMode();

	// If we didn't find a mode with ammo, do nothing.
	if (OldAmmoMode == AmmoType.AmmoMode)
		return;

	// Tell the server that we changed modes.
	if ( Owner.IsA('DukePlayer') )
		DukePlayer(Owner).ServerUpdateAmmoMode( AmmoType.AmmoMode );

	// Play the menu interface sound.
	PlayerPawn(Owner).PlayOwnedSound(ModeChangeSound, SLOT_Interface);

	// Set us up for reloading.
	if ( bReloadOnModeChange )
	{
		AmmoLoaded = 0;
		if ( bFast )
			PlayerPawn(Owner).Reload();
		else
			ReloadTimer = 0.75;
	}
}

function UpdateAmmoMode( int NewAmmoMode )
{
	AmmoType.AmmoMode = NewAmmoMode;
	if ( bReloadOnModeChange )
	{
		AmmoLoaded = 0;
		ReloadTimer = 0.75;
	}
}



/*-----------------------------------------------------------------------------
	Weapon Rendering
-----------------------------------------------------------------------------*/

// Allows the weapon to draw directly to the canvas.
simulated event RenderOverlays( canvas C )
{
	local Weapon OldWeapon;
	local rotator NewRot;
    local texture Tex;
	local PlayerPawn PlayerOwner;

	PlayerOwner = PlayerPawn(Owner);
	if ( PlayerOwner == None )
		return;

	// Quick Kick overlay.
	if ( DukeFoot != None )
	{
		DukeFoot.SetLocation( Owner.Location + DukeFoot.CalcDrawOffset() );
		NewRot = PlayerOwner.ViewRotation;

		if ( PlayerOwner.Handedness == 0 )
			newRot.Roll = -2 * DukeFoot.Default.Rotation.Roll;
		else
			newRot.Roll = DukeFoot.Default.Rotation.Roll * PlayerOwner.Handedness;

		DukeFoot.SetRotation(newRot);

		OldWeapon = PlayerOwner.Weapon;
		PlayerOwner.Weapon = DukeFoot;
		if ( DukeFoot.IsAnimating() )
		{
			C.SetClampMode( false );
			C.DrawActor( DukeFoot, false );
			C.SetClampMode( true );
		}
		PlayerOwner.Weapon = OldWeapon;
	}

    Super.RenderOverlays(C);
}

// Draws the ammo bars for the weapon in the Q-menu.
simulated function DrawAmmoAmount( Canvas C, DukeHUD HUD, float X, float Y )
{
	local int i, YPos;
	local float AmmoScale, AmmoCount;

	if (AmmoType == None)
		return;

	YPos = 51;
	for (i=0; i<AmmoType.MaxAmmoMode; i++)
	{
		AmmoScale = float(AmmoType.GetModeAmount(i)) / AmmoType.MaxAmmo[i];
		AmmoScale *= 0.8;
		DrawAmmoBar( C, HUD, AmmoScale, X+4*HUD.HUDScaleX*0.8, Y+YPos*HUD.HUDScaleY*0.8 );
		YPos += 4*0.8*HUD.HUDScaleY;
	}
}

/*
simulated function DropShell()
{
	local vector realLoc, X, Y, Z;	
	local SoftParticleSystem.Particle p;
	local int pIndex;

	if ( Owner.bIsPlayerPawn )
		GetAxes(PlayerPawn(Owner).ViewRotation, X, Y, Z);
	else
		GetAxes(Owner.Rotation, X, Y, Z);

	realLoc = Owner.Location + CalcDrawOffset();

	if (ShellMaster==None)
	{
		ShellMaster = spawn(class'dnShellCaseMaster', Instigator, '', Owner.Location);
		ShellMaster.SetPhysics(PHYS_MovingBrush);
		ShellMaster.AttachActorToParent(Owner, false, false);
		ShellMaster.bDontReflect = true;
		ShellMaster.bOnlyOwnerSee = true;
		ShellMaster.Mesh = ShellMesh;
	}

	if (ShellMaster3rd==None)
	{
//		ShellMaster3rd = spawn(class'dnShellCaseMaster', Pawn(Owner), '', Owner.Location);
//		ShellMaster3rd.bOwnerSeeSpecial = true;
//		ShellMaster3rd.Mesh = ShellMesh;
	}

	if ( Owner.bIsPlayerPawn )
		ShellMaster.BounceSound = ShellBounceSound;
	else
		ShellMaster.BounceSound = None;
	if ( !Owner.bIsPlayerPawn )
		ShellMaster3rd.BounceSound = ShellBounceSound;
	else
		ShellMaster3rd.BounceSound = None;

	if ( !IsA('M16') || (M16(self).BurstCount%3 != 0) )
	{
		// 1st shell master.
		if ( Owner.bIsPlayerPawn )
		{
			pIndex = ShellMaster.SpawnParticle(1);
			if (pIndex!=-1)
			{
				ShellMaster.GetParticle(pIndex, p);
				p.Rotation3d = Rotation;
				p.Location = realLoc + 
					(FireOffset.X+ShellOffset.X)*X + (FireOffset.Y+ShellOffset.Y)*Y + (FireOffset.Z+ShellOffset.Z)*Z;
				p.Velocity = Owner.Velocity*0.8 + 
					((FRand()*0.3+ShellVelocity.X)*X + (FRand()*0.2+ShellVelocity.Y)*Y + (FRand()*0.3+ShellVelocity.Z) * Z)*160;
			
				p.RotationVelocity3D = RotRand();
				p.RotationVelocity3D.Pitch = FRand()*200000.0 - 100000.0;
				p.RotationVelocity3D.Yaw = FRand()*200000.0 - 100000.0;
				p.RotationVelocity3D.Roll = FRand()*200000.0 - 100000.0;
			
				ShellMaster.SetParticle(pIndex, p);
			}
		}

		// 3rd shell master.
		pIndex = ShellMaster3rd.SpawnParticle(1);
		if (pIndex!=-1)
		{
			ShellMaster3rd.GetParticle(pIndex, p);
			p.Rotation3d = Rotation;
			p.Location = Weapon3rdLocation;
			p.Velocity = Owner.Velocity*0.8 + ((FRand()*0.3+0.3)*X + (FRand()*0.2+0.6)*Y + (FRand()*0.3+0.6) * Z)*160;
			
			p.RotationVelocity3D = RotRand();
			p.RotationVelocity3D.Pitch = FRand()*200000.0 - 100000.0;
			p.RotationVelocity3D.Yaw = FRand()*200000.0 - 100000.0;
			p.RotationVelocity3D.Roll = FRand()*200000.0 - 100000.0;
			
			ShellMaster3rd.SetParticle(pIndex, p);
		}
	}
}
*/



/*-----------------------------------------------------------------------------
	Quick Kick
-----------------------------------------------------------------------------*/

// Replicated to the client.  Performs quick kick anim.
simulated function ClientQuickKick( optional bool bForceKick )
{
	if ( DukeFoot == None )
	{
		DukeFoot = MightyFoot( Instigator.FindInventoryType(class'MightyFoot') );
		if ( DukeFoot == None )
			return;
	}
	if ( !bForceKick && DukeFoot.IsAnimating() )
		return;
	DukeFoot.WpnFire();
}

// Does the quick kick attack.
function QuickKick( optional bool bNoTraceHit, optional bool bForceKick )
{
	if ( DukeFoot == None )
	{
		DukeFoot = MightyFoot( Instigator.FindInventoryType(class'MightyFoot') );
		if ( DukeFoot == None )
			return;
	}
	if ( !bForceKick && DukeFoot.IsAnimating() )
		return;
	DukeFoot.WpnFire();
	if ( !bNoTraceHit )
		DukeFoot.TraceFire( Owner );
}

defaultproperties
{
    SAnimActivate(0)=(AnimChance=1.000000,animSeq=Activate,AnimRate=1.000000)
    SAnimDeactivate(0)=(AnimChance=1.000000,animSeq=Deactivate,AnimRate=1.000000)
    SAnimFire(0)=(AnimChance=1.000000,animSeq=Fire,AnimRate=1.000000)
    SAnimAltFire(0)=(AnimChance=1.000000,animSeq=AltFire,AnimRate=1.000000)
    SAnimReload(0)=(AnimChance=1.000000,animSeq=Reload,AnimRate=1.000000)
    dnInventoryCategory=1
    bActivatable=True
    AnimRate=1.000000
    BobDamping=1.12
	bHeated=true
	HeatIntensity=255
    HeatRadius=0
    HeatFalloff=255
	bAmmoItem=true
	bAltAmmoItem=true
	AltAmmoItemClass=class'HUDIndexItem_AltAmmo'
	AmmoItemClass=class'HUDIndexItem_Ammo'
	ReloadTimer=0	
	ShellMesh=mesh'm16shell'
	WaterSplashClass=dnParticles.dnBulletFX_WaterSplashSpawner
	LightDetail=LTD_Normal
	bClientAnim=true
	ModeChangeSound=sound'a_generic.Menu.QMenuHL1'
	HitPackageLevelClass=class'HitPackage_DukeLevel'
	bReloadOnModeChange=true
}
