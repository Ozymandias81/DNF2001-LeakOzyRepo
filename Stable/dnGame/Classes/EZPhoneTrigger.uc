/*-----------------------------------------------------------------------------
	EZPhoneTrigger
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class EZPhoneTrigger extends Triggers;

var() name			EZPhoneEventName;
var EZPhoneEvent	PhoneEvent;

function PostBeginPlay()
{
	local EZPhoneEvent PhoneEvents;

	foreach AllActors(class'EZPhoneEvent', PhoneEvents, EZPhoneEventName)
	{
		PhoneEvent = PhoneEvents;
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	local EZPhone EZ;

	foreach AllActors(class'EZPhone', EZ, Event)
	{
		EZ.CurrentEvent = PhoneEvent;
		EZ.IncomingCall();
	}
}

defaultproperties
{
	Texture=texture'S_EZPhoneTrig'
}