#include "EnginePrivate.h"
#include "Rope.h"

#include "..\..\Cannibal\CannibalUnr.h"

#define m_baseBoneCoords ((VCoords3 *)(m_baseBoneCoords))

static VVec3 xAxis( 1, 0, 0 );
static VVec3 yAxis( 0, 1, 0 );
static VVec3 zAxis( 0, 0, 1 );

IMPLEMENT_CLASS(ABoneRope);
IMPLEMENT_CLASS(RopePrimitive);

#define ROPE_CYLINDERS(p) ((Cylinder*)p->m_ropeCylinders)

#pragma warning(disable:4714)

// JEP ...
//====================================================================
//	UpdateRopeRenderBox
//====================================================================
static void UpdateRopeRenderBox(ABoneRope *Rope)
{
	UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>(Rope->GetMeshInstance() );

    if (!MeshInst || !MeshInst->Mac)
        return;
	
	FVector *Min = &MeshInst->Mac->mDukeBounds[0];
	FVector *Max = &MeshInst->Mac->mDukeBounds[1];

#if 1
    NDword		i;
    VCoords3	BoneLoc;
    NDword		BoneCount  = MeshInst->Mac->mActorBones.GetCount();
    CMacBone	*Bone      = MeshInst->Mac->mActorBones.GetData();

	for (i=0; i<BoneCount; i++, Bone++)
	{
		BoneLoc = Bone->GetCoords(true);
		FVector Origin(*(FVector*)&BoneLoc.t);
		Origin = Origin.ToUnr();

        if (i == 0)
		{
			*Min = *Max = Origin;
			continue;
		}

		if (Origin.X > Max->X)
			Max->X = Origin.X;
        else if (Origin.X < Min->X)
			Min->X = Origin.X;
		
		if (Origin.Y > Max->Y)
			Max->Y = Origin.Y;
        else if (Origin.Y < Min->Y)
			Min->Y = Origin.Y;
		
		if (Origin.Z > Max->Z)
			Max->Z = Origin.Z;
        else if (Origin.Z < Min->Z)
			Min->Z = Origin.Z;
    }
	
	float HalfRadius = Rope->m_ropeRadius*0.5f;

	Min->X -= HalfRadius;
	Min->Y -= HalfRadius;
	
	Max->X += HalfRadius;
	Max->Y += HalfRadius;
#else
	*Min = FVector(-Rope->m_ropeRadius,-Rope->m_ropeRadius,0);//Rope->m_ropeLength);
	*Max = FVector( Rope->m_ropeRadius, Rope->m_ropeRadius,Rope->m_ropeLength);
#endif
}
// ... JEP

//====================================================================
//RotateOCS - Rotate an OCS about an axis by the specified angle
//====================================================================
void RotateOCS
    (
    VCoords3&   ocs, 
    VVec3       axis,
    float       angle
    )
{
    ocs >>= VAxes3( axis, angle );
}

//====================================================================
//RotateBone - Rotates the specified bone around the passed in axis and angle
//====================================================================
void RotateBone
    (
    CMacBone *bone,
    VVec3    axis,
    float    angle
    )

{
    VCoords3 base;
    VAxes3   rotAxes;

    rotAxes = VAxes3( axis, angle );

    base   = bone->GetCoords( false );
    base.r <<= rotAxes;
    bone->SetCoords( base, false );
}


//====================================================================
//RotateBone - Converts a world OCS into the OCS of the bone
//====================================================================
void World2Bone
    (
    CMacBone    *bone,
    VCoords3&   inWorldOCS
    )
{
	VCoords3 tempCoord;

	for (CMacBone *b = bone->mParent; b; b = b->mParent )
    {
        tempCoord <<= b->GetCoords(false);
    }
	inWorldOCS >>= tempCoord;
}

#if 0
//====================================================================
//Bone2World
//====================================================================
static void Bone2World
    (
    CMacBone *bone,
    VCoords3& myBaseWorld
    )
{
	myBaseWorld = bone->GetCoords(false);

	for (CMacBone* b = bone->mParent; b; b = b->mParent )
    {
		myBaseWorld <<= b->GetCoords(false);
    }
}
#endif

//====================================================================
//ABoneRope::ABoneRope
//====================================================================
ABoneRope::ABoneRope() 
{
	m_ropeCylinders=0;
}

//====================================================================
//ABoneRope::UpdateCylinders - Update the location and orientation of the
//bounding cylinders on the rope which are used for collision
//====================================================================
void ABoneRope::UpdateCylinders
    (
    void
    )

{
    FCoords boneLoc1, boneLoc2;

    UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>( GetMeshInstance() );

	if( !MeshInst || !m_ropeCylinders )
		return;

    NDword   BoneCount  = MeshInst->Mac->mActorBones.GetCount();
    CMacBone *bone      = MeshInst->Mac->mActorBones.GetData();
    CMacBone *nextBone  = NULL;
    
    NDword  i;
    if ( BoneCount > 1 )
    {
        nextBone = bone+1;

        for ( i=0; i<BoneCount-1; i++,bone++,nextBone++ )
        {
            FVector axis;
            FLOAT   height;

            MeshInst->GetBoneCoords( bone,     boneLoc1 );
            MeshInst->GetBoneCoords( nextBone, boneLoc2 );
            boneLoc1 = boneLoc1.Transpose();            
            boneLoc2 = boneLoc2.Transpose();	
            
            axis = boneLoc2.Origin - boneLoc1.Origin;
            axis.Normalize();
            height = FDist( boneLoc1.Origin, boneLoc2.Origin );

            // Update the cylinder
            ((Cylinder *)(m_ropeCylinders)+i)->setOrigin( boneLoc1.Origin );
            ((Cylinder *)(m_ropeCylinders)+i)->setAxis( axis );
            ((Cylinder *)(m_ropeCylinders)+i)->setHeight( height );
        }
    }
}

void ABoneRope::Destroy()
{
	debugf( TEXT(" ABoneRope::Destroy() : %X" ), m_ropeCylinders );

	if ( m_ropeCylinders )
	{
		appFree( (void *)m_ropeCylinders );
		//GMalloc->HeapCheck();
		//free( (void *)m_ropeCylinders );
		m_ropeCylinders = 0;
	}

	Super::Destroy();
}

//====================================================================
//ABoneRope::InitializeRope - Initializes the Rope and it's bounding
//cylinders.  This can be called multiple times to change the cylinders (i.e. for netplay)
//====================================================================
void ABoneRope::InitializeRope
    (
    void
    )

{
    NDword  i;
    FCoords boneLoc1, boneLoc2;
    
    // Initialize all the rope stuff
	UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>( GetMeshInstance() );

    if ( !MeshInst )
        return;

    NDword   BoneCount  = MeshInst->Mac->mActorBones.GetCount();
    CMacBone *bone      = MeshInst->Mac->mActorBones.GetData();

    VCoords3 &myBase = bone->GetCoords( false );
    FVector v( 1,1,1 );
    
    v.X *= m_ropeScale;
    v.Y = -v.Y;
	v = v.ToStd();
	myBase.s = *(VVec3*)&v;
    bone->SetCoords( myBase, false );

    // Initialize collision cylinders    
    bone  = MeshInst->Mac->mActorBones.GetData();
    CMacBone *nextBone  = NULL;

    // Only if there's more than 1 bone
    if ( BoneCount > 1 )
    {
        VCoords3 &myBase = bone->GetCoords( true );

        m_baseBoneCoords->r  = myBase.r;
        m_baseBoneCoords->s  = myBase.s;
        m_baseBoneCoords->t  = myBase.t;

        nextBone = bone+1;

        // Allocate memory for cylinders
        if ( !m_ropeCylinders )
        {
            //Cylinder *tc = new Cylinder[ BoneCount ];

			Cylinder *tc = (Cylinder *)appMalloc( sizeof( Cylinder ) * BoneCount, TEXT("Cylinder") );			
			//Cylinder *tc = (Cylinder *)malloc( sizeof( Cylinder ) * BoneCount );
            m_ropeCylinders = (INT)tc;
			debugf( TEXT(" ABoneRope::InitializeRope() : %X - %d bytes" ), m_ropeCylinders, sizeof( Cylinder ) * BoneCount );
			GMalloc->HeapCheck();
        }
		
		m_ropeLength = 0;

        for ( i=0; i<BoneCount-1; i++,bone++,nextBone++ )
        {
            MeshInst->GetBoneCoords( bone, boneLoc1 );
            MeshInst->GetBoneCoords( nextBone, boneLoc2 );
            boneLoc1 = boneLoc1.Transpose();            
            boneLoc2 = boneLoc2.Transpose();

            FLOAT   height;
            FVector axis = boneLoc2.Origin - boneLoc1.Origin;
            axis.Normalize();
            height = FDist( boneLoc1.Origin, boneLoc2.Origin );
            
            ((Cylinder *)(m_ropeCylinders)+i)->setOrigin( boneLoc1.Origin );
            ((Cylinder *)(m_ropeCylinders)+i)->setAxis( axis );
            ((Cylinder *)(m_ropeCylinders)+i)->setRadius( m_ropeRadius );
            ((Cylinder *)(m_ropeCylinders)+i)->setHeight( height );
            
            m_ropeLength += height;
        }
    }
    else
    {
        debugf( TEXT("ABoneRope::Initialize: Invalid rope, must have more than 1 bone") );
        this->Destroy();
    }
	
	UpdateRopeRenderBox(this);		// JEP
}

//====================================================================
//ABoneRope::execInitializeRope - Initializes the Rope and it's bounding
//cylinders
//====================================================================
void ABoneRope::execInitializeRope
    (
    FFrame& Stack,
    RESULT_DECL
    )

{
    P_FINISH;
    InitializeRope();
}

//====================================================================
//ABoneRope::GetBoneFromHandle
//====================================================================
void *ABoneRope::GetBoneFromHandle( int handle )
{
    if ( handle < 0 )
        return NULL;

    UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>( GetMeshInstance() );

    if ( !MeshInst )
    {
        return NULL;
    }

    CMacBone *bone = MeshInst->Mac->mActorBones.GetData();    
    return bone + handle;
}

//====================================================================
//ABoneRope::GetHandleFromBone
//====================================================================
INT ABoneRope::GetHandleFromBone( void *bone )
{
	UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>( GetMeshInstance() );

    if ( !MeshInst )
        return -1;

    if ( !bone )
        return -1;

    return( ( CMacBone*)(bone) - MeshInst->Mac->mActorBones.GetData() );
}

//====================================================================
//ABoneRope::execCheckCollision - Check to see if the ray collides with
//the rope.  Returns a pointer to the bone on the rope that was hit.
//====================================================================
void ABoneRope::execCheckCollision
    (
    FFrame& Stack,
    RESULT_DECL
    )

{
    VVec3          xAxis( 1, 0, 0 );
    VVec3          yAxis( 0, 1, 0 );
    VVec3          zAxis( 0, 0, 1 );

    P_GET_VECTOR(point);
    P_GET_VECTOR(dir);
    P_GET_FLOAT(max_distance);
    P_FINISH;

    *(INT*)Result = 0;

	UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>( GetMeshInstance() );

    if ( !MeshInst || !m_ropeCylinders )
    {
        *(INT*)Result = 0;
        return;
    }

    // Check to see if this ray hits the rope
    NDword   BoneCount  = MeshInst->Mac->mActorBones.GetCount();
    CMacBone *bone      = MeshInst->Mac->mActorBones.GetData();
    
    for ( NDword i=0; i<BoneCount; i++,bone++ )
    {
        FLOAT distance;
        UBOOL ret;

        ret = ((Cylinder *)(m_ropeCylinders)+i)->Intersect( point, dir, &distance );

        if ( ret && ( distance > 0 ) && ( distance < max_distance ) )
        {
            *(INT*)Result = (INT)i;  // return index of the bone
            return;
        }
    }

    // No bone hit
    *(INT*)Result = 0;
}

//======================================================================
//ABoneRope::GetRiderPosition
//Returns a value of from 0 to 1.0 based on the distance that the rider is
//away from the base of the rope.  
//======================================================================
FLOAT ABoneRope::GetRiderPosition
    (
    void
    )

{
    if ( !m_Rider )
        return 0;

    FVector delta = m_Rider->Location - Location;
    return ( delta.Size() / m_ropeLength );
}

//====================================================================
//ABoneRope::CalculateDirectionVector - Calculates a vector based on the
//angular displacement of the rope
//====================================================================
FVector ABoneRope::CalculateDirectionVector
   (
   void
   )

   {
   FVector dir;

   // convert the angular displacement into a vector
   dir.X = sin( m_angularDisplacement.X );
   dir.Y = sin( m_angularDisplacement.Y );
   dir.Z = -1;
   dir.Normalize();

   return dir;
   }

void CheapBroadcastMessage(AActor* inActor, TCHAR* inFmt, ... )
{ 
	static TCHAR buf[256];
	GET_VARARGS( buf, ARRAY_COUNT(buf), inFmt );
	inActor->Level->eventBroadcastMessage(FString(buf),0,NAME_None);
}

//====================================================================
//ABoneRope::execOnRope - Called when a player gets on the rope
//====================================================================
void ABoneRope::execOnRope( FFrame& Stack, RESULT_DECL )
{
    P_FINISH;
    
    // Give the rope a bit of a push in the direction that the player is moving, so 
    // it feels like the rope is moving a bit
    if ( m_Rider )
    {
        m_angularVelocity.X += m_Rider->Velocity.X * m_angularInputVelocityScale / m_ropeLength;
        m_angularVelocity.Y += m_Rider->Velocity.Y * m_angularInputVelocityScale / m_ropeLength;
    }
    m_swingStateAway = true;
}

//====================================================================
//ABoneRope::execDamageRope - Damage to a rope - passes in a location and a dir
//====================================================================
void ABoneRope::execDamageRope( FFrame& Stack, RESULT_DECL )
{
    P_GET_VECTOR( hitLocation );
    P_GET_VECTOR( hitDirection );
    P_FINISH;

    return;

    /*
    if ( m_lastHitTime + 0.1 > Level->TimeSeconds )
        return;

    m_lastHitTime = Level->TimeSeconds;

    // Find the bone that is closest to this location
    UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>( GetMeshInstance() );

    if ( !MeshInst )
        return;
   
    if ( m_Rider )
        return;

    CMacBone    *bone          = MeshInst->Mac->mActorBones.GetData();
    NDword      BoneCount      = MeshInst->Mac->mActorBones.GetCount();
    CMacBone    *topBone       = bone;
    CMacBone    *closestBone   =NULL;
    FLOAT       closestDistance=9999999;
    
    for ( NDword i=0; i<BoneCount; i++,bone++ )
    {   
        FCoords boneLoc;
        MeshInst->GetBoneCoords( bone, boneLoc );
        boneLoc = boneLoc.Transpose();

        FLOAT distance = (hitLocation - boneLoc.Origin).Size();

        if ( distance < closestDistance )
        {
            closestDistance = distance;
            closestBone     = bone;
        }
    }

    if ( closestBone )
    {
        hitDirection.Normalize();
        hitDirection *= 0.7;

        FRotator rot = hitDirection.Rotation();
        
        VCoords3 &myBase = closestBone->GetCoords( false );

        VAxes3 rotAxes = VAxes3( xAxis, hitDirection.X );
        myBase.r <<= rotAxes;
        rotAxes = VAxes3( zAxis, hitDirection.Y );
        myBase.r <<= rotAxes;

        closestBone->SetCoords( myBase, false );
        
        bone = closestBone;

        // Starting with this bone and moving upwards, put a fraction of the impulse onto it.
        while ( bone != topBone )
        {
            bone--;
            hitDirection *= 0.75;
            VCoords3 &myBase = bone->GetCoords( false );

            VAxes3 rotAxes = VAxes3( xAxis, hitDirection.X );
            myBase.r <<= rotAxes;
            rotAxes = VAxes3( zAxis, hitDirection.Y );
            myBase.r <<= rotAxes;

            bone->SetCoords( myBase, false );
        } 

        m_riderBoneHandle = -1; // So rope doesn't straighten out automatically
    }
    */
}

//====================================================================
//ABoneRope::GetPlayerPositionFactor
//Figure out where the player is and return a factor.
//0 is top of the rope, and 1 is bottom.
//====================================================================
void ABoneRope::execGetPlayerPositionFactor( FFrame& Stack, RESULT_DECL )
{
    P_FINISH;

    UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>( GetMeshInstance() );

    if ( !MeshInst )
    {
        *(FLOAT*)Result = 0;
        return;
    }

    if ( !m_Rider )
    {
        *(FLOAT*)Result = 0;
        return;
    }

    CMacBone *playerBone = (CMacBone*)GetBoneFromHandle(m_Rider->boneRopeHandle);
    
    CMacBone *bone   = MeshInst->Mac->mActorBones.GetData();
    NDword BoneCount = MeshInst->Mac->mActorBones.GetCount();

    // Search for the bone
    for ( NDword i=0; i<BoneCount; i++,bone++ )
    {
        if ( playerBone == bone )
            break;
    }

    if ( i == BoneCount ) // Bone not found
    {
        *(FLOAT*)Result = 0;
        return;
    }
    else
    {
        *(FLOAT*)Result = (FLOAT) i / (FLOAT)BoneCount;
        return;
    }
}

void ABoneRope::execDoBoneRope( FFrame& Stack, RESULT_DECL )
{
    P_GET_FLOAT(deltaTime);
    P_GET_UBOOL(action);
    P_FINISH;
    
    DoBoneRope( deltaTime, action );
}

//====================================================================
//ABoneRope::execDoBoneRope - The main thinking function of the rope. 
//This will take care of all the swinging and effects of gravity on the rope.
//====================================================================
void ABoneRope::DoBoneRope( FLOAT deltaTime, UBOOL action )
{
	static UBOOL    initialized=false;
    FCoords         boneLoc1, boneLoc2;
    NDword          i=0;
    static VQuat3   acceleration[MAX_ROPE_SEGMENTS];
    static UBOOL    initaccel=false;
    FLOAT           MyDot;

    // Intitialize the acceleration array
    if ( !initaccel )
    {
        initaccel = true;
        for ( i=0; i<MAX_ROPE_SEGMENTS; i++ )
        {
            acceleration[i] = VAxes3();
        }
    }

    UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>( GetMeshInstance() );

    if ( !MeshInst )
        return;
    
	m_oldAngularDisplacement = m_angularDisplacement;

    if ( bSwingable ) // Do the rope swinging
    {   
        FLOAT       riderPosition=0.5;
        FLOAT       impulseSpeed[ 2 ]={0,0};
                
        //if ( Role==ROLE_Authority )
        {
            // Update the displacement based on the angular velocity
            m_angularDisplacement += m_angularVelocity * deltaTime; 

            // Clamps
            if ( m_angularDisplacement.X > m_maxAngularDisplacement )
                m_angularDisplacement.X = m_maxAngularDisplacement;
            else if ( m_angularDisplacement.X < -m_maxAngularDisplacement )
                m_angularDisplacement.X = -m_maxAngularDisplacement;
            if ( m_angularDisplacement.Y > m_maxAngularDisplacement )
                m_angularDisplacement.Y = m_maxAngularDisplacement;
            else if ( m_angularDisplacement.Y < -m_maxAngularDisplacement )
                m_angularDisplacement.Y = -m_maxAngularDisplacement;

            if ( m_Rider ) // We have a rider
            {
                FVector     endpos;

                m_riderBoneHandle = m_Rider->boneRopeHandle;

                // Check to see if the rider is looking up or down, that will make the rope not move
                MyDot = m_Rider->ViewRotation.Vector() | FVector( 0,0,1 );
                if ( ( MyDot < m_lookThreshold ) || ( MyDot > -m_lookThreshold ) )
                {
                    // add impulse velocity to the base velocity
                    impulseSpeed[0] = cos( m_angularDisplacement.X ) * m_Rider->Velocity.X * m_angularInputVelocityScale / m_ropeLength;
                    impulseSpeed[1] = cos( m_angularDisplacement.Y ) * m_Rider->Velocity.Y * m_angularInputVelocityScale / m_ropeLength;
                }

                // Clamps
                if ( impulseSpeed[0] > m_maxAngularInputVelocity )
                    impulseSpeed[0] = m_maxAngularInputVelocity;
                else if ( impulseSpeed[0] < -m_maxAngularInputVelocity )
                    impulseSpeed[0] = -m_maxAngularInputVelocity;
                if ( impulseSpeed[1] > m_maxAngularInputVelocity )
                    impulseSpeed[1] = m_maxAngularInputVelocity;
                else if ( impulseSpeed[1] < -m_maxAngularInputVelocity )
                    impulseSpeed[1] = -m_maxAngularInputVelocity;            
            
                m_angularVelocity.X += impulseSpeed[0];
                m_angularVelocity.Y += impulseSpeed[1];            
            }
            // adjust x and y velocities to swing back to center
            m_angularVelocity.X += ( -sin( m_angularDisplacement.X ) * m_ropeSpeed ) / m_ropeLength;
            m_angularVelocity.Y += ( -sin( m_angularDisplacement.Y ) * m_ropeSpeed ) / m_ropeLength;
        } // ROLE == Role_Authority

        // apply some friction to the velocity to slow the rope down
        if ( m_Rider )
        {
            FLOAT size;

            m_Rider->Velocity = FVector( 0,0,0 ); // Zero out the Rider's velocity
            m_angularVelocity *= m_angularFriction;

            size = m_angularVelocity.Size();

            if ( Level->TimeSeconds > ( m_lastRopeSoundTime + 2.0 ) )
            {
                if ( m_angularDisplacement.Size() > 0.02 ) // Don't creak near 0 displacement
                {            
                    if ( m_swingStateAway ) // swinging away from center
                    {
                        if ( size < m_lastSwingSize ) // detect swinging back towards center
                        {
                            m_swingStateAway = false;
                            m_lastRopeSoundTime = Level->TimeSeconds;
                            eventPlaySwingSound();
                        }
                    }
                    else // Swinging toward center
                    {
                        if ( size > m_lastSwingSize ) // detect swinging away from center
                        {
                            m_swingStateAway = false;
                            m_lastRopeSoundTime = Level->TimeSeconds;
                            eventPlaySwingSound();
                        }
                    }
                }
            }

            m_lastSwingSize = size;
        }
        else
        {
            m_angularVelocity *= m_angularFrictionNoRider;
        }


#define SMALL_DISPLACEMENT 0.005
		// Early out
		if ( !m_Rider &&
			( m_angularDisplacement.X <= SMALL_DISPLACEMENT && m_angularDisplacement.X >= -SMALL_DISPLACEMENT ) &&
		    ( m_angularDisplacement.Y <= SMALL_DISPLACEMENT && m_angularDisplacement.Y >= -SMALL_DISPLACEMENT )
		   )
			return;

		if ( !m_Rider && 
			( m_angularVelocity.X <= SMALL_DISPLACEMENT && m_angularVelocity.X >= -SMALL_DISPLACEMENT ) &&
		    ( m_angularVelocity.Y <= SMALL_DISPLACEMENT && m_angularVelocity.Y >= -SMALL_DISPLACEMENT )
		   )
		{
			m_angularVelocity.X = 0;
			m_angularVelocity.Y = 0;
		   return;
		}

        VAxes3    rotAxes;
        CMacBone* bone      = MeshInst->Mac->mActorBones.GetData();
        NDword    BoneCount = MeshInst->Mac->mActorBones.GetCount();
        UBOOL     pastRider = false;

        // Rotate first bone to the angular displacement determined above
        VCoords3 &myBase = bone->GetCoords( true );
        myBase.r = m_baseBoneCoords->r;
        rotAxes = VAxes3( xAxis, ( m_angularDisplacement.X ) );        
        myBase.r <<= rotAxes;
        rotAxes = VAxes3( zAxis, ( m_angularDisplacement.Y ) );
        myBase.r <<= rotAxes;
        bone->SetCoords( myBase, true );

        NDword skip = 1;
        bone++;

        // Go through the rest of the bones and adjust their orientation due to gravity
        for ( NDword i=0; i<BoneCount-skip; i++, bone++ )
        {
            FCoords     boneStartLoc;
            VAxes3      accelerationFrame;
            VCoords3    &myBase = bone->GetCoords( false );
            VCoords3    world;
            VAxes3      temp;

            // Wait till we get past the rider to modify the rest of the rope            
            if ( !pastRider )  // false if we haven't passed the rider yet
            {                                    
                if ( m_Rider && ( ( GetBoneFromHandle( m_Rider->boneRopeHandle ) ) == bone ) )  // if there is a rider and his handle == the current bone
                {
                    pastRider = true;
                }
                else if ( ( m_riderBoneHandle < 0 ) || ( (CMacBone*)GetBoneFromHandle( m_riderBoneHandle ) == bone ) )
                {
                    pastRider = true;
                }
                else 
                {
                    if ( i == 0 )
                    {                    
                        VCoords3    &myBase = bone->GetCoords( false );
                        VCoords3 temp( myBase );
                        temp.r.vX.x = 1; temp.r.vX.y = 0; temp.r.vX.z = 0;
                        temp.r.vY.x = 0; temp.r.vY.y = 1; temp.r.vY.z = 0;
                        temp.r.vZ.x = 0; temp.r.vZ.y = 0; temp.r.vZ.z = 1;
                        bone->SetCoords( temp, false );
                    }
                    else
                    {
                        VCoords3    &myBase = bone->GetCoords( false );
                        VCoords3 temp( myBase );
                        temp.r.vX.x = 1; temp.r.vX.y = 0; temp.r.vX.z = 0;
                        temp.r.vY.x = 0; temp.r.vY.y = 1; temp.r.vY.z = 0;
                        temp.r.vZ.x = 0; temp.r.vZ.y = 0; temp.r.vZ.z = 1;
                        bone->SetCoords( temp, false );
                    }

#if 0 
                    debugf( TEXT("ONBONE:%s (%0.2f,%0.2f,%0.2f) (%0.2f,%0.2f,%0.2f) (%0.2f,%0.2f,%0.2f)" ), 
                            bone->mSklBone->name, 
                            myBase.r.vX.x, myBase.r.vX.y, myBase.r.vX.z,
                            myBase.r.vY.x, myBase.r.vY.y, myBase.r.vY.z,
                            myBase.r.vZ.x, myBase.r.vZ.y, myBase.r.vZ.z );
#endif
                    continue;
                }
            }

            RotateOCS( world, xAxis, -PI/2 ); // Compute the net force of gravity on the bone:
            World2Bone( bone, world );	      // Transform into the bone space            

            // Compute my delta angular acceleration
            FLOAT alpha = deltaTime * 2;
            acceleration[i].Slerp( VQuat3(myBase.r), VQuat3(world.r), 1.0 - alpha, alpha, true );
            accelerationFrame   = acceleration[i];

            accelerationFrame   = VAxes3() >> accelerationFrame;
            accelerationFrame <<= myBase.r;
            acceleration[i]     = accelerationFrame;

            myBase.r >>= acceleration[i];
            bone->SetCoords( myBase, false );
        }

    }
    UpdateCylinders(); // Update the collision of the cylinders

	UpdateRopeRenderBox(this);		// JEP: Update RenderBBox
}

//====================================================================
//ABoneRope::RiderHitSolid - Rider hit a solid object.  Take all velocity
//away from the rope and let gravity return it to center.  Also don't do this
//more than once a second.
//====================================================================
void ABoneRope::RiderHitSolid
    (
    void
    )

{
    if ( m_lastHitTime + 1 > Level->TimeSeconds )
        return;

    m_lastHitTime = Level->TimeSeconds;

    // Zero the velocity and set to the old displacement so we don't get a jerk
    if ( m_Rider )
    {
        m_Rider->Velocity *= -1;
    }

    m_angularVelocity *= 0;
    m_angularDisplacement = m_oldAngularDisplacement;

    // Do the rope to update it to the new velocity    
    DoBoneRope( 1, false ); 
}

//====================================================================
//ABoneRope::CreatePrimitive
//====================================================================
UPrimitive *ABoneRope::CreatePrimitive
    (
    void
    )

{
    RopePrimitive   *rp;
	FVector			TLoc;

    InitializeRope();

    //m_Location2 = Location;
    //m_Location2.Z *= m_ropeScale - 1;
	// JEP: This code was mucking up m_Location2, when script code was setting it up instead
	TLoc = Location;
    TLoc *= m_ropeScale - 1;

    if ( !m_ropePrimitive )
    {
        UClass *Cls = RopePrimitive::StaticClass();
        rp = (RopePrimitive*)StaticConstructObject( Cls, 
                                                    GetTransientPackage(),
                                                    NAME_None,
                                                    RF_Transient,
                                                    Cls->GetDefaultObject()
                                                  );
        m_ropePrimitive = (INT)rp;
        rp->m_RopeInstance = this;
		rp->AddToRoot();  // Unreal don't delete me!
    }
    else
    {
        rp = (RopePrimitive*)m_ropePrimitive;
    }

    // Create the bounding box for the primitive
    FVector extent,pos;
    extent = FVector( CollisionRadius, CollisionRadius, m_ropeLength/2 );
    
    // Calculate center of the rope
    //pos = m_Location2 - FVector(0,0,1) * m_ropeLength * 0.5;		// JEP: Commented out
    pos = TLoc - FVector(0,0,1) * m_ropeLength * 0.5;				// JEP
    rp->BoundingBox = FBox( pos - extent, pos + extent );	
    
    return rp;
}

//====================================================================
//ABoneRope::execRecreatePrimitive
//====================================================================
void ABoneRope::execRecreatePrimitive( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

    CreatePrimitive();
}

//====================================================================
//ABoneRope::execAddRope
//====================================================================
void ABoneRope::execAddRope( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	m_nextRope = GetLevel()->GetLevelInfo()->RopeList;
	GetLevel()->GetLevelInfo()->RopeList = this;
}

//====================================================================
//ABoneRope::execRemoveRope
//====================================================================
void ABoneRope::execRemoveRope( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;

	ABoneRope *next = GetLevel()->GetLevelInfo()->RopeList;
	
    if ( next == this )
    {
		GetLevel()->GetLevelInfo()->RopeList = next->m_nextRope;
    }
	else
	{
		while ( next )
		{
			if ( next->m_nextRope == this )
			{
				next->m_nextRope = m_nextRope;
				break;
			}
			next = next->m_nextRope;
		}
	}
}

//====================================================================
//ABoneRope::GetPrimitive - Returns a primitive for system collision
//====================================================================
UPrimitive *ABoneRope::GetPrimitive() const
{
    if ( m_ropePrimitive )
    {
        return (RopePrimitive *)m_ropePrimitive;
    }

    // primitive doesn't exist, so create a primitve
    RopePrimitive *rp = (RopePrimitive*)((ABoneRope*)this)->CreatePrimitive();

    if ( rp )
        return rp;

    return(GetLevel()->Engine->Cylinder);
}


//====================================================================
//RopePrimitive::PointCheck
//====================================================================
UBOOL RopePrimitive::PointCheck
    (
    FCheckResult& Result,
    AActor* Owner,
    FVector Location,
    FVector Extent,
    DWORD ExtraNodeFlags
    )
{
    return UPrimitive::PointCheck( Result,Owner,Location,Extent,ExtraNodeFlags );
}

//====================================================================
//RopePrimitive::LineCheck - This has been hacked to only use the 
//bMeshAccurate flag (when a gun is being fired).  We don't care about
//any of the other traces
//====================================================================
UBOOL RopePrimitive::LineCheck
    (
    FCheckResult& Result,
    AActor* Owner,
    FVector End,
    FVector Start,
    FVector Extent,
    DWORD ExtraNodeFlags,
    UBOOL bMeshAccurate
    )
{
    UBOOL ret;
    
    if ( !bMeshAccurate || !m_RopeInstance || !m_RopeInstance->m_ropeCylinders || m_RopeInstance->m_Rider )
        return true;

    UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>( m_RopeInstance->GetMeshInstance() );

    if ( !MeshInst || !m_RopeInstance || !m_RopeInstance->m_ropeCylinders )
        return true;

    // Check to see if this ray hits any of the rope cylinders
    NDword   BoneCount   = MeshInst->Mac->mActorBones.GetCount();
    CMacBone *bone       = MeshInst->Mac->mActorBones.GetData();
    FVector  Dir         = End-Start;
    FLOAT    maxDistance = Dir.Size();
    FLOAT    inDist, outDist;
    
    Dir.Normalize();
    
    for ( NDword i=0; i<BoneCount; i++,bone++ )
    {
        ret = ((Cylinder *)(m_RopeInstance->m_ropeCylinders)+i)->Intersect( Start, Dir, &inDist, &outDist );

        if ( ret && ( inDist > 0 ) && ( inDist < maxDistance ) )
        {
            Result.Time         = inDist/maxDistance;
			Result.Location     = Start + Dir * inDist;
			Result.Normal       = ((Start-Owner->Location)*FVector(1,1,0)).SafeNormal();
			Result.Actor        = Owner;
			Result.Primitive    = NULL;
			Result.MeshBoneName = NAME_None;
			Result.MeshTri      = -1;
			Result.MeshBarys    = FVector(0.33,0.33,0.34);
			Result.MeshTexture  = NULL;		
            return false;
        }
    }
    return true;
}

//====================================================================
//RopePrimitive::GetRenderBoundingBox
//====================================================================
FBox RopePrimitive::GetRenderBoundingBox
    (
    const AActor* Owner,
    UBOOL Exact
    )

{	
#if 1
	// JEP ... New way
    // Get the mesh instance from the Rope
	UDukeMeshInstance* MeshInst = Cast<UDukeMeshInstance>( m_RopeInstance->GetMeshInstance() );

	if (!MeshInst)		// If we don't have an instance, then return the generic version (we should always have one though in practice)
		return UPrimitive::GetRenderBoundingBox( Owner, Exact );

	//UpdateRopeRenderBox(m_RopeInstance);		

	// Return the meshes bounding box
	return MeshInst->GetRenderBoundingBox(Owner, Exact);
	// ... JEP
#else
	// Old way
	return UPrimitive::GetRenderBoundingBox( Owner, Exact );
#endif
}

//====================================================================
//RopePrimitive::GetCollisionBoundingBox
//====================================================================
FBox RopePrimitive::GetCollisionBoundingBox( const AActor* Owner ) const
{	
    return UPrimitive::GetCollisionBoundingBox( Owner );
}
 
void ABoneRope::Spawned()
{}
