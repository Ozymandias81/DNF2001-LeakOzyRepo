/*=============================================================================
	UnClass.cpp: Object class implementation.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "..\..\Engine\Src\EnginePrivate.h"

#define VF_HASH_VARIABLES 0 /* Undecided!! */

/*-----------------------------------------------------------------------------
	FPropertyTag.
-----------------------------------------------------------------------------*/

//
// A tag describing a class property, to aid in serialization.
//
struct FPropertyTag
{
	// Archive for counting property sizes.
	class FArchiveCountSize : public FArchive
	{
	public:
		FArchiveCountSize( FArchive& InSaveAr )
		: Size(0), SaveAr(InSaveAr)
		{
			ArIsSaving     = InSaveAr.IsSaving();
			ArIsPersistent = InSaveAr.IsPersistent();
		}
		INT Size;
	private:
		FArchive& SaveAr;
		FArchive& operator<<( UObject*& Obj )
		{
			INT Index = SaveAr.MapObject(Obj);
			return *this << AR_INDEX(Index);
		}
		FArchive& operator<<( FName& Name )
		{
			INT Index = SaveAr.MapName(&Name);
			return *this << AR_INDEX(Index);
		}
		void Serialize( void* V, INT Length )
		{
			Size += Length;
		}
	};

	// Variables.
	BYTE	Type;		// Type of property, 0=end.
	BYTE	Info;		// Packed info byte.
	FName	Name;		// Name of property.
	FName	ItemName;	// Struct name if UStructProperty.
	INT		Size;       // Property size.
	INT		ArrayIndex;	// Index if an array; else 0.

	// Constructors.
	FPropertyTag()
	{}
	FPropertyTag( FArchive& InSaveAr, UProperty* Property, INT InIndex, BYTE* Value )
	:	Type		( Property->GetID() )
	,	Name		( Property->GetFName() )
	,	ItemName	( NAME_None     )
	,	Size		( 0             )
	,	ArrayIndex	( InIndex       )
	,	Info		( Property->GetID() )
	{
		// Handle structs.
		UStructProperty* StructProperty = Cast<UStructProperty>( Property );
		if( StructProperty )
			ItemName = StructProperty->Struct->GetFName();

		// Set size.
		FArchiveCountSize ArCount( InSaveAr );
		SerializeTaggedProperty( ArCount, Property, Value );
		Size = ArCount.Size;

		// Update info bits.
		Info |=
		(	Size==1		? 0x00
		:	Size==2     ? 0x10
		:	Size==4     ? 0x20
		:	Size==12	? 0x30
		:	Size==16	? 0x40
		:	Size<=255	? 0x50
		:	Size<=65536 ? 0x60
		:			      0x70);
		UBoolProperty* Bool = Cast<UBoolProperty>( Property );
		if( ArrayIndex || (Bool && (*(BITFIELD*)Value & Bool->BitMask)) )
			Info |= 0x80;
	}

	// Serializer.
	friend FArchive& operator<<( FArchive& Ar, FPropertyTag& Tag )
	{
		static TCHAR PrevTag[NAME_SIZE]=TEXT("");
		BYTE SizeByte;
		_WORD SizeWord;
		INT SizeInt;

		// Name.
		Ar << Tag.Name;
		if( Tag.Name == NAME_None )
			return Ar;
		appStrcpy( PrevTag, *Tag.Name );

		// Packed info byte:
		// Bit 0..3 = raw type.
		// Bit 4..6 = serialized size: [1 2 4 12 16 byte word int].
		// Bit 7    = array flag.
		Ar << Tag.Info;
		Tag.Type = Tag.Info & 0x0f;
		if( Tag.Type == NAME_StructProperty )
			Ar << Tag.ItemName;
		switch( Tag.Info & 0x70 )
		{
			case 0x00:
				Tag.Size = 1;
				break;
			case 0x10:
				Tag.Size = 2;
				break;
			case 0x20:
				Tag.Size = 4;
				break;
			case 0x30:
				Tag.Size = 12;
				break;
			case 0x40:
				Tag.Size = 16;
				break;
			case 0x50:
				SizeByte =  Tag.Size;
				Ar       << SizeByte;
				Tag.Size =  SizeByte;
				break;
			case 0x60:
				SizeWord =  Tag.Size;
				Ar       << SizeWord;
				Tag.Size =  SizeWord;
				break;
			case 0x70:
				SizeInt		=  Tag.Size;
				Ar          << SizeInt;
				Tag.Size    =  SizeInt;
				break;
		}
		if( (Tag.Info&0x80) && Tag.Type!=NAME_BoolProperty )
		{
			BYTE B
			=	(Tag.ArrayIndex<=127  ) ? (Tag.ArrayIndex    )
			:	(Tag.ArrayIndex<=16383) ? (Tag.ArrayIndex>>8 )+0x80
			:	                          (Tag.ArrayIndex>>24)+0xC0;
			Ar << B;
			if( (B & 0x80)==0 )
			{
				Tag.ArrayIndex = B;
			}
			else if( (B & 0xC0)==0x80 )
			{
				BYTE C = Tag.ArrayIndex & 255;
				Ar << C;
				Tag.ArrayIndex = ((INT)(B&0x7F)<<8) + ((INT)C);
			}
			else
			{
				BYTE C = Tag.ArrayIndex>>16;
				BYTE D = Tag.ArrayIndex>>8;
				BYTE E = Tag.ArrayIndex;
				Ar << C << D << E;
				Tag.ArrayIndex = ((INT)(B&0x3F)<<24) + ((INT)C<<16) + ((INT)D<<8) + ((INT)E);
			}
		}
		else Tag.ArrayIndex = 0;
		return Ar;
	}

	// Property serializer.
	void SerializeTaggedProperty( FArchive& Ar, UProperty* Property, BYTE* Value )
	{
		if( Property->GetClass()==UBoolProperty::StaticClass() )
		{
			UBoolProperty* Bool = (UBoolProperty*)Property;
			check(Bool->BitMask!=0);
			if( Ar.IsLoading() )				
			{
				if( Info&0x80)	*(BITFIELD*)Value |=  Bool->BitMask;
				else			*(BITFIELD*)Value &= ~Bool->BitMask;
			}
		}
		else
		{
			Property->SerializeItem( Ar, Value );
		}
	}
};

/*-----------------------------------------------------------------------------
	UField implementation.
-----------------------------------------------------------------------------*/

UField::UField( ENativeConstructor, UClass* InClass, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags, UField* InSuperField )
: UObject				( EC_NativeConstructor, InClass, InName, InPackageName, InFlags )
, SuperField			( InSuperField )
, Next					( NULL )
, HashNext				( NULL )
{}
UField::UField( UField* InSuperField )
:	SuperField( InSuperField )
{}
UClass* UField::GetOwnerClass()
{
	UObject* Obj;
	for( Obj=this; Obj->GetClass()!=UClass::StaticClass(); Obj=Obj->GetOuter() );
	return (UClass*)Obj;
}
void UField::Bind()
{
}
void UField::PostLoad()
{
	Super::PostLoad();
	Bind();
}
void UField::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );

	Ar << SuperField << Next;
	if( Ar.IsLoading() )
		HashNext = NULL;

}

INT UField::GetPropertiesSize()
{
	return 0;
}

UBOOL UField::MergeBools()
{
	return 1;
}
void UField::AddCppProperty( UProperty* Property )
{
	appErrorf(TEXT("UField::AddCppProperty"));
}
void UField::Register()
{
	Super::Register();
	if( SuperField )
		SuperField->ConditionalRegister();
}
IMPLEMENT_CLASS(UField)

/*-----------------------------------------------------------------------------
	UStruct implementation.
-----------------------------------------------------------------------------*/

//
// Constructors.
//
UStruct::UStruct( ENativeConstructor, INT InSize, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags, UStruct* InSuperStruct )
:	UField			( EC_NativeConstructor, UClass::StaticClass(), InName, InPackageName, InFlags, InSuperStruct )
,	ScriptText		( NULL )
,	Children		( NULL )
//,	PropertiesSize	( InSize )
,	Script			()
,	TextPos			( 0 )
,	Line			( 0 )
,	RefLink			( NULL )
,	StructLink		( NULL )
,	PropertyLink	( NULL )
,	ConfigLink	    ( NULL )
,	ConstructorLink	( NULL )
,	FriendlyName	( /*Uninitialized*/ )
,	StructFlags		( 0 )
,	StructCategory	( NAME_None )
{
    appMemzero(PropertiesSizes, CPD_MAX*sizeof(INT));
	SetPropertiesSize( InSize );
}

UStruct::UStruct( UStruct* InSuperStruct )
:	UField( InSuperStruct )
//,	PropertiesSize( InSuperStruct ? InSuperStruct->GetPropertiesSize() : 0 )
,	FriendlyName( GetFName() )
,	StructFlags( 0 )
,	StructCategory( InSuperStruct ? InSuperStruct->StructCategory : NAME_None )
{
	PropertiesSizes[CPD_Normal] = InSuperStruct ? InSuperStruct->GetPropertiesSize() : 0;
}

//
// Add a property.
//
void UStruct::AddCppProperty( UProperty* Property )
{
	Property->Next = Children;
	Children       = Property;
}

//
// Register.
//
void UStruct::Register()
{
	Super::Register();

	// Friendly name.
	FriendlyName = GetFName();

}

//
// Link offsets.
//
void UStruct::Link( FArchive& Ar, UBOOL Props )
{
	// Link the properties.
	if( Props )
	{
		SetPropertiesSize(0);
		if( GetInheritanceSuper() )
		{
			Ar.Preload( GetInheritanceSuper() );
			SetPropertiesSize( Align(GetInheritanceSuper()->GetPropertiesSize(),4) );

		}
		UProperty* Prev = NULL;
		for( UField* Field=Children; Field; Field=Field->Next )
		{
			Ar.Preload( Field );
			if( Field->GetOuter()!=this )
				break;
			UProperty* Property = Cast<UProperty>( Field );
			if( Property )
			{
				Property->Link( Ar, Prev );
				SetPropertiesSize( Property->Offset + Property->GetSize() );
				Prev = Property;
			}
		}
		SetPropertiesSize( Align(GetPropertiesSize(),4) );
	}
	else
	{
		UProperty* Prev = NULL;

		for( UField* Field=Children; Field && Field->GetOuter()==this; Field=Field->Next )
		{
			UProperty* Property = Cast<UProperty>( Field );
			if( Property )
			{
				INT SavedOffset = Property->Offset;
				Property->Link( Ar, Prev );
				Property->Offset = SavedOffset;
				Prev = Property;
			}
		}
	}

	// Link the references.
	UObjectProperty** RefLinkPtr = &RefLink;
	for( TFieldIterator<UObjectProperty> ItR(this); ItR; ++ItR,RefLinkPtr=&(*RefLinkPtr)->NextReference )
		*RefLinkPtr = *ItR;
	*RefLinkPtr = NULL;

	// Link the structs.
	UStructProperty** StructLinkPtr = &StructLink;
	for( TFieldIterator<UStructProperty> ItS(this); ItS; ++ItS,StructLinkPtr=&(*StructLinkPtr)->NextStruct )
		*StructLinkPtr = *ItS;
	*StructLinkPtr = NULL;

	// Link the cleanup.
	TMap<UProperty*,INT> Map;
	UProperty** PropertyLinkPtr    = &PropertyLink;
	UProperty** ConfigLinkPtr      = &ConfigLink;
	UProperty** ConstructorLinkPtr = &ConstructorLink;
	for( TFieldIterator<UProperty> ItC(this); ItC; ++ItC )
	{
		if( (ItC->PropertyFlags & CPF_Net) && !GIsEditor )
		{
			ItC->RepOwner = *ItC;
			FArchive TempAr;
			INT iCode = ItC->RepOffset;
			ItC->GetOwnerClass()->SerializeExpr( iCode, TempAr );
			Map.Set( *ItC, iCode );
			for( TFieldIterator<UProperty> ItD(this); *ItD!=*ItC; ++ItD )
			{
				if( ItD->PropertyFlags & CPF_Net )
				{
					INT* iCodePtr = Map.Find( *ItD );
					check(iCodePtr);
					if
					(	iCode-ItC->RepOffset==*iCodePtr-ItD->RepOffset
					&&	appMemcmp(&ItC->GetOwnerClass()->Script(ItC->RepOffset),&ItD->GetOwnerClass()->Script(ItD->RepOffset),iCode-ItC->RepOffset)==0 )
					{
						ItD->RepOwner = ItC->RepOwner;
					}
				}
			}
		}
		if( ItC->PropertyFlags & CPF_NeedCtorLink )
		{
			*ConstructorLinkPtr = *ItC;
			ConstructorLinkPtr  = &(*ConstructorLinkPtr)->ConstructorLinkNext;
		}
		if( ItC->PropertyFlags & CPF_Config )
		{
			*ConfigLinkPtr = *ItC;
			ConfigLinkPtr  = &(*ConfigLinkPtr)->ConfigLinkNext;
		}
		*PropertyLinkPtr = *ItC;
		PropertyLinkPtr  = &(*PropertyLinkPtr)->PropertyLinkNext;
	}
	*PropertyLinkPtr    = NULL;
	*ConfigLinkPtr      = NULL;
	*ConstructorLinkPtr = NULL;
}

//
// Serialize all of the class's data that belongs in a particular
// bin and resides in Data.
//
void UStruct::SerializeBin( FArchive& Ar, BYTE* Data )
{
	FName PropertyName(NAME_None);
	INT Index=0;
	for( TFieldIterator<UProperty> It(this); It; ++It )
	{
		PropertyName = It->GetFName();
		if( It->ShouldSerializeValue(Ar) )
			for( Index=0; Index<It->ArrayDim; Index++ )
				It->SerializeItem( Ar, Data + It->Offset + Index*It->ElementSize );
	}
}
void UStruct::SerializeTaggedProperties( FArchive& Ar, BYTE* Data, UClass* DefaultsClass )
{
	FName PropertyName(NAME_None);
	INT Index=-1;
	check(Ar.IsLoading() || Ar.IsSaving());

    
	// Find defaults.
	BYTE* Defaults      = NULL;
	INT   DefaultsCount = 0;
	if( DefaultsClass )
	{
		Defaults      = &DefaultsClass->Defaults[CPD_Normal](0);
		DefaultsCount =  DefaultsClass->Defaults[CPD_Normal].Num();
	}    

	// Load/save.
#if VF_HASH_VARIABLES
	UClass* C = CastChecked<UClass>(this);
#endif
	if( Ar.IsLoading() )
	{
		// Load all stored properties.
		INT Count=0;
		while( 1 )
		{
			FPropertyTag Tag;
			Ar << Tag;
			if( Tag.Name == NAME_None )
				break;
			PropertyName = Tag.Name;
			UProperty* Property=NULL;
#if VF_HASH_VARIABLES
			for( UField* Node=C->VfHash[Tag.Name.GetIndex() & (UField::HASH_COUNT-1)]; Node; Node=Node->HashNext )
				if( Node->GetFName()==Tag.Name )
					{Property = Cast<UProperty>(Node); break;}
#else
			for( Property=PropertyLink; Property; Property=Property->PropertyLinkNext )
				if( Property->GetFName()==Tag.Name )
					break;
#endif
			if( !Property )
			{
				debugf( NAME_Warning, TEXT("Property %s of %s not found"), *Tag.Name, GetFullName() );
			}
			else if( Tag.Type==NAME_StringProperty && Property->GetID()==NAME_StrProperty )
			{
				//oldver: Upgrade fixed-length strings to dynamic strings
				TCHAR Temp[255];
				INT Count, MaxCount=Tag.Size ? Tag.Size+1 : ARRAY_COUNT(Temp);
				for( Count=0; Count<MaxCount-1; Count++ )
				{
					BYTE ACh;
					Ar << ACh;
					Temp[Count] = FromAnsi(ACh);
					if( Temp[Count] == 0 )
						break;
				}
				Temp[Count] = 0;
				*(FString*)(Data + Property->Offset + Tag.ArrayIndex * Property->ElementSize ) = Temp;
				continue;
			}
			else if( Tag.Type!=Property->GetID() )
			{
				//debugf( NAME_Warning, TEXT("Type mismatch in %s of %s: file %i, class %i"), *Tag.Name, GetName(), Tag.Type, Property->GetID() );
                GWarn->Logf( TEXT("Type mismatch in %s of %s: file %i, class %i"), *Tag.Name, GetName(), Tag.Type, Property->GetID() );
			}
			else if( Tag.ArrayIndex>=Property->ArrayDim )
			{
				//debugf( NAME_Warning, TEXT("Array bounds in %s of %s: %i/%i"), *Tag.Name, GetName(), Tag.ArrayIndex, Property->ArrayDim );
                GWarn->Logf( TEXT("Array bounds in %s of %s: %i/%i"), *Tag.Name, GetName(), Tag.ArrayIndex, Property->ArrayDim );
			}
			else if( Tag.Type==NAME_StructProperty && Tag.ItemName!=CastChecked<UStructProperty>(Property)->Struct->GetFName() )
			{
				//debugf( NAME_Warning, TEXT("Property %s of %s struct type mismatch %s/%s"), *Tag.Name, GetName(), *Tag.ItemName, CastChecked<UStructProperty>(Property)->Struct->GetName() );
                GWarn->Logf( TEXT("Property %s of %s struct type mismatch %s/%s"), *Tag.Name, GetName(), *Tag.ItemName, CastChecked<UStructProperty>(Property)->Struct->GetName() );
			}
			else if( !Property->ShouldSerializeValue(Ar) )
			{
				if( appStricmp(*Tag.Name,TEXT("XLevel"))!=0 )
					//debugf( NAME_Warning, TEXT("Property %s of %s is not serialiable"), *Tag.Name, GetName() );
                    GWarn->Logf( TEXT("Property %s of %s is not serialiable"), *Tag.Name, GetName() );
			}
			else
			{
				// This property is ok.
				Tag.SerializeTaggedProperty( Ar, Property, Data + Property->Offset + Tag.ArrayIndex*Property->ElementSize );
				continue;
			}

			// Skip unknown or bad property.
			if( appStricmp(*Tag.Name,TEXT("XLevel"))!=0 )
				//debugf( NAME_Warning, TEXT("Skipping %i bytes of type %i"), Tag.Size, Tag.Type );
                GWarn->Logf( TEXT("Skipping %i bytes of type %i"), Tag.Size, Tag.Type );

			BYTE B;
			for( INT i=0; i<Tag.Size; i++ )
				Ar << B;
		}
		Count = 0;
	}
	else
	{
		// Save tagged properties.
		for( TFieldIterator<UProperty> It(this); It; ++It )
		{
			if( It->ShouldSerializeValue(Ar) )
			{
				PropertyName = It->GetFName();
                //GWarn->Logf( TEXT( "Property Name:%s" ), *PropertyName );

				for( Index=0; Index<It->ArrayDim; Index++ )
				{
					INT Offset = It->Offset + Index*It->ElementSize;
					
                    if( !Defaults || !It->Matches( Data, (Offset+It->ElementSize<=DefaultsCount) ? Defaults : NULL, Index) )
					{
                 
                        //GWarn->Logf( TEXT( "%s: Prop[%d]: Class:%s" ), It->GetFullName(), Index, this->GetFullName() );
                        if ( !appStricmp( TEXT("Class dnParticles.dnWallConcreteSpark"), this->GetFullName() ) )
                        {
                       //     if ( !appStricmp( TEXT("StructProperty Engine.SoftParticleSystem.AdditionalSpawn"), It->GetFullName() ) )
                            {
                                int blah=0;blah;
                            }
                        }
                 
 						FPropertyTag Tag( Ar, *It, Index, Data + Offset );
						Ar << Tag;
						Tag.SerializeTaggedProperty( Ar, *It, Data + Offset );
					}
				}
			}
		}
		FName Temp(NAME_None);
		Ar << Temp;
	}
}
void UStruct::Destroy()
{
	Script.Empty();
	Super::Destroy();
}
void UStruct::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );

	// Serialize stuff.
	Ar << ScriptText << Children;
	Ar << FriendlyName;
	check(FriendlyName!=NAME_None);
	// CDH...
	if (Ar.LVer() >= 2)
		Ar << StructFlags << StructCategory;
	// ...CDH

	// Compiler info.
	Ar << Line << TextPos;

	// Script code.
	INT ScriptSize = Script.Num();
	Ar << ScriptSize;
	if( Ar.IsLoading() )
	{
		Script.Empty();
		Script.Add( ScriptSize );
	}
	INT iCode = 0;
	while( iCode < ScriptSize )
		SerializeExpr( iCode, Ar );
	if( iCode != ScriptSize )
		appErrorf( TEXT("Script serialization mismatch: Got %i, expected %i"), iCode, ScriptSize );

	// Link the properties.
	if( Ar.IsLoading() )
		Link( Ar, 1 );

}

//
// Actor reference cleanup.
//
void UStruct::CleanupDestroyed( BYTE* Data )
{
	if( GIsEditor )
	{
		// Slow cleanup.
		for( TFieldIterator<UProperty> It(this); It; ++It )
		{
			UProperty* Property = *It;
			if( Property->IsA(UObjectProperty::StaticClass()) )
			{
				// Cleanup object reference.
				UObject** LinkedObjects = (UObject**)(Data + Property->Offset);
				for( INT k=0; k<Property->ArrayDim; k++ )
				{
					if( LinkedObjects[k] )
					{
						check(LinkedObjects[k]->IsValid());
						if( LinkedObjects[k]->IsPendingKill() )
						{
							// Remove this reference.
							LinkedObjects[k]->Modify();
							LinkedObjects[k] = NULL;
						}
					}
				}
			}
			else if( Property->GetClass()==UStructProperty::StaticClass() )
			{
				// Cleanup substructure.
				for( INT k=0; k<Property->ArrayDim; k++ )
					((UStructProperty*)Property)->Struct->CleanupDestroyed( Data + Property->Offset + k*Property->ElementSize );
			}
		}
	}
	else
	{
		// Optimal cleanup.
		for( UObjectProperty* Ref=RefLink; Ref; Ref=Ref->NextReference )
		{
			UObject** LinkedObjects = (UObject**)(Data+Ref->Offset);
			for( INT k=0; k<Ref->ArrayDim; k++ )
			{
				if( LinkedObjects[k] )
				{
					check(LinkedObjects[k]->IsValid());
					if( LinkedObjects[k]->IsPendingKill() )
						LinkedObjects[k] = NULL;
				}
			}
		}
		for( UStructProperty* St=StructLink; St; St=St->NextStruct )
		{
			for( INT k=0; k<St->ArrayDim; k++ )
				St->Struct->CleanupDestroyed( Data + St->Offset + k*St->ElementSize );
		}
	}
}

IMPLEMENT_CLASS(UStruct);

/*-----------------------------------------------------------------------------
	UState.
-----------------------------------------------------------------------------*/

UState::UState( UState* InSuperState )
: UStruct( InSuperState )
{}
UState::UState( ENativeConstructor, INT InSize, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags, UState* InSuperState )
:	UStruct			( EC_NativeConstructor, InSize, InName, InPackageName, InFlags, InSuperState )
,	ProbeMask		( 0 )
,	IgnoreMask		( 0 )
,	StateFlags		( 0 )
,	LabelTableOffset( 0 )
{}
void UState::Destroy()
{
	Super::Destroy();
}
void UState::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );

	// Class/State-specific union info.
	Ar << ProbeMask << IgnoreMask;
	Ar << LabelTableOffset << StateFlags;

}
void UState::Link( FArchive& Ar, UBOOL Props )
{
	Super::Link( Ar, Props );

	// Initialize hash.
	if( GetSuperState() )
		appMemcpy( VfHash, GetSuperState()->VfHash, sizeof(VfHash) );
	else
		appMemzero( VfHash, sizeof(VfHash) );

	// Add all stuff at this node to the hash.
#if VF_HASH_VARIABLES
	for( TFieldIterator<UField> It(this); It && It->GetOuter()==this; ++It )
#else
	for( TFieldIterator<UStruct> It(this); It && It->GetOuter()==this; ++It )
#endif
	{
		INT iHash          = It->GetFName().GetIndex() & (UField::HASH_COUNT-1);
		It->HashNext       = VfHash[iHash];
		VfHash[iHash]      = *It;
	}
}
IMPLEMENT_CLASS(UState);

/*-----------------------------------------------------------------------------
	UClass implementation.
-----------------------------------------------------------------------------*/

//
// Register the native class.
//
void UClass::Register()
{
	Super::Register();

	// Get stashed registration info.
	const TCHAR* InClassConfigName = *(TCHAR**)&ClassConfigName;
	ClassConfigName = InClassConfigName;

    // Init default object.
	Defaults[CPD_Normal].Empty( GetPropertiesSize() );
	Defaults[CPD_Normal].Add( GetPropertiesSize() );

    GetDefaultObject()->InitClassDefaultObject( this );	

	// Perform static construction.
	if( !GetSuperClass() || GetSuperClass()->ClassStaticConstructor!=ClassStaticConstructor )
		(GetDefaultObject()->*ClassStaticConstructor)();

	// Propagate inhereted flags.
	if( SuperField )
		ClassFlags |= (GetSuperClass()->ClassFlags & CLASS_Inherit);

	// Link the cleanup.
	FArchive ArDummy;
	Link( ArDummy, 0 );

	// Load defaults.
	GetDefaultObject()->LoadConfig();
	GetDefaultObject()->LoadLocalized();
}

//
// Find the class's native constructor.
//
void UClass::Bind()
{
	UStruct::Bind();
	check(GIsEditor || GetSuperClass() || this==UObject::StaticClass());
	if( !ClassConstructor && (GetFlags() & RF_Native) )
	{
		// Find the native implementation.
		TCHAR ProcName[256];
		appSprintf( ProcName, TEXT("autoclass%s"), GetNameCPP() );

		// Find export from the DLL.
		UPackage* ClassPackage = GetOuterUPackage();
		UClass** ClassPtr = (UClass**)ClassPackage->GetDllExport( ProcName, 0 );
		if( ClassPtr )
		{
			check(*ClassPtr);
			check(*ClassPtr==this);
			ClassConstructor = (*ClassPtr)->ClassConstructor;
		}
		else if( !GIsEditor )
		{
			appErrorf( TEXT("Can't bind to native class %s"), GetPathName() );
		}
	}
	if( !ClassConstructor && GetSuperClass() )
	{
		// Chase down constructor in parent class.
		GetSuperClass()->Bind();
		ClassConstructor = GetSuperClass()->ClassConstructor;
	}
	check(GIsEditor || ClassConstructor);
}

/*-----------------------------------------------------------------------------
	UClass UObject implementation.
-----------------------------------------------------------------------------*/

INT Compare( UField* A, UField* B )
{
	if( !A->GetLinker() || !B->GetLinker() )
		return 0;
//#if ENGINE_VERSION<230
//	INT Diff = CompareGuids( &A->GetLinker()->Summary.Guid, &B->GetLinker()->Summary.Guid );
//	if( Diff )
//		return Diff;
//#endif
	return A->GetLinkerIndex() - B->GetLinkerIndex();
}

void UClass::Destroy()
{
	// Empty arrays.
	//warning: Must be emptied explicitly in order for intrinsic classes
	// to not show memory leakage on exit.
	NetFields.Empty();
	Dependencies.Empty();
	PackageImports.Empty();
//	ExitProperties( &Defaults(0), this );
	Defaults[CPD_Normal].Empty();
	DefaultPropText=TEXT("");

	Super::Destroy();
}

void UClass::PostLoad()
{
	check(ClassWithin);
	Super::PostLoad();

	// Postload super.
	if( GetSuperClass() )
		GetSuperClass()->ConditionalPostLoad();

}
void UClass::Link( FArchive& Ar, UBOOL Props )
{
	Super::Link( Ar, Props );

	if( !GIsEditor )
	{
		NetFields.Empty();
#if ENGINE_VERSION<230
		ClassReps.Empty();
		for( TFieldIterator<UField> It(this); It; ++It )
#else
		ClassReps = SuperField ? GetSuperClass()->ClassReps : TArray<FRepRecord>();
		for( TFieldIterator<UField> It(this); It && It->GetOwnerClass()==this; ++It )
#endif
		{
			UProperty* P;
			UFunction* F;
			if( (P=Cast<UProperty>(*It))!=NULL )
			{
				if( P->PropertyFlags&CPF_Net )
				{
					NetFields.AddItem( *It );
					if( P->GetOuter()==this )
					{
						P->RepIndex = ClassReps.Num();
						for( INT i=0; i<P->ArrayDim; i++ )
							new(ClassReps)FRepRecord(P,i);
					}
				}
			}
			else if( (F=Cast<UFunction>(*It))!=NULL )
			{
				if( (F->FunctionFlags&FUNC_Net) && !F->GetSuperFunction() )
					NetFields.AddItem( *It );
			}
		}
		NetFields.Shrink();
		Sort( &NetFields(0), NetFields.Num() );
	}
}
void UClass::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );

	// Variables.
/*
    if( Ar.Ver() <= 61 )//oldver
	{
		INT OldClassRecordSize=0;
		Ar << OldClassRecordSize; 
		SetFlags( RF_Public | RF_Standalone );
	}
*/
	Ar << ClassFlags << ClassGuid;
	Ar << Dependencies << PackageImports;
//	if( Ar.Ver()>=62 )
    	Ar << ClassWithin << ClassConfigName;
//	else
//		ClassConfigName = FName(TEXT("System"));

	// Defaults.
	if( Ar.IsLoading() )
	{
		check(GetPropertiesSize()>=sizeof(UObject));
		check(!GetSuperClass() || !(GetSuperClass()->GetFlags()&RF_NeedLoad));
		Defaults[CPD_Normal].Empty( GetPropertiesSize() );
		Defaults[CPD_Normal].Add( GetPropertiesSize() );
		GetDefaultObject()->InitClassDefaultObject( this );
		SerializeTaggedProperties( Ar, &Defaults[CPD_Normal](0), GetSuperClass() );
		GetDefaultObject()->LoadConfig();
		GetDefaultObject()->LoadLocalized();
		ClassUnique = 0;
//		if( Ar.Ver()<=61 )//oldver
//			ClassWithin = UObject::StaticClass();
	}
	else if( Ar.IsSaving() )
	{
		check(Defaults[CPD_Normal].Num()==GetPropertiesSize());
		SerializeTaggedProperties( Ar, &Defaults[CPD_Normal](0), GetSuperClass() );
	}
	else
	{
		check(Defaults[CPD_Normal].Num()==GetPropertiesSize());
		Defaults[CPD_Normal].CountBytes( Ar );
		SerializeBin( Ar, &Defaults[CPD_Normal](0) );
	}
}

/*-----------------------------------------------------------------------------
	UClass constructors.
-----------------------------------------------------------------------------*/

//
// Internal constructor.
//
UClass::UClass()
:	ClassWithin( UObject::StaticClass() )
{}

//
// Create a new UClass given its superclass.
//
UClass::UClass( UClass* InBaseClass )
:	UState( InBaseClass )
,	ClassWithin( UObject::StaticClass() )
{
	if( GetSuperClass() )
	{
		ClassWithin = GetSuperClass()->ClassWithin;
        Defaults[CPD_Normal] = GetSuperClass()->Defaults[CPD_Normal];
        Bind();		
	}
}

//
// UClass autoregistry constructor.
//warning: Called at DLL init time.
//
UClass::UClass
(
	ENativeConstructor,
	DWORD			InSize,
	DWORD			InClassFlags,
	UClass*			InSuperClass,
	UClass*			InWithinClass,
	FGuid			InGuid,
	const TCHAR*	InNameStr,
	const TCHAR*    InPackageName,
	const TCHAR*    InConfigName,
	DWORD			InFlags,
	void			(*InClassConstructor)(void*),
	void			(UObject::*InClassStaticConstructor)()
)
:	UState					( EC_NativeConstructor, InSize, InNameStr, InPackageName, InFlags, InSuperClass!=this ? InSuperClass : NULL )
,	ClassFlags				( InClassFlags | CLASS_Parsed | CLASS_Compiled )
,	ClassUnique				( 0 )
,	ClassGuid				( InGuid )
,	ClassWithin				( InWithinClass )
,	ClassConfigName			()
,	Dependencies			()
,	PackageImports			()
,	Defaults     			()
,	NetFields				()
,	ClassConstructor		( InClassConstructor )
,	ClassStaticConstructor	( InClassStaticConstructor )
{
	*(const TCHAR**)&ClassConfigName = InConfigName;
}

IMPLEMENT_CLASS(UClass);

/*-----------------------------------------------------------------------------
	FClassDependency.
-----------------------------------------------------------------------------*/

//
// FClassDependency inlines.
//
FClassDependency::FClassDependency()
{}
FClassDependency::FClassDependency( UClass* InClass )
:	Class( InClass )
,	ScriptTextCRC( Class ? Class->GetScriptTextCRC() : 0 )
{}
UBOOL FClassDependency::IsUpToDate()
{
	check(Class!=NULL);
	return Class->GetScriptTextCRC()==ScriptTextCRC;
}
CORE_API FArchive& operator<<( FArchive& Ar, FClassDependency& Dep )
{
	return Ar << Dep.Class << Dep.ScriptTextCRC;
}

/*-----------------------------------------------------------------------------
	FLabelEntry.
-----------------------------------------------------------------------------*/

FLabelEntry::FLabelEntry( FName InName, INT iInCode )
:	Name	(InName)
,	iCode	(iInCode)
{}
CORE_API FArchive& operator<<( FArchive& Ar, FLabelEntry &Label )
{
	Ar << Label.Name;
	Ar << Label.iCode;
	return Ar;
}

/*-----------------------------------------------------------------------------
	UStruct implementation.
-----------------------------------------------------------------------------*/

//
// Serialize an expression to an archive.
// Returns expression token.
//
EExprToken UStruct::SerializeExpr( INT& iCode, FArchive& Ar )
{
	EExprToken Expr=(EExprToken)0;
	#define XFER(T) {Ar << *(T*)&Script(iCode); iCode += sizeof(T); }

	// Get expr token.
	XFER(BYTE);
	Expr = (EExprToken)Script(iCode-1);
	if( Expr >= EX_MinConversion && Expr < EX_MaxConversion )
	{
		// A type conversion.
		SerializeExpr( iCode, Ar );
	}
	else if( Expr >= EX_FirstNative )
	{
		// Native final function with id 1-127.
		while( SerializeExpr( iCode, Ar ) != EX_EndFunctionParms );
	}
	else if( Expr >= EX_ExtendedNative )
	{
		// Native final function with id 256-16383.
		XFER(BYTE);
		while( SerializeExpr( iCode, Ar ) != EX_EndFunctionParms );
	}
	else switch( Expr )
	{
		case EX_Let:
		case EX_LetBool:
		{
			SerializeExpr( iCode, Ar ); // Variable expr.
			SerializeExpr( iCode, Ar ); // Assignment expr.
			break;
		}
		case EX_Jump:
		{
			XFER(_WORD); // Code offset.
			break;
		}
		case EX_LocalVariable:
		case EX_InstanceVariable:
		case EX_DefaultVariable:
		{
			XFER(UProperty*);
			break;
		}
		case EX_BoolVariable:
		case EX_Nothing:
		case EX_EndFunctionParms:
		case EX_IntZero:
		case EX_IntOne:
		case EX_True:
		case EX_False:
		case EX_NoObject:
		case EX_Self:
		case EX_IteratorPop:
		case EX_Stop:
		case EX_IteratorNext:
		{
			break;
		}
		case EX_EatString:
		{
			SerializeExpr( iCode, Ar ); // String expression.
			break;
		}
		case EX_Return:
		{
			SerializeExpr( iCode, Ar ); // Return expression.
			break;
		}
		case EX_FinalFunction:
		{
			XFER(UStruct*); // Stack node.
			while( SerializeExpr( iCode, Ar ) != EX_EndFunctionParms ); // Parms.
			break;
		}
		case EX_VirtualFunction:
		case EX_GlobalFunction:
		{
			XFER(FName); // Virtual function name.
			while( SerializeExpr( iCode, Ar ) != EX_EndFunctionParms ); // Parms.
			break;
		}
		case EX_NativeParm:
		{
			XFER(UProperty*);
			break;
		}
		case EX_ClassContext:
		case EX_Context:
		{
			SerializeExpr( iCode, Ar ); // Object expression.
			XFER(_WORD); // Code offset for NULL expressions.
			XFER(_WORD); //XFER(BYTE); // Zero-fill size if skipped. // CDH: changed size to 16 bits
			SerializeExpr( iCode, Ar ); // Context expression.
			break;
		}
		case EX_ArrayElement:
		case EX_DynArrayElement:
		{
			SerializeExpr( iCode, Ar ); // Index expression.
			SerializeExpr( iCode, Ar ); // Base expression.
			break;
		}
		case EX_New:
		{
			SerializeExpr( iCode, Ar ); // Parent expression.
			SerializeExpr( iCode, Ar ); // Name expression.
			SerializeExpr( iCode, Ar ); // Flags expression.
			SerializeExpr( iCode, Ar ); // Class expression.
			break;
		}
		case EX_IntConst:
		{
			XFER(INT);
			break;
		}
		case EX_FloatConst:
		{
			XFER(FLOAT);
			break;
		}
		case EX_StringConst:
		{
			do XFER(BYTE) while( Script(iCode-1) );
			break;
		}
		case EX_UnicodeStringConst:
		{
			do XFER(_WORD) while( Script(iCode-1) );
			break;
		}
		case EX_ObjectConst:
		{
			XFER(UObject*);
			break;
		}
		case EX_NameConst:
		{
			XFER(FName);
			break;
		}
		case EX_RotationConst:
		{
			XFER(INT); XFER(INT); XFER(INT);
			break;
		}
		case EX_VectorConst:
		{
			XFER(FLOAT); XFER(FLOAT); XFER(FLOAT);
			break;
		}
		case EX_ByteConst:
		case EX_IntConstByte:
		{
			XFER(BYTE);
			break;
		}
		case EX_MetaCast:
		{
			XFER(UClass*);
			SerializeExpr( iCode, Ar );
			break;
		}
		case EX_DynamicCast:
		{
			XFER(UClass*);
			SerializeExpr( iCode, Ar );
			break;
		}
		case EX_JumpIfNot:
		{
			XFER(_WORD); // Code offset.
			SerializeExpr( iCode, Ar ); // Boolean expr.
			break;
		}
		case EX_Iterator:
		{
			SerializeExpr( iCode, Ar ); // Iterator expr.
			XFER(_WORD); // Code offset.
			break;
		}
		case EX_Switch:
		{
			XFER(_WORD); //XFER(BYTE); // Value size. // CDH: changed size to 16 bits
			SerializeExpr( iCode, Ar ); // Switch expr.
			break;
		}
		case EX_Assert:
		{
			XFER(_WORD); // Line number.
			SerializeExpr( iCode, Ar ); // Assert expr.
			break;
		}
		case EX_Case:
		{
			_WORD *W=(_WORD*)&Script(iCode);
			XFER(_WORD);; // Code offset.
			if( *W != MAXWORD )
				SerializeExpr( iCode, Ar ); // Boolean expr.
			break;
		}
		case EX_LabelTable:
		{
			check((iCode&3)==0);
			for( ; ; )
			{
				FLabelEntry* E = (FLabelEntry*)&Script(iCode);
				XFER(FLabelEntry);
				if( E->Name == NAME_None )
					break;
			}
			break;
		}
		case EX_GotoLabel:
		{
			SerializeExpr( iCode, Ar ); // Label name expr.
			break;
		}
		case EX_Skip:
		{
			XFER(_WORD); // Skip size.
			SerializeExpr( iCode, Ar ); // Expression to possibly skip.
			break;
		}
		case EX_StructCmpEq:
		case EX_StructCmpNe:
		{
			XFER(UStruct*); // Struct.
			SerializeExpr( iCode, Ar ); // Left expr.
			SerializeExpr( iCode, Ar ); // Right expr.
			break;
		}
		case EX_StructMember:
		{
			XFER(UProperty*); // Property.
			SerializeExpr( iCode, Ar ); // Inner expr.
			break;
		}
		default:
		{
			// This should never occur.
			appErrorf( TEXT("Bad expr token %02x"), Expr );
			break;
		}
	}
	return Expr;
	#undef XFER
}

void UStruct::PostLoad()
{
	Super::PostLoad();
}

/*-----------------------------------------------------------------------------
	UFunction.
-----------------------------------------------------------------------------*/

UFunction::UFunction( UFunction* InSuperFunction )
: UStruct( InSuperFunction )
{
	ProfileCycles=ProfileChildrenCycles=0;
	ProfileCalls=0;
}
void UFunction::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );

	// Function info.
	if( Ar.Ver()<=63 )
		Ar << ParmsSize;//oldver
	Ar << iNative;
	if( Ar.Ver()<=63 )
		Ar << NumParms;//oldver
	Ar << OperPrecedence;
	if( Ar.Ver()<=63 )
		Ar << ReturnValueOffset;//oldver
	Ar << FunctionFlags;

	// Replication info.
	if( FunctionFlags & FUNC_Net )
		Ar << RepOffset;

	// Precomputation.
	if( Ar.IsLoading() )
	{
		NumParms          = 0;
		ParmsSize         = 0;
		ReturnValueOffset = MAXWORD;
		for( UProperty* Property=Cast<UProperty>(Children); Property && (Property->PropertyFlags & CPF_Parm); Property=Cast<UProperty>(Property->Next) )
		{
			NumParms++;
			ParmsSize = Property->Offset + Property->GetSize();
			if( Property->PropertyFlags & CPF_ReturnParm )
				ReturnValueOffset = Property->Offset;
		}
	}

}
void UFunction::PostLoad()
{
	Super::PostLoad();
}

UProperty* UFunction::GetReturnProperty()
{
	for( TFieldIterator<UProperty> It(this); It && (It->PropertyFlags & CPF_Parm); ++It )
		if( It->PropertyFlags & CPF_ReturnParm )
			return *It;
	return NULL;
}
void UFunction::Bind()
{
	if( !(FunctionFlags & FUNC_Native) )
	{
		// Use UnrealScript processing function.
		check(iNative==0);
		Func = &UObject::ProcessInternal;
	}
	else if( iNative != 0 )
	{
		// Find hardcoded native.
		check(iNative<EX_Max);
		check(GNatives[iNative]!=0);
		Func = GNatives[iNative];
	}
	else
	{
		// Find dynamic native.
		TCHAR Proc[256];
		appSprintf( Proc, TEXT("int%sexec%s"), GetOwnerClass()->GetNameCPP(), GetName() );
		UPackage* ClassPackage = GetOwnerClass()->GetOuterUPackage();
		Native* Ptr = (Native*)ClassPackage->GetDllExport( Proc, 1 );
		if( Ptr )
			Func = *Ptr;
	}
}
void UFunction::Link( FArchive& Ar, UBOOL Props )
{
	Super::Link( Ar, Props );
}
IMPLEMENT_CLASS(UFunction);

/*-----------------------------------------------------------------------------
	UConst.
-----------------------------------------------------------------------------*/

UConst::UConst( UConst* InSuperConst, const TCHAR* InValue )
:	UField( InSuperConst )
,	Value( InValue )
{}
void UConst::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << Value;
}
IMPLEMENT_CLASS(UConst);

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
