/*-----------------------------------------------------------------------------
	MasterCreatureChunk
-----------------------------------------------------------------------------*/
class MasterCreatureChunk extends CreatureChunks;

replication
{
}

simulated function InitFor( RenderActor Other )
{
	Super.InitFor( Other );

	ClientExtraChunks();
}

defaultproperties
{
     TrailClass=Class'dnParticles.dnBloodFX_BloodTrail'
}
