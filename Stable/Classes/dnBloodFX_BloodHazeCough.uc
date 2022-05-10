//=============================================================================
// dnBloodFX_BloodHazeCough. 			January 16th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBloodFX_BloodHazeCough expands dnBloodFX_BloodHaze;

// Tiny puff of blood when a guy coughs

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Lifetime=1.000000
     SpawnAtApex=False
     RelativeSpawn=True
     InitialVelocity=(X=4.000000,Z=-8.000000)
     MaxVelocityVariance=(X=2.000000)
     Apex=(Z=0.000000)
     Textures(0)=Texture't_generic.bloodpuffs.genbloodp1aRC'
     StartDrawScale=0.025000
     EndDrawScale=0.100000
     AlphaStart=0.500000
     AlphaEnd=0.000000
     ExamineFOV=90.000000
     CollisionRadius=0.000000
}
