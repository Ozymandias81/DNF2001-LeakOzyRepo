/*-----------------------------------------------------------------------------
	HitPackage_Inventory
	Author: Brandon Reinhart

	Used when the shot hits an inventory item.
-----------------------------------------------------------------------------*/
class HitPackage_Inventory extends HitPackage;

simulated function Deliver()
{
	// Only perform behavior on the right kind of system.
	if ( Level.NetMode == NM_DedicatedServer)
		return;

	// Call base behavior.
	Super.Deliver();

	// Call the hit effect on the item.
	if ( Owner != None )
		Inventory(Owner).HitEffect( Location, class'BulletDamage', HitMomentum, 0, HitDamage, bNoCreationSounds );
}