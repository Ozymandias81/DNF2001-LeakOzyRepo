//=============================================================================
// G_WaterCooler (Newstyle)
//====================================Created Sept 6th, 2000 - Brandon Reinhart
class G_WaterCooler extends Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
#exec OBJ LOAD FILE=..\sounds\a_generic.dfx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     DamageThreshold=50
     FragType(0)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(2)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1c'
     FragType(4)=Class'dnParticles.dnDebris_WaterSplash'
     FragType(5)=Class'dnParticles.dnDebris_Smoke'
     FragType(6)=Class'dnParticles.dnDebris_Metal1'
     TriggerRetriggerDelay=1.500000
     HealOnTrigger=5
     bDrinkSoundOnHeal=True
     SpawnOnHit=Class'dnParticles.dnBulletFX_GlassSpawner'
     TriggeredSequence=Activate
     TriggeredSpawn(0)=(ActorClass=Class'dnParticles.dnWaterCoolerBubbles',MountMeshItem=CoolerBubbles,SpawnOnce=True,TriggerWhenTriggered=True)
     TriggeredSound=Sound'a_generic.Water.WCoolBubble7'
     SpawnOnDestroyed(0)=(SpawnClass=Class'U_Generic.G_WaterCooler_Broken')
     LandDirection=LAND_Upright
     LodScale=6.000000
     ItemName="Water Cooler"
     bTakeMomentum=False
     bUseTriggered=True
     bFlammable=True
     CollisionRadius=12.000000
     CollisionHeight=30.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.WaterCooler'
}
