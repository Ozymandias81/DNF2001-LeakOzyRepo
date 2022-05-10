//=============================================================================
// TriggerLightStyle. (NJS)
//
// Sets the light style of the actor(s) specified by event.
//=============================================================================
class TriggerLightStyle expands Triggers;

var () name newLightString;
var () name newLightStringRed;
var () name newLightStringGreen;
var () name newLightStringBlue;
var () int  newLightPeriod;
var () bool newLightStringLoop;
var () bool setStringStart;
var () ELightType newLightType;

function Trigger( actor Other, pawn EventInstigator )
{
	local actor A;
	
	if(Event!='')
		// Trigger all actors with matching triggers 
		foreach AllActors( class 'Actor', A, Event )		
		{
			a.LightString=newLightString;
			a.LightStringRed=newLightStringRed;
			a.lightStringGreen=newLightStringGreen;
			a.LightStringBlue=newLightStringBlue;
			a.LightPeriod=newLightPeriod;
			a.LightStringLoop=newLightStringLoop;
			if(setStringStart) a.LightStringStart=Level.TimeSeconds;
			a.LightType=newLightType;
		}
	
}

defaultproperties
{
     setStringStart=True
}
