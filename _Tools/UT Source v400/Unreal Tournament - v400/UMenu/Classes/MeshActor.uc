class MeshActor extends Info;

var UMenuPlayerMeshClient NotifyClient;

function AnimEnd()
{
	NotifyClient.AnimEnd(Self);
}

defaultproperties
{
	Physics=PHYS_Rotating
	CollisionRadius=0
	CollisionHeight=0
	bCollideActors=False
	bCollideWorld=False
	bBlockActors=False
	bBlockPlayers=False
	bOnlyOwnerSee=True
	RemoteRole=ROLE_None
	DrawType=DT_Mesh
	bUnlit=True
	bHidden=False
	DrawScale=0.1
	bAlwaysTick=True
	AmbientGlow=255
	bStatic=False
}