/*-----------------------------------------------------------------------------
	MightyFoot
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class MightyFoot expands MeleeWeapon;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

var sound ImpactSound;



/*-----------------------------------------------------------------------------
	Third Person Animations
-----------------------------------------------------------------------------*/

var WAMEntry StandingMightyFootFireAnim;
var WAMEntry StandingQuickKickFireAnim;
var WAMEntry MovingFireAnim;



/*-----------------------------------------------------------------------------
	Cannibal notifications.
-----------------------------------------------------------------------------*/

simulated function FootSmash()
{
	// No longer used.
}

simulated function FootSmashDone()
{
	// No longer used.
}


/*-----------------------------------------------------------------------------
	Firing and Input
-----------------------------------------------------------------------------*/

// No alt fire.
function bool ButtonAltFire() { return false; }
function AltFire() {}
simulated function bool ClientAltFire() { return false; }

// Can't fire if animating.  Prevents double kicking from quickkick.
simulated function bool ClientFire()
{
	if ( IsAnimating() )
		return false;
	else
		return Super.ClientFire();
}

// Can't fire if animating.  Prevents double kicking from quickkick.
function Fire()
{
	if ( !IsAnimating() )
		Super.Fire();
}

// We always have time for lubricant.
simulated function bool HaveModeAmmo() { return true; }



/*-----------------------------------------------------------------------------
	Animation
-----------------------------------------------------------------------------*/

// Determines correct 3rd person animation based on movement state.
simulated function WAMEntry GetFireAnim()
{
    if ( Pawn(Owner) == None )
    {
        return NoAnim;
    }

    // Get the proper animation based on the player's movement states       
    if ( Pawn(Owner).GetMovementState() != MS_Waiting ) 
    {
        // Owner is moving
        return MovingFireAnim;
    }
    else
    {    
        if ( Pawn(Owner).Weapon == self ) // MightyFoot weapon
        {    
            return StandingMightyFootFireAnim;
        }
        else // QuickKick
        {
            return StandingQuickKickFireAnim;        
        }
    }
}

// Determines correct 3rd person animation based on movement state.
simulated function WpnFire( optional bool noWait )
{
	local WAMEntry entry;
    local rotator r;

    r = Pawn(Owner).ViewRotation;
    r = Normalize(r);

    if ( (Pawn(Owner)!=None) && (r.Pitch < -10000) )
        ActiveWAMIndex = GetRandomWAMEntry( default.SAnimAltFire, entry );
    else
	    ActiveWAMIndex = GetRandomWAMEntry( default.SAnimFire, entry );

	if ( Owner.IsA('DukePlayer') && (DukePlayer(Owner).SmashPawn != None) )
		entry.AnimRate *= 1.5;

	PlayWAMEntry( entry, !noWait, 'None' );

    if ( !bDontPlayOwnerAnimation )
    {
        if ( Pawn(Owner).Weapon == self ) // MightyFoot 
        {
            Pawn(Owner).WpnPlayFire();
        }
        else
        {
            Pawn(Owner).WpnAuxPlayFire( self ); // Quick Kick
        }
    }

    bDontPlayOwnerAnimation = false;
}

// No alt fire animations.
simulated function WpnAltFireStart() {}
simulated function WpnAltFire() {}
simulated function WpnAltFireStop() {}

// No activate animation.
simulated function WpnActivate()
{
	bHideWeapon = false;

	// No activate animation for the foot.
    WeaponState = WS_ACTIVATE;

    // Third person animation
    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayActivate();
    bDontPlayOwnerAnimation = false;
}

// No deactivate animation.
simulated function WpnDeactivated()
{
	// No deactivate animation for the foot.
    WeaponState = WS_DEACTIVATED;

    if ( !bDontPlayOwnerAnimation )
        Pawn(Owner).WpnPlayDeactivated();
    bDontPlayOwnerAnimation = false;
}



/*-----------------------------------------------------------------------------
	Traces
-----------------------------------------------------------------------------*/

// Performs trace fire logic.
simulated function TraceFire( Actor HitInstigator, 
				    optional float HorizError, optional float VertError, 
					optional bool bDontPenetrate, optional bool bEffectsOnly,
					optional bool bNoActors, optional bool bNoMeshAccurate,
					optional bool bNoCreationSounds )
{
	local Actor HitActor;
	local vector Direction;
	local vector StartTrace, EndTrace, BeamStart;
	local vector HitLocation, HitNormal;
	local vector BackHitLocation, BackHitNormal;
	local vector HitMeshBarys;
	local int HitMeshTri;
	local name HitMeshBone;
	local texture HitMeshTex;
	local PointRegion HitRegion;
	local class<Material> HitMat;
	local float MaxMaterialWidth;
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local int HitSurfaceIndex;	

	// See if there is a door to kick down.
	if ( PlayerPawn(Owner) != None )
	{
		HitActor = PlayerPawn(Owner).TraceFromCrosshair(PlayerPawn(Owner).UseDistance/2);
		if ( (DoorMover(HitActor) != None) && DoorMover(HitActor).bKickable )
		{
			DoorMover(HitActor).bKickedOpen = true;
			DoorMover(HitActor).Used( PlayerPawn(Owner), PlayerPawn(Owner) );
		}
	}

	// Get our trace parameters.
	PawnOwner = Pawn(Owner);
	StartTrace = Owner.Location + PawnOwner.BaseEyeHeight * vect(0,0,1);
	EndTrace = StartTrace + vector(PawnOwner.ViewRotation)*MeleeHitRadius;

	// Trace out to see what we hit.
	HitActor = Trace( 
		HitLocation, HitNormal, EndTrace, StartTrace, !bNoActors, ,
		!bNoMeshAccurate, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex
		);

	if ( HitActor != none )
	{
		// JEP...
		// Find the material if we hit a brush.
		if ( (HitActor != None) && ((HitActor == Level) || HitActor.IsA('Mover')) )
			HitMat = TraceMaterial( EndTrace, StartTrace, HitSurfaceIndex );

		// Hit the material.
		if ( (HitMat != None) && (Level.NetMode != NM_DedicatedServer) )
			//HitMaterial( HitMat, TraceHitCategory, HitLocation, HitNormal, !bNoCreationSounds, HitSurfaceIndex );
			HitMaterial( HitMat, 2, HitLocation, HitNormal, !bNoCreationSounds, HitSurfaceIndex );
		// ...JEP

		// JEP... Notify glass we want to break it, if it was part of the trace (this is a total special case)
		if (HitActor.IsA('BreakableGlass'))
		{
			// Notify the glass that we hit it
			if (BreakableGlass(HitActor).GlassBreakCount > 0)
				BreakableGlass(HitActor).ReplicateBreakGlassDir( HitLocation, vector(PawnOwner.ViewRotation), 30.0f );
			else
				BreakableGlass(HitActor).ReplicateBreakGlass( HitLocation );
		}
		// ...JEP
		else if ( HitActor.IsA('Snatcher') )
		{
			Pawn(HitActor).Died( PawnOwner, class'MightyFootDamage', HitActor.Location );
		}
		else if ( HitActor.IsA('SnatcherCarcass') )
		{
			HitActor.TakeDamage( 100, PawnOwner, HitActor.Location, vect( 0, 0, 0 ), class'MightyFootDamage' );
		}
		else if ( !bEffectsOnly )
		{
			TraceHit( 
				StartTrace, EndTrace, HitActor, HitLocation, HitNormal, 
				HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitInstigator, BeamStart
				);
		}
	}
}

// Does the trace hit.
function TraceHit( vector StartTrace, vector EndTrace, Actor HitActor, vector HitLocation, 
				   vector HitNormal, int HitMeshTri, vector HitMeshBarys, name HitMeshBone, 
				   texture HitMeshTex, Actor HitInstigator, vector BeamStart )
{
	if ( HitActor != None )
		Owner.PlaySound( ImpactSound, SLOT_Interact, Pawn(Owner).SoundDampening );

	// JEP: Commented out.  Materials now spawn the effect
	//if ( (HitActor != None) && !HitActor.bIsPawn )
	//	spawn(class'dnCharacterFX_Dirt_FootHaze', Self, , HitLocation + HitNormal*1, rotator(HitNormal));

	Super.TraceHit( StartTrace, EndTrace, HitActor, HitLocation, HitNormal, HitMeshTri, HitMeshBarys, HitMeshBone, HitMeshTex, HitInstigator, BeamStart );
}



/*-----------------------------------------------------------------------------
	Inventory System
-----------------------------------------------------------------------------*/

// Draws the...ah hell you know.
simulated function DrawAmmoAmount( Canvas C, DukeHUD HUD, float X, float Y ) { }



/*-----------------------------------------------------------------------------
	States
-----------------------------------------------------------------------------*/

// Overridden because there is no activate animation.
state Active
{
	simulated function BeginState()
	{
		Super.BeginState();
		GotoState('Idle');
	}
}

// Overridden because there is no deactivate animation.
state DownWeapon
{
	simulated function BeginState()
	{
		AnimEnd();
	}
}

defaultproperties
{
	AmmoName=class'dnGame.MightyFootAmmo'
	PickupAmmoCount(0)=1
    MeleeHitMomentum=2000.0
    MeleeHitRadius=128.0
    SAnimFire(0)=(AnimSeq=FireA,AnimRate=1.0,AnimSound=sound'dnsWeapn.MightyFoot.MFWhoosh16')
    dnInventoryCategory=0
    dnCategoryPriority=0
    Icon=texture'hud_effects.mitem_mightyboo'
    PlayerViewMesh=Mesh'c_dnWeapon.MightyFoot'
    PlayerViewScale=0.3
    PlayerViewOffset=(X=3.5,Y=1.5,Z=-22.3)
    ItemName="Mighty Foot"
    TraceHitCategory=TH_Foot
    bAmmoItem=false
    bAltAmmoItem=false
    ImpactSound=sound'dnsWeapn.MightyFoot.MFImpact19'

    StandingMightyFootFireAnim=(AnimSeq=A_Kick_Front,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=false,DebugString="StandingMightyFootFireAnim")
    StandingQuickKickFireAnim=(AnimSeq=B_Kick,AnimChan=WAC_Bottom,AnimRate=1.0,AnimTween=0.1,AnimLoop=false,DebugString="StandingQuickKickFireAnim")
    MovingFireAnim=(AnimSeq=B_Kick,AnimChan=WAC_Bottom,AnimRate=1.0,AnimTween=0.1,AnimLoop=false,DebugString="MovingFireAnim")
    CrouchFireAnim=(AnimSeq=B_CrchWalk_Kick,AnimChan=WAC_Bottom,AnimRate=1.0,AnimTween=0.1,AnimLoop=false,DebugString="CrouchFireAnim")
    IdleAnim=(PlayNone=true,AnimChan=WAC_Top)
    CrouchIdleAnim=(PlayNone=true,AnimChan=WAC_Top)
    CrouchWalkAnim=(AnimSeq=A_CrchWalk,AnimChan=WAC_All,AnimRate=1.0,AnimTween=0.1,AnimLoop=true)
	CrosshairIndex=3
	bNoShake=true
}

