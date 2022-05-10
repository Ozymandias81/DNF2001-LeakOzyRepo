//=============================================================================
// dnFlamethrowerFX_Shrunk_BallFlame_Debris. 		June 4th, 2001 - Charlie Wiederhold
//=============================================================================
class dnFlamethrowerFX_Shrunk_BallFlame_Debris expands dnFlamethrowerFX_Shrunk_WallFlame_Debris;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

defaultproperties
{
     InitialVelocity=(X=0.0000,Z=16.000000)
     MaxVelocityVariance=(Y=0.000000,Z=4.000000)
     SpawnPeriod=0.025000
     StartDrawScale=0.1500000
     EndDrawScale=0.1500000
     CollisionRadius=3.000000
     CollisionHeight=3.000000
}
