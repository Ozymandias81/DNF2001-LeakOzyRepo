//=============================================================================
// PainPath.
//=============================================================================
class PainPath extends LiftCenter;

var() name	 DamageType;

function PostBeginPlay()
{
	local inventory Inv;

	Super.PostBeginPlay();

	if ( Region.Zone.bPainZone )
		DamageType = Region.Zone.DamageType;
}

event int SpecialCost(Pawn Seeker)
{
	//log(self@"special cost for"@Seeker@"with reduced damage"@Seeker.ReducedDamageType);

	if ( Seeker.ReducedDamageType == DamageType )
		return 0;

	return 1000000;
}

/* SpecialHandling is called by the navigation code when the next path has been found.  
It gives that path an opportunity to modify the result based on any special considerations
*/
function Actor SpecialHandling(Pawn Other)
{
	if ( Other.ReducedDamageType == DamageType )
		return self;

	return None;
}

defaultproperties
{
	bNoDelete=true
	bStatic=false
	bSpecialCost=true
}