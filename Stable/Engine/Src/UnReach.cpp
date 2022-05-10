/*=============================================================================
	UnReach.cpp: Reachspec creation and management

	These methods are members of the FReachSpec class, 

	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Steven Polge 3/97
=============================================================================*/
#include "EnginePrivate.h"

FPlane FReachSpec::PathColor()
{
/*
	if ( reachFlags & R_FORCED ) // yellow for forced paths
		return FPlane(1.f, 1.f, 0.f, 0.f);

	if ( reachFlags & R_PROSCRIBED ) // red is reserved for proscribed paths
		return FPlane(1.f, 0.f, 0.f, 0.f);

	if ( reachFlags & R_SPECIAL )
		return FPlane(1.f,0.f,1.f, 0.f);	// purple path = special (lift or teleporter)

	if ( reachFlags & R_LADDER )
		return FPlane(1.f,0.5f, 1.f,0.f);	// light purple = ladder

	if ( (CollisionRadius >= COMMONRADIUS) && (CollisionHeight >= MINCOMMONHEIGHT)
			&& !(reachFlags & R_FLY) )
		return FPlane(0.f,1.f,0.f,0.f);  // blue path = wide
*/
	return FPlane(0.f,0.f,1.f,0.f); // green path = narrow
}

int FReachSpec::BotOnlyPath()
{

	return ( CollisionRadius < MINCOMMONRADIUS );
	
}
/* 
+ adds two reachspecs - returning the combined reachability requirements and total distance 
Note that Start and End are not set
*/
FReachSpec FReachSpec::operator+ (const FReachSpec &Spec) const
{
	FReachSpec Combined;
	
	Combined.CollisionRadius = Min(CollisionRadius, Spec.CollisionRadius);
	Combined.CollisionHeight = Min(CollisionHeight, Spec.CollisionHeight);
	Combined.reachFlags = (reachFlags | Spec.reachFlags);
	Combined.distance = distance + Spec.distance;
	
	return Combined; 
}
/* operator <=
Used for comparing reachspecs reach requirements
less than means that this has easier reach requirements (equal or easier in all categories,
does not compare distance, start, and end
*/
int FReachSpec::operator<= (const FReachSpec &Spec)
{
	int result =  
		(CollisionRadius >= Spec.CollisionRadius) &&
		(CollisionHeight >= Spec.CollisionHeight) &&
		((reachFlags | Spec.reachFlags) == Spec.reachFlags);
	return result; 
}

/* operator ==
Used for comparing reachspecs for choosing the best one
does not compare start and end
*/
int FReachSpec::operator== (const FReachSpec &Spec)
{
	int result = (distance == Spec.distance) && 
		(CollisionRadius == Spec.CollisionRadius) &&
		(CollisionHeight == Spec.CollisionHeight) &&
		(reachFlags == Spec.reachFlags);
	
	return result; 
}

/* defineFor()
initialize the reachspec for a  traversal from start actor to end actor.
Note - this must be a direct traversal (no routing).
Returns 1 if the definition was successful (there is such a reachspec), and zero
if no definition was possible
*/

int FReachSpec::defineFor(AActor * begin, AActor * dest, APawn * Scout)
{
	Start = begin;
	End = dest;
	Scout->Physics = PHYS_Walking;
	Scout->JumpZ = 280.0; //FIXME- test with range of JumpZ values - or let reachable code set max needed
	Scout->bCanWalk = 1;
	Scout->bCanJump = 0;
	Scout->bCanSwim = 1;
	Scout->bCanFly = 0;
	Scout->GroundSpeed = 320.0; 
	Scout->MaxStepHeight = 25; //FIXME - get this stuff from human class

	return findBestReachable(Start->Location, End->Location,Scout);
}

int FReachSpec::findBestReachable(FVector &begin, FVector &Destination, APawn * Scout)
{

	Scout->SetCollisionSize( HUMANRADIUS, HUMANHEIGHT );

	int result = 0;
	FLOAT stepsize = MAXCOMMONRADIUS - Scout->CollisionRadius;
	int success;
	int stilltrying = 1;
	FLOAT bestRadius = 0;
	FLOAT bestHeight = 0;
	//debugf("Find reachspec from %f %f %f to %f %f %f", begin.X, begin.Y, begin.Z,
	//	Destination.X, Destination.Y, Destination.Z);
	while (stilltrying) //find out max radius
	{
		success = Scout->GetLevel()->FarMoveActor( Scout, begin);

		if (success)
			success = Scout->pointReachable(Destination);

		if (success)
		{
			reachFlags = success;
			result = 1;
			bestRadius = Scout->CollisionRadius;
			bestHeight = Scout->CollisionHeight;
			Scout->SetCollisionSize( Scout->CollisionRadius + stepsize, MINCOMMONHEIGHT);
			stepsize *= 0.5;
			if ( (stepsize < 2) || (Scout->CollisionRadius > MAXCOMMONRADIUS) )
				stilltrying = 0;
		}
		else
		{
			Scout->SetCollisionSize(Scout->CollisionRadius - stepsize, Scout->CollisionHeight);
			stepsize *= 0.5;
			if ( (stepsize < 2) || (Scout->CollisionRadius < HUMANRADIUS) )
				stilltrying = 0;
		}
	}
	
	if (result)
	{
		Scout->SetCollisionSize(bestRadius, Scout->CollisionHeight + 4);
		stilltrying = 1;
		stepsize = MAXCOMMONHEIGHT - Scout->CollisionHeight; 
	}

	while (stilltrying) //find out max height
	{
		success = Scout->GetLevel()->FarMoveActor( Scout, begin);
		if (success)
			success = Scout->pointReachable(Destination);
		if (success)
		{
			reachFlags = success;
			bestHeight = Scout->CollisionHeight;
			Scout->SetCollisionSize(Scout->CollisionRadius, Scout->CollisionHeight + stepsize);
			stepsize *= 0.5;
			if ( (stepsize < 1.0) || (Scout->CollisionHeight > MAXCOMMONHEIGHT) ) 
				stilltrying = 0;
		}
		else
		{
			Scout->SetCollisionSize(Scout->CollisionRadius, Scout->CollisionHeight - stepsize);
			stepsize *= 0.5;
			if ( (stepsize < 1.0) || (Scout->CollisionHeight < HUMANHEIGHT + 1) )
				stilltrying = 0;
		}
	}

	if (result)
	{
		CollisionRadius = (INT) Scout->CollisionRadius;
		CollisionHeight = (INT) bestHeight;
		FVector path = End->Location - Start->Location;
		distance = (int)path.Size(); //fixme - reachable code should calculate
		if ( reachFlags & R_SWIM )
			distance *= 2;
	}

	return result; 
}



