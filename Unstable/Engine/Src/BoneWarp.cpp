#include "EnginePrivate.h"

#include "..\..\Cannibal\CannibalUnr.h"

///////////////////////
// Bone Experiment   //
///////////////////////

//static VVec3 xAxisB( 1, 0, 0 );
//static VVec3 yAxisB( 0, 1, 0 );
//static VVec3 zAxisB( 0, 0, 1 );

void OCSRotate( VCoords3& ocs, VVec3& axis, float angle )
{
	ocs >>= VAxes3( axis, angle );
}

void BoneRotate( CMacBone *bone, VVec3& axis, float angle )
{
	VCoords3 base;
	VAxes3   rotAxes;

	rotAxes = VAxes3( axis, angle );

	base   = bone->GetCoords( true );
	base.r <<= rotAxes;
	bone->SetCoords( base, true );
}

extern void World2Bone ( CMacBone *bone, VCoords3& inWorldOCS );

static float wooj = 0.f;
void AActor::execNativeEvalSlack( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

    VVec3 xAxis( 1, 0, 0 );
    VVec3 yAxis( 0, 1, 0 );
    VVec3 zAxis( 0, 0, 1 );

	UDukeMeshInstance* dmi = Cast<UDukeMeshInstance>(MeshInstance);

	CMacBone* bone = dmi->Mac->FindBone("bicep_r");
	VCoords3  base = bone->GetCoords( true );

	/*
	VVec3 BonePoint = base.r.vY;
	VVec3 Perp = ~base.r.vY;
	Perp.Normalize();
	BonePoint.Normalize();
	VVec3 Down = VVec3( 0, 0, -1 );
	BonePoint = Down - BonePoint;
	BonePoint.Normalize();

	FLOAT Torque = Perp | BonePoint;

	if (Torque > 0.0)
		BoneRotate( bone, yAxis, 0.1 * Torque );
	else if (Torque < 0.0)
		BoneRotate( bone, yAxis, -0.1 * Torque );
*/
	VCoords3 world;
	OCSRotate( world, xAxis, wooj );

	base.r >>= world.r;

	bone->SetCoords( base, true );

/*
	VCoords3 world;
	BoneRotate( bone, xAxis, wooj );


	BoneRotate( bone, xAxis, wooj );
/*
	World2Bone( bone, world );
	OCSRotate( world, zAxis, PI/2 ); // Compute the net force of gravity on the bone:

	VAxes3 Temp;
	VQuat3 Blah = VAxes3();
	FLOAT alpha = wooj;
	if (alpha > 1.0)
		alpha = 1.0;
	Blah.Slerp( VQuat3(Base.r), VQuat3(world.r), 1.0f - alpha, alpha, true );
	Temp = Blah;
	Temp = VAxes3() >> Temp;
	Temp <<= Base.r;
	Blah = Temp;
	Base.r >>= Blah;

	bone->SetCoords( Base, false );
/*

	bone = dmi->Mac->FindBone("forearm_r");

	world = VCoords3();
	BoneRotate( bone, xAxis, wooj );

	Base = bone->GetCoords( true );

	OCSRotate( world, zAxis, PI/2 ); // Compute the net force of gravity on the bone:
//	World2Bone( bone, world );

	Temp = VAxes3();
	Blah = VAxes3();
	alpha = wooj;
	if (alpha > 1.0)
		alpha = 1.0;
	Blah.Slerp( VQuat3(Base.r), VQuat3(world.r), 1.0f - alpha, alpha, true );
	Temp = Blah;
	Temp = VAxes3() >> Temp;
	Temp <<= Base.r;
	Blah = Temp;
	Base.r >>= Blah;

	bone->SetCoords( Base, true );
*/
	wooj += 0.05f;
}
