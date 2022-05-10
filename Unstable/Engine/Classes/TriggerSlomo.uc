//=============================================================================
// TriggerSlomo.
// NJS: Defines a time warp zone:
//=============================================================================
class TriggerSlomo expands Triggers;

var() float NewGameSpeed;               // Time Dialation in zone
var() float Seconds;					// Time to get to this speed

var float StartTime;
var float StartSpeed;

function PostBeginPlay()
{
	Disable('Tick');
}

function Tick(float DeltaSeconds)
{
	if(Level.TimeSeconds>=StartTime+Seconds)
	{
		Level.Game.SetGameSpeed(NewGameSpeed);
		Disable('Tick');
		return;
	}

	
	Level.Game.SetGameSpeed(Lerp((Level.TimeSeconds-StartTime)/Seconds,StartSpeed,NewGameSpeed));
}

function Trigger( actor Other, pawn EventInstigator )
{
    if ( (Level.Netmode == NM_Standalone) )
	{
		if(Seconds==0) Level.Game.SetGameSpeed(NewGameSpeed);
		else
		{
			StartTime=Level.TimeSeconds;
			StartSpeed=Level.Game.GameSpeed;
			Enable('Tick');
		}
		

	}
}

defaultproperties
{
     NewGameSpeed=1.00000
     Texture=Texture'Engine.S_TrigTimeWarp'
}
