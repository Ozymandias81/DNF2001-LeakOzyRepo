//=============================================================================
// RingExplosion3.
//=============================================================================
class UT_RingExplosion3 extends ut_RingExplosion;


#exec TEXTURE IMPORT NAME=BlueRing FILE=MODELS\ring3.pcx GROUP=Effects


simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'Explo', 0.15, 0.0 );
		SpawnEffects();
	}	
	if ( Instigator != None )
		MakeNoise(0.5);
}

defaultproperties
{
     Skin=Texture'Botpack.Effects.BlueRing'
     DrawScale=1.250000
}
