class SnatchActor expands RenderActor;

var float LifeSpan;

function PostBeginPlay()
{
	if( PlayerPawn( Owner ) != None )
		PlayerPawn( Owner ).AddDOT( DOT_Fire, 1.0, 0.5, 3.0, None );
	LifeSpan = 1.0;
	HumanNPC( Owner ).MySnatcher = self;
}

auto state Snatching
{
Begin:
	FinishAnim();
	Destroy();
}

DefaultProperties
{
	 DrawType=DT_Mesh
     Mesh=DukeMesh'c_characters.alien_snatcher'
	 CollisionHeight=0
	 CollisionRadius=0
	 DrawScale=0.7 
}

