//===========================================================================
//	AGeoWater.cpp
//	John Pollard
//===========================================================================
#include "EnginePrivate.h"

IMPLEMENT_CLASS(AGeoWater);

//===========================================================================
//	JWaterPrimitive
//===========================================================================
class JWaterPrimitive : public UPrimitive
{
public:
	DECLARE_CLASS( JWaterPrimitive, UPrimitive, 0 );
	
    AGeoWater   *WaterInstance;

    JWaterPrimitive() {};
	
    virtual UBOOL PointCheck
	(
        FCheckResult	&Result,
        AActor			*Owner,
        FVector			Location,
        FVector			Extent,
        DWORD			ExtraNodeFlags
	);

	virtual UBOOL LineCheck
	(
		FCheckResult	&Result,
		AActor			*Owner,
		FVector			End,
		FVector			Start,
		FVector			Extent,
		DWORD		ExtraNodeFlags,
		UBOOL		bMeshAccurate=0
	);

    virtual FBox GetRenderBoundingBox(const AActor* Owner, UBOOL Exact);

    virtual FBox GetCollisionBoundingBox( const AActor* Owner ) const;
};

IMPLEMENT_CLASS(JWaterPrimitive);

struct WaterInternalData
{
	JWaterPrimitive		*WaterPrimitive;
};

#define WATER_INTERNALDATA(w) ((WaterInternalData*)w->InternalData)

#define WATER_PRIMITIVE(w) WATER_INTERNALDATA(w)->WaterPrimitive;

//===========================================================================
//	JWaterPrimitive::PointCheck
//===========================================================================
UBOOL JWaterPrimitive::PointCheck
(
	FCheckResult	&Result,
	AActor			*Owner,
	FVector			Location,
	FVector			Extent,
	DWORD			ExtraNodeFlags
)
{
	return true;
}

//===========================================================================
//	JWaterPrimitive::LineCheck
//===========================================================================
UBOOL JWaterPrimitive::LineCheck
(
	FCheckResult	&Result,
	AActor			*Owner,
	FVector			End,
	FVector			Start,
	FVector			Extent,
	DWORD			ExtraNodeFlags,
	UBOOL			bMeshAccurate
)
{
	return true;
}

//===========================================================================
//	JWaterPrimitive::GetRenderBoundingBox
//===========================================================================
FBox JWaterPrimitive::GetRenderBoundingBox
(
	const AActor	*Owner,
	UBOOL			Exact
)
{	
	return UPrimitive::GetRenderBoundingBox( Owner, Exact );
}

//===========================================================================
//	JWaterPrimitive::GetCollisionBoundingBox
//===========================================================================
FBox JWaterPrimitive::GetCollisionBoundingBox(const AActor *Owner ) const
{	
	return UPrimitive::GetCollisionBoundingBox( Owner );
}

//===========================================================================
// AGeoWater::AGeoWater
//===========================================================================
AGeoWater::AGeoWater() 
{
	// Allocate internal data
	InternalData = (INT)appMalloc(sizeof(WaterInternalData), TEXT("WaterInternalData"));
	appMemzero(WATER_INTERNALDATA(this), sizeof(WaterInternalData));
}

//===========================================================================
// AGeoWater::Destroy
//===========================================================================
void AGeoWater::Destroy() 
{
	if (InternalData)
	{
		appFree(WATER_INTERNALDATA(this));
		InternalData = NULL;
	}
		
	if (WATER_PRIMITIVE(this))
	{
		WATER_PRIMITIVE(this)->RemoveFromRoot();
		WATER_PRIMITIVE(this)->ConditionalDestroy();
		delete WATER_PRIMITIVE(this);
		WATER_PRIMITIVE(this) = NULL;
	}

	Super::Destroy();
}

//===========================================================================
//	WaterInternalTick
//===========================================================================
static void WaterInternalTick(AGetWater *Water, FLOAT DeltaTime)
{
}

//===========================================================================
//	DrawWater
//===========================================================================
void AGeoWater::DrawWater(void *VoidFrame)
{
}

//===========================================================================
//	CreatePrimitive
//===========================================================================
UPrimitive *CreatePrimitive(AGeoWater *Water)
{
    JWaterPrimitive		*Prim;

    if (!WATER_PRIMITIVE(Water))
    {
        UClass *Cls = JWaterPrimitive::StaticClass();
        Prim = (JWaterPrimitive*)UObject::StaticConstructObject(Cls, 
																UObject::GetTransientPackage(),
																NAME_None,
																RF_Transient,
																Cls->GetDefaultObject());
        WATER_PRIMITIVE(Water) = Prim;
        WATER_PRIMITIVE(Water)->WaterInstance = Water;

		Prim->AddToRoot();		// Don't delete me Unreal!!!
    }
    else
    {
        Prim = WATER_PRIMITIVE(Water);
    }

    FVector Extent(30, 30, 30);

	Prim->BoundingBox = FBox(Extent,Extent);	
    
    return Prim;
}

//====================================================================
//	AGeoWater::GetPrimitive - Returns a primitive for system collision
//====================================================================
UPrimitive *AGeoWater::GetPrimitive() const
{
#if 1
	if (!WATER_PRIMITIVE(this))
		CreatePrimitive(this);

	if (WATER_PRIMITIVE(this))
		return WATER_PRIMITIVE(this);
#endif

	return GetLevel()->Engine->Cylinder;
}

//
//	Script functions
//

//===========================================================================
// AGeoWater::execSplashWater
//===========================================================================
void AGeoWater::execSplashWater( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(Location);
	P_GET_FLOAT_OPTX(SplashScale, 1.0f);
	P_FINISH;
}

//===========================================================================
// AGeoWater::execInternalTick
//===========================================================================
void AGeoWater::execInternalTick( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(DeltaTime);
	P_FINISH;

	WaterInternalTick(this, DeltaTime);
}
