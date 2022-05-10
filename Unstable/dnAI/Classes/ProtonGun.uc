class ProtonGun extends dnDecoration;

#exec OBJ LOAD FILE=..\Meshes\c_Characters.dmx

simulated function MuzzleFlash()
{
	local actor S;
	local float RandRot;

//	MuzzleFlashClass=class'M16Flash';

	S = Spawn(class'M16Flash');
	S.DrawScale *= 5;
	S.MountMeshItem = 'MuzzleMount';
	S.AttachActorToParent( Self, true, true );
	S.MountOrigin = vect( 3, 0, 0 );
	S.MountType = MOUNT_MeshSurface;
	S.bOwnerSeeSpecial = true;
	S.SetOwner( Owner );
	S.SetPhysics( PHYS_MovingBrush );
	RandRot = FRand();
	if (RandRot < 0.3)
		S.SetRotation(rot(S.Rotation.Pitch,S.Rotation.Yaw,S.Rotation.Roll+16384));
	else if (RandRot < 0.6)
		S.SetRotation(rot(S.Rotation.Pitch,S.Rotation.Yaw,S.Rotation.Roll+32768));
//		MuzzleLocation = S.Location;
}

DefaultProperties
{
	Mesh=DukeMesh'c_characters.Proton_MonitorGun'
    Drawscale=10.000000
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    CollisionHeight=0
    CollisionRadius=0
    VisibilityRadius=8000
}
