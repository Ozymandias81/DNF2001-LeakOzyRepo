/*-----------------------------------------------------------------------------
	OctabrainCarcass
-----------------------------------------------------------------------------*/
class OctabrainCarcass extends CreaturePawnCarcass;

var name TentacleList[ 17 ];

simulated function bool OnEvalBones(int Channel)
{
	// OnEvalBones should do nothing on a dedicated server.
	if (Level.NetMode == NM_DedicatedServer)
		return false;
	
	// Perform client-side bone manipulation.

	if (Channel==3)
	{
		if( TentacleList[ 0 ] != '' )
			EvalDamagedTentacles();
		EvalBodyDamage();
		if (DamageBoneShakeFactor > 0.0)
			EvalShakeDamageBone();
		return true;
	}	
}

function bool EvalDamagedTentacles()
{
	local int i, bone;
	local MeshInstance Minst;

	for( i = 0; i <= 15; i++ )
	{
		if( TentacleList[ i ] != '' )
		{
			Minst = GetMeshInstance();

			bone = Minst.BoneFindNamed( TentacleList[ i ] );

			if( bone != 0 )
			{
				MeshInstance.BoneSetScale(bone, vect(0,0,0), true);
			}
		}
		else
			break;
	}
}

defaultproperties
{
     CollisionHeight=1.0
	 CollisionRadius=16.0
	 bBlockPlayers=false
     Mass=100.000000
     Mesh=DukeMesh'c_characters.octabrain'
     Physics=PHYS_Falling
     ItemName="Octabrain Corpse"
	 bRandomName=false
	 bCanHaveCash=false
 	 bSearchable=false
	 bNotTargetable=true
 	 MasterReplacement=class'SnatcherMasterChunk'
}
