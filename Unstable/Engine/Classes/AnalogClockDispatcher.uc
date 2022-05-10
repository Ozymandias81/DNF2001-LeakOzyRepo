//=============================================================================
// AnalogClockDispatcher. (NJS)
//=============================================================================
class AnalogClockDispatcher expands Dispatchers;

var () enum ERotationAxis	// Axis you want the clock to rotate on.
{
	AC_Yaw,
	AC_Pitch,
	AC_Roll
} RotationAxis;

var () name HourHandTag;
var () name MinuteHandTag;
var () name SecondHandTag;

var () float HourHandSpeed;
var () float MinuteHandSpeed;
var () float SecondHandSpeed;

function SetTime(float SpeedMultiplier)
{
	local rotator HourRotator, MinuteRotator, SecondRotator;
	local int HourRotation, MinuteRotation, SecondRotation;
	local actor a;
	
	HourRotation=65535-(int(((Level.Hour%12)*65535.0)/12.0)/*+16384*/);
	MinuteRotation=65535-(int((float(Level.Minute)*65535.0)/60.0)/*+16384*/);
	SecondRotation=65535-(int((float(Level.Second)*65535.0)/60.0)/*+16384*/);
	
	HourRotator.Yaw=0; HourRotator.Pitch=0; HourRotator.Roll=0;
	MinuteRotator.Yaw=0; MinuteRotator.Pitch=0; MinuteRotator.Roll=0;
	SecondRotator.Yaw=0; SecondRotator.Pitch=0; SecondRotator.Roll=0;

	switch(RotationAxis)
	{
		case AC_Yaw:
			HourRotator.Yaw=HourRotation;
			MinuteRotator.Yaw=MinuteRotation;
			SecondRotator.Yaw=SecondRotation;
			break;
			
		case AC_Pitch:
			HourRotator.Pitch=HourRotation;
			MinuteRotator.Pitch=MinuteRotation;
			SecondRotator.Pitch=SecondRotation;
			break;
			
		case AC_Roll:
			HourRotator.Roll=HourRotation;
			MinuteRotator.Roll=MinuteRotation;
			SecondRotator.Roll=SecondRotation;
			break;
	}
	
	foreach allactors(class'actor',a)
	{
		if(bool(a.tag))
		{
			if(a.tag==HourHandTag) 		  	a.RotateTo(HourRotator,false,HourHandSpeed*SpeedMultiplier);
			else if(a.tag==MinuteHandTag) 	a.RotateTo(MinuteRotator,false,MinuteHandSpeed*SpeedMultiplier);
			else if(a.tag==SecondHandTag) 	a.RotateTo(SecondRotator,false,SecondHandSpeed*SpeedMultiplier);
		}
	}
	
	//BroadcastMessage("The time is"$Level.Hour$":"$Level.Minute$":"$Level.Second,false);
}

function PostBeginPlay()
{	
		 if(SecondHandTag!='') SetTimer(1,true); 	
	else if(MinuteHandTag!='') SetTimer(60,true);
	else if(HourHandTag!='')   SetTimer(60*60,true);
	Enable( 'Tick' );
}

function Tick( float DeltaSeconds )
{
	SetTime( 0 );
	Disable( 'Tick' );
}

function Timer(optional int TimerNum)
{
	SetTime( 1 );
}

defaultproperties
{
}
