//=============================================================================
// Z2_FlingCan.                    Created by Charlie Wiederhold April 14, 2000
//=============================================================================
class Z2_FlingCan expands Zone2_Dam;

// Spawns a can to be thrown by The General in the Lake Mead level

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx

defaultproperties
{
     FragType(0)=None
     NumberFragPieces=0
     DamageOnHitWall=1000
     DamageOnHitWater=1000
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnWaterSplash_Effect1')
     LodMode=LOD_Disabled
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Physics=PHYS_Falling
     Mesh=None
     DrawScale=1.250000
}
