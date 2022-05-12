//=============================================================================
// TBossCarcass.
// DO NOT USE THESE AS DECORATIONS
//=============================================================================
class TBossCarcass extends TMaleBody;

defaultproperties
{
     Mass=100.000000
     Mesh=Mesh'BotPack.Boss'
     AnimSequence=Dead1
	 Physics=PHYS_Falling
	 bBlockActors=true
	 bBlockPlayers=true
     GibSounds(1)=BNewGib
	 MasterReplacement=class'TBossMasterChunk'
}