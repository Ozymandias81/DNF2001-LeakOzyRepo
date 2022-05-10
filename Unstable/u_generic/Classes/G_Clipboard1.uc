//=============================================================================
// G_Clipboard1.
//=============================================================================
class G_Clipboard1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

//====================Created December 10th, 1998 Happy DOOM Day! - Stephen Cole

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Wood1'
     FragType(1)=Class'dnParticles.dnDebris_Paper1'
     FragType(2)=Class'dnParticles.dnDebris_Smoke_Small1'
     NumberFragPieces=24
     FragBaseScale=0.200000
     SpawnOnHit=Class'dnParticles.dnBulletFX_WoodSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood1A'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandUpright=True
     bLandUpsideDown=True
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=-0.250000,Y=-0.750000,Z=-0.450000)
     BobDamping=0.920000
     Health=2
     ItemName="Clipboard"
     bFlammable=True
     CollisionRadius=10.000000
     CollisionHeight=2.000000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.clipboard1'
}
