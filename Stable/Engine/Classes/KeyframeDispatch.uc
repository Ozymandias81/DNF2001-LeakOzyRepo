//=============================================================================
// KeyframeDispatch. (NJS)
//=============================================================================
class KeyframeDispatch expands InfoActor;

#exec Texture Import File=Textures\KeyframeDispatch.pcx Name=S_KeyframeDispatch Mips=Off Flags=2

var () rotator RotateTo;
var () bool    RelativeRotation;
var () rotator MinimumRotation;
var () rotator MaximumRotation;
 
var () vector  MoveTo;
var () bool    RelativeMotion;
var () bool    MotionRelativeToRotation;
var () vector  MinimumMotion;
var () vector  MaximumMotion;
var () float   CJDistance				?("Updates the constaint joint associated with this dispatcher.");
var () float   CJPullBack;				// E3 Demo Hack

var () float   Seconds;

var () bool    UseMyRotation;
var () bool    UseMyPosition;


/* Clip a rotation axis to the desired minimum and maximum: */
function int ClipRotationAxis( int x, int min, int max )
{
	local int minRotation;
	local int maxRotation;
	
	/* When min==max==0, don't clip. */
	if((min==0)&&(max==0))
		return x;
	
	/* If min is larger than max, don't clip. */
	if(min>max)
		return x;
		
	/* Normalize the angle: */
	x=x&65535; 
	if((x>=min)&&(x<=max))	/* Am I in the valid range? */ 
		return x;			/* Return the original value. */
	
	minRotation=RotationDistance(x,min);	
	maxRotation=RotationDistance(x,max);
	
	/* Is the minimum location closer? */	
	if(minRotation<=maxRotation)
		return min;
			
	return max; /* Return the maximum value */
}

function rotator ClipRotation( rotator r )
{
	local rotator result;
	
	result.yaw=ClipRotationAxis(r.yaw,MinimumRotation.yaw,MaximumRotation.yaw);
	result.pitch=ClipRotationAxis(r.pitch,MinimumRotation.pitch,MaximumRotation.pitch);
	result.roll=ClipRotationAxis(r.roll,MinimumRotation.roll,MaximumRotation.roll);
	
	return result;
}

function int ClipMotionAxis( int x, int min, int max )
{
	/* Don't clip motion when min and max are zero: */
	if((min==0)&&(max==0))
		return x;
	
	if(x<min) return min;
	if(x>max) return max;
	
	return x;
}		

function vector ClipMotion( vector motion )
{
	local vector result;

	result.x=ClipMotionAxis(motion.x,MinimumMotion.x,MaximumMotion.x);
	result.y=ClipMotionAxis(motion.y,MinimumMotion.y,MaximumMotion.y);
	result.z=ClipMotionAxis(motion.z,MinimumMotion.z,MaximumMotion.z);

	return result;
}

function SetActorKeyframe( actor Target )
{
	local vector  myMoveTo;
	local rotator myRotateTo;
	local bool    noNetRotation, noNetMotion;
	
	myMoveTo=MoveTo;		/* Set up internal move to copy. */
	myRotateTo=RotateTo;	/* Set up internal rotate to copy. */

	/* Should I use my rotation as the desired rotation? */
	if(UseMyRotation) myRotateTo=Rotation;
	if(UseMyPosition) myMoveTo=Location;
	
	/* Determine if I'm rotating at all: */
	if(RelativeRotation&&!bool(myRotateTo.yaw)&&!bool(myRotateTo.pitch)&&!bool(myRotateTo.roll))
		noNetRotation=true;
	else 
	   	noNetRotation=false;
	
	/* Determine if I'm not moving at all: */
	if(RelativeMotion&&!bool(myMoveTo.X)&&!bool(myMoveTo.Y)&&!bool(myMoveTo.Z))
		noNetMotion=true;
	else 
	   	noNetMotion=false;
	
	/* Should I move relative to my rotation? */
	if(MotionRelativeToRotation&&RelativeMotion)
		myMoveTo=myMoveTo>>Target.Rotation;
	
	/* Is this instantaneous movement? */
	if(Seconds==0)
	{
		if(!noNetRotation) 		/* Does rotation need to be accounted for? */
		{
			/****************** Set up final rotation: *********************/
			if(bool(Target.MountParent))
			{
				if(RelativeRotation)
					Target.MountAngles=ClipRotation(Target.MountAngles+myRotateTo);
				else
					Target.MountAngles=myRotateTo;
			}
			else
			{
				/* If this is relative rotation, add in the original position. */
				if(RelativeRotation) 
					Target.SetRotation(ClipRotation(Target.Rotation+myRotateTo));			
				else 
					/* This is absolute rotation, just set the rotation. */			
					Target.SetRotation(myRotateTo);
		
				/* Make sure I snap to the rotation: */
				Target.DesiredRotation=Target.Rotation;	
			}
			
			Target.RotationRate.yaw=0;
			Target.RotationRate.pitch=0;
			Target.RotationRate.roll=0;
		}
		
		if(!noNetMotion)
		{
			/****************** Set up final motion: *********************/
			/* If this is relative motion, add in the original position. */	
			if(RelativeMotion==true)
			{
				if(bool(Target.MountParent))		// Do I have a parent?
					Target.MountOrigin=ClipMotion(Target.MountOrigin+myMoveTo);
				else								// Nope, just move.
					Target.SetLocation(ClipMotion(Target.Location+myMoveTo));
			} else 	// This is abosolute motion, just set the final position:
			{
				if(bool(Target.MountParent))		// Do I have a parent?
					Target.MountOrigin=ClipMotion(myMoveTo);
				else								// Nope, don't sweat it.
					Target.SetLocation(ClipMotion(myMoveTo));		
			}
		}
	} else 
	/* This is timed movement. */
	{
		if(!noNetRotation) 		/* Does rotation need to be accounted for? */
		{
			/************** Set up temporal rotation: ********************/	
			if(bool(Target.MountParent))
			{
				Target.DesiredRotation=myRotateTo;
				
				if(RelativeRotation)
					Target.DesiredRotation+=Target.MountAngles;
				
				Target.DesiredRotation=ClipRotation(Target.DesiredRotation);
				
				if(Target.DesiredRotation!=Target.MountAngles)
				{		
					Target.RotationRate.yaw=Abs(RotationDistance(Target.MountAngles.yaw,Target.DesiredRotation.yaw))/Seconds;
					Target.RotationRate.pitch=Abs(RotationDistance(Target.MountAngles.pitch,Target.DesiredRotation.pitch))/Seconds;
					Target.RotationRate.roll=Abs(RotationDistance(Target.MountAngles.roll,Target.DesiredRotation.roll))/Seconds;			
					Target.bRotateToDesired=true; /* Make DesiredRotation valid. */
					Target.bFixedRotationDir=false;			
				} 

			} else
			{
				Target.DesiredRotation=myRotateTo;

				if(RelativeRotation)
					Target.DesiredRotation+=Target.Rotation;
			
				Target.DesiredRotation=ClipRotation(Target.DesiredRotation);

				if(Target.DesiredRotation!=Target.Rotation)
				{		
					Target.RotationRate.yaw=Abs(RotationDistance(Target.Rotation.yaw,Target.DesiredRotation.yaw))/Seconds;
					Target.RotationRate.pitch=Abs(RotationDistance(Target.Rotation.pitch,Target.DesiredRotation.pitch))/Seconds;
					Target.RotationRate.roll=Abs(RotationDistance(Target.Rotation.roll,Target.DesiredRotation.roll))/Seconds;			
					Target.bRotateToDesired=true; /* Make DesiredRotation valid. */
					Target.bFixedRotationDir=false;			
				} 

			}
						
		}
		
		if(!noNetMotion)
		{	
			/************** Set up temporal motion: *********************/

			if(bool(Target.MountParent))	// Am I mounted to something?
			{
				Target.DesiredLocation=myMoveTo;

				if(RelativeMotion==true)
					Target.DesiredLocation+=Target.MountOrigin;
				
				// Clip the motion.
				Target.DesiredLocation=ClipMotion(Target.DesiredLocation);
				
				if(Target.DesiredLocation!=Target.MountOrigin)
				{
					Target.bMoveToDesired=true;
					Target.DesiredLocationSeconds=Seconds;
				}
			} else
			{			
				Target.DesiredLocation=myMoveTo;
		
				if(RelativeMotion==true)
					Target.DesiredLocation+=Target.Location;
	
				// Clip my motion:
				Target.DesiredLocation=ClipMotion(Target.DesiredLocation);
			
				// If I'm not already there, move it: 	
				if(Target.DesiredLocation!=Target.Location)
				{	
					Target.bMoveToDesired=true;			
					Target.DesiredLocationSeconds=Seconds;
				}
			}
		}
	}
}

function StartKeyframe( optional pawn EventInstigator )
{
	/* Cycle through all actors: */
	foreach AllActors( class 'Actor', Target , Event )
	{
		if ( Target.IsA('ConstraintJoint') && (CJDistance != 0) )
			ConstraintJoint(Target).ModMaxDistance(CJDistance);
		else if ( Target.IsA('ConstraintJoint') && (CJPullBack != 0) )
			ConstraintJoint(Target).PullBack(CJPullBack);
		else
			SetActorKeyframe(Target);
	}
}
		
function Trigger( actor Other, pawn EventInstigator )
{
	StartKeyframe(EventInstigator);
}

defaultproperties
{
     bHidden=True
     bDirectional=True
     Texture=Texture'Engine.S_KeyframeDispatch'
}
