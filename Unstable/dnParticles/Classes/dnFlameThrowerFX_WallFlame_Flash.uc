//=============================================================================
// dnFlamethrowerFX_WallFlame_Flash.				May 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlamethrowerFX_WallFlame_Flash expands dnFlamethrowerFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnFlamethrowerFX_WallFlame_Impact')
     SpawnNumber=0
     PrimeCount=1
     MaximumParticles=1
     Lifetime=0.250000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Sparks.cometspark2RC'
     StartDrawScale=32.000000
     EndDrawScale=0.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
