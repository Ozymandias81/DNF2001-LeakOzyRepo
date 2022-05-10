/*-----------------------------------------------------------------------------
	dnBloodPool
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class dnBloodPool extends dnDecal;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

var float BloodSpread;

function Initialize()
{
	Super.Initialize();

	if (bInitialized)
		return;

	SetTimer( 5.0, false, 2 );
}

simulated function Tick(float DeltaTime)
{
	if (DrawScale < 0.5)
	{
		DetachDecal();
		DrawScale += DeltaTime/BloodSpread;
		AttachDecal(100, vector(Rotation));
		BloodSpread += DeltaTime*10;
	}
}

simulated function Timer(optional int TimerNum)
{
	if( TimerNum == 2 )
	{
		NotifyNearbyPawns();
	}
}

function NotifyNearbyPawns()
{
	local Pawn P;

	for( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		if( P.IsA( 'EDFDog' ) )
		{
			P.NotifyInterest( self );
		}
	}
}

defaultproperties
{
	Decals(0)=Texture't_generic.bloodpool1RC'
	BloodSpread=10.0
    Behavior=DB_Normal
    MinSpawnDistance=2.0
    DrawScale=0.01
	LifeSpan=120.0
}
