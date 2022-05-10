//=============================================================================
// G_TV1.
//=============================================================================
class G_TV1 expands Generic;

#exec OBJ LOAD FILE=..\meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\textures\m_generic.dtx
// September 18th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold
//====================Created December 10th, 1998 Happy DOOM Day! - Stephen Cole

// append AllenB

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_Glass1'
     FragType(1)=Class'dnParticles.dnDebris_Metal1'
     FragType(2)=Class'dnParticles.dnDebris_Sparks1_Large'
     FragType(3)=Class'dnParticles.dnDebrisMesh_Metal1'
     FragType(4)=Class'dnParticles.dnDebrisMesh_Metal1a'
     FragType(5)=Class'dnParticles.dnDebrisMesh_Metal1b'
     FragType(6)=Class'dnParticles.dnDebrisMesh_Metal1c'
     FragBaseScale=0.500000
     SpawnOnDestroyed(0)=(SpawnClass=Class'dnParticles.dnExplosion3_SmallElectronic')
     bLandForward=True
     bLandBackwards=True
     bLandLeft=True
     bLandUpright=True
     bLandUpsideDown=True
     LandFrontCollisionHeight=18.000000
     LandSideCollisionHeight=18.000000
     bPushable=True
     Grabbable=True
     PlayerViewOffset=(X=0.000000,Y=1.000000,Z=-1.000000)
     BobDamping=0.850000
     bHeated=True
     HeatIntensity=255.000000
     HeatRadius=16.000000
     HeatFalloff=128.000000
     ItemName="Television"
     bFlammable=True
     bDirectional=True
     CollisionHeight=18.000000
     bProjTarget=True
     Physics=PHYS_Falling
     Mass=300.000000
     Mesh=DukeMesh'c_generic.tv1'
     DrawScale=1.500000
     LightDetail=LTD_Normal
}
