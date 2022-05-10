/*-----------------------------------------------------------------------------
	ExpanderPulse
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class ExpanderPulse extends dnRocket_BrainBlast;

simulated function ProcessTouch( Actor Other, Vector HitLocation )
{
	local actor s;
	local vector HitNormal;

	if ( (Other == Instigator) || Other.IsA('Projectile') ) 
		return;

	if ( Other.bIsPawn )
		Pawn(Other).ExpandBone( FindDamageBone( Other, HitLocation ) );

	HitNormal = Normal(HitLocation-Other.Location);
	s = spawn( ExplosionClass,,,HitLocation + HitNormal*16, rotator(HitNormal) );
 	s.RemoteRole = ROLE_None;
	Destroy();
}

simulated function int FindDamageBone( Actor Other, Vector HitLocation )
{
	local name CheckBones[6];
	local int i, ClosestBone, CheckBone, ClosestIndex;
	local MeshInstance minst;
	local float CheckDist, ClosestDist;
	local vector CheckPos;

	CheckBones[0] = 'Pelvis';
	CheckBones[1] = 'Chest';
	CheckBones[2] = 'Abdomen';
	CheckBones[3] = 'Head';
	CheckBones[4] = 'Bicep_L';
	CheckBones[5] = 'Bicep_R';

	ClosestDist = 999999.f;
	minst = Other.GetMeshInstance();
	for (i=0; i<6; i++)
	{
		CheckBone = minst.BoneFindNamed( CheckBones[i] );
		CheckPos  = minst.BoneGetTranslate( CheckBone, true );
		CheckPos  = minst.MeshToWorldLocation( CheckPos );
		CheckDist = VSize(HitLocation - CheckPos);
		if ( CheckDist < ClosestDist )
		{
			ClosestDist = CheckDist;
			ClosestBone = CheckBone;
			ClosestIndex = i;
		}
	}

	return ClosestIndex;
}
