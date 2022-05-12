//=============================================================================
// GrBase.
//=============================================================================
class GrBase extends ut_Decoration;

#exec MESH IMPORT MESH=GrBaseM ANIVFILE=MODELS\GrBase_a.3D DATAFILE=MODELS\GrBase_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=GrBaseM X=0 Y=0 Z=0 PITCH=0 YAW=128 ROLL=-64
#exec MESH SEQUENCE MESH=GrBaseM SEQ=All    STARTFRAME=0   NUMFRAMES=20
#exec MESH SEQUENCE MESH=GrBaseM SEQ=Activate  STARTFRAME=0   NUMFRAMES=20
#exec MESH SEQUENCE MESH=GrBaseM SEQ=Fire1  STARTFRAME=19   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GrBaseM SEQ=Fire2  STARTFRAME=19   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GrBaseM SEQ=Fire3  STARTFRAME=19   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GrBaseM SEQ=Fire4  STARTFRAME=19   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GrBaseM SEQ=Fire5  STARTFRAME=19   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GrBaseM SEQ=Fire6  STARTFRAME=19   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GrBaseM SEQ=Fire7  STARTFRAME=19   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GrBaseM SEQ=Fire8  STARTFRAME=19   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GrBaseM SEQ=Fire9  STARTFRAME=19   NUMFRAMES=1
#exec MESH SEQUENCE MESH=GrBaseM SEQ=Fire10 STARTFRAME=19   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jGrBase FILE=MODELS\GrBase.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=GrBaseM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=GrBaseM NUM=1 TEXTURE=jGrBase

// Steve:  The gun base and the grmock gun must both be played in unison at the same origin for the down animation.
// once down, destroy the mock gun and replace it with the grfinal gun.  It has an origin about it's pivot point
// so that you can rotate it through scripting.

// The ceiling cannon (files CD*.uc) are comprised of the base and the gun.  They are separate so you can
// yaw the gun around though script, while the base remains stationary.

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'Botpack.GrBaseM'
	 bStatic=false
	 RemoteRole=ROLE_None
}
