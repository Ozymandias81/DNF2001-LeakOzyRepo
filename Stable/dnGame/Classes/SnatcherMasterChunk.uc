/*-----------------------------------------------------------------------------
	SnatcherMasterChunk
-----------------------------------------------------------------------------*/
class SnatcherMasterChunk extends MasterCreatureChunk;

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

simulated function InitFor( RenderActor Other )
{
	Super.InitFor(Other);
	DrawScale=0.6;
	ClientExtraChunks();
}

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
}

DefaultProperties
{
     BloodHitDecalName="dnGame.dnAlienBloodHit"
	 HitPackageClass=class'HitPackage_AlienFlesh'
	 bloodSplatClass=class'dnAlienBloodSplat'
}
