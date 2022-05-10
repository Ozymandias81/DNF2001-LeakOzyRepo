//=============================================================================
// RouletteWheelDispatcher. (NJS)
//=============================================================================
class RouletteWheelDispatcher expands Dispatchers;

var () name WheelTag;	// Tag of the object to use as the roulette wheel.
var () name BallTag;	// Tag of the object to use as the roulette ball.

var () int InitialWheelVelocity;	// Velocity a spin imparts on the wheel.
var () int WheelFriction;			// Rate at which the wheel slows down.

var () int InitialBallVelocity;		// Amount the ball slows down per second.
var () int BallFriction;			// Rate at which the ball slows down.

var  () float InitialHeight;		// Initial height to bounce the ball above the board
var  () float Gravity;				// Rate at which the ball falls per second.

var float   BallVelocity;
var float 	BaseHeight;
var float   MaxHeight;
var bool	BallFalling;

var actor WheelActor;				// Determined from WheelTag
var actor BallActor;				// Determined from BallTag

var float PendingWheelDeceleration;		// Temp variable for wheel.
var float CurrentBallVelocity;
var float PendingBallDeceleration;

var int   WheelNumbers[38];		// Numbers on the wheel.

function PostBeginPlay()
{
	local actor a;
	
	// Find the wheel actor:
	if(WheelTag!='')
		foreach allactors(class'actor',a,WheelTag)
		{
			WheelActor=a;
			break;
		}

	// Find the ball actor:
	if(BallTag!='')
		foreach allactors(class'actor',a,BallTag)
		{
			BallActor=a;
			break;
		}
		
	Disable('Tick');
}

function Tick(float DeltaSeconds)
{
	local float DecelerationThisFrame;
	local vector v;
		
	// Compute the deceleration this frame:
	PendingWheelDeceleration+=(DeltaSeconds*float(WheelFriction));
	PendingBallDeceleration+=(DeltaSeconds*float(BallFriction));

	// Is the ball actually falling?
	
	// Slow down the wheel:
	if(bool(WheelActor))
	{
		if(PendingWheelDeceleration>=1.0)
		{	
			// Have I completely stopped?
			if(PendingWheelDeceleration>=WheelActor.RotationRate.Yaw)
			{
				WheelActor.RotationRate.Yaw=0;
				WheelActor.RotationRate.Pitch=0;
				WheelActor.RotationRate.Roll=0;
				WheelActor.bFixedRotationDir=false;
				Enable('Trigger');
				Disable('Tick');
				return; // Done for good.				
			} else
			{
				WheelActor.RotationRate.Yaw-=int(PendingWheelDeceleration);
				PendingWheelDeceleration-=int(PendingWheelDeceleration);
			}
		}
	}
	
	if(bool(BallActor))
	{
		// Work out the bouncing:
		if(MaxHeight!=0)	// If I'm still bouncing.
		{
			v=BallActor.Location;
			BallVelocity+=(Gravity*DeltaSeconds);	
			v.z+=(BallVelocity*DeltaSeconds);		
		
			if(v.z<BaseHeight)
			{
				v.z=BaseHeight;
				MaxHeight*=0.89;
				if(MaxHeight<=2.5) 
				{
					MaxHeight=0;
					CurrentBallVelocity=0;
				
					Payout(((BallActor.Rotation.Yaw-WheelActor.Rotation.Yaw)&65535)*38/65535);
					Enable('Trigger');
				}
				
				
				BallVelocity=MaxHeight;
			} 
			
			BallActor.SetLocation(v); // Set the new location;
		}

		BallActor.RotationRate.Yaw=WheelActor.RotationRate.Yaw-((MaxHeight*float(WheelActor.RotationRate.Yaw)/InitialHeight)*(0.8+(Frand()*0.1)));		
	}
}

// Trigger activates the wheel:
function Trigger( actor Other, pawn EventInstigator )
{
	local vector v;
	// If WheelActor is valid, then set it's initial spin:
	if(bool(WheelActor))
	{
		PendingWheelDeceleration=0;
		WheelActor.bFixedRotationDir=true;
		WheelActor.RotationRate.Yaw=InitialWheelVelocity;
		WheelActor.RotationRate.Pitch=0;
		WheelActor.RotationRate.Roll=0;
	}
	
	if(bool(BallActor))
	{
		PendingBallDeceleration=0;
		CurrentBallVelocity=InitialBallVelocity;
		BallActor.bFixedRotationDir=true;
		BallActor.RotationRate.Yaw=0;
		BallActor.RotationRate.Pitch=0;
		BallActor.RotationRate.Roll=0;
		MaxHeight=InitialHeight;
		BallVelocity=MaxHeight;
		BaseHeight=BallActor.Location.z;			// Set the base height (Point at which the ball will bounce)
	}
	// Enable the tick handler and disable trigger:
	Enable('Tick');
	Disable('Trigger');
}

function Payout(int number)
{
	local string PayoutString;
	
	if(WheelNumbers[number]==37)
		PayoutString="Double Zero";
	else if(WheelNumbers[number]==0)
		PayoutString="Zero";
	else
	{
		if(bool(number&1)) PayoutString="Black";
		else PayoutString="Red";	
		
		PayoutString=PayoutString$" "$WheelNumbers[number];
	}
	
//	BroadcastMessage(PayoutString,true);
}

defaultproperties
{
     WheelNumbers(1)=28
     WheelNumbers(2)=9
     WheelNumbers(3)=26
     WheelNumbers(4)=30
     WheelNumbers(5)=11
     WheelNumbers(6)=7
     WheelNumbers(7)=20
     WheelNumbers(8)=32
     WheelNumbers(9)=17
     WheelNumbers(10)=5
     WheelNumbers(11)=22
     WheelNumbers(12)=34
     WheelNumbers(13)=15
     WheelNumbers(14)=3
     WheelNumbers(15)=24
     WheelNumbers(16)=36
     WheelNumbers(17)=13
     WheelNumbers(18)=1
     WheelNumbers(19)=37
     WheelNumbers(20)=27
     WheelNumbers(21)=10
     WheelNumbers(22)=25
     WheelNumbers(23)=29
     WheelNumbers(24)=12
     WheelNumbers(25)=8
     WheelNumbers(26)=19
     WheelNumbers(27)=31
     WheelNumbers(28)=18
     WheelNumbers(29)=6
     WheelNumbers(30)=21
     WheelNumbers(31)=33
     WheelNumbers(32)=16
     WheelNumbers(33)=4
     WheelNumbers(34)=23
     WheelNumbers(35)=35
     WheelNumbers(36)=14
     WheelNumbers(37)=2
}
