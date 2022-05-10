/*-----------------------------------------------------------------------------
	DukeVoice
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DukeVoice extends Info;

function DukeSay( sound Phrase )
{
	local float Pitch;

	if ( Owner.DrawScale < 0.5 )
		Pitch = 1.5;
	else
		Pitch = 1.0;

	if ( Level.NetMode == NM_Standalone )
	{
		PlayOwnedSound(Phrase, SLOT_Talk,,,,Pitch,true);
		PlayOwnedSound(Phrase, SLOT_Ambient,,,,Pitch,true);
		PlayOwnedSound(Phrase, SLOT_Interface,,,,Pitch,true);
	}
	else
	{
		if ( PlayerPawn( Owner ) != None )
		{
			// Need to propogate this to everyone
			Owner.PlaySound(Phrase, SLOT_Talk,,,,Pitch,true);
		}
	}
}

defaultproperties
{
	RemoteRole=ROLE_None
}