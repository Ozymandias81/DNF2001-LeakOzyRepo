//=============================================================================
// dnWaterFX_Effect2.	Keith Schuler	Sept 29, 2000
//=============================================================================
class dnWaterFX_Effect2 expands dnWaterFX_Spawner1;

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None,Mount=False)
     AdditionalSpawn(1)=(SpawnClass=None,Mount=False,MountOrigin=(Z=0.000000))
     SpawnNumber=16
     SpawnPeriod=0.050000
     Lifetime=2.000000
     RelativeSpawn=True
     InitialVelocity=(Z=0.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Water.Rain0001'
     DieOnLastFrame=True
     StartDrawScale=0.250000
     EndDrawScale=0.250000
     PulseSeconds=2.000000
     CollisionRadius=192.000000
}
