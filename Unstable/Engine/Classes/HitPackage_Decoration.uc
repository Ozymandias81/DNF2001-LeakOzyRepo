/*-----------------------------------------------------------------------------
	HitPackage_Decoration
	Author: Brandon Reinhart

	Used when the shot hits a decoration.
-----------------------------------------------------------------------------*/
class HitPackage_Decoration extends HitPackage;

var int DecoHealth;

simulated function Deliver()
{
	// Only perform behavior on the right kind of system.
	if ( Level.NetMode == NM_DedicatedServer)
		return;

	// Call base behavior.
	Super.Deliver();

	// Call the hit effect on the decoration.
	if ( Owner != None )
		Item(Owner).HitEffect( Location, class'BulletDamage', HitMomentum, DecoHealth, HitDamage, bNoCreationSounds );
}