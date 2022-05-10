//=============================================================================
// dnJetski_Trail1.                Created by Charlie Wiederhold April 19, 2000
//=============================================================================
class dnJetski_Trail1 expands dnWater1_Spray;

// Water trail for the jetski with fake motion
// Does NOT do damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmpty=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=1
     SpawnPeriod=0.025000
     Lifetime=1.000000
     LifetimeVariance=0.000000
     RelativeSpawn=True
     InitialVelocity=(X=-256.000000,Z=0.000000)
     InitialAcceleration=(Z=0.000000)
     MaxVelocityVariance=(X=16.000000,Y=16.000000,Z=16.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.waterwake.wake1aRC'
     DrawScaleVariance=2.000000
     StartDrawScale=0.000000
     AlphaStart=0.500000
     AlphaEnd=0.000000
     TriggerOnSpawn=False
     TriggerOnDismount=True
     TriggerType=SPT_Toggle
     bUnlit=True
     VisibilityRadius=4096.000000
     VisibilityHeight=1024.000000
}
