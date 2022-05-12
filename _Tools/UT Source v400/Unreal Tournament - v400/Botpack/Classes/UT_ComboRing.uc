//=============================================================================
// RingExplosion4.
//=============================================================================
class UT_ComboRing extends UT_RingExplosion;

#exec TEXTURE IMPORT NAME=pBlueRing FILE=MODELS\ring2.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=pPurpleRing FILE=MODELS\pPurpleRing.pcx GROUP=Effects

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'Explo', 0.1, 0.0 );
		SpawnEffects();
	}	
	if ( Instigator != None )
		MakeNoise(0.5);
}

simulated function SpawnEffects()
{
	local actor a;

	if ( Level.bHighDetailMode && !Level.bDropDetail )
	{
		a = Spawn(class'ut_RingExplosion4',self);
		a.RemoteRole = ROLE_None;
	}

	Spawn(class'BigEnergyImpact',,,,rot(16384,0,0));

	a = Spawn(class'shockexplo');
	a.RemoteRole = ROLE_None;

	a =	Spawn(class'shockrifleWave');	
	a.RemoteRole = ROLE_None;
}
	
defaultproperties
{
     LifeSpan=0.900000
     Skin=Texture'Botpack.Effects.pPurpleRing'
     DrawScale=4.000000
}