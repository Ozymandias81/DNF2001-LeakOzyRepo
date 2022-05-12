//=============================================================================
// BioSplash
//=============================================================================
class BioSplash extends UT_BioGel;

auto state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation) 
	{ 
		if ( Other.IsA('UT_BioGel') && (LifeSpan > Default.LifeSpan - 0.2) )
			return;
		if ( Pawn(Other)!=Instigator || bOnGround) 
			Global.Timer(); 
	}
}

defaultproperties
{
     speed=+00300.000000
}
