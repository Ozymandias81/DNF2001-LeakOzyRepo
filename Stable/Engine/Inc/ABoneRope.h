/*=============================================================================
	ABoneRope.h
=============================================================================*/	    
#define MAX_ROPE_SEGMENTS   30

                        ABoneRope();
    // Member funcs
    void                UpdateCylinders( void );
    FVector             AngularDisplacement;
    FVector             AngularVelocity;
    FLOAT               GetRiderPosition( void );
    FVector             CalculateDirectionVector( void );
    void                RiderHitSolid( void );
    virtual UPrimitive  *GetPrimitive() const;
    UPrimitive          *CreatePrimitive( void );
    void                InitializeRope( void );
    void                *GetBoneFromHandle( INT handle );
    INT                 GetHandleFromBone( void *bone );
    void                DoBoneRope( FLOAT deltaTime, UBOOL action );
    virtual void        Spawned();
	virtual void        Destroy();

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
