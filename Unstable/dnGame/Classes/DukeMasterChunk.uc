/*-----------------------------------------------------------------------------
	DukeMasterChunk
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DukeMasterChunk extends MasterCreatureChunk;

simulated function ClientExtraChunks()
{
	local carcass carc;

	if ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( class'GameInfo'.Default.bLowGore )
	{
		Destroy();
		return;
	}

	if ( FRand() < 0.5 )
		carc = Spawn(class 'Chunk_FleshB',Self);
	else
		carc = Spawn(class 'Chunk_Head', Self);
	carc = Spawn(class 'Chunk_FleshC', Self);
	carc = Spawn(class 'Chunk_FleshA', Self);
	carc = Spawn(class 'Chunk_FleshA', Self);
	carc = Spawn(class 'Chunk_FleshB', Self);
	carc = Spawn(class 'Chunk_FleshA', Self);
	carc = Spawn(class 'Chunk_FleshB', Self);
	carc = Spawn(class 'Chunk_OrganA', Self);
	carc = Spawn(class 'Chunk_FleshB', Self);
	carc = Spawn(class 'Chunk_OrganA', Self);
}