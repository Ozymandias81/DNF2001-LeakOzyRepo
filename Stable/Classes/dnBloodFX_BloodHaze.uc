//=============================================================================
// dnBloodFX_BloodHaze.					 January 4th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBloodFX_BloodHaze expands dnBloodFX;

// Large puff of blood when a body gibs

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     Lifetime=3.000000
     SpawnAtApex=True
     InitialVelocity=(Z=-24.000000)
     Apex=(Z=32.000000)
     Textures(0)=Texture't_generic.bloodpuffs.genbloodp2cRC'
     StartDrawScale=0.500000
     EndDrawScale=1.250000
     AlphaEnd=1.000000
     Style=STY_Modulated
     CollisionRadius=32.000000
}
