//=============================================================================
// G_WaterCooler_Broken.
//=============================================================================
class G_WaterCooler_Broken expands G_WaterCooler;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDebris_WaterFountain',SetMountOrigin=True,MountOrigin=(Z=16.000000))
     DamageThreshold=0
     FragType(0)=Class'dnParticles.dnLeaves'
     FragType(1)=None
     FragType(2)=None
     FragType(3)=None
     FragType(4)=None
     FragType(5)=None
     FragType(6)=None
     FragType(7)=None
     SpawnOnDestroyed(0)=(SpawnClass=None)
     HealthPrefab=HEALTH_NeverBreak
     bSetFragSkin=False
     Style=STY_Masked
     Texture=Texture'm_generic.burntbigskinRC'
     Skin=Texture'm_generic.burntbigskinRC'
     ItemName="Broken Water Cooler"
     MultiSkins(0)=Texture'm_generic.burntbigskinRC'
     MultiSkins(1)=Texture'm_generic.burntbigskinRC'
     MultiSkins(2)=Texture'm_generic.burntbigskinRC'
     MultiSkins(3)=Texture'm_generic.burntbigskinRC'
}
