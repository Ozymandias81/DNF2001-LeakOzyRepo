class JetskiTorpedo extends RenderActor;

#exec OBJ LOAD FILE=..\Meshes\c_Characters.dmx
#exec OBJ LOAD FILE=..\Meshes\c_vehicles.dmx


auto state Riding
{
	ignores Touch, Bump, ZoneChange, HitWall;
}

function Mover FindTarget()
{
	local mover A;

	foreach allactors( class'Mover', A )
	{
		return A;
	}
}

state Firing
{
	function Tick( float DeltaTime )
	{
		local dnHomingTorpedo Torpedo;

		if( VSize( Location - Owner.Location ) > 128 )
		{
			Torpedo = Spawn( class'dnHomingTorpedo',,, Location, Rotation );
			Torpedo.Target = FindTarget();
			Destroy();
		}
	}
Begin:
	MountParent = None;
	AttachActorToParent( none, false, false );
	SetPhysics( PHYS_Projectile );
	Velocity = vector( Rotation ) * 750;
//	Accelrate = Owner.Accelrate * 1.5;
}

/*
auto state starting
{
Begin:
	Sleep( 3.0 );
	AttachActorToParent( none, false, false );
	SetPhysics( PHYS_Projectile );
	Velocity = vector( Rotation ) * 500;
}
*/

DefaultProperties
{
	Mesh=DukeMesh'c_dnWeapon.missle_jetski'
    DrawScale=0.750000	
	DrawType=DT_Mesh
	Physics=PHYS_MovingBrush
	VisibilityRadius=8000
	//	Buoyancy=201
}
