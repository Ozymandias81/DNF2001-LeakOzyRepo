/*=============================================================================
	HeadCreeperCarcass
	Author: Jess Crable

=============================================================================*/
class HeadCreeperCarcass extends CreaturePawnCarcass;

#exec OBJ LOAD FILE=..\meshes\c_characters.dmx

function PostBeginPlay()
{
	SetCallbackTimer( 2.0, false, 'DestroySelf' );
	Super.PostBeginPlay();
}

function DestroySelf()
{
	Destroy();
}


defaultproperties
{
     CollisionHeight=1.0
	 CollisionRadius=16.0
	 bBlockPlayers=false
     Mass=100.000000
     Mesh=DukeMesh'c_characters.HeadCreeper'
     Physics=PHYS_Falling
     ItemName="HeadCreeper Corpse"
	 bRandomName=false
	 bCanHaveCash=false
 	 bSearchable=false
	 bNotTargetable=true
 	 MasterReplacement=class'SnatcherMasterChunk'
	 bNoTakeOwnerProperties=true
	 bBloodPool=false
}
