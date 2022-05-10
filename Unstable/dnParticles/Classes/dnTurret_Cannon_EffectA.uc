//=============================================================================
// dnTurret_Cannon_EffectA.
//=============================================================================

// Cole

class dnTurret_Cannon_EffectA expands dnTurret_Cannon;

#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     Enabled=True
     BillboardHorizontal=False
     BillboardVertical=False
     DestroyWhenEmpty=False
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=None)
     AdditionalSpawn(1)=(SpawnClass=None)
     AdditionalSpawn(2)=(SpawnClass=None)
     AdditionalSpawn(3)=(SpawnClass=None)
     SpawnPeriod=0.100000
     PrimeCount=2
     SpawnAtRadius=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     Textures(0)=Texture't_explosionFx.explosion64.Sals_032'
     StartDrawScale=0.000001
     EndDrawScale=2.000000
     RotationVariance=65535.000000
     PulseSeconds=0.250000
     SpriteProjForward=25.000000
     TimeWarp=0.500000
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     Style=STY_Translucent
}
