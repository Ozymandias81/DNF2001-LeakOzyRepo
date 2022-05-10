//=============================================================================
// G_FireHydrant_Broken. 			  CW .. mod AB
//=============================================================================
class G_FireHydrant_Broken expands G_FireHydrant;

// Broken version of the Fire Hydrant

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     MountOnSpawn(0)=(ActorClass=Class'dnParticles.dnDebris_WaterFountain',SetMountOrigin=True,MountOrigin=(Z=16.000000))
     FragType(0)=Class'dnParticles.dnLeaves'
     FragType(1)=None
     FragType(2)=None
     FragType(3)=None
     FragType(4)=None
     FragType(5)=None
     FragType(6)=None
     TriggerRetriggerDelay=1.000000
     HealOnTrigger=1
     SpawnOnDestroyed(0)=(SpawnClass=None)
     bTumble=False
     HealthPrefab=HEALTH_NeverBreak
     MultiSkins(0)=Texture'm_generic.burntbigskinRC'
     MultiSkins(1)=Texture'm_generic.burntbigskinRC'
     ItemName="Broken Fire Hydrant"
     bUseTriggered=True
     bMovable=False
     Tag=G_FireHydrant_Broken
     bProjTarget=True
     Physics=PHYS_MovingBrush
     bBounce=False
     Style=STY_Masked
     Skin=Texture'm_generic.burntbigskinRC'
}
