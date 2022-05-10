//=============================================================================
// BoneRope. (NJS) Funzies.
//=============================================================================
class BoneRope expands Decoration
    abstract
    native;

var() float  m_maxAngularDisplacement           ?("Max angle the rope can bend (in Radians)");
var() float  m_ropeSpeed                        ?("Speed at which the rope returns to center");
var() float  m_angularFriction                  ?("Friction value to apply to the rope to slow it down when there is a rider");
var() float  m_angularFrictionNoRider           ?("Friction value to apply to the rope to slow it down when there is no rider");
var() float  m_maxAngularInputVelocity          ?("Max amount of input velocity to apply to rope each frame");
var() float  m_angularInputVelocityScale        ?("Scale of the input velocity");
var() float  m_angularInputVelocityScaleOnRope  ?("Scale of the input velocity when the player jumps on the rope");
var() float  m_maxAngularVelocity               ?("Max angular velocity of the rope");
var() float  m_ropeRadius                       ?("Radius of the rope cylinders for collision");
var() float  m_ropeScale                        ?("Scale of the rope's length");
var() float  m_climbUpSpeed                     ?("Speed at which players climb up the rope");
var() float  m_climbDownSpeed                   ?("Speed at which players climb down the rope");
var() float  m_riderRopeOffset                  ?("X/Y distance away from the rope");
var() float  m_riderHorizontalOffset            ?("Horizontal offset from the rope" );
var() float  m_riderVerticalOffset              ?("Vertical offset from the rope");
var() float  m_jumpOffSpeedHorizontal           ?("Amount of speed to give the player when they jump off (horizontal)");
var() float  m_jumpOffSpeedVertical             ?("Amount of speed to give the player when they jump off (vertical)");
var() float  m_jumpOffSpeedAngular              ?("Amount of speed to give the player when they jump off (based on the angular velocity of the rope)");
var() float  m_lookThreshold                    ?("Determines whether or not to move the player up or down if they're view angle exceeds this threshold");
var() bool   bSwingable                         ?("Whether or not this rope swings");
var() bool   bAdjustView                        ?("Whether or not this rope alters the player's view");

var   PlayerPawn            m_Rider;
var   float                 m_ropeLength;
var   vector                m_angularVelocity;
var   vector                m_angularDisplacement;
var   vector                m_oldAngularDisplacement;
var   transient int         m_ropeCylinders;
var   float                 m_CollisionRadiusSquared;
var   vector                m_Location2;            // Endpoint of the rope based on scale and a rope of 256 length
var   float                 m_lastHitTime;
var   int                   m_riderBoneHandle;  
var   const	BoneRope	    m_nextRope;
var   sound                 m_ropeCreakSounds[3];
var   sound                 m_onOffRopeSound;
var   sound                 m_climbSound;
var   float                 m_lastRopeSoundTime;
var   float                 m_lastSwingSize;
var   bool                  m_swingStateAway;
var   transient int         m_ropePrimitive;        // sizeof( RopePrimitive * )
var   int                   m_baseBoneCoords[15];   // sizeof( VCoords3 )
var   float                 m_netAngularDisplacementX;
var   float                 m_netAngularDisplacementY;
var   float                 m_netAngularVelocityX;
var   float                 m_netAngularVelocityY;

native final simulated function DoBoneRope( float deltaTime, optional bool action );
native final simulated function int CheckCollision( vector point, vector dir, float max_distance );
native final simulated function float GetPlayerPositionFactor();
native final simulated function DamageRope( vector hitLocation, vector direction );
native final function OnRope();
native final simulated function InitializeRope();
native final simulated function RecreatePrimitive();
native final simulated function AddRope();		// Add rope to level rope list (linked using m_nextRope).
native final simulated function RemoveRope();	// Remove rope from level rope list.

replication
{
    reliable if ( Role==ROLE_Authority )
        m_riderBoneHandle;
    reliable if ( Role==ROLE_Authority && bNetInitial )
        m_ropeScale;
    unreliable if ( Role==ROLE_Authority && !bNetOwner )
        m_netAngularDisplacementX, m_netAngularDisplacementY, m_netAngularVelocityX, m_netAngularVelocityY;
}

simulated function Tick( float deltaTime )
{
    local float t;

	super.Tick( deltaTime );

    // Server running this tick: if there is a rider, the DoBoneRope will be called from the player's physics code, so don't enter here
    // Client running this code: there won't be a rider unless they are the rider themselves (which is what we want).
    
    // This code should only get executed on a client/server with no rider and it will take the angular displacement from the
    // server and execute based on that.
    if ( m_Rider == None )
    {
	    DoBoneRope( deltaTime, false );
    }

    // Server sends over the angular displacement and velocity as components
    if ( Role == ROLE_Authority )
    {
        m_netAngularDisplacementX   = m_angularDisplacement.X;
        m_netAngularDisplacementY   = m_angularDisplacement.Y;
        m_netAngularVelocityX       = m_angularVelocity.X;
        m_netAngularVelocityY       = m_angularVelocity.Y;
    }
}

simulated function PostNetReceive()
{
    m_angularDisplacement.X = m_netAngularDisplacementX;
    m_angularDisplacement.Y = m_netAngularDisplacementY;
    m_angularVelocity.X     = m_netAngularVelocityX;
    m_angularVelocity.Y     = m_netAngularVelocityY;
}

simulated function Destroyed()
{
	RemoveRope();
}

function Trigger( actor Other, pawn EventInstigator )
{
	// Action bones!
	DoBoneRope( 0, true );
}

simulated function CalculateRopeLocationAndCollision()
{
    // Find the location of the bottom of the rope
    m_CollisionRadiusSquared    = m_ropeLength * m_ropeLength;
    m_Location2                 = Location + ( vect(0,0,-1) * ( m_ropeScale - 1 ) * 256 );
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();   
    AddRope();
    CalculateRopeLocationAndCollision();
	Enable('Tick');
}

simulated event PostNetInitial()
{
    RecreatePrimitive();
    CalculateRopeLocationAndCollision();
}

simulated function bool CheckTouchRope( Actor Other )
{
    local vector delta;
    local float  dist;

    delta = Other.Location - m_Location2;
    dist  = delta dot delta;

    if ( dist < m_CollisionRadiusSquared )
    {
        return true;
    }
}

function TakeDamage
    ( 
    int NDamage,
    Pawn instigatedBy,
    Vector hitlocation, 
	Vector momentum, 
    class<DamageType> DamageType
    )
{
    DamageRope( hitLocation, momentum );
}

event PlaySwingSound()
{
    local int index;

    index = rand(ArrayCount(m_ropeCreakSounds));
    
    if ( m_rider != None )
    {
        m_rider.PlaySound( m_ropeCreakSounds[index], SLOT_Interact );
    }
    else
    {
        PlaySound( m_ropeCreakSounds[index], SLOT_Interact );
    }
}

simulated function ClimbSound()
{
    if ( m_rider != None )
    {
        m_rider.PlaySound( m_climbSound, SLOT_Interact );
    }
    else
    {
        PlaySound( m_climbSound, SLOT_Interact );
    }    
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bBlockActors=false
    bCollideActors=true
    bProjTarget=true
    CollisionRadius=128.000000
    CollisionHeight=256.000000
    bStatic=false
    bStasis=false
    m_maxAngularDisplacement=1.500000
    m_ropeSpeed=25.000000
    m_angularFriction=0.995000
    m_angularFrictionNoRider=0.997500
    m_maxAngularInputVelocity=0.017000
    m_angularInputVelocityScale=0.300000
    m_angularInputVelocityScaleOnRope=0.300000
    m_maxAngularVelocity=4.000000
    m_ropeRadius=10.000000
    m_ropeScale=1.0
    m_climbUpSpeed=75.000000
    m_climbDownSpeed=250.000000
    m_riderRopeOffset=10.000000
    m_riderVerticalOffset=-16.000000
    m_riderHorizontalOffset=2.000000
    m_jumpOffSpeedHorizontal=250.000000
    m_jumpOffSpeedVertical=300.000000
    m_jumpOffSpeedAngular=400.000000
    m_lookThreshold=0.6000000
    m_riderBoneHandle=-1
    bUseViewportForZ=true
    bSwingable=true
    bAdjustView=false
    MinDesiredActorLights=3
    bTickNotRelevant=False
}