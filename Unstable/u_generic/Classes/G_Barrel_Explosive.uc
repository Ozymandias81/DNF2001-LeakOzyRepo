//=============================================================================
// G_Barrel_Explosive. 					October 19th, 2000 - Charlie Wiederhold
//=============================================================================
class G_Barrel_Explosive expands G_Barrel;

// Barrel that is unmoveable and causes a small explosion when it dies
// Created for use as random fodder in the Lake Mead map

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     DamageThreshold=0
     FragType(0)=Class'dnParticles.dnExplosion3_SmallElectronic'
     FragType(1)=None
     FragType(2)=None
     FragType(3)=None
     FragType(4)=None
     FragType(5)=None
     FragType(6)=None
     FragType(7)=None
     bTumble=False
     HealthPrefab=HEALTH_Easy
     bLandForward=False
     bPushable=False
     Grabbable=False
     bNotTargetable=True
}
