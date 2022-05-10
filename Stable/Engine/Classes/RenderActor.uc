/*-----------------------------------------------------------------------------
	RenderActor
	Author: Brandon Reinhart

	RenderActor contains the extensive renderable information used by many actors.
-----------------------------------------------------------------------------*/
class RenderActor extends Actor
	abstract
	native
	nativereplication;

/*-----------------------------------------------------------------------------
	FIXME!! HACK FLAGS!! 
	MOMMAS DON'T LET YOUR CHILDREN GROW UP TO BE PROGRAMMERS!!
-----------------------------------------------------------------------------*/

var	bool					bEMPulsed;
var(Hackflags) bool			bSteelSkin;
var bool					bSpecialLook;



/*-----------------------------------------------------------------------------
	Rendering
-----------------------------------------------------------------------------*/

var(Display) bool			bHighDetail			?("Only show up on high-detail.");
var(Display) bool			bCollisionForRenderBox;

var(Display) texture		MultiSkins[8]		?("Multi-skin support.");

// UT LOD:
var(Display) float			LODBias;

// DNF LOD:
var(Display) enum ELodMode
{
	LOD_Full,				// Complete falloff to nothing.
	LOD_StopMinimum,		// Falloff to minimum geometry.
	LOD_Disabled			// Disable LOD.
}							LodMode				?("Level of detail reduction mode for DNF meshes.\nFull is full reduction and disappearance\nStopMinimum stops reduction after minimum geometry\nDisabled causes no reduction");
var(Display) float			LodScale			?("Level of detail falloff scale for DNF meshes");
var(Display) float			LodOffset			?("Level of detail starting falloff offset for DNF meshes");

var(Display) float			VisibilityRadius	?("Actor is drawn if viewer is within its visibility cylinder.  Zero = infinite visibility");
var(Display) float			VisibilityHeight	?("Actor is drawn if viewer is within its visibility cylinder.  Zero = infinite visibility");

// Z Visibility Control
var(Display) bool			bUseViewportForZ	?("If true, this actor will always pass Z visibility tests.");
var(Display) float			SpriteProjForward	?("Amount to bias Z visibility tests.");

var(Display) bool			bOwnerNoSee			?("Everything but the owner can see this actor.");
var(Display) bool			bOnlyOwnerSee		?("Only owner can see this actor.");
var(Display) bool			bOwnerGetFrameOnly	?("Evaluate the mesh tris, but don't actually draw if viewport actor is the owner.");



/*-----------------------------------------------------------------------------
	Extended Physics
-----------------------------------------------------------------------------*/



/*-----------------------------------------------------------------------------
	Lighting
-----------------------------------------------------------------------------*/

// CDH: Heat properties, used for heat-based vision etc.
var(HeatVision) bool		bHeated					?("Emits heat in heatvision mode.");
var(HeatVision) bool		bHeatNoHide				?("Even if bHidden, do not hide when in heatvision mode.");
var(HeatVision) float		HeatIntensity			?("Intensity of heat, zero is cold, 255 is furnace.");
var(HeatVision) float		HeatRadius				?("Inner radius of full heat.");
var(HeatVision) float		HeatFalloff				?("Rate at which heat falls into cold.");



/*-----------------------------------------------------------------------------
	Networking
-----------------------------------------------------------------------------*/

// This is the network versions of the animation channels.
// There are 4 channels which are replicated ( channels 1-5, channel 0 is replicated in Actor )
var int						net_bAnimFinished[4];
var int						net_bAnimLoop[4];
var int						net_bAnimNotify[4];
var int						net_bAnimBlendAdditive[4];
var name					net_AnimSequence[4];
var float					net_AnimFrame[4];
var float					net_AnimRate[4];
var float					net_AnimBlend[4];
var float					net_TweenRate[4];
var float					net_AnimLast[4];
var float					net_AnimMinRate[4];
var float					net_OldAnimRate[4];
var plane					net_SimAnim[4];

var bool					bDeletedOwner;			// Used to notify viewmappers that their owner is being deleted.
													// Currently only used with turrets.  Could be used with vehicles.



/*-----------------------------------------------------------------------------
	Interactivity
-----------------------------------------------------------------------------*/

var(Interactivity) bool		bExaminable;
var bool					bNoFOVOnExamine;
var(Interactivity) float	ExamineFOV;
var(Interactivity) float	ExamineRadius;
var(Interactivity) bool		bExamineRadiusCheck;

var(Interactivity) travel int Health				?("Health: 100 = normal maximum (0 = indistructable for decorations)");
var(Interactivity) string	ItemName				?("Used with identification of the object in game.");
var(Interactivity) bool		bNotTargetable			?("The object is not targetable;");
var(Interactivity) bool		bTakeMomentum			?("Actor receives momentum from hits.");
var(Interactivity) bool		bUseTriggered		    ?("Triggered by player use.");
var(Interactivity) bool		bClientUse				?("Whether to perform use functionality on the client.");



/*-----------------------------------------------------------------------------
	Fiery Damnation
-----------------------------------------------------------------------------*/

var(Interactivity) bool			bBurning			?("If the actor is burning it will ignite things that can explode.  Like gas clouds.");
var(Interactivity) bool			bFlammable			?("If true, the actor can be set on fire.");
var(Interactivity) bool			bIgnitable			?("If true, the actor can ignite when someone shoots while inside it.");
var ActorDamageEffect			ImmolationActor;
var(Interactivity) string		ImmolationClass;



/*-----------------------------------------------------------------------------
	Frost of the 7th Plane
-----------------------------------------------------------------------------*/

var(Interactivity) bool			bFreezable			?("If true, the actor can be frozen.");
var ActorDamageEffect			FreezeActor;
var(Interactivity) string		FreezeClass;



/*-----------------------------------------------------------------------------
	Shrink of the 98th Kuruma
-----------------------------------------------------------------------------*/

var(Interactivity) bool			bShrinkable			?("If true, the actor can be shrunken.  Currently only valid for pawn types.");
var ActorDamageEffect			ShrinkActor;
var(Interactivity) string		ShrinkClass;



/*-----------------------------------------------------------------------------
	Replication
-----------------------------------------------------------------------------*/

replication
{
	// Animation. 
    unreliable if( DrawType==DT_Mesh && ((RemoteRole<=ROLE_SimulatedProxy && (!bNetOwner || !bClientAnim)) || bDemoRecording) )
        net_AnimSequence, net_SimAnim, net_AnimMinRate, net_bAnimNotify, net_AnimBlend, net_bAnimBlendAdditive;

	// Rendering.
	unreliable if( Role==ROLE_Authority )
		bOnlyOwnerSee;
	unreliable if( !bDontReplicateMesh && DrawType==DT_Mesh && Role==ROLE_Authority )
		MultiSkins;

	// Interactivity
	unreliable if( Role==ROLE_Authority )
		ItemName;
	reliable if( Role==ROLE_Authority )
		Health, ShrinkActor, ImmolationActor;
}

simulated event Destroyed()
{
	RemoveEffects();

	Super.Destroyed();
}

simulated function RemoveEffects()
{
	// Destroy fire.
	if ( ImmolationActor != None )
		ImmolationActor.Destroy();

	// Destroy ice.
	if ( FreezeActor != None )
		FreezeActor.Destroy();

	// Destroy shrink.
	if ( ShrinkActor != None )
		ShrinkActor.Destroy();
}

function RenderActor SpecialLook( PlayerPawn LookPlayer );

// These special effects queries could be combined into one, but I like them seperate for now.
function Ignite( Pawn Instigator );
simulated function bool CanBurn( class<DamageType> DamageType )
{
	if ( bFlammable && ClassIsChildOf( DamageType, class'FireDamage' ) &&
		((ImmolationActor == None) || ImmolationActor.bDeleteMe) &&
		(ImmolationClass != "") )
		return true;
	else
		return false;
}

simulated function bool CanFreeze( class<DamageType> DamageType )
{
	if ( bFreezable && ClassIsChildOf( DamageType, class'ColdDamage' ) &&
		((FreezeActor == None) || FreezeActor.bDeleteMe) &&
		(FreezeClass != "") )
		return true;
	else
		return false;
}

simulated function bool CanShrink( class<DamageType> DamageType )
{
	if ( bShrinkable && ClassIsChildOf( DamageType, class'ShrinkerDamage' ) &&
		((ShrinkActor == None) || ShrinkActor.bDeleteMe) &&
		(ShrinkClass != "") )
		return true;
	else
		return false;
}

defaultproperties
{
	bIsRenderActor=true
	SpriteProjForward=32.0
	ExamineFOV=60.0
	ExamineRadius=80.0
	bExamineRadiusCheck=false
	LODBias=1.000000
	LodScale=1.000000
	LodOffset=0.000000
	bTakeMomentum=True
}