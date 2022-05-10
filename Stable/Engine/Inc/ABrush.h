/*=============================================================================
	ABrush.h.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

	// Constructors.
	ABrush() {}

	// UObject interface.
	void PostLoad();

	// OLD
	// OLD
	// These functions exist for the "ucc mapconvert" commandlet.  The engine/editor should NOT
	// be using them otherwise.
	FCoords OldToLocal() const
	{
		guardSlow(ABrush::OldToLocal);
		return GMath.UnitCoords / -PrePivot / MainScale / Rotation / PostScale / Location;
		unguardSlow;
	}
	FCoords OldToWorld() const
	{
		guardSlow(ABrush::OldToWorld);
		return GMath.UnitCoords * Location * PostScale * Rotation * MainScale * -PrePivot;
		unguardSlow;
	}
	virtual FLOAT OldBuildCoords( FModelCoords* Coords, FModelCoords* Uncoords )
	{
		guard(ABrush::OldBuildCoords);
		if( Coords )
		{
			Coords->PointXform    = (GMath.UnitCoords * PostScale * Rotation * MainScale);
			Coords->VectorXform   = (GMath.UnitCoords / MainScale / Rotation / PostScale).Transpose();
		}
		if( Uncoords )
		{
			Uncoords->PointXform  = (GMath.UnitCoords / MainScale / Rotation / PostScale);
			Uncoords->VectorXform = (GMath.UnitCoords * PostScale * Rotation * MainScale).Transpose();
		}
		return MainScale.Orientation() * PostScale.Orientation();
		unguard;
	}
	// OLD
	// OLD

	// AActor interface.
	virtual FCoords ToLocal() const
	{
		guardSlow(ABrush::ToLocal);
		return GMath.UnitCoords / -PrePivot / Location;
		unguardSlow;
	}
	virtual FCoords ToWorld() const
	{
		guardSlow(ABrush::ToWorld);
		return GMath.UnitCoords * Location * -PrePivot;
		unguardSlow;
	}
	virtual FLOAT BuildCoords( FModelCoords* Coords, FModelCoords* Uncoords )
	{
		guard(ABrush::BuildCoords);
		if( Coords )
		{
			Coords->PointXform    = GMath.UnitCoords;
			Coords->VectorXform   = GMath.UnitCoords.Transpose();
		}
		if( Uncoords )
		{
			Uncoords->PointXform  = GMath.UnitCoords;
			Uncoords->VectorXform = GMath.UnitCoords.Transpose();
		}
		return 0.0f;
		unguard;
	}

	// ABrush interface.
	virtual void CopyPosRotScaleFrom( ABrush* Other )
	{
		guard(ABrush::CopyPosRotScaleFrom);
		check(Brush);
		check(Other);
		check(Other->Brush);

		Location    = Other->Location;
		Rotation    = Other->Rotation;
		PrePivot	= Other->PrePivot;
		MainScale	= Other->MainScale;
		PostScale	= Other->PostScale;

		Brush->BuildBound();

		unguard;
	}
	virtual void InitPosRotScale();

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
