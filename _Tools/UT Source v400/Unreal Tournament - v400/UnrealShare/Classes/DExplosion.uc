//=============================================================================
// DExplosion.
//=============================================================================
class DExplosion extends Effects;

#exec TEXTURE IMPORT NAME=ExplosionPal FILE=textures\exppal.pcx GROUP=Effects
#exec OBJ LOAD FILE=textures\deburst.utx PACKAGE=UnrealShare.DBEffect

defaultproperties
{
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=UnrealShare.DBEffect.de_A00
     Skin=UnrealShare.ExplosionPal
     bUnlit=True
     bMeshCurvy=False
     LightType=LT_TexturePaletteOnce
     LightEffect=LE_NonIncidence
     LightRadius=8
     Physics=PHYS_None
     LifeSpan=+00000.500000
     RemoteRole=ROLE_SimulatedProxy
}
