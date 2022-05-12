//=============================================================================
// BulletImpact.
//=============================================================================
class BulletImpact expands Effects;

#exec MESH IMPORT MESH=BulletImpact ANIVFILE=MODELS\bulletimpact_a.3d DATAFILE=MODELS\bulletimpact_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BulletImpact X=0 Y=0 Z=0 PITCH=-64
#exec MESH SEQUENCE MESH=BulletImpact SEQ=All          STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BulletImpact SEQ=hit          STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=BulletImpact MESH=BulletImpact
#exec MESHMAP SCALE MESHMAP=BulletImpact X=0.12 Y=0.12 Z=0.3
#exec OBJ LOAD FILE=Textures\HitFx.utx  PACKAGE=Botpack.HitFx
#exec MESHMAP SETTEXTURE MESHMAP=BulletImpact NUM=1 TEXTURE=Botpack.HitFx.Impact_A00

simulated function PostBeginPlay()
{	
	Super.PostBeginPlay();
	PlayAnim('Hit',0.5);	
}

simulated function AnimEnd()
{
	Destroy();
}		

defaultproperties
{
	 AnimSequence=Hit
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=LodMesh'Botpack.BulletImpact'
     DrawScale=0.280000
     AmbientGlow=255
     bUnlit=True
	 bNetTemporary=true
}
