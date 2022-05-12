class CannonMuzzle extends Effects;

function PostBeginPlay()
{
		Super.PostBeginPlay();
		LoopAnim('Shoot');
}

defaultproperties
{
	Physics=PHYS_None
	DrawType=DT_Mesh
	bParticles=true
	bStatic=false
	bUnlit=true
	bHidden=true
	bNetTemporary=false
	bBlockActors=false
	bBlockPlayers=false
	bCollideActors=false
	bCollideWorld=false
	Style=STY_Translucent
	DrawScale=0.25
	Mesh=mesh'Botpack.MuzzFlash3'
	Texture=Texture'Botpack.Skins.Muzzy'
	RemoteRole=ROLE_DumbProxy
	LifeSpan=+0.0
}