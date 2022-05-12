//=============================================================================
// UT_BloodPuff.
//=============================================================================
class UT_BloodPuff extends UT_SpriteSmokePuff;

#exec OBJ LOAD FILE=..\Unrealshare\textures\BloodyPuff.utx PACKAGE=UnrealShare.BloodyPuff

defaultproperties
{
     NumSets=3
     SSprites(0)=Texture'UnrealShare.BloodyPuff.bp_A01'
     SSprites(1)=Texture'UnrealShare.BloodyPuff.bp8_a00'
     SSprites(2)=Texture'UnrealShare.BloodyPuff.Bp6_a00'
     SSprites(3)=None
     RisingRate=-50.000000
     bHighDetail=True
     LifeSpan=0.500000
     Texture=Texture'UnrealShare.BloodyPuff.bp_A01'
     DrawScale=2.000000
}
