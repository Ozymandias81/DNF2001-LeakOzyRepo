/*=============================================================================
	BellowsaurCarcass
	Author: Jess Crable

=============================================================================*/
class BellowsaurCarcass extends CreaturePawnCarcass;

defaultproperties
{
     CollisionHeight=1.0
	 CollisionRadius=16.0
	 bBlockPlayers=false
     Mass=100.000000
     Mesh=DukeMesh'c_characters.alien_bellowsaur'
     Physics=PHYS_Falling
     ItemName="Bellowsaur Corpse"
	 bRandomName=false
	 bCanHaveCash=false
 	 bSearchable=false
	 bNotTargetable=true
 	 MasterReplacement=class'SnatcherMasterChunk'
}
