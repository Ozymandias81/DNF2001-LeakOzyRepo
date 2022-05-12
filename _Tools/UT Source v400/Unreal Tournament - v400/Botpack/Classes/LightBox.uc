//=============================================================================
// lightbox.
//=============================================================================
class LightBox extends UT_Decoration;

#exec MESH IMPORT MESH=lightboxM ANIVFILE=MODELS\lightbox_a.3D DATAFILE=MODELS\lightbox_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=lightboxM X=0 Y=0 Z=0 PITCH=0
#exec MESH SEQUENCE MESH=lightboxM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=lightboxM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=jlightbox FILE=MODELS\lightbox.pcx GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=lightboxM X=0.3 Y=0.3 Z=0.6
#exec MESHMAP SETTEXTURE MESHMAP=lightboxM NUM=1 TEXTURE=jlightbox

defaultproperties
{
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=LodMesh'Botpack.lightboxM'
     bUnlit=True
}
