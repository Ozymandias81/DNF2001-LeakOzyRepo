class PlayerShadow expands Decal;

var vector OldOwnerLocation;
var Actor OldLight;
//var FadeShadow FadeShadow;

function BeginPlay()
{
}
/*
function Destroyed()
{
	Super.Destroyed();

	if ( FadeShadow != None )
		FadeShadow.Destroy();
}
*/
function Timer()
{
	DetachDecal();
	OldOwnerLocation = vect(0,0,0);
}
			
event Update(Actor L)
{
	local Actor HitActor;
	local Vector HitNormal,HitLocation, ShadowStart, ShadowDir;

	if ( !Level.bHighDetailMode )
		return;

	SetTimer(0.08, false);
	if ( OldOwnerLocation == Owner.Location )
		return;

	OldOwnerLocation = Owner.Location;

	DetachDecal();

	if ( Owner.Style == STY_Translucent )
		return;

	if ( L == None )
		ShadowDir = vect(0.1,0.1,0);
	else
	{
		ShadowDir = Normal(Owner.Location - L.Location);
		/*
		if ( OldLight != L )
		{
			if ( FadeShadow == None )
				FadeShadow = spawn(class'FadeShadow',self);
		
			FadeShadow.LightSource = OldLight;
		}
		OldLight = L;
		*/
		if ( ShadowDir.Z > 0 )
			ShadowDir.Z *= -1;
	}


	ShadowStart = Owner.Location + Owner.CollisionRadius * ShadowDir;
	HitActor = Trace(HitLocation, HitNormal, ShadowStart - vect(0,0,300), ShadowStart, false);

	if ( HitActor == None )
		return;

	SetLocation(HitLocation);
	SetRotation(rotator(HitNormal));
	AttachDecal(10, ShadowDir);
}


defaultproperties
{
	MultiDecalLevel=3
	DrawScale=+0.5
	Texture=texture'Botpack.energymark'
	ScaleGlow=+1.0
}
