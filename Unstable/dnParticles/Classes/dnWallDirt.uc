//=============================================================================
// dnWallDirt.                                                    created by AB
//=============================================================================
class dnWallDirt expands dnWallFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnWallDust')
     SpawnPeriod=0.050000
     PrimeCount=1
     PrimeTimeIncrement=0.100000
     Lifetime=0.750000
     LifetimeVariance=0.750000
     RelativeSpawn=True
     InitialVelocity=(X=192.000000,Z=0.000000)
     MaxVelocityVariance=(X=128.000000,Y=64.000000,Z=64.000000)
     LocalFriction=1024.000000
     BounceElasticity=0.250000
     UseZoneGravity=False
     LineStartColor=(R=122,G=61,B=46)
     LineEndColor=(R=183,G=106,B=96)
     Textures(0)=Texture't_generic.dirtcloud.dirtcloud1aRC'
     Textures(1)=Texture't_generic.dirtcloud.dirtcloud1bRC'
     Textures(2)=Texture't_generic.dirtcloud.dirtcloud1cRC'
     Textures(3)=Texture't_generic.dirtcloud.dirtcloud1dRC'
     StartDrawScale=0.100000
     EndDrawScale=0.400000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=1.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=0.175000
     PulseSecondsVariance=0.075000
     AlphaEnd=0.000000
     bHidden=True
     CollisionRadius=4.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
}
