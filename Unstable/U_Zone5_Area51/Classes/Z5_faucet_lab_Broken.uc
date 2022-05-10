//=============================================================================
// Z5_faucet_lab_Broken.
//=============================================================================
class Z5_faucet_lab_Broken expands Z5_faucet_lab;

#exec OBJ LOAD FILE=..\meshes\c_zone5_area51.dmx
#exec OBJ LOAD FILE=..\textures\t_generic.dtx
// October 3rd, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDebris_WaterFountain',SetMountOrigin=True,MountOrigin=(X=-8.000000,Z=4.000000))
     DontDie=True
     DamageThreshold=0
     FragType(0)=None
     FragType(1)=None
     FragType(2)=None
     FragType(3)=None
     FragType(5)=None
     FragType(6)=None
     FragType(7)=None
     SpawnOnDestroyed(0)=(SpawnClass=None)
     HealthPrefab=HEALTH_NeverBreak
     MultiSkins(0)=Texture'm_generic.burntbigskinRC'
     MultiSkins(1)=Texture'm_generic.burntbigskinRC'
     MultiSkins(2)=Texture'm_generic.burntbigskinRC'
     MultiSkins(3)=Texture'm_generic.burntbigskinRC'
     ItemName="Broken Lab Faucet"
     Style=STY_Masked
     Texture=Texture'm_generic.burntbigskinRC'
     Skin=Texture'm_generic.burntbigskinRC'
}
