//=============================================================================
// G_Soda_Pop.
//=============================================================================
// AllenB
class G_Soda_Pop expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     HealthMarkers(0)=(Threshold=4,PlaySequence=soda_crunch2)
     FragType(0)=Class'dnParticles.dnDebrisMesh_GenericTiny1'
     FragType(1)=Class'dnParticles.dnDebrisMesh_GenericTiny1a'
     FragType(2)=Class'dnParticles.dnDebrisMesh_GenericTiny1b'
     FragType(3)=Class'dnParticles.dnDebris_Smoke'
     FragType(4)=Class'dnParticles.dnDebris_Smoke_Dirt1'
     NumberFragPieces=0
     MassPrefab=MASS_Light
     HealthPrefab=HEALTH_Easy
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandRight=True
     LandFrontCollisionRadius=5.000000
     LandFrontCollisionHeight=2.000000
     LandSideCollisionRadius=5.000000
     LandSideCollisionHeight=2.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=1.000000,Y=-0.750000,Z=1.500000)
     BobDamping=0.900000
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_generic.soda_pop'
     ItemName="Cola"
     CollisionRadius=3.000000
     CollisionHeight=4.000000
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=True
     AnimSequence=crunch
     Health=5
}
