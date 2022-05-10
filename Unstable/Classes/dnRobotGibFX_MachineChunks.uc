//=============================================================================
// dnRobotGibFX_MachineChunks. 				Feb. 16th, 2001 - Charlie Wiederhold
//=============================================================================
class dnRobotGibFX_MachineChunks expands dnBloodFX_BloodChunks;

// Robot Gibs

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\soundss\a_impact.dfx

defaultproperties
{
     TriggeredSound=Sound'a_impact.metal.MetalGibExpl01'
     TriggeredSoundRadius=512.000000
     Textures(0)=Texture't_generic.robotgibs.genrobotgib10RC'
     Textures(1)=Texture't_generic.robotgibs.genrobotgib1RC'
     Textures(2)=Texture't_generic.robotgibs.genrobotgib2RC'
     Textures(3)=Texture't_generic.robotgibs.genrobotgib3RC'
     Textures(4)=Texture't_generic.robotgibs.genrobotgib4RC'
     Textures(5)=Texture't_generic.robotgibs.genrobotgib5RC'
     Textures(6)=Texture't_generic.robotgibs.genrobotgib6RC'
     Textures(7)=Texture't_generic.robotgibs.genrobotgib7RC'
     Textures(8)=Texture't_generic.robotgibs.genrobotgib8RC'
     Textures(9)=Texture't_generic.robotgibs.genrobotgib9RC'
     DrawScaleVariance=0.100000
     StartDrawScale=0.075000
     EndDrawScale=0.075000
     SpawnOnBounce=None
     TriggerOnSpawn=True
}
