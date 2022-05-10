//=============================================================================
// dnDebris_Glass_Chandalier. 			  March 28th, 2001 - Charlie Wiederhold
//=============================================================================
class dnDebris_Glass_Chandalier expands dnDebris_Glass1;

// Chandalier glass particles

#exec OBJ LOAD FILE=..\Textures\m_zone1_vegas.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnDebris_SmokeSubtle')
     Textures(0)=Texture'm_zone1_vegas.crystal1'
     Textures(1)=None
     Textures(2)=None
     Textures(3)=None
     Textures(4)=None
     Textures(5)=None
     AlphaStart=1.000000
     AlphaEnd=1.000000
     Style=STY_Masked
}
