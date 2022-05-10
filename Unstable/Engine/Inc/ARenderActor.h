/*-----------------------------------------------------------------------------
	ARenderActor.h
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/

	virtual INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map );
	virtual UTexture* GetSkin( INT Index );
	virtual void PreNetReceive();
	virtual void PostNetReceive();
    virtual void UpdateNetAnimationChannels(UMeshInstance *minst);
