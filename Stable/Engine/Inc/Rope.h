class ABoneRope;

class RopePrimitive : public UPrimitive
{
public:
	DECLARE_CLASS( RopePrimitive, UPrimitive, 0 );
	
    ABoneRope   *m_RopeInstance;

    RopePrimitive() {};
	
    virtual UBOOL PointCheck
        (
        FCheckResult& Result,
        AActor* Owner,
        FVector Location,
        FVector Extent,
        DWORD ExtraNodeFlags
        );

	virtual UBOOL LineCheck
        (
        FCheckResult& Result,
        AActor* Owner,
        FVector End,
        FVector Start,
        FVector Extent,
        DWORD ExtraNodeFlags,
        UBOOL bMeshAccurate=0
        );

    virtual FBox GetRenderBoundingBox
        (
        const AActor* Owner,
        UBOOL Exact
        );

    virtual FBox GetCollisionBoundingBox( const AActor* Owner ) const;
};
