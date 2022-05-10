/*-----------------------------------------------------------------------------
	ObjectiveTrigger
	Author: Brandon Reinhart

    This trigger casts no judgement.

    Since bool arrays aren't allowed in UnrealScript, ints are used.
-----------------------------------------------------------------------------*/
class ObjectiveTrigger extends Triggers;

var() int SetState[6];
var() int NewState[6];

var() int SetString[6];
var() string NewString[6];

var string ObjMsg1, ObjMsg2;

function Trigger( actor Other, pawn EventInstigator )
{
	local int i;
	local DukePlayer P;
	
	for (i=0; i<6; i++)
	{
		if (SetState[i] != 0)
			Level.ObjectiveInfos[i].Complete = (NewState[i] != 0);
		if (SetString[i] != 0)
			Level.ObjectiveInfos[i].Text = NewString[i];
	}

	foreach AllActors( class'DukePlayer', P )
	{
		DukeHUD(P.MyHUD).RegisterSOSEventMessage(ObjMsg1, ObjMsg2, 128, 128, 1);
	}
}

defaultproperties
{
	ObjMsg1="SOS Memory Event"
	ObjMsg2="Objectives list updated..."
}