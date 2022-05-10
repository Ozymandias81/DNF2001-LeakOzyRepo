/*=============================================================================
	EggPodCarcass
	Author: Jess Crable

=============================================================================*/
class EggPodCarcass extends CreaturePawnCarcass;

#exec OBJ LOAD FILE=..\meshes\c_characters.dmx

function PostBeginPlay()
{
	PlayAnim( 'DeathA' );
}

function Timer(optional int TimerNum)
{
}

defaultproperties
{
     CollisionHeight=1.0
	 CollisionRadius=16.0
	 bBlockPlayers=false
     Mass=100.000000
     Mesh=DukeMesh'c_characters.EggPod_LRGcrps'
     Physics=PHYS_Falling
     ItemName="EggPod Corpse"
	 bRandomName=false
	 bCanHaveCash=false
 	 bSearchable=false
	 bNotTargetable=true
 	 MasterReplacement=class'SnatcherMasterChunk'
	 bNoTakeOwnerProperties=true
}
