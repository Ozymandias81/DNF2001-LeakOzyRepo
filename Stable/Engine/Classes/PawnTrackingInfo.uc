class PawnTrackingInfo extends Info;

var float TrackTimer;			 // Variable-used timer counted down to zero at tick time.
var rotator Rotation;			 // Current rotation of the tracking angle.
var rotator DesiredRotation;	 // Desired rotation of the tracking angle.
var rotator BaseRotation;		 // Baseline rotation angle.
var rotator RotationRate;		 // Maximum rate of rotation toward desired.
var rotator RotationConstraints; // Rotation limits to clamp to.
var float Weight;				 // Current weight of tracking rotation against default forward angle, 1.0 is full tracking, 0.0 is no tracking.
var float DesiredWeight;		 // Desired weight of tracking angle.
var float WeightRate;			 // Maximum rate of change toward desired weight.

simulated function Destroyed()
{
}

defaultproperties
{
	RemoteRole=ROLE_None
}