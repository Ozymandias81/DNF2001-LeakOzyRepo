class StunLeech extends Info;

var Pawn MyTarget;

function PostBeginPlay()
{
	SetTimer( 5.5, false );
}

function Timer( optional int TimerNum )
{
	DetachLeech();
}


function InputHook(out float aForward,out float aLookUp,out float aTurn,out float aStrafe,optional float DeltaTime)
{
	if( Pawn( Owner ) != None && Pawn( Owner ).Health > 0 )
	{
		aForward = 0;
		aTurn = 0.0;
		aStrafe = 0;
		aLookup = 0.0;
		return;
	}
	else
		DetachLeech();
}

function AttachTo( Pawn Victim )
{
	if( PlayerPawn( Victim ) != None )
		PlayerPawn( Victim ).InputHookActor = self;
	MyTarget = Victim;
}

function DetachLeech()
{
	if( PlayerPawn( MyTarget ) != None )
		PlayerPawn( MyTarget ).InputHookActor = None;
	EDFHeavyWeps( Owner ).MyStunLeech = None;
	Destroy();
}

DefaultProperties
{}
