/*=============================================================================
	AMover.h: Class functions residing in the AMover class.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

	// Constructors.
	AMover();

	// UObject interface.
	void PostLoad();
	void PostEditChange();

	// AActor interface.
	void Spawned();
	void PostEditMove();
	void PreRaytrace();
	void PostRaytrace();
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map );

	// ABrush interface.
	virtual FCoords ToLocal() const
	{
		return GMath.UnitCoords / -PrePivot / Rotation / Location;
	}
	virtual FCoords ToWorld() const
	{
		return GMath.UnitCoords * Location * Rotation * -PrePivot;
	}
	virtual FLOAT BuildCoords( FModelCoords* Coords, FModelCoords* Uncoords )
	{
		if( Coords )
		{
			Coords->PointXform    = (GMath.UnitCoords * Rotation);
			Coords->VectorXform   = (GMath.UnitCoords / Rotation).Transpose();
		}
		if( Uncoords )
		{
			Uncoords->PointXform  = (GMath.UnitCoords / Rotation);
			Uncoords->VectorXform = (GMath.UnitCoords * Rotation).Transpose();
		}
		return 0.0f;
	}
	virtual void SetWorldRaytraceKey();
	virtual void SetBrushRaytraceKey();

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
