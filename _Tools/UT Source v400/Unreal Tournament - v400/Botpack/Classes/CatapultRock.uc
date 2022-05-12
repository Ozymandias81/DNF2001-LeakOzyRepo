//=============================================================================
// CatapultRock.
//=============================================================================
class CatapultRock extends BigRock;

auto state Flying
{
	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local int hitdamage;

		PlaySound(ImpactSound, SLOT_Interact, DrawScale/10);	

		if ( !Other.IsA('BigRock') )
		{
			Hitdamage = Damage * 0.00002 * (DrawScale**3) * speed;
			if ( (HitDamage > 6) && (speed > 150) )
				Other.TakeDamage(hitdamage, instigator,HitLocation,
					(35000.0 * Normal(Velocity)), 'crushed' );
		}
	}

Begin:
	SetPhysics(PHYS_Falling);
}

defaultproperties
{
	Physics=PHYS_Falling
    DrawScale=+00008.500000
}