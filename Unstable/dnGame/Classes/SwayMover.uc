/*-----------------------------------------------------------------------------
	SwayMover
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class SwayMover extends Mover;

var() bool  UseX, UseY;
var() float XMotionScale, XGravityScale, MaxXRotation;
var() float YMotionScale, YGravityScale, MaxYRotation;
var() float AirFrictionDivisor;
var() float ImpactForce;

var PivotJoint Joint;

simulated function BeginPlay()
{
	Joint = spawn(class'PivotJoint');

	Joint.bHidden = true;
	Joint.AirFrictionDivisor = AirFrictionDivisor;

	Joint.UseX = UseX; 
	Joint.XMotionScale		= XMotionScale;
	Joint.XGravityScale		= XGravityScale;
	Joint.MaxXRotation		= MaxXRotation;

	Joint.UseY = UseY;
	Joint.YMotionScale		= YMotionScale;
	Joint.YGravityScale		= YGravityScale;
	Joint.MaxYRotation		= MaxYRotation;

	AttachActorToParent(Joint);
}

function TakeDamage( int Damage, Pawn InstigatedBy, vector Hitlocation, vector Momentum, class<DamageType> DamageType)
{
	Impact( ImpactForce, Momentum );
}

function Impact( float Force, vector HitVector )
{
	Enable('Tick');
	SetPhysics(PHYS_MovingBrush);
	if (UseX)
		Joint.RotationVelocity.Y += Force * Normal(HitVector).X;
	if (UseY)
		Joint.RotationVelocity.Z += -Force * Normal(HitVector).Y;
}

function Tick(float DeltaTime)
{
	local float Mag;

	Super.Tick(DeltaTime);

	Mag = Sqrt(Joint.RotationVelocity.Y*Joint.RotationVelocity.Y +
			   Joint.RotationVelocity.Z*Joint.RotationVelocity.Z);
	if ( (Mag < 50) && (Mag > -50) && (Rotation == rot(0,0,0)) )
	{
		SetPhysics(PHYS_None);
		Disable('Tick');
	}
}

defaultproperties
{
    UseX=True
    UseY=True
    XMotionScale=900.000000
    XGravityScale=2.000000
    YMotionScale=900.000000
    YGravityScale=2.000000
    AirFrictionDivisor=2.000000
	MaxXRotation=16384
	MaxYRotation=16384
	ImpactForce=3000
}