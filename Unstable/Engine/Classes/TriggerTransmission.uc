/*-----------------------------------------------------------------------------
	TriggerTransmission
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class TriggerTransmission extends Triggers;

//#exec AUDIO IMPORT FILE="Sounds\ugotmail.WAV" NAME="YouGotMail" GROUP="Transmission"

var() sound PopupSound;

function Touch( actor Other )
{
	if ( Other.IsA('PlayerPawn') )
	{
//		PlayerPawn(Other).RegisterSOSMessage( self );
	}
}

defaultproperties
{
	PopupSound=sound'Engine.YouGotMail'
}