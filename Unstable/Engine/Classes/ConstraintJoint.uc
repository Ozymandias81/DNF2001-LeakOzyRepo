/*-----------------------------------------------------------------------------
	ConstraintJoint
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ConstraintJoint extends InfoActor;

var() bool  Anchor;
var() float MinConstraint, MaxConstraint;
var   float MaxDistance;
var   bool  Gravity, DoForce;
var   float OneOverMass, TorqueMod;
var   ConstraintJoint FriendJoint;
var   rotator ParentLastRot;
var   vector FrameForce;
var   vector Position;

var() float TorquePushForce;
var() float TorquePushTime;

const GRAVITY_CONSTANT = -300.0f;

function PostBeginPlay()
{
	local ConstraintJoint CJ;
	local vector Equilibrium;

	Super.PostBeginPlay();

	foreach AllActors( class'ConstraintJoint', CJ, Event )
	{
		FriendJoint = CJ;
	}

	if ( FriendJoint == None )
		Log("ConstraintJoint failed to find friend with tag"@Event);

	OneOverMass = 1.f / Mass;

	MaxDistance = VSize( Location - FriendJoint.Location );
	
	if ( !Anchor )
	{
		Equilibrium = FriendJoint.Location + vect(0,0,-MaxDistance);
		SetLocation( Equilibrium );
	}

	TorqueMod = 1.0;
}

function CalculateForces( float TimeStep )
{
	local vector DistDelta, ModVector, Gravity, Equilibrium, EquilDir, Tension, Torque;
	local float Distance, DistFromEquil, cosAngle, TensionF, TorqueF;

	// Add line tension.
	DistDelta = Position - FriendJoint.Location;
	Distance = VSize( DistDelta );
	if ( Distance >= MaxDistance )
	{		
		// Add the torque.
		Equilibrium = FriendJoint.Location + vect(0,0,-MaxDistance);
		DistFromEquil = VSize( Position - Equilibrium );
		EquilDir = Normal(Position - Equilibrium);
		cosAngle = ((DistFromEquil*DistFromEquil) - (MaxDistance*MaxDistance) - (Distance*Distance)) / (-2*MaxDistance*Distance);
		TorqueF = -Mass*GRAVITY_CONSTANT*sin(acos(cosAngle));
		Torque = normal(Position - Equilibrium) * TorqueF * TorqueMod;
		FrameForce -= Torque;
	}
}

function Integrate( float TimeStep )
{
	local vector ForceByMass, ForceByMassAndTime;
	local float dTimeStep;

	// Determine force vectors.
	ForceByMass = FrameForce * OneOverMass;
	ForceByMassAndTime = ForceByMass * TimeStep;

	// Integrate by time.
	dTimeStep = 0.5f * (TimeStep * TimeStep);
	Position = Position + TimeStep * Velocity + dTimeStep * ForceByMass;
	Velocity += ForceByMassAndTime;

	// Zero out the frame force.
	FrameForce = vect( 0.f, 0.f, 0.f );
}

event Tick( float DeltaTime )
{
	local float TimeStep, Distance, a, DistFromEquil;
	local vector XAxis, YAxis, ZAxis, X, Y, Z, ModVector, DistDelta, Equilibrium;
	local rotator r, r2;

	local float XEquil, XPos;
	local float YEquil, YPos;

	if ( !Anchor )
	{
		Position = Location;
		TimeStep = DeltaTime;
		if ( TimeStep > 0.033f )
			TimeStep = 0.033f;

		if ( DoForce )
		{
			CalculateForces( TimeStep );
			Integrate( TimeStep );
		}

		// Maintain constraint.
		DistDelta = Position - FriendJoint.Location;
		Distance = VSize( DistDelta );
		ModVector = (Distance - MaxDistance) * Normal( DistDelta );
		Position -= ModVector;
		SetLocation( Position );

		ZAxis = normal(Position - FriendJoint.Location);
		ZAxis = -ZAxis;
		a = (ZAxis.X * 3.0 + ZAxis.Y * 0.0)/ZAxis.Z;
		XAxis = normal(vect(-3.0, -0.0, a));
		YAxis = normal(ZAxis cross XAxis);
		r = OrthoRotation( XAxis, YAxis, ZAxis );
		SetRotation( r );
	}

	if ( FriendJoint.Rotation != ParentLastRot )
		DoForce = true;
	ParentLastRot = FriendJoint.Rotation;
}

function Trigger( actor Other, pawn EventInstigator )
{
	local vector X, Y, Z;
	DoForce = true;
	GetAxes( FriendJoint.Rotation, X, Y, Z );
	FrameForce += Y*100000;
	TorqueMod = TorquePushForce;
	SetTimer( TorquePushTime, false );
}

function Timer( optional int TimerNum )
{
	TorqueMod = 1.0;
	SetTimer( 0.0, false );
}

function ModMaxDistance( float DeltaDist )
{
	DoForce = true;
	MaxDistance += DeltaDist;
	MaxDistance = FClamp(MaxDistance+DeltaDist, MinConstraint, MaxConstraint );
}

function PullBack( float DeltaDist )
{
	local vector X, Y, Z;

	DoForce = false;
	GetAxes( FriendJoint.Rotation, X, Y, Z );
	SetLocation( Location + Y*DeltaDist );
}

defaultproperties
{
	Mass=100
	bHidden=true
	MinConstraint=100
	MaxConstraint=300
	DoForce=true
	TorquePushForce=5.0
	TorquePushTime=0.1
}