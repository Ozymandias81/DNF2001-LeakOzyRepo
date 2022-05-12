class TargetShadow expands Decal;

function BeginPlay()
{
}
			
simulated function Tick(float DeltaTime)
{
	local Actor HitActor;
	local Vector HitNormal,HitLocation;

	if ( Owner == None )
		return;
	if ( Owner.Physics == PHYS_None )
	{
		Destroy();
		return;
	}
	DetachDecal();

	SetLocation(Owner.Location);
	AttachDecal(320);
}

defaultproperties
{
	MultiDecalLevel=0
	DrawScale=+0.2
	Texture=texture'Botpack.energymark'
	Rotation=(Pitch=16384,Yaw=0,Roll=0)
}