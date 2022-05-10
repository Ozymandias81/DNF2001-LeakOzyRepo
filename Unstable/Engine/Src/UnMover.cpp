/*=============================================================================
	UnMover.cpp: Keyframe mover actor code
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	AMover implementation.
-----------------------------------------------------------------------------*/

AMover::AMover()
{}
void AMover::Spawned()
{
	ABrush::Spawned();

	BasePos = Location;
	BaseRot	= Rotation;
}
void AMover::PostLoad()
{
	AActor::PostLoad();

	// For refresh.
	SavedPos = FVector(-12345,-12345,-12345);
	SavedRot = FRotator(123,456,789);

	// Fix brush poly iLinks which were broken.
	if( Brush && Brush->Polys )
		for( INT i=0; i<Brush->Polys->Element.Num(); i++ )
			Brush->Polys->Element(i).iLink = i;
}
void AMover::PostEditMove()
{
	ABrush::PostEditMove();
	if( KeyNum == 0 )
	{
		// Changing location.
		BasePos  = Location - OldPos;
		BaseRot  = Rotation - OldRot;
	}
	else
	{
		// Changing displacement of KeyPos[KeyNum] relative to KeyPos[0].
		KeyPos[KeyNum] = Location - (BasePos + KeyPos[0]);
		KeyRot[KeyNum] = Rotation - (BaseRot + KeyRot[0]);

		// Update Old:
		OldPos = KeyPos[KeyNum];
		OldRot = KeyRot[KeyNum];
	}
	Location = BasePos + KeyPos[KeyNum];
}
void AMover::PostEditChange()
{
	ABrush::PostEditChange();

	// Validate KeyNum.
	KeyNum = Clamp( (INT)KeyNum, (INT)0, (INT)ARRAY_COUNT(KeyPos)-1 );

	// Update BasePos.
	BasePos  = Location - OldPos;
	BaseRot  = Rotation - OldRot;

	// Update Old.
	OldPos = KeyPos[KeyNum];
	OldRot = KeyRot[KeyNum];

	// Update Location.
	Location = BasePos + OldPos;
	Rotation = BaseRot + OldRot;

	PostEditMove();
}
void AMover::PreRaytrace()
{
	ABrush::PreRaytrace();

	// Place this brush in position to raytrace the world.
	SavedPos = FVector(0,0,0);
	SavedRot = FRotator(0,0,0);

	SetWorldRaytraceKey();
}
void AMover::SetWorldRaytraceKey()
{
	if( WorldRaytraceKey!=255 )
	{
		WorldRaytraceKey = Clamp((INT)WorldRaytraceKey,0,(INT)ARRAY_COUNT(KeyPos)-1);
		if( bCollideActors && GetLevel()->Hash ) GetLevel()->Hash->RemoveActor( this );
		Location = BasePos + KeyPos[WorldRaytraceKey];
		Rotation = BaseRot + KeyRot[WorldRaytraceKey];
		if( bCollideActors && GetLevel()->Hash ) GetLevel()->Hash->AddActor( this );
		if( GetLevel()->BrushTracker )
			GetLevel()->BrushTracker->Update( this );
	}
	else
	{
		if( GetLevel()->BrushTracker )
			GetLevel()->BrushTracker->Flush( this );
	}
}
void AMover::SetBrushRaytraceKey()
{
	BrushRaytraceKey = Clamp((INT)BrushRaytraceKey,0,(INT)ARRAY_COUNT(KeyPos)-1);
	if( bCollideActors && GetLevel()->Hash ) GetLevel()->Hash->RemoveActor( this );
	Location = BasePos + KeyPos[BrushRaytraceKey];
	Rotation = BaseRot + KeyRot[BrushRaytraceKey];
	if( bCollideActors && GetLevel()->Hash ) GetLevel()->Hash->AddActor( this );
	if( GetLevel()->BrushTracker )
		GetLevel()->BrushTracker->Update( this );
}
void AMover::PostRaytrace()
{
	ABrush::PostRaytrace();

	// Called before/after raytracing session beings.
	if( bCollideActors && GetLevel()->Hash ) GetLevel()->Hash->RemoveActor( this );
	Location = BasePos + KeyPos[KeyNum];
	Rotation = BaseRot + KeyRot[KeyNum];
	if( bCollideActors && GetLevel()->Hash ) GetLevel()->Hash->AddActor( this );
	SavedPos = FVector(0,0,0);
	SavedRot = FRotator(0,0,0);
	if( GetLevel()->BrushTracker )
		GetLevel()->BrushTracker->Update( this );
}

void AMover::execGetMoverCollisionBox( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR_REF(Min);
	P_GET_VECTOR_REF(Max);
	P_FINISH;

	FBox Bounding = GetPrimitive()->GetCollisionBoundingBox(this);
	*Min = Bounding.Min;
	*Max = Bounding.Max;
}

IMPLEMENT_CLASS(AMover);

/*-----------------------------------------------------------------------------
	ADoorMover implementation.
-----------------------------------------------------------------------------*/

void ADoorMover::physMovingBrush( FLOAT DeltaTime )
{
	if (MoveByForce)
	{
		FRotator NewRotation;
		FVector NewLocation = FVector(0,0,0);

		// Don't think if we aren't moving.
		if ((RadialForce == FRotator(0,0,0)) && (RadialVelocity == FRotator(0,0,0)))
			return;

		// Apply acceleration to velocity.
		RadialVelocity = RadialVelocity + (DeltaTime * (RadialForce + AppliedRadialFriction));

		// Stop a very slow movement.
		if ((RadialVelocity.Yaw < 100)  && (RadialVelocity.Yaw > 100))
			RadialVelocity.Yaw = 0;

		// Apply velocity to position.
		NewRotation = OldRot + (DeltaTime * RadialVelocity);

		// Apply a friction force opposite the movement direction.
		if (RadialVelocity.Yaw > 0)
			AppliedRadialFriction.Yaw = -BaseRadialFriction.Yaw;
		if (RadialVelocity.Yaw < 0)
			AppliedRadialFriction.Yaw = BaseRadialFriction.Yaw;
		if (RadialVelocity.Yaw == 0)
			AppliedRadialFriction.Yaw = 0;

		// If we opened beyond our door frame limit, ricochet.
		if (RadialVelocity.Yaw > 0)
		{
			if ((BaseRot.Yaw < BaseYaw) && (NewRotation.Yaw > BaseYaw))
			{
				eventDoorframeImpact();
				NewRotation.Yaw = BaseYaw;
			}
			else if ((BaseRot.Yaw > BaseYaw) && (NewRotation.Yaw < BaseYaw))
			{
				eventDoorframeImpact();
				NewRotation.Yaw = BaseYaw;
			}
		} 
		else if (RadialVelocity.Yaw < 0) 
		{
			if ((BaseRot.Yaw > BaseYaw) && (NewRotation.Yaw < BaseYaw))
			{
				eventDoorframeImpact();
				NewRotation.Yaw = BaseYaw;
			}
			else if ((BaseRot.Yaw < BaseYaw) && (NewRotation.Yaw > BaseYaw))
			{
				eventDoorframeImpact();
				NewRotation.Yaw = BaseYaw;
			}
		}

		FCheckResult Hit(1.0);
		if (GetLevel()->MoveActor( this, NewLocation, NewRotation, Hit ))
		{
			LastMoveTime += DeltaTime;
			OldRot = NewRotation;
		}
		return;
	} else if (MoveBySlide) {
		// Get axes.
		FCoords Coords = GMath.UnitCoords / Rotation;
		FVector X = Coords.XAxis;

		// Determine direction of motion.
		FLOAT SlideDirection;
		if (DoorSlideDirection == DSD_Left)
		{
			if (SlidingForward)
				SlideDirection = 1;
			else
				SlideDirection = -1;
		} else {
			if (SlidingForward)
				SlideDirection = -1;
			else
				SlideDirection = 1;
		}

		// Integrate.
		SlideVelocity = SlideVelocity + (DeltaTime * (SlideForce + AppliedSlideFriction));
		FVector MoveDelta = (DeltaTime * SlideVelocity) * X * SlideDirection;

		// Stop a very slow movement.
		if ((SlideVelocity < 2) && (SlideVelocity > -2) && (SlideVelocity != 0))
		{
			eventStoppedMoving();
			SlideVelocity = 0;
		}

		// Apply a friction force opposite the movement direction.
		if ( SlideVelocity > 0 )
			AppliedSlideFriction = -BaseSlideFriction;
		if ( SlideVelocity < 0 )
			AppliedSlideFriction = BaseSlideFriction;
		if ( SlideVelocity == 0 )
			AppliedSlideFriction = 0;

		// If we opened past our door frame limit, ricochet.
		FVector MoveDistance = Location - InitialLocation;
		FLOAT MoveDistance2D = appSqrt(MoveDistance.X*MoveDistance.X + MoveDistance.Y*MoveDistance.Y);
		if (MoveDistance2D > SlideDistance)
			eventDoorframeImpact();

		// Apply changes.
		FCheckResult Hit(1.0);
		GetLevel()->MoveActor( this, MoveDelta, Rotation, Hit );
	}
	else
	{
		Super::physMovingBrush( DeltaTime );
		if ( CloseBySlide )
		{
			// If we opened past our door frame limit, ricochet.
			FVector MoveDistance = Location - InitialLocation;
			FLOAT MoveDistance2D = appSqrt(MoveDistance.X*MoveDistance.X + MoveDistance.Y*MoveDistance.Y);
			if ( MoveDistance2D < AlmostClosedDist )
				eventAlmostClosed();
		}
		else
		{
			if ( OpenDirection == 1 )
			{
				if ( Rotation.Yaw < BaseRot.Yaw + ((AlmostClosedDegrees/360.f)*65536.f) )
					eventAlmostClosed();
			}
			else
			{
				if ( Rotation.Yaw > BaseRot.Yaw - ((AlmostClosedDegrees/360.f)*65536.f) )
					eventAlmostClosed();
			}
		}
	}
}

IMPLEMENT_CLASS(ADoorMover);

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
