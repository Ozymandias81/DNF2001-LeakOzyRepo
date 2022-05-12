//=============================================================================
// StudMetal
// Simple static low-poly environment mapped decorations.
// 10-16-98  Erik de Neve
//=============================================================================
class StudMetal extends Decoration;

#exec TEXTURE IMPORT NAME=StudMap  FILE=MODELS\Gold.PCX GROUP=Skins

defaultproperties
{
    DrawType=DT_Mesh
    bMeshEnviroMap=True
    bMeshCurvy=False
}
