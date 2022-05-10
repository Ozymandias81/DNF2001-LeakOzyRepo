//=============================================================================
// dnWeaponFX_NukeSphere_Shrunk. 					August 9th, 2001 - Charlie Wiederhold
//=============================================================================
class dnWeaponFX_NukeSphere_Shrunk expands dnWeaponFX;

#exec OBJ LOAD FILE=..\meshes\c_fx.dmx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnNukeFX_Shrunk_GroundWave_Flash',SetMountOrigin=True,MountOrigin=(Z=-28.000000),SurviveDismount=True)
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnNukeFX_Shrunk_GroundWave_Smoke',SetMountOrigin=True,MountOrigin=(Z=-28.000000),SurviveDismount=True)
     MountOnSpawn(2)=(ActorClass=Class'dnParticles.dnNukeFX_Shrunk_CenterStack',SetMountOrigin=True,MountOrigin=(Z=-24.000000),SurviveDismount=True)
     MountOnSpawn(3)=(ActorClass=Class'dnParticles.dnNukeFX_Shrunk_TopCover',SetMountOrigin=True,MountOrigin=(Z=128.000000),SurviveDismount=True)
     MountOnSpawn(4)=(ActorClass=Class'dnParticles.dnNukeFX_Shrunk_MiddleCover',SetMountOrigin=True,MountOrigin=(Z=64.000000),SurviveDismount=True)
     MountOnSpawn(5)=(ActorClass=Class'dnParticles.dnNukeFX_Shrunk_BottomCover',SetMountOrigin=True,MountOrigin=(Z=24.000000),SurviveDismount=True)
     MountOnSpawn(6)=(ActorClass=Class'dnParticles.dnNukeFX_Shrunk_ShockCloud',SurviveDismount=True)
     MountOnSpawn(7)=(ActorClass=Class'dnParticles.dnNukeFX_Shrunk_ShockWave',SurviveDismount=True)
     MountOnSpawn(8)=(ActorClass=Class'dnParticles.dnNukeFX_Shrunk_Glow',SurviveDismount=True)
     MountOnSpawn(9)=(ActorClass=Class'dnParticles.dnNukeFX_Shrunk_Flash',SurviveDismount=True)
     bNotTargetable=True
     LifeSpan=0.100000
     Style=STY_None
     Mesh=None
     DrawScale=1.000000
}
