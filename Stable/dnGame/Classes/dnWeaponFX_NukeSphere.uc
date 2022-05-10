//=============================================================================
// dnWeaponFX_NukeSphere. 					June 6th, 2001 - Charlie Wiederhold
//=============================================================================
class dnWeaponFX_NukeSphere expands dnWeaponFX;

#exec OBJ LOAD FILE=..\meshes\c_fx.dmx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnNukeFX_GroundWave_Flash',SetMountOrigin=True,MountOrigin=(Z=-112.000000),SurviveDismount=True)
     MountOnSpawn(1)=(ActorClass=Class'dnParticles.dnNukeFX_GroundWave_Smoke',SetMountOrigin=True,MountOrigin=(Z=-112.000000),SurviveDismount=True)
     MountOnSpawn(2)=(ActorClass=Class'dnParticles.dnNukeFX_CenterStack',SetMountOrigin=True,MountOrigin=(Z=-96.000000),SurviveDismount=True)
     MountOnSpawn(3)=(ActorClass=Class'dnParticles.dnNukeFX_TopCover',SetMountOrigin=True,MountOrigin=(Z=512.000000),SurviveDismount=True)
     MountOnSpawn(4)=(ActorClass=Class'dnParticles.dnNukeFX_MiddleCover',SetMountOrigin=True,MountOrigin=(Z=256.000000),SurviveDismount=True)
     MountOnSpawn(5)=(ActorClass=Class'dnParticles.dnNukeFX_BottomCover',SetMountOrigin=True,MountOrigin=(Z=96.000000),SurviveDismount=True)
     MountOnSpawn(6)=(ActorClass=Class'dnParticles.dnNukeFX_ShockCloud',SurviveDismount=True)
     MountOnSpawn(7)=(ActorClass=Class'dnParticles.dnNukeFX_ShockWave',SurviveDismount=True)
     MountOnSpawn(8)=(ActorClass=Class'dnParticles.dnNukeFX_Glow',SurviveDismount=True)
     MountOnSpawn(9)=(ActorClass=Class'dnParticles.dnNukeFX_Flash',SurviveDismount=True)
     bNotTargetable=True
     LifeSpan=0.100000
     Style=STY_None
     Mesh=None
     DrawScale=1.000000
}
