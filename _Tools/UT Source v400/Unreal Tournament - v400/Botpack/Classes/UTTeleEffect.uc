//=============================================================================
// UTTeleEffect.
//=============================================================================
class UTTeleEffect extends Effects;

#exec MESH IMPORT MESH=Tele2 ANIVFILE=MODELS\Tele2_a.3d DATAFILE=MODELS\Tele2_d.3d X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=Tele2 SEQ=All                      STARTFRAME=0 NUMFRAMES=100
#exec MESH SEQUENCE MESH=Tele2 SEQ=Teleport                 STARTFRAME=0 NUMFRAMES=100
#exec MESHMAP NEW   MESHMAP=Tele2 MESH=Tele2
#exec MESHMAP SCALE MESHMAP=Tele2 X=0.1 Y=0.1 Z=0.2

#exec TEXTURE IMPORT NAME=JTele2_01 FILE=Textures\Trail.PCX GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=Tele2 NUM=1 TEXTURE=JTele2_01


function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('Teleport', 2.0, 0.0);
}

defaultproperties
{
	 RemoteRole=ROLE_None
	 LifeSpan=1.0
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=LodMesh'Botpack.Tele2'
     bUnlit=True
}
