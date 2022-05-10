//=============================================================================
// dnDebris_WaterFountain. 			  September 23rd, 2000 - Charlie Wiederhold
//=============================================================================
class dnDebris_WaterFountain expands dnDebris;

// Root of the water fountain spawner, for faucets, etc.

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\soundss\a_generic.dfx

defaultproperties
{
     CreationSound=Sound'a_generic.Water.FHydrantLp14'
     CreationSoundRadius=384.000000
     SpawnPeriod=0.050000
     MaximumParticles=30
     Lifetime=0.625000
     LifetimeVariance=0.250000
     InitialVelocity=(Z=192.000000)
     InitialAcceleration=(Z=-640.000000)
     MaxVelocityVariance=(X=24.000000,Y=24.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.WaterImpact.waterimpact3dRC'
     StartDrawScale=0.075000
     EndDrawScale=0.150000
     AlphaEnd=0.000000
     TriggerType=SPT_None
     Style=STY_Translucent
     bUnlit=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
}
