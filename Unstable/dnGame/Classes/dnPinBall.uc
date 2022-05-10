//=============================================================================
// dnPinBall. (JP)
//=============================================================================
class dnPinBall expands dnBall;

#exec OBJ LOAD FILE=..\Meshes\c_zone1_vegas.dmx 

var () vector		PinballGravity;
var float			OriginalZ;

//=============================================================================
//	PostBeginPlay
//=============================================================================
function PostBeginPlay()
{
	Super.PostBeginPlay();

	DropToFloor();

	OriginalZ = Location.Z;
}


//=============================================================================
//	Tick
//=============================================================================
function Tick(float DeltaSeconds)
{
	local vector		l;

	Super.Tick(DeltaSeconds);

	SetRotation(rot(0,0,0));

	l = Location;
	l.Z = OriginalZ;
	SetLocation(l);
}

//=============================================================================
//	MoveBall
//=============================================================================
function MoveBall(float DeltaSeconds)
{
	Super.MoveBall(DeltaSeconds);

	//Velocity += vect(0,60,0)*DeltaSeconds;
	Velocity += PinballGravity*DeltaSeconds;
}

//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	bMeshEnviroMap=True 
	Texture=Texture'vegas.floors.peoplemover1bRC'
	Mesh=DukeMesh'c_zone1_vegas.billiards_ball'
	CollisionHeight=0.25
	CollisionRadius=0.25
	DrawScale=0.5

	GroundFriction=-2.1
	
	bCollideWhenPlacing=false

	DontDie=true
	Health=0
	BallGroundFriction=0.2
	BallPushVelocityScale=1.0
	bUnlit=true

	PinballGravity=(X=0.0,Y=60.0,Z=0.0)
}
