//=============================================================================
// UT_GreenBloodPuff.
//=============================================================================
class UT_GreenBloodPuff extends UT_SpriteSmokePuff;

#exec OBJ LOAD FILE=..\UnrealShare\textures\SmokeGreen.utx PACKAGE=UnrealShare.SmokeGreen

defaultproperties
{
	 NumSets=3
     SSprites(0)=Texture'UnrealShare.SmokeGreen.gs_A00'
     SSprites(1)=Texture'UnrealShare.SmokeGreen.gs2_A00'
     SSprites(2)=Texture'UnrealShare.SmokeGreen.gs3_A00'
     SSprites(3)=None
     Pause=0.070000
     Texture=Texture'UnrealShare.SmokeGreen.gs2_A00'
     DrawScale=2.000000
	 RisingRate=-50.0
	 bHighDetail=false
	 LifeSpan=0.500000
}
