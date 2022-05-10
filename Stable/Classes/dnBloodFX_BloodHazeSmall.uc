//=============================================================================
// dnBloodFX_BloodHazeSmall.			 January 4th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBloodFX_BloodHazeSmall expands dnBloodFX_BloodHaze;

// Small puff of blood when a body part gibs

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Lifetime=1.000000
     SpawnAtApex=False
     InitialVelocity=(Z=0.000000)
     Apex=(Z=0.000000)
     Textures(0)=Texture't_generic.bloodpuffs.genbloodp1aRC'
     StartDrawScale=0.125000
     EndDrawScale=0.375000
     AlphaEnd=0.000000
     ExamineFOV=90.000000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     Style=STY_Translucent
}
