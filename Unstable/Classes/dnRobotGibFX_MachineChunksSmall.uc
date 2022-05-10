//=============================================================================
// dnRobotGibFX_MachineChunksSmall.		   Feb. 16th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRobotGibFX_MachineChunksSmall expands dnBloodFX_BloodChunksSmall;

// Small Robot Gibs

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     TriggeredSound=Sound'a_impact.metal.MetalGibExpl01'
     TriggeredSoundRadius=256.000000
     Textures(0)=Texture't_generic.robotgibs.genrobotgib10RC'
     Textures(1)=Texture't_generic.robotgibs.genrobotgib9RC'
     Textures(2)=Texture't_generic.robotgibs.genrobotgib8RC'
     Textures(3)=Texture't_generic.robotgibs.genrobotgib7RC'
     Textures(4)=Texture't_generic.robotgibs.genrobotgib6RC'
     Textures(5)=Texture't_generic.robotgibs.genrobotgib5RC'
     Textures(6)=Texture't_generic.robotgibs.genrobotgib4RC'
     Textures(7)=Texture't_generic.robotgibs.genrobotgib3RC'
     Textures(8)=Texture't_generic.robotgibs.genrobotgib2RC'
     Textures(9)=Texture't_generic.robotgibs.genrobotgib1RC'
     DrawScaleVariance=0.035000
     StartDrawScale=0.030000
     EndDrawScale=0.030000
     SpawnOnBounce=None
     TriggerOnSpawn=True
}
