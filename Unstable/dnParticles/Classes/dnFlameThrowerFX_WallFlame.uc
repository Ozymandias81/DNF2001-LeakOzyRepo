//=============================================================================
// dnFlamethrowerFX_WallFlame. 				May 24th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlamethrowerFX_WallFlame expands dnFlamethrowerFX;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnFlamethrowerFX_WallFlame_Debris',Mount=True)
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnFlamethrowerFX_WallFlame_Flash')
     SpawnOnDestruction(0)=(SpawnClass=Class'dnParticles.dnFlamethrowerFX_WallFlame_Flash')
     SpawnPeriod=0.150000
     PrimeCount=3
     PrimeTimeIncrement=0.000000
     Lifetime=0.500000
     LifetimeVariance=0.250000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_firefx.firespray.flamehotend1RC'
     Textures(1)=Texture't_firefx.firespray.flamehotend3RC'
     Textures(2)=Texture't_firefx.firespray.flamehotend2RC'
     DrawScaleVariance=0.500000
     StartDrawScale=0.225000
     EndDrawScale=0.825000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Disable
     AlphaStart=0.000000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     bUseAlphaRamp=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
