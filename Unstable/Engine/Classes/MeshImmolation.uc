/*-----------------------------------------------------------------------------
	MeshImmolation
	Author: Brandon Reinhart

	A cl@ss for handling frame based meshes that are on fire. (Snatchers/Decos)
	PawnImmolation is for skeletal meshes.
-----------------------------------------------------------------------------*/
class MeshImmolation extends ActorImmolation;

var class<SoftParticleSystem> MeshFlameClass;
var SoftParticleSystem MeshFlame;

simulated function RemoveEffect()
{
	Super.RemoveEffect();

	// Trigger effects off.
	if ( MeshFlame != None )
		MeshFlame.Trigger( Self, None );
}

simulated function AttachEffect( Actor Other )
{
	Super.AttachEffect( Other );

	// Set us on fire.
	if ( Other.IsA('Decoration') && Decoration(Other).MeshFlameClass != None )
		MeshFlame = spawn( Decoration(Other).MeshFlameClass, Self,, Owner.Location );
	else
	{
		MeshFlame = spawn( MeshFlameClass, Self,, Owner.Location );
		MeshFlame.SetCollisionSize( Other.CollisionRadius, Other.CollisionHeight );
	}

	MeshFlame.SpawnAtRadius = false;
	MeshFlame.SetPhysics( PHYS_MovingBrush );
	MeshFlame.AttachActorToParent( Owner );
}

simulated function ScaleDrawScale( float Scale )
{
	if ( MeshFlame != None )
	{
		/*
		MeshFlame.StartDrawScale *= Scale;
		MeshFlame.EndDrawScale *= Scale;
		MeshFlame.SetCollisionSize( MeshFlame.CollisionRadius*Scale, MeshFlame.CollisionHeight*Scale );
		*/
	}
}
