//=============================================================================
// dnTripmineFX_RootExp.            Created by Charlie Wiederhold June 14, 2000
//=============================================================================
class dnTripmineFX_RootExp expands dnTripmineFX;

// Laser trip mine explosion effects.
// Does NOT do damage. 
// Spawns the root explosion effect.

#exec OBJ LOAD FILE=..\Textures\t_explosionfx.dtx

defaultproperties
{
     CreationSound=Sound'a_impact.explosions.Expl118'
     SpawnNumber=0
     PrimeCount=2
     MaximumParticles=2
     Lifetime=5.000000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_explosionFx.explosions.X_fi_001'
     DieOnLastFrame=True
     StartDrawScale=2.000000
     EndDrawScale=2.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     AlphaEnd=0.000000
     LifeSpan=1.250000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bIgnoreBList=True
}
