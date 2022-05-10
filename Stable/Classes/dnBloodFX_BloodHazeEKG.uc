//=============================================================================
// dnBloodFX_BloodHazeEKG.					 January 4th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBloodFX_BloodHazeEKG expands dnBloodFX_BloodHaze;

// Massive puff of blood when a body gibs

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Lifetime=3.000000
     SpawnAtApex=True
     InitialVelocity=(Z=-32.000000)
     Apex=(Z=48.000000)
     Textures(0)=Texture't_generic.bloodpuffs.genbloodp2cRC'
     StartDrawScale=1.00000
     EndDrawScale=3.0000
     AlphaEnd=1.000000
     Style=STY_Modulated
     CollisionRadius=32.000000
}
