// UnRenderIterator.cpp

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	URenderIterator.
-----------------------------------------------------------------------------*/

URenderIterator::URenderIterator()
:	Index( 0 ),
	Observer( NULL )
{
	check( GetOuter()->IsA( AActor::StaticClass() ) );

	// Check for binary compatibility.
    check(sizeof(URenderIterator)==URenderIterator::StaticClass()->GetPropertiesSize());
}

void URenderIterator::Init( APlayerPawn* Camera ) //override to initialize subclass data (call Super required)
{
//	Observer = Camera;
}

//void URenderIterator::UnInit()
//{
//}

void URenderIterator::First()
{
	Index = 0;
}

void URenderIterator::Next()
{
	Index++;
}

bool URenderIterator::IsDone() //override to adjust iteration termination criteria (call Super recommended)
{
	return Index >= MaxItems;
}

AActor* URenderIterator::CurrentItem() //override to adjust actor render properties based on Index (call Super recommended)
{
	return (AActor*)GetOuter();
}

// end of UnRenderIterator.cpp
