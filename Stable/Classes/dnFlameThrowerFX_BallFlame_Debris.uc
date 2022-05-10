//=============================================================================
// dnFlameThrowerFX_BallFlame_Debris. 		June 4th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlameThrowerFX_BallFlame_Debris expands dnFlameThrowerFX_WallFlame_Debris;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     InitialVelocity=(X=0.0000,Z=64.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000,Z=16.000000)
     SpawnPeriod=0.025000
     StartDrawScale=0.500000
     EndDrawScale=0.500000
     CollisionRadius=12.000000
     CollisionHeight=12.000000
}
