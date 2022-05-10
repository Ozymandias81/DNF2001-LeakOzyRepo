//=============================================================================
// PivotJoint. (NJS)
// As this moves, it keeps the angle of the previous position of it's target
// at the same place
//=============================================================================
class PivotJoint expands Dispatchers;

//var() bool PrecomputeTarget;
//var() name TargetActorTag;
var() bool UseX, UseY;
var() float XMotionScale, XGravityScale, MaxXRotation;
var() float YMotionScale, YGravityScale, MaxYRotation;
var() float AirFrictionDivisor;

var() float TriggerImpulseX;
var() float TriggerImpulseY;

var vector PreviousLocation;
var vector RotationVelocity;
 
var() name  DisableImpulseVelocity;
var   actor DisableImpulseVelocityActor;
var() bool  ImpulseVelocityEnabled;

function PreBeginPlay()
{
	super.PreBeginPlay();
	PreviousLocation=Location;
	
	DisableImpulseVelocityActor=Spawn(class'TriggerSelfForward',self,DisableImpulseVelocity);
}

function Trigger( actor Other, pawn EventInstigator )
{
	if(Other==DisableImpulseVelocityActor) ImpulseVelocityEnabled=false; 
	else 								   ImpulseVelocityEnabled=true; 
}

function Tick( float DeltaSeconds )
{
	local vector  DeltaMotion,temp;
	local rotator currentRotation;

	// Compute delta motion:
	DeltaMotion=PreviousLocation-Location;
	
	// Get current Rotation:
	currentRotation=Rotation;
	
	// Compute angular velocity on X and Y axes:
	if(UseX)
	{	
		if(ImpulseVelocityEnabled) RotationVelocity.y+=TriggerImpulseX*deltaSeconds;
		else
		{
			RotationVelocity.Y+=DeltaMotion.X*DeltaSeconds*XMotionScale;			// Lagging motion.
			RotationVelocity.Y-=CurrentRotation.Pitch*DeltaSeconds*XGravityScale;	// Compensate for gravity.
		}
	}

	if(UseY)
	{	
		if(ImpulseVelocityEnabled) RotationVelocity.z+=TriggerImpulseY*deltaSeconds;
		else
		{
			RotationVelocity.Z+=(-DeltaMotion.Y)*DeltaSeconds*YMotionScale;			// Lagging motion.
			RotationVelocity.Z-=CurrentRotation.Roll*DeltaSeconds*YGravityScale;	// Compensate for gravity.
		}
	}
	
	// Err air friction:
	if(!ImpulseVelocityEnabled)
	{
		temp=RotationVelocity/AirFrictionDivisor*DeltaSeconds;
		RotationVelocity-=temp;
	}
	
	// Update current rotational position:
	currentRotation.Yaw+=RotationVelocity.X*DeltaSeconds;
	currentRotation.Pitch+=RotationVelocity.Y*DeltaSeconds;
	currentRotation.Roll+=RotationVelocity.Z*DeltaSeconds;

	// Clamp rotation to max:
	if(MaxXRotation!=0)
		if(abs(currentRotation.Pitch)>MaxXRotation)
		{
			currentRotation.Pitch=MaxXRotation*(currentRotation.Pitch/abs(currentRotation.Pitch));
			RotationVelocity.Y=0;
		}

	// Clamp rotation to max:
	if(MaxYRotation!=0)
		if(abs(currentRotation.Roll)>MaxYRotation)
		{
			currentRotation.Roll=MaxYRotation*(currentRotation.Roll/abs(currentRotation.Roll));
			RotationVelocity.Z=0;
		}

	SetRotation(currentRotation);
	
	// Store previous location:
	PreviousLocation=Location;
}

defaultproperties
{
     bHidden=true
     UseX=true
     UseY=true
     XMotionScale=900.000000
     XGravityScale=2.000000
     YMotionScale=900.000000
     YGravityScale=2.000000
     AirFrictionDivisor=4.000000
}
