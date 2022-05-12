//=============================================================================
// ChunkTrail.
//=============================================================================
class ChunkTrail extends Effects;

#exec OBJ LOAD FILE=textures\flakGlow.utx PACKAGE=Botpack.FlakGlow

defaultproperties
{
	 RemoteRole=ROLE_None
	 bUnlit=true
     bTrailerSameRotation=True
     Physics=PHYS_Trailer
     LifeSpan=0.500000
     DrawType=DT_SpriteAnimOnce
     Style=STY_Translucent
     Sprite=Texture'Botpack.FlakGlow.fglow_a00'
     Texture=Texture'Botpack.FlakGlow.fglow_a00'
     Skin=Texture'Botpack.FlakGlow.fglow_a00'
     DrawScale=0.350000
     ScaleGlow=0.600000
     Mass=30.000000
}
