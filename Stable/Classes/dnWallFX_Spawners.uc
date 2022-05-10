//=============================================================================
// dnWallFX_Spawners. 				   December 15th, 2000 - Charlie Wiederhold
//=============================================================================
class dnWallFX_Spawners expands dnWallFX;

// Spawner for all the wall effects. This specifies the sound and effects.

#exec OBJ LOAD FILE=..\Sounds\a_impact.dfx

defaultproperties
{
     DestroyWhenEmpty=True
     CreationSound=Sound'a_impact.metal.ImpactMtl49'
     CreationSoundRadius=512.000000
     SpawnNumber=0
     PrimeCount=1
     PrimeTimeIncrement=0.000000
     MaximumParticles=1
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.lensflares.bluelensflare1B'
     StartDrawScale=0.000000
     EndDrawScale=0.000000
     AlphaStart=0.000000
     AlphaEnd=0.000000
     TriggerType=SPT_None
	 bNetTemporary=true
	 bDontSimulateMotion=true
	 DrawType=DT_Mesh // For replication
}
