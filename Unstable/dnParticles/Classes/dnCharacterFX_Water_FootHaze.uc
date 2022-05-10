//=============================================================================
// dnCharacterFX_Water_FootHaze. 		  March 16th, 2001 - Charlie Wiederhold
//=============================================================================
class dnCharacterFX_Water_FootHaze expands dnCharacterFX_Water_FootSplash;

// Haze left behind after a step in the water

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     CreationSound=Sound'dnsMaterials.Mud_Squishy.LeatherMud14'
     CreationSoundRadius=384.000000
     Lifetime=1.000000
     InitialVelocity=(Z=-16.000000)
     Textures(0)=Texture't_generic.Smoke.gensmoke1dRC'
     StartDrawScale=0.250000
     EndDrawScale=0.500000
     AlphaEnd=0.000000
}
