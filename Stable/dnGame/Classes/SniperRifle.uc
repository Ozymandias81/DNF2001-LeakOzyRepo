/*-----------------------------------------------------------------------------
	SniperRifle
	Author: Brandon Reinhart

	- Doesn't send TraceHitCategory over network.
-----------------------------------------------------------------------------*/
class SniperRifle expands dnWeapon;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

var int				ZoomPower;
var bool			bZoomed;

var bool			bDrawBootup;
var bool			bDrawReload;

var bool			bNeedToCharge, bCharging;

// Sniper overlay graphics.
var texture SniperInnerCircle[3];
var texture SniperVisionOverlay;
var texture SniperZoomLevel[3];
var texture SniperUplink[2];
var texture SniperXYPosition[2];
var smackertexture SniperPitch;
var smackertexture SniperStats[2];
var smackertexture SniperBacteria;
var smackertexture SniperBootUp[2];
var smackertexture SniperLoadBattery;
var texture SniperCompassArrow;
var texture ChargeTextures[13];
var int ChargeLevel;

var sound ActivateSound;

// Muzzle flash!
var SoftParticleSystem Flash;



/*-----------------------------------------------------------------------------
	Object
-----------------------------------------------------------------------------*/

// Called by the engine when the object is destroyed.
simulated function Destroyed()
{
	// Make sure associated effects are destroyed.
	StopSound( SLOT_Talk );

	Super.Destroyed();
}



/*-----------------------------------------------------------------------------
	Overlays / Rendering
-----------------------------------------------------------------------------*/

simulated function bool CanDrawCrosshair()
{
	if ( bZoomed )
		return false;
	else
		return true;
}

simulated function bool CanDrawSOS()
{
	if ( bZoomed )
		return false;
	else
		return true;
}

// Allows the weapon to draw directly to the canvas.
simulated event RenderOverlays( canvas Canvas )
{
	local DukeHUD HUD;
	local texture Tex;
	local vector P1, P2;
	local float XL, YL, RotationScale, SizeX, SizeY;

	HUD = DukeHUD(DukePlayer(Owner).MyHUD);

	if ( DukePlayer(Owner).bEMPulsed )
		return;

	// Draw the sniper zoom overlay.
	if ( bZoomed )
	{
		Canvas.Font = HUD.MediumFont;

		// Draw the static.
		Canvas.DrawColor = HUD.WhiteColor;
		Canvas.Style = 4;
		if ( DukePlayer(Owner).ZoomVisionSubtleStatic == None )
			DukePlayer(Owner).ZoomVisionSubtleStatic = Texture( DynamicLoadObject( DukePlayer(Owner).ZoomVisionSubtleStaticString, class'Texture' ) );
		Tex = DukePlayer(Owner).ZoomVisionSubtleStatic;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX, Canvas.ClipY, 0, 0, Tex.USize, Tex.VSize);

		// Draw the lines.
		Canvas.Style = 3;
		Canvas.DrawColor.R = 5;
		Canvas.DrawColor.G = 246;
		Canvas.DrawColor.B = 151;
		P1.x = int(Canvas.ClipX / 2);
		P1.y = 86 * HUD.HUDScaleX;
		P2.x = int(Canvas.ClipX / 2);
		P2.y = 683 * HUD.HUDScaleY;
		Canvas.DrawLine( P1, P2, false );
		P1.x = int(Canvas.ClipX / 2) + 1;
		P1.y = 86 * HUD.HUDScaleX;
		P2.x = int(Canvas.ClipX / 2) + 1;
		P2.y = 683 * HUD.HUDScaleY;
		Canvas.DrawLine( P1, P2, false );
		P1.x = 220 * HUD.HUDScaleX;
		P1.y = int(Canvas.ClipY / 2);
		P2.x = 805 * HUD.HUDScaleY;
		P2.y = int(Canvas.ClipY / 2);
		Canvas.DrawLine( P1, P2, false );
		P1.x = 220 * HUD.HUDScaleX;
		P1.y = int(Canvas.ClipY / 2) + 1;
		P2.x = 805 * HUD.HUDScaleY;
		P2.y = int(Canvas.ClipY / 2) + 1;
		Canvas.DrawLine( P1, P2, false );

		Canvas.DrawColor = HUD.WhiteColor;
		Canvas.Style = 3;

		// Draw the inner circle pieces. (1)
		Tex = SniperInnerCircle[0];
		SizeX = Tex.USize*HUD.HudScaleX;
		SizeY = Tex.VSize*HUD.HudScaleY;
		Canvas.SetPos(256*HUD.HudScaleX, 128*HUD.HUDScaleY);
		Canvas.DrawTile(Tex, SizeX, Tex.VSize*HUD.HudScaleY, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos((256+Tex.USize)*HUD.HudScaleX, 128*HUD.HUDScaleY);
		Canvas.DrawTile(Tex, SizeX, Tex.VSize*HUD.HudScaleY, 0, 0, Tex.USize, Tex.VSize, , , , true, , true );
		Canvas.SetPos(256*HUD.HudScaleX, (128+Tex.VSize)*HUD.HUDScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, , , , true, , , true );
		Canvas.SetPos((256+Tex.USize)*HUD.HudScaleX, (128+Tex.VSize)*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, , , , true, , true, true );

		// Draw the inner circle pieces. (2)
		Tex = SniperInnerCircle[1];
		SizeX = Tex.USize*HUD.HudScaleX;
		SizeY = Tex.VSize*HUD.HudScaleY;
		Canvas.SetPos(256*HUD.HudScaleX, 0);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos(Canvas.ClipX/2, 0);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, , , , true, , true );
		Canvas.SetPos(256*HUD.HudScaleX, (768-Tex.VSize)*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, , , , true, , , true );
		Canvas.SetPos(Canvas.ClipX/2, (768-Tex.VSize)*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, , , , true, , true, true );

		// Draw the inner circle pieces. (3)
		Tex = SniperInnerCircle[2];
		SizeX = Tex.USize*HUD.HudScaleX;
		SizeY = Tex.VSize*HUD.HudScaleY;
		Canvas.SetPos(128*HUD.HudScaleX, 128*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos((896-Tex.USize)*HUD.HudScaleX, 128*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, , , , true, , true);
		Canvas.SetPos(128*HUD.HudScaleX, (640-Tex.VSize)*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, , , , true, , , true );
		Canvas.SetPos((896-Tex.USize)*HUD.HudScaleX, (640-Tex.VSize)*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, , , , true, , true, true );

		// Calc rotation from true north.
		RotationScale = (Normalize(PlayerPawn(Owner).ViewRotation).Yaw - Level.North) / 32768.0;

		// Draw the overlay.
		Canvas.Style = 4;
		Tex = SniperVisionOverlay;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos(Canvas.ClipX/2, 0);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true );
		Canvas.SetPos(0, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , , true );
		Canvas.SetPos(Canvas.ClipX/2, Canvas.ClipY/2);
		Canvas.DrawTile(Tex, Canvas.ClipX/2, Canvas.ClipY/2, 0, 0, Tex.USize, Tex.VSize, , , , true, , true, true );

		// Draw the XY position pieces. (1)
		Canvas.Style = 3;
		Tex = SniperXYPosition[0];
		SizeX = Tex.USize*HUD.HudScaleX;
		SizeY = Tex.VSize*HUD.HudScaleY;
		Canvas.SetPos(256*HUD.HudScaleX, 42*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, RotationScale*3.14159, (256-(Tex.USize/2))*HUD.HudScaleX, (384 - 42 - (Tex.VSize/2))*HUD.HudScaleY, true);
		Canvas.SetPos(512*HUD.HudScaleX, 42*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, RotationScale*3.14159, (-Tex.USize/2)*HUD.HudScaleX, (384 - 42 - (Tex.VSize/2))*HUD.HudScaleY, true, , true);

		// Draw the XY position pieces. (2)
		RotationScale = -RotationScale;
		Tex = SniperXYPosition[1];
		SizeX = Tex.USize*HUD.HudScaleX;
		SizeY = Tex.VSize*HUD.HudScaleY;
		Canvas.SetPos(256*HUD.HudScaleX, 42*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, RotationScale*3.14159 + PI, (256-(Tex.USize/2))*HUD.HudScaleX, (384 - 42 - (Tex.VSize/2))*HUD.HudScaleY, true, , , true);
		Canvas.SetPos(512*HUD.HudScaleX, 42*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize, RotationScale*3.14159 + PI, (-Tex.USize/2)*HUD.HudScaleX, (384 - 42 - (Tex.VSize/2))*HUD.HudScaleY, true, , true, true);

		// Draw the uplink status.
		Tex = SniperUplink[1];
		SizeX = Tex.USize*HUD.HudScaleX;
		SizeY = Tex.VSize*HUD.HudScaleY;
		Canvas.SetPos(31*HUD.HudScaleX, 464*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize);

		// Draw the zoom level.
		Tex = SniperZoomLevel[ZoomPower];
		SizeX = Tex.USize*HUD.HudScaleX;
		SizeY = Tex.VSize*HUD.HudScaleY;
		Canvas.SetPos(505*HUD.HudScaleX, 510*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize);

		// Draw the stats smack.
		Tex = SniperStats[1];
		SizeX = Tex.USize*HUD.HudScaleX;
		SizeY = Tex.VSize*HUD.HudScaleY;
		Canvas.SetPos(252*HUD.HudScaleX, 146*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize);

		// Draw the bacteria display.
		Tex = SniperBacteria;
		SizeX = Tex.USize*HUD.HudScaleX;
		SizeY = Tex.VSize*HUD.HudScaleY;
		Canvas.SetPos(11*HUD.HudScaleX, 244*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize);

		// Draw the pitch display.
		RotationScale = ((Normalize(PlayerPawn(Owner).ViewRotation).Pitch + 16384.0) / 32768) * 60;
		Tex = SniperPitch;
		SizeX = Tex.USize*HUD.HudScaleX;
		SizeY = Tex.VSize*HUD.HudScaleY;
		SniperPitch.CurrentFrame = clamp(60 - RotationScale, 0, 60);
		Canvas.SetPos(883*HUD.HudScaleX, 255*HUD.HudScaleY);
		Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize);
	}
	else
	{
		Canvas.DrawColor = HUD.WhiteColor;
		Canvas.Style = 3;

		if ( bDrawBootup )
		{
			// Draw the status bootup smack.
			Tex = SniperBootup[0];
			SizeX = Tex.USize*HUD.HudScaleX;
			SizeY = Tex.VSize*HUD.HudScaleY;
			Canvas.SetPos(96*HUD.HudScaleX, 146*HUD.HudScaleY);
			Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize);
		}

		if ( bDrawReload )
		{
			// Draw the battery reload smack.
			Tex = SniperLoadBattery;
			SizeX = Tex.USize*HUD.HudScaleX;
			SizeY = Tex.VSize*HUD.HudScaleY;
			Canvas.SetPos(96*HUD.HudScaleX, 146*HUD.HudScaleY);
			Canvas.DrawTile(Tex, SizeX, SizeY, 0, 0, Tex.USize, Tex.VSize);
		}
	}

	MultiSkins[5] = ChargeTextures[ChargeLevel];

	Super.RenderOverlays( Canvas );
}

// Change the player's FOV angle.
simulated function ChangeFOVLevel()
{
	switch ( ZoomPower )
	{
	case 0:
		PlayerPawn(Owner).DesiredFOV = PlayerPawn(Owner).DefaultFOV;
		PlayerPawn(Owner).FOVAngle = 90;
		bZoomed = false;
		break;
	case 1:
		if (PlayerPawn(Owner).CameraStyle == PCS_ZoomMode)
			PlayerPawn(Owner).SOSPowerOff();
		PlayerPawn(Owner).DesiredFOV = 30;
		PlayerPawn(Owner).FOVAngle = 30;
		bZoomed = true;
		bDrawBootup = false;
		break;
	case 2:
		if (PlayerPawn(Owner).CameraStyle == PCS_ZoomMode)
			PlayerPawn(Owner).SOSPowerOff();
		PlayerPawn(Owner).DesiredFOV = 10;
		PlayerPawn(Owner).FOVAngle = 10;
		bZoomed = true;
		bDrawBootup = false;
		break;
	}
}

/*
// Draw reload sequence...
simulated function DrawReloadSequence( optional bool On )
{
	if ( On )
	{
		// Stop any bootup sequence...
		bDrawBootup = false;
		SniperBootUp[0].pause = true;
		SniperBootUp[0].currentFrame = 0;

		// Draw the reload sequence...
		bDrawReload = true;
	}
	else
	{
		// Turn off the reload sequence...
		bDrawReload = false;
	}
}
*/

// We prevent FOV change on power off.
simulated function SOSPowerOff()
{
}

// Allows us to choose to let the player use zoom mode.
simulated function bool AllowZoom()
{
	// Can't use this SOS power when in zoom mode.
	if ( ZoomPower > 0 )
		return false;
	else
		return true;
}



/*-----------------------------------------------------------------------------
	Damage
-----------------------------------------------------------------------------*/

// Returns the damage values for this hit.
simulated function int GetHitDamage(actor Victim, name BoneName)
{
    local Pawn.EPawnBodyPart BodyPart;
	local int Dmg;
    
    BodyPart = BODYPART_Default;
    if (Pawn(Victim)!=None)
		BodyPart = Pawn(Victim).GetPartForBone(BoneName);

	switch ( BodyPart )
	{
	case BODYPART_Head:
		Dmg = 125;
		break;
	case BODYPART_Chest:
	case BODYPART_Stomach:
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
		Dmg = 80;
		break;
	}

	// Multiply by weapon third person scale for the shrinkray effect.
	Dmg *= ThirdPersonScale;

	return Max( Dmg, 1 );
}



/*-----------------------------------------------------------------------------
	Firing
-----------------------------------------------------------------------------*/

// Helper functions that check and see if it's okay to fire.
simulated function bool ButtonFire()
{
	// No continuous firing.
	return false;
}

// Check to see if the client can fire.
simulated function bool ClientFire()
{
	// This weapon does nothing on fire down.  It operates on fire up.
	return true;
}

function Fire()
{
	// This weapon does nothing on fire down.  It operates on fire up.
	return;
}

simulated function ClientUnFire()
{
	if ( CanFire() && !ButtonAltFire() && (Level.NetMode == NM_Client) )
	{
		// Go to the firing state.
		GotoState('Firing');
		StartFiring();
	}
}

function UnFire()
{
	// Do the actual hit trace here.
    if ( !ButtonAltFire() && AmmoType.UseAmmo(1) )
    {
		// Reduce the loaded ammo count.
		AmmoLoaded--;
		if (AmmoType == AltAmmoType)
			AltAmmoLoaded--;

		// Make a firing noise.
		Owner.MakeNoise( Pawn(Owner).SoundDampening );

		// Perform hit logic.
		TraceFire( Owner );

		// Go to the firing state.
		GotoState('Firing');
		StartFiring();
	}
}

// Stub for ammo mode cycling handler for multimode weapons.
// With this weapon, we just zoom.
simulated function CycleAmmoMode( optional bool bFast )
{
	IncrementZoom();
}

// Increment the zoom mode.
simulated function IncrementZoom()
{
	// Cycle through the magnification levels.
	ZoomPower++;
	if (ZoomPower > 2)
		ZoomPower = 0;
	PlayerPawn(Owner).PlayOwnedSound( ModeChangeSound, SLOT_Interface );

	ChangeFOVLevel();
}

// Returns true if we have ammo for the current mode, don't have to reload, 
// and aren't completely out of ammo.
simulated function bool CanFire()
{
	// Can't fire if we need to charge or are charging.
	if ( bNeedToCharge || bCharging )
		return false;

	return Super.CanFire();
}



/*-----------------------------------------------------------------------------
	Timing
-----------------------------------------------------------------------------*/
/*
simulated function Timer(optional int TimerNum)
{
	if ( TimerNum == 1 )
	{
		// Stop the boot sequence.
		bDrawBootup = false;
		SniperBootUp[0].pause = true;
		SniperBootUp[0].currentFrame = 0;
	}
}
*/



/*-----------------------------------------------------------------------------
	Effects
-----------------------------------------------------------------------------*/

// First person laser effect.
simulated function SpawnFirstPersonLaserBeam()
{
	local Pawn PawnOwner;
	local vector X, Y, Z, DrawOffset, BeamStart, Start, End, Not, HitLocation, HitNormal;
	local Actor HitActor;
	local class<LaserBeam> LaserBeamClass;
	local LaserBeam Laser;

	// Get trace segment.
	GetTraceFireSegment( Start, End, Not );

	// Trace out to see what we hit.
	HitActor = Trace( HitLocation, HitNormal, End, Start, true );

	// Spawn the first person laser beam.
	PawnOwner = PlayerPawn(Owner);
	if ( (PawnOwner != None) && (HitActor != None) )
	{
		GetAxes( PawnOwner.ViewRotation, X, Y, Z );
		DrawOffset = PawnOwner.BaseEyeHeight * vect(0,0,1) + X*40 + Y*10 - Z*11;
		BeamStart = PawnOwner.Location + DrawOffset;

		LaserBeamClass = class<LaserBeam>( DynamicLoadObject( "dnGame.dnLaserBeam", class'Class' ) );
		Laser = spawn( LaserBeamClass, Owner );
		Laser.SpawnLaserBeam( BeamStart, HitLocation, true, false );
		Flash = Laser.LaserFlash;
		Laser.Destroy();
	}
}

// There are animation driven client side effects.
simulated function ClientSideEffects( optional bool bAltFire )
{
	Super.ClientSideEffects( bAltFire );

	// Spawn first person laser...
	SpawnFirstPersonLaserBeam();
}

// Customize the hitpackage before replication/delivery.
function FillHitPackage( HitPackage hit, float HitDamage, Pawn HitInstigator, vector StartTrace, vector BeamStart )
{
	if ( hit == None )
		return;

	Super.FillHitPackage( hit, HitDamage, HitInstigator, StartTrace, BeamStart );

	hit.bLaserBeam = true;
	hit.TraceOriginZ += 2;
}

// Update the flash effect location.
simulated function UpdateFlash( float DeltaTime )
{
	local vector FlashOffset, X, Y, Z;

	GetAxes( Pawn(Owner).ViewRotation, X, Y, Z );
	FlashOffset = Pawn(Owner).Location + Pawn(Owner).BaseEyeHeight*vect(0,0,1) + X*40 + Y*10 - Z*11;
	Flash.SetLocation( FlashOffset );
}

// Per-frame tick.
simulated function Tick( float DeltaTime )
{
	// Call parent.
	Super.Tick( DeltaTime );

	if ( (Flash != None) && Flash.bOnlyOwnerSee )
		UpdateFlash( DeltaTime );
}



/*-----------------------------------------------------------------------------
	Animation
-----------------------------------------------------------------------------*/

// Play the activation animation.
simulated function WpnActivate()
{
	// Call parent behavior.
	Super.WpnActivate();

	// Play an ambient sound.
	PlaySound( ActivateSound, SLOT_Talk, 2.0 );

	// Set up rendering.
//	bDrawBootup = true;
	SniperBootUp[0].pause = false;
	SniperStats[1].pause = false;
//	SetTimer(7.0, false, 1);

	// If the player is using zoom powers, turn it off.
	if ( (ZoomPower > 0) && (PlayerPawn(Owner).CameraStyle == PCS_ZoomMode) )
		PlayerPawn(Owner).SOSPowerOff();
}

// Play the deactivation animation.
simulated function WpnDeactivated()
{
	// Call parent behavior.
	Super.WpnDeactivated();

	// Stop the ambient sound.
	StopSound( SLOT_Talk );
}



/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

// This state is used to bring the weapon up.
state Active
{
	// Called when the state is entered.
	// We reset any variables that need reset, install the hud, and play the activate anim.
	simulated function BeginState()
	{
		// Reset.
		bNeedToCharge = false;
		bCharging = false;
		ChargeLevel = 12;

		// Call super.
		Super.BeginState();
	}
}

// The PlayerPawn does not send bFire messages while the weapon is in this state.
state Reloading
{
	// Don't allow firing while in this state.
	simulated function ClientUnFire()
	{
	}

	// Don't allow firing while in this state.
	function UnFire()
	{
	}

	simulated function bool ClientAltFire()
	{
		return Global.ClientAltFire();
	}

	function AltFire()
	{
		Global.AltFire();
	}

	// Called when state is entered.
	simulated function BeginState()
	{
//		DrawReloadSequence(true);

		Super.BeginState();
	}

	// Called when state is exited.
	simulated function EndState()
	{
//		DrawReloadSequence(false);
		
		// No need to charge.
		bNeedToCharge = false;
		ChargeLevel = 12;

		Super.EndState();
	}
}

// Main firing state.
state Firing
{
	// Check to see if the client can fire.
	simulated function bool ClientFire()
	{
		// Can't send firing messages here.
		return false;
	}

	// Don't allow firing while in this state.
	simulated function ClientUnFire()
	{
	}

	simulated function bool ClientAltFire()
	{
		return Global.ClientAltFire();
	}

	function AltFire()
	{
		Global.AltFire();
	}

	// Don't allow firing while in this state.
	function UnFire()
	{
	}

	// Called when the state is entered.
	simulated function BeginState()
	{
		// We need to recharge now.
		bNeedToCharge = true;
		ChargeLevel = 0;

		Super.BeginState();
	}

}

// This state is entered when the weapon is in a light idling state.
state Idle
{
	/*
	// Check to see if the client can fire.
	simulated function bool ClientFire()
	{
		// We can only send fire messages when charged.
		if ( bCharging )
			return false;
		else
			return Global.ClientFire();
	}
	*/
	// Can't fire if we are charging up.
	function UnFire()
	{
		if ( !bCharging )
			Global.UnFire();
	}

	// Charge up.
	simulated function Timer( optional int TimerNum )
	{
		if ( TimerNum == 0 )
		{
			ChargeLevel++;
			if ( ChargeLevel == 12 )
			{
				bCharging = false;
				SetTimer(0.0, false);
			}
		}
		else
			Global.Timer( TimerNum );
	}

	// Called when state is entered.
	simulated function BeginState()
	{
		// We are in need of a charge.  Start charge timer.
		if ( bNeedToCharge )
		{
			bCharging = true;
			bNeedToCharge = false;
			SetTimer( 0.05, true );
		}

		// Call parent.
		Super.BeginState();
	}

	// Called when state is exited.
	simulated function EndState()
	{
		// Turn of charge timer.
		bCharging = false;
		bNeedToCharge = false;
		ChargeLevel = 12;
		SetTimer( 0.0, false );
	}
}

// This state is entered when the weapon is idling after reloading.
// This state exists so that the weapon won't reenter reloading animations if the server's AmmoLoaded update hasn't arrived on time.
state PostLoadIdle
{
	// Can't fire if we are charging up.
	function UnFire()
	{
		if ( !bCharging )
			Global.UnFire();
	}

	// Charge up.
	simulated function Timer( optional int TimerNum )
	{
		if ( TimerNum == 1 )
			Global.Timer( TimerNum );
		else
		{
			ChargeLevel++;
			if ( ChargeLevel == 12 )
			{
				bCharging = false;
				SetTimer(0.0, false);
			}
		}
	}

	// Called when state is entered.
	simulated function BeginState()
	{
		// Call parent.
		Super.BeginState();

		// We are in need of a charge.  Start charge timer.
		if ( bNeedToCharge )
		{
			bCharging = true;
			bNeedToCharge = false;
			SetTimer(0.05, true);
		}
	}
}



defaultproperties
{
    SAnimActivate(0)=(AnimChance=1.0,animSeq=Activate,AnimRate=1.0)
    SAnimDeactivate(0)=(AnimChance=1.0,animSeq=Deactivate,AnimRate=1.0)
    SAnimFire(0)=(AnimChance=1.0,animSeq=FireA,AnimRate=1.0,AnimSound=sound'dnsWeapn.Energy.LSniperFire12')
    SAnimReload(0)=(AnimChance=1.0,animSeq=Reload,AnimRate=1.0)
    SAnimIdleSmall(0)=(AnimSeq=IdleA,AnimRate=1.0,AnimTween=0.0,AnimChance=0.5)
    SAnimIdleSmall(1)=(AnimSeq=IdleB,AnimRate=1.0,AnimTween=0.0,AnimChance=0.5)
    SAnimIdleLarge(0)=(AnimSeq=IdleC,AnimRate=1.0,AnimTween=0.0,AnimChance=1.0)

	AmmoName=class'dnGame.SniperCell'
	AmmoItemClass=class'HUDIndexItem_Sniper'
	AltAmmoItemClass=class'HUDIndexItem_SniperAlt'
	ReloadCount=20
	PickupAmmoCount(0)=20
	bMultiMode=true

	CollisionHeight=6
	CollisionRadius=18

	bInstantHit=true

	ItemName="Sniper Rifle"
    PickupSound=Sound'dnGame.Pickups.WeaponPickup'
	PickupIcon=texture'hud_effects.am_sniper'
    Icon=Texture'hud_effects.mitem_sniper2'

    AutoSwitchPriority=9

	dnInventoryCategory=1
	dnCategoryPriority=3

	LodMode=LOD_Disabled

	FireOffset=(X=0.0,Y=0.0,Z=0.0)

	PlayerViewScale=0.1
	PlayerViewOffset=(X=0.4,Y=-0.00384,Z=-9)
    PlayerViewMesh=Mesh'c_dnWeapon.snipergun'
    PickupViewMesh=Mesh'c_dnWeapon.w_snipergun'
    ThirdPersonMesh=Mesh'c_dnWeapon.w_snipergun'
    Mesh=Mesh'c_dnWeapon.w_snipergun'

    FireAnim=(AnimSeq=T_SniperFire,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)
    IdleAnim=(AnimSeq=T_SniperIdle,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
    ReloadLoopAnim=(AnimSeq=T_SniperReload,AnimChan=WAC_Top,AnimRate=1.0,AnimTween=0.1,AnimLoop=false)

	SniperVisionOverlay=texture'hud_effects.sniperblack1BC'
	SniperInnerCircle(0)=texture'hud_effects.snp_innercircle1BC'
	SniperInnerCircle(1)=texture'hud_effects.snp_innercircle2BC'
	SniperInnerCircle(2)=texture'hud_effects.snp_innercircle3BC'
	SniperZoomLevel(0)=texture'hud_effects.snpzoom1BC'
	SniperZoomLevel(1)=texture'hud_effects.snpzoom10BC'
	SniperZoomLevel(2)=texture'hud_effects.snpzoom40BC'
	SniperUplink(0)=texture'hud_effects.snpriflelink1BC'
	SniperUplink(1)=texture'hud_effects.snpriflelink2BC'
	SniperStats(0)=smackertexture'hud_effects.snpstats1BC'
	SniperStats(1)=smackertexture'hud_effects.snpstats2BC'
	SniperPitch=smackertexture'hud_effects.heightangle'
	SniperBacteria=smackertexture'hud_effects.bacteriadisp1'
	SniperBootup(0)=smackertexture'hud_effects.snpbootup1BC'
	SniperBootup(1)=smackertexture'hud_effects.snpbootup2BC'
	SniperLoadBattery=smackertexture'hud_effects.loadbat1BC'
	SniperXYPosition(0)=texture'hud_effects.xy_position1BC'
	SniperXYPosition(1)=texture'hud_effects.xy_position2BC'
	SniperCompassArrow=texture'hud_effects.sniperarrow1BC'
	ChargeTextures(0)=texture'm_dnWeapon.sniperrifle_lights13bc'
	ChargeTextures(1)=texture'm_dnWeapon.sniperrifle_lights12bc'
	ChargeTextures(2)=texture'm_dnWeapon.sniperrifle_lights11bc'
	ChargeTextures(3)=texture'm_dnWeapon.sniperrifle_lights10bc'
	ChargeTextures(4)=texture'm_dnWeapon.sniperrifle_lights9bc'
	ChargeTextures(5)=texture'm_dnWeapon.sniperrifle_lights8bc'
	ChargeTextures(6)=texture'm_dnWeapon.sniperrifle_lights7bc'
	ChargeTextures(7)=texture'm_dnWeapon.sniperrifle_lights6bc'
	ChargeTextures(8)=texture'm_dnWeapon.sniperrifle_lights5bc'
	ChargeTextures(9)=texture'm_dnWeapon.sniperrifle_lights4bc'
	ChargeTextures(10)=texture'm_dnWeapon.sniperrifle_lights3bc'
	ChargeTextures(11)=texture'm_dnWeapon.sniperrifle_lights2bc'
	ChargeTextures(12)=texture'm_dnWeapon.sniperrifle_lightsbc'

	TraceHitCategory=TH_LaserBurn
	ActivateSound=sound'dnsWeapn.Energy.LSniperOnLp02'
	TraceDamageType=class'SniperLaserDamage'
	ChargeLevel=12
	CrosshairIndex=12
	bUseMuzzleAnchor=true
	MuzzleFlashOrigin=(Z=6)
}
