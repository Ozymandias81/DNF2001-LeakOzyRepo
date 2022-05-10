//=============================================================================
// dnPBomb_Effect3.
//=============================================================================
class dnPBomb_Effect3 expands dnParachuteBombExplosion;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

// Fire. Scaled up 2x. Relative spawns at -50 relative apex
// Stephen Cole

defaultproperties
{
     DestroyWhenEmpty=False
     AdditionalSpawn(0)=(SpawnClass=None)
     SpawnNumber=1
     SpawnPeriod=0.050000
     Lifetime=0.500000
     LifetimeVariance=0.200000
     SpawnAtApex=True
     RelativeSpawn=True
     InitialVelocity=(Y=-64.000000,Z=150.000000)
     Apex=(Z=-50.000000)
     Textures(0)=Texture't_generic.fireflames.flame1aRC'
     Textures(1)=Texture't_generic.fireflames.flame2aRC'
     Textures(2)=Texture't_generic.fireflames.flame3aRC'
     Textures(3)=Texture't_generic.fireflames.flame4bRC'
     DieOnLastFrame=True
     DrawScaleVariance=0.250000
     StartDrawScale=2.000000
     EndDrawScale=0.250000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=4.000000
     bBurning=True
}
