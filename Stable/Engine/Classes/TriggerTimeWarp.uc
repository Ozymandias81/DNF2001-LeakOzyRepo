//=============================================================================
// TriggerTimeWarp.
// NJS: Defines a time warp zone:
//=============================================================================
class TriggerTimeWarp expands Triggers;

var() float TimeDilation; 		// Time Dialation in zone
var() bool  activateOnTouch;	// Whether to dialate time on touch

function SetTimeDilation(actor other)
{
	Other.TimeWarp=TimeDilation;
}

function Touch( actor Other )
{
	if(activateOnTouch)	SetTimeDilation(other);
}

function Untouch( actor Other )
{
	if(activateOnTouch) Other.TimeWarp=Level.TimeDilation;
}

function Trigger( actor Other, pawn EventInstigator )
{
	if(EventInstigator!=none)
		SetTimeDilation(EventInstigator);
}

defaultproperties
{
     TimeDilation=1.000000
     activateOnTouch=True
     Texture=Texture'Engine.S_TrigTimeWarp'

}
