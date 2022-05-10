//=============================================================================
// Z1_CoinCup.
//=============================================================================
// AllenB
class Z1_CoinCup expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 27th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     HealthMarkers(0)=(Threshold=4,PlaySequence=cupcrshbot)
     FragType(0)=Class'dnParticles.dnDebris_Fabric1'
     FragType(1)=Class'dnParticles.dnDebris_SmokeSubtle'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(3)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(4)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     NumberFragPieces=0
     SpawnOnHit=Class'dnParticles.dnBulletFX_FabricSpawner'
     DestroyedSound=Sound'a_impact.wood.ImpactWood42'
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=7.500000
     LandFrontCollisionHeight=5.000000
     LandSideCollisionRadius=7.500000
     LandSideCollisionHeight=5.000000
     bPushable=True
     Grabbable=True
     MeshFlameClass=Class'dnParticles.dnFlameThrowerFX_ObjectBurn_Small'
     PlayerViewOffset=(X=1.000000,Y=-1.000000,Z=2.000000)
     BobDamping=0.900000
     Health=5
     ItemName="Coin Cup"
     bFlammable=True
     CollisionRadius=5.500000
     CollisionHeight=6.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.gamblingcup'
}
