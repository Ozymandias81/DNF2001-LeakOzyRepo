//=============================================================================
// UT_BlackSmoke.
//=============================================================================
class UT_BlackSmoke extends UT_SpriteSmokePuff;

#exec OBJ LOAD FILE=..\UnrealShare\textures\SmokeBlack.utx PACKAGE=UnrealShare.SmokeBlack

defaultproperties
{
	 NumSets=3
     SSprites(0)=Texture'UnrealShare.SmokeBlack.bs_a00'
     SSprites(1)=Texture'UnrealShare.SmokeBlack.bs2_a00'
     SSprites(2)=Texture'UnrealShare.SmokeBlack.bs3_a00'
     SSprites(3)=None
     RisingRate=70.000000
     bHighDetail=True
     Style=STY_Modulated
     Texture=Texture'UnrealShare.SmokeBlack.bs2_a00'
     DrawScale=2.200000
}
