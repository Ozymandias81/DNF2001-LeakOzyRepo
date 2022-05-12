class VisibleTeleporter extends Teleporter;

var UTTeleEffect T;

simulated function Destroyed()
{
	if ( T != None )
		T.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	LoopAnim('Teleport', 2.0, 0.0);
	T = spawn(class'UTTeleeffect');
	T.lifespan = 0.0;
}

defaultproperties
{
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=LodMesh'Botpack.Tele2'
     bUnlit=True
 	 bStatic=false
	 bHidden=false
	 RemoteRole=ROLE_SimulatedProxy
}
