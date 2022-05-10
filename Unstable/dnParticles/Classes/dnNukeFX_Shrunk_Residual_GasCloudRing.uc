//=============================================================================
// dnNukeFX_Shrunk_Residual_GasCloudRing. 					November 1st, 2000 - Charlie Wiederhold
//=============================================================================
class dnNukeFX_Shrunk_Residual_GasCloudRing expands dnNukeFX_Shrunk;

// Creates the gas cloud that hovers around a gas spawner

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

var bool bCanPoison;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer( 5.0, true, 1 );
}

function Timer( optional int TimerNum )
{
	local Pawn P;

	if ( TimerNum == 1 )
	{
		bCanPoison = true;
		SetTimer( 0.0, false, 1 );
		foreach TouchingActors( class'Pawn', P )
		{
			if ( P.CanBeGassed() )
				P.AddDot( DOT_Poison, 2.0, 1.0, 2.0, Pawn(Owner), Self );
		}
	}
	else
		Super.Timer( TimerNum );
}

event Touch( Actor Other )
{
	Super.Touch( Other );

	// If we were touched by a pawn, poison it.
	if ( bCanPoison && Other.bIsPawn && Pawn(Other).CanBeGassed() )
	{
		Pawn(Other).AddDOT( DOT_Poison, 2.0, 1.0, 2.0, Pawn(Owner), Self );
	}
}

defaultproperties
{
     bIgnoreBList=True
     Enabled=False
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=0.500000
     Lifetime=10.000000
     SpawnAtRadius=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.greensmoke1aRC'
     DrawScaleVariance=0.500000
     StartDrawScale=1.000000
     EndDrawScale=1.000000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=0.175000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=2.500000
     TriggerType=SPT_Pulse
     PulseSeconds=20.000000
     AlphaStart=0.000000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.250000
     bUseAlphaRamp=True
     CollisionRadius=192.000000
     CollisionHeight=64.000000
     bCollideActors=True
     Style=STY_Translucent
}
