//=============================================================================
// dnExplosion2_Effect1.           Created by Charlie Wiederhold April 12, 2000
//=============================================================================
class dnExplosion2_Effect1 expands dnExplosion2;

// Explosion effect.
// Does NOT do damage. 
// Spawns 8 explosion particles, random rotation, die on last frame.

#exec OBJ LOAD FILE=..\Textures\t_explosionfx.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     AdditionalSpawn(1)=(SpawnClass=None)
     PrimeCount=8
     Lifetime=0.000000
     MaxVelocityVariance=(X=128.000000)
     Textures(0)=Texture't_explosionfx.explosions.Herc_001'
     DieOnLastFrame=True
     StartDrawScale=5.000000
     EndDrawScale=5.000000
     RotationVariance=32768.000000
     CollisionRadius=256.000000
     CollisionHeight=256.000000
}
