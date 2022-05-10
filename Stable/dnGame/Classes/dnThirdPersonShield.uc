class dnThirdPersonShield extends dnDecoration;

simulated function Tick( float Delta )
{
	local PlayerPawn PPOwner;
	local float NewDrawScale;
	
	if ( (Owner != None) && Owner.bIsPlayerPawn )
	{
		PPOwner = PlayerPawn(Owner);
		NewDrawScale = FMax( 1.0 - (PPOwner.ShrinkCounter/PPOwner.ShrinkTime), 0.25 );
		if ( DrawScale != NewDrawScale )
		{
			DrawScale = NewDrawScale;
			MountOrigin = default.MountOrigin * DrawScale;
		}
	}

	Super.Tick( Delta );
}

defaultproperties
{
     Physics=PHYS_MovingBrush
     LodMode=LOD_Disabled
     Texture=Texture'm_characters.edfshieldglassR'
     Mesh=DukeMesh'c_characters.EDFshield'
     bOwnerSeeSpecial=true
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=false
     bCollideWorld=false
     MountType=MOUNT_MeshBone
     MountOrigin=(X=0.500000,Y=-6.500000,Z=1.400000)
     MountAngles=(Yaw=-800,Roll=32768)
     MountMeshItem=Forearm_L
	 bNeverTravel=true
}
