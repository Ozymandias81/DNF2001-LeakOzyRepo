//
// dnFXSpawner - used to spawn effects on the client, so we don't have to replicate any particle systems
//

class dnFXSpawner extends Actor;

var () class<actor>	FXClass;

replication
{
    reliable if ( Role == ROLE_Authority )
        FXClass;
}

simulated function PostNetInitial()
{
	Super.PostNetInitial();

    // Do the spawn on the client
    if ( Role < ROLE_Authority )
		DoSpawn();
}

simulated function DoSpawn()
{
    local Actor SpawnActor;
 
    if ( Level.NetMode == NM_DedicatedServer )
		return;

    SpawnActor = spawn(FXClass, , , self.Location, self.Rotation);
    SpawnActor.RemoteRole = ROLE_None;
}

defaultproperties
{
    Texture=None
    DrawType=DT_Sprite
    bNetTemporary=true
    bHidden=false
    RemoteRole=ROLE_SimulatedProxy
    LifeSpan=1.0
}
