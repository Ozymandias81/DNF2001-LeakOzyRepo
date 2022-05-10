/*=============================================================================
	AlienPigCarcass
	Author: Jess Crable

=============================================================================*/
class AlienPigCarcass extends CreaturePawnCarcass;

defaultproperties
{
     CollisionHeight=1.0
	 CollisionRadius=16.0
	 bBlockPlayers=false
     Mass=100.000000
     Mesh=DukeMesh'c_characters.alien_pig'
     Physics=PHYS_Falling
     ItemName="Alien Pig Corpse"
	 bRandomName=false
	 bCanHaveCash=false
 	 bSearchable=false
	 bNotTargetable=true
 	 MasterReplacement=class'SnatcherMasterChunk'
}
