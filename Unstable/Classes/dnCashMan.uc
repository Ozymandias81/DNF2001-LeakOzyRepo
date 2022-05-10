//=============================================================================
// dnCashMan.							 January 4th, 2001 - Charlie Wiederhold
//=============================================================================
class dnCashMan expands SoftParticleSystem;

// You didn't think we would forget dncashman did you?

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.050000
     Lifetime=7.500000
     RelativeSpawn=True
     InitialVelocity=(X=384.000000,Z=128.000000)
     MaxVelocityVariance=(X=512.000000,Y=192.000000,Z=128.000000)
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.money.dollar1aRC'
     Textures(1)=Texture't_generic.money.dollar2aRC'
     StartDrawScale=0.125000
     EndDrawScale=0.125000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     Style=STY_Masked
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     TimeWarp=0.500000
}
