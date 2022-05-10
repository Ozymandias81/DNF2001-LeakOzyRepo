//=============================================================================
// PaintBomb.
//=============================================================================
class PaintBomb expands DecalBomb;

#exec OBJ LOAD FILE=..\textures\t_generic.dtx

defaultproperties
{
     TraceNum=4
     TraceRotationVariance=(Pitch=16384,Yaw=16384,Roll=16384)
     MaxTraceDistance=128.000000
     MeshDecalSize=0.250000
     MeshDecalSizeVariance=0.125000
     LevelDecalSize=0.250000
     LevelDecalSizeVariance=0.125000
     Decals(0)=Texture't_generic.Paint.paint4RC'
     Decals(1)=Texture't_generic.Paint.paint5RC'
     Style=STY_Translucent
     bUnlit=True
}
