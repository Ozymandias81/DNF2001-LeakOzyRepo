/*-----------------------------------------------------------------------------
	dnGasMineFX_Shrunk_FadeIn
	Author: Charlie Wiederhold
	Gameplay Author: Brandon Reinhart

	* Poison DOT is enabled after 5 seconds.
	* Does 5 damage per second of DOT.
	* Ignites when it touches a bBurning actor.
	* Ignites when a weapon is fired in it.
-----------------------------------------------------------------------------*/
class dnGasMineFX_Shrunk_FadeIn expands dnGasMineFX_Shrunk;

// Creates the gas cloud that hovers around a gas spawner
#exec OBJ LOAD FILE=..\sounds\dnsWeapn.dfx
#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

var bool bCanPoison, bIgnited;

function PostBeginPlay()
{
	local Pawn P;

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
				P.AddDot( DOT_Poison, 5.0, 1.0, 5.0, Pawn(Owner), Self );
		}
	}
	else
		Super.Timer( TimerNum );
}

event Touch( Actor Other )
{
	Super.Touch( Other );

	if ( bIgnited )
		return;

	// Tell the pawn we entered an explosive area.
	if ( Other.bIsPawn )
		Pawn(Other).EnterExplosiveArea();

	// If we were touched by a pawn, poison it.
	if ( bCanPoison && Other.bIsPawn && Pawn(Other).CanBeGassed() )
	{
		Pawn(Other).AddDOT( DOT_Poison, 5.0, 1.0, 5.0, Pawn(Owner), Self );
	}

	// If we were touched by something burning, explode.
	if ( Other.bIsRenderActor && RenderActor(Other).bBurning )
		Ignite( Pawn(Other) );
}

event UnTouch( Actor Other )
{
	Super.UnTouch( Other );

	if ( bIgnited )
		return
;
	// Tell the pawn we exited an explosive area.
	if ( Other.bIsPawn )
		Pawn(Other).ExitExplosiveArea();
}

function Destroyed()
{
	local Pawn P;

	foreach TouchingActors( class'Pawn', P )
	{
		// Tell the pawn we exited an explosive area.
		P.ExitExplosiveArea();
	}

	Super.Destroyed();
}

function Ignite( Pawn Instigator )
{
	spawn( class'dnGasMineFX_Shrunk_Ignition', Instigator,, Location, Rotation );
	Destroy();
}

defaultproperties
{
     bIgnoreBList=True
     DestroyWhenEmptyAfterSpawn=True
     SpawnPeriod=1.000000
     Lifetime=10.000000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.Smoke.greensmoke1aRC'
     DrawScaleVariance=0.500000
     StartDrawScale=0.7500000
     EndDrawScale=0.7500000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=0.175000
     UpdateWhenNotVisible=True
     TriggerAfterSeconds=20.000000
     TriggerType=SPT_Disable
     AlphaStart=0.000000
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.100000
     bUseAlphaRamp=True
     CollisionRadius=48.000000
     CollisionHeight=48.000000
	 bCollideActors=true
     Style=STY_Translucent
	 bIgnitable=true
	 AmbientSound=sound'dnsWeapn.Flamethrower.FTGasLp'
	 RemoteRole=ROLE_SimulatedProxy
}
