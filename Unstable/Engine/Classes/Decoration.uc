//=============================================================================
// Decoration.
//=============================================================================
class Decoration expands Item
	abstract
	native;

// If set, the pyrotechnic or explosion when item is damaged.
var() class<actor>					EffectWhenDestroyed;
var() bool							bDestroyMatchingTags ?("Destroys all other actors with matching tags.");
var() bool							bPushable;
var() bool							Grabbable;	// NJS: Whether this decoration can be picked up. Needs the above to be set
var() bool							bOnlyTriggerable;
var   travel bool					bSplash;
var   travel bool					bBobbing;
var   travel bool					bWasCarried;
var() sound							PushSound;
var   const int						numLandings; // Used by engine physics.
var() sound							EndPushSound;
var   bool							bPushSoundPlaying;
var() float							ThrowForce;		// Force with which to throw the decoration if non-zero
var() bool							bSetFragSkin;
var   texture						FragSkin;

var   float							OrigCollisionRadius;
var   float							OrigCollisionHeight;

var   travel Pawn					CarriedBy;

var   bool							bNotifyUnUsed;			// For dnDecorations
var   bool							bClientNotifyUnUsed;
var	  bool							bOldShadowReceive;

var float							ShrinkStartScale;
var float							ShrinkStartRadius;
var float							ShrinkStartHeight;
var float							ShrinkPitchWiggle;
var float							ShrinkYawWiggle;

var() class<SoftParticleSystem>		MeshFlameClass;

// ---------------------------
// ScaleGlow Ramp Variables
// ---------------------------
var float	ScaleGlowRampTime;
var float	OriginalScaleGlow;
var float	TargetScaleGlow;
var float	TimePassed;
var bool	ScaleGlowRampUp;

enum EThirdPersonHand
{
    OneHanded,
    TwoHanded,
};

// These are the values that are used when a decoration gets attached to a player in 3rd person
var() struct native SThirdPersonInfo
{
    var() EThirdPersonHand Hand            ?("Set which type of upper body animationt to play when carrying this decoration");
    var() vector           MountOrigin     ?("Specify an origin offset for the decoration from the mount point");
    var() rotator          MountAngles     ?("Specify aangles for the decoration from the mount point");
} ThirdPersonInfo;

/*-----------------------------------------------------------------------------
	dnDecoration Stub Functions
-----------------------------------------------------------------------------*/

function PostBeginPlay()
{
	Super.PostBeginPlay();

	OrigCollisionRadius = CollisionRadius;
	OrigCollisionHeight = CollisionHeight;
	FragSkin = MeshGetTexture(0);
}

function Tossed(optional bool bDropped)
{
	bCollideWorld = Default.bCollideWorld;
	SetTimer(0.1, false, 1);
	SetCollisionSize( OrigCollisionRadius, OrigCollisionHeight );

	bHidden = false;
	bWasCarried = true;
	SetBase( None );
	SetPhysics( PHYS_Falling );
}

function WaterPush()
{
}

function bool IsWaterLogged()
{
	return false;
}

function float GetForceScale()
{
	return 1.0;
}

function float GetJumpZScale()
{
	return 1.0;
}

/*-----------------------------------------------------------------------------
	Landing behavior.
-----------------------------------------------------------------------------*/

function Landed( vector HitNormal )
{
	if ( bWasCarried && !SetLocation(Location) )
	{
//		BroadcastMessage( Self@"was carried and couldn't set location." );
		if( Instigator != None && (VSize(Instigator.Location - Location) < CollisionRadius + Instigator.CollisionRadius) )
			SetLocation( Instigator.Location );
		TakeDamage( 1000, Instigator, Location, Vect(0,0,1)*900, class'ExplosionDamage' );
	}

	bBobbing = false;
}

function ZoneChange( ZoneInfo NewZone )
{
	local float splashsize;
	local actor splash;

	if( NewZone.bWaterZone )
	{
		if( bSplash && !Region.Zone.bWaterZone && Mass<=Buoyancy 
			&& ((Abs(Velocity.Z) < 100) || (Mass == 0)) && (FRand() < 0.05) && !PlayerCanSeeMe() )
		{
			bSplash = false;
			SetPhysics(PHYS_None);
		}
		else if( !Region.Zone.bWaterZone && (Velocity.Z < -200) )
		{
			// Else play a splash.
			splashSize = FClamp(0.0001 * Mass * (250 - 0.5 * FMax(-600,Velocity.Z)), 1.0, 3.0 );
			if( NewZone.EntrySound != None )
				PlaySound(NewZone.EntrySound, SLOT_Interact, splashSize);
			if( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor); 
				if ( splash != None )
					splash.DrawScale = splashSize;
			}
		}
		bSplash = true;
	}
	else if( Region.Zone.bWaterZone && (Buoyancy > Mass) )
	{
		bBobbing = true;
		if( Buoyancy > 1.1 * Mass )
			Buoyancy = 0.95 * Buoyancy;
		else if( Buoyancy > 1.03 * Mass )
			Buoyancy = 0.99 * Buoyancy;
	}

	if ( NewZone.DOT_Type != DOT_None )
		TakeDamage( 100, None, Location, vect(0,0,0), class'CrushingDamage' );
}

function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	TakeDamage( 1000, Instigator, Location, Vect(0,0,1)*900, class'ExplosionDamage' );
}

singular function BaseChange()
{
	local float decorMass, decorMass2;

	decorMass	 = FMax(1, Mass);
	bBobbing	 = false;

	if( Velocity.Z < -500 )
		TakeDamage( (1-Velocity.Z/30), Instigator, Location, vect(0,0,0) , class'CrushingDamage' );

	if( (Base == None) && (bPushable || IsA('Carcass')) && (Physics == PHYS_None) )
	{
		SetPhysics(PHYS_Falling);
	} else if( (Pawn(Base) != None) && (Pawn(Base).CarriedDecoration != self) )
	{
		Base.TakeDamage( (1-Velocity.Z/400)* decormass/Base.Mass,Instigator,Location,0.5 * Velocity , class'CrushingDamage' );

		// If we land on a pawn, bounce us clear.
		Velocity.X += Rand(50) + 50;
		Velocity.Y += Rand(50) + 50;
		Velocity.Z = 100;
		Acceleration = vect(0, 0, 0);

		SetPhysics(PHYS_Falling);
		SetBase(None);
	}
	else if( Decoration(Base)!=None && Velocity.Z<-500 )
	{
		decorMass2 = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((1 - decorMass/decorMass2 * Velocity.Z/30), Instigator, Location, 0.2 * Velocity, class'CrushingDamage' );
		Velocity.Z = 100;
		if (FRand() < 0.5)
			Velocity.X += 70;
		else
			Velocity.Y += 70;
		SetPhysics(PHYS_Falling);
	}
	else
		instigator = None;
}

function Destroyed()
{
	local actor dropped, A;
	local class<actor> 	tempClass;
	local name 			oldTag;

	// Wipe out all actors with matching tags.
	if (bDestroyMatchingTags) {
		oldTag = Tag;
		Tag		= 'None';
		foreach AllActors( class 'Actor', A, oldTag)
			A.Destroy();
		Tag = oldTag;
	}

	if( (Pawn(Base) != None) && (Pawn(Base).CarriedDecoration == self) )
		Pawn(Base).DropDecoration();

	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, None );

	if ( bPushSoundPlaying )
		PlaySound(EndPushSound, SLOT_Misc,0.0);
			
	foreach AllActors( class'Actor', A )
	{
		if (A.IsA('Decoration'))
		{
			if ((A.base == Self) && (A != Self))
			{
				A.SetBase(None);
				A.SetPhysics(PHYS_Falling);
			}
		}
		else if (A.IsA('Inventory') && (A.base == Self) && (!Inventory(A).bCarriedItem))
		{
			A.SetBase(None);
			A.SetPhysics(PHYS_Falling);
		}
	}

	Super.Destroyed();

}

simulated function SpawnFrag(class<SoftParticleSystem> FragType)
{
	local SoftParticleSystem s;

	if ( bOnlyTriggerable )
		return;
	if ( !Region.Zone.bDestructive )
		s = Spawn( FragType, Self );
}

function Timer(optional int TimerNum)
{
	local float VelocitySize;
	local vector Down;

	if (TimerNum == 1)
	{
		if( self.IsA( 'G_Flashlight' ) )
			SetCollision( true, true, true );
		else
		SetCollision( Default.bCollideActors, Default.bBlockActors, Default.bBlockPlayers );
	}
	else if ((TimerNum == 0) && (Physics == PHYS_Rolling))
	{
		if (Velocity == vect(0,0,0)) {
			SetPhysics(PHYS_None);
			SetTimer(0.0,false);
		}
	}
}

function Bump( actor Other )
{
	local float Speed;
	local vector TraceStart, TraceEnd, HitLocation, HitNormal, Vel2D, Norm2D;
	local Actor HitActor;

	if ((Physics == PHYS_Falling) && (!IsWaterLogged()))
		return;
	if( bPushable && (Pawn(Other) != None) && (Other.Mass > 40) )
	{
		bBobbing = false;
		Speed = VSize(Other.Velocity);
		Velocity = Other.Velocity * FMin(120.0, 20 + Speed)/Speed;
		SetPhysics(PHYS_Rolling);
		SetTimer(0.5,true);
		Instigator = Pawn(Other);
	}
}

function NotifyPickup( Inventory Other );

function UnUsed( Actor Other, Pawn EventInstigator );
function ClientUnUsed( Actor Other, Pawn EventInstigator );


/*-----------------------------------------------------------------------------
	ScaleGlow Ramping
-----------------------------------------------------------------------------*/
function RampScaleGlow (float NewScaleGlow, float NewScaleGlowRampTime)
{
	ScaleGlowRampTime = NewScaleGlowRampTime;
	OriginalScaleGlow = ScaleGlow;
	TargetScaleGlow = NewScaleGlow;
	if (TargetScaleGlow < 0) TargetScaleGlow=0;
	GotoState ('StartScaleGlowRamp');
}

state StartScaleGlowRamp

{
	simulated function BeginState()
	{
		TimePassed = 0;
		if (TargetScaleGlow > ScaleGlow) ScaleGlowRampUp = True;
			else ScaleGlowRampUp = False;
	}

	simulated function Tick( float Delta )
	{
		Global.Tick( Delta );
		TimePassed += Delta;
		if (ScaleGlowRampUp)
		{
			ScaleGlow = OriginalScaleGlow + ((TimePassed / ScaleGlowRampTime) * TargetScaleGlow);
			if (ScaleGlow >= TargetScaleGlow) GotoState ('EndScaleGlowRamp');
		}
		else
		{
			ScaleGlow = OriginalScaleGlow - ((TimePassed / ScaleGlowRampTime) * OriginalScaleGlow);
			if (ScaleGlow <= TargetScaleGlow) GotoState ('EndScaleGlowRamp');
		}
	}
}

state EndScaleGlowRamp
{
	simulated function BeginState()
	{
		ScaleGlow = TargetScaleGlow;
	}
}
/*-----------------------------------------------------------------------------
	End ScaleGlow Ramping
	This is my random comment that has nothing to do with the code, but has
	everything to do with McKenna McKenna McKenna. Hi Brandon. I Love You.
-----------------------------------------------------------------------------*/

defaultproperties
{
    bStatic=false
    bStasis=false
    Texture=None
    Mass=0.000000
    PhysNoneOnStop=true
    bForceCollisionRep=true;
    ThirdPersonInfo=(Hand=OneHanded,MountAngles=(Yaw=0,Pitch=16384,Roll=0));
//	MaxTimers=5
	bNeverTravel=true
}