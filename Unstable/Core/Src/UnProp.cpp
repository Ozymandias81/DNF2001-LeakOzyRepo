/*=============================================================================
	UnClsPrp.cpp: FProperty implementation
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "..\..\Engine\Src\EnginePrivate.h"

//!!fix hardcoded lengths
/*-----------------------------------------------------------------------------
	Helpers.
-----------------------------------------------------------------------------*/

//
// Parse a hex digit.
//
static INT HexDigit( TCHAR c )
{
	if( c>='0' && c<='9' )
		return c - '0';
	else if( c>='a' && c<='f' )
		return c + 10 - 'a';
	else if( c>='A' && c<='F' )
		return c + 10 - 'A';
	else
		return 0;
}

//
// Parse a token.
//
const TCHAR* ReadToken( const TCHAR* Buffer, TCHAR* String, INT MaxLength, UBOOL DottedNames=0 )
{
	INT Count=0;
	if( *Buffer == 0x22 )
	{
		// Get quoted string.
		Buffer++;
		while( *Buffer && *Buffer!=0x22 && *Buffer!=13 && *Buffer!=10 && Count<MaxLength-1 )
		{
			if( *Buffer != '\\' )
			{
				String[Count++] = *Buffer++;
			}
			else if( *++Buffer=='\\' )
			{
				String[Count++] = '\\';
				Buffer++;
			}
			else
			{
				String[Count++] = HexDigit(Buffer[0])*16 + HexDigit(Buffer[1]);
				Buffer += 2;
			}
		}
		if( Count==MaxLength-1 )
		{
			debugf( NAME_Warning, TEXT("ReadToken: Quoted string too long") );
			return NULL;
		}
		if( *Buffer++!=0x22 )
		{
			GWarn->Logf( NAME_Warning, TEXT("ReadToken: Bad quoted string") );
			return NULL;
		}
	}
	else if( appIsAlnum( *Buffer ) )
	{
		// Get identifier.
		while
		(	(appIsAlnum(*Buffer) || *Buffer=='_' || *Buffer=='-' || (DottedNames && *Buffer=='.' ))
		&&	Count<MaxLength-1 )
			String[Count++] = *Buffer++;
		if( Count==MaxLength-1 )
		{
			debugf( NAME_Warning, TEXT("ReadToken: Alphanumeric overflow") );
			return NULL;
		}
	}
	else
	{
		// Get just one.
		String[Count++] = *Buffer;
	}
	String[Count] = 0;
	return Buffer;
}

/*-----------------------------------------------------------------------------
	UProperty implementation.
-----------------------------------------------------------------------------*/

//
// Constructors.
//
UProperty::UProperty()
:	UField( NULL )
,	ArrayDim( 1 )
{}
UProperty::UProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags )
:	UField( NULL )
,	ArrayDim( 1 )
,	PropertyFlags( InFlags )
,	Category( InCategory )
,	Offset( InOffset )
{
	GetOuterUField()->AddCppProperty( this );
}

//
// Serializer.
//
void UProperty::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );

	// Archive the basic info.
	Ar << ArrayDim << PropertyFlags << Category;
	if( PropertyFlags & CPF_Net )
		Ar << RepOffset;
	if( Ar.Ver() <= 61 )//oldver: clear old net flags.
		PropertyFlags &= ~0x00080040;
	// CDH...
	if( PropertyFlags & CPF_Comment )
		Ar << CommentString;
	// ...CDH
	if( Ar.IsLoading() )
	{
		Offset = 0;
		ConstructorLinkNext = NULL;
	}
}

//
// Export this class property to an output
// device as a C++ header file.
//
void UProperty::ExportCpp( FOutputDevice& Out, UBOOL IsLocal, UBOOL IsParm ) const
{
	TCHAR ArrayStr[80] = TEXT("");
	if
	(	IsParm
	&&	IsA(UStrProperty::StaticClass())
	&&	!(PropertyFlags & CPF_OutParm) )
		Out.Log( TEXT("const ") );
	ExportCppItem( Out );
	if( ArrayDim != 1 )
		appSprintf( ArrayStr, TEXT("[%i]"), ArrayDim );
	if( IsA(UBoolProperty::StaticClass()) )
	{
		if( ArrayDim==1 && !IsLocal && !IsParm )
			Out.Logf( TEXT(" %s%s:1"), GetName(), ArrayStr );
		else if( IsParm && (PropertyFlags & CPF_OutParm) )
			Out.Logf( TEXT("& %s%s"), GetName(), ArrayStr );
		else
			Out.Logf( TEXT(" %s%s"), GetName(), ArrayStr );
	}
	else if( IsA(UStrProperty::StaticClass()) )
	{
		if( IsParm && ArrayDim>1 )
			Out.Logf( TEXT("* %s"), GetName() );
		else if( IsParm )
			Out.Logf( TEXT("& %s"), GetName() );
		else if( IsLocal )
			Out.Logf( TEXT(" %s"), GetName() );
		else
			Out.Logf( TEXT("NoInit %s%s"), GetName(), ArrayStr );
	}
	else
	{
		if( IsParm && ArrayDim>1 )
			Out.Logf( TEXT("* %s"), GetName() );
		else if( IsParm && (PropertyFlags & CPF_OutParm) )
			Out.Logf( TEXT("& %s%s"), GetName(), ArrayStr );
		else
			Out.Logf( TEXT(" %s%s"), GetName(), ArrayStr );
	}
}

//
// Export the contents of a property.
//
UBOOL UProperty::ExportText
(
	INT		Index,
	TCHAR*	ValueStr,
	BYTE*	Data,
	BYTE*	Delta,
	INT		PortFlags
) const
{
	ValueStr[0]=0;
	if( Data==Delta || !Matches(Data,Delta,Index) )
	{
		ExportTextItem
		(
			ValueStr,
			Data + Offset + Index * ElementSize,
			Delta ? (Delta + Offset + Index * ElementSize) : NULL,
			PortFlags
		);
		return 1;
	}
	else return 0;
}

//
// Copy a unique instance of a value.
//
void UProperty::CopySingleValue( void* Dest, void* Src ) const
{
	appMemcpy( Dest, Src, ElementSize );
}

//
// Destroy a value.
//
void UProperty::DestroyValue( void* Dest ) const
{}

//
// Net serialization.
//
UBOOL UProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	SerializeItem( Ar, Data );
	return 1;
}

//
// Return whether the property should be exported.
//
UBOOL UProperty::Port() const
{
	return 
	(	GetSize()
	&&	(Category!=NAME_None || !(PropertyFlags & (CPF_Transient | CPF_Native)))
	&&	GetFName()!=NAME_Class );
}

//
// Return type id for encoding properties in .u files.
//
BYTE UProperty::GetID() const
{
	return GetClass()->GetFName().GetIndex();
}

//
// Copy a complete value.
//
void UProperty::CopyCompleteValue( void* Dest, void* Src ) const
{
	for( INT i=0; i<ArrayDim; i++ )
		CopySingleValue( (BYTE*)Dest+i*ElementSize, (BYTE*)Src+i*ElementSize );
}

//
// Link property loaded from file.
//
void UProperty::Link( FArchive& Ar, UProperty* Prev )
{}

IMPLEMENT_CLASS(UProperty);

/*-----------------------------------------------------------------------------
	UByteProperty.
-----------------------------------------------------------------------------*/

void UByteProperty::Link( FArchive& Ar, UProperty* Prev )
{
	Super::Link( Ar, Prev );
	ElementSize = sizeof(BYTE);
	Offset      = Align( GetOuterUField()->GetPropertiesSize(), sizeof(BYTE) );
}
void UByteProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(BYTE*)Dest = *(BYTE*)Src;
}
void UByteProperty::CopyCompleteValue( void* Dest, void* Src ) const
{
	if( ArrayDim==1 )
		*(BYTE*)Dest = *(BYTE*)Src;
	else
		appMemcpy( Dest, Src, ArrayDim );
}
UBOOL UByteProperty::Identical( const void* A, const void* B ) const
{
	return *(BYTE*)A == (B ? *(BYTE*)B : 0);
}
void UByteProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar << *(BYTE*)Value;
}
UBOOL UByteProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	Ar.SerializeBits( Data, Enum ? appCeilLogTwo(Enum->Names.Num()) : 8 );
	return 1;
}
void UByteProperty::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << Enum;
}
void UByteProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Log( TEXT("BYTE") );
}
void UByteProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	if( Enum )
		appSprintf( ValueStr, TEXT("%s"), *Enum->Names(*(BYTE*)PropertyValue) );
	else
		appSprintf( ValueStr, TEXT("%i"), *(BYTE*)PropertyValue );
}
const TCHAR* UByteProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	TCHAR Temp[1024];
	if( Enum )
	{
		Buffer = ReadToken( Buffer, Temp, ARRAY_COUNT(Temp) );
		if( !Buffer )
			return NULL;
		FName EnumName = FName( Temp, FNAME_Find );
		if( EnumName != NAME_None )
		{
			INT EnumIndex=0;
			if( Enum->Names.FindItem( EnumName, EnumIndex ) )
			{
				*(BYTE*)Data = EnumIndex;
				return Buffer;
			}
		}
	}
	if( appIsDigit(*Buffer) )
	{
		*(BYTE*)Data = appAtoi( Buffer );
		while( *Buffer>='0' && *Buffer<='9' )
			Buffer++;
	}
	else
	{
		//debugf( "Import: Missing byte" );
		return NULL;
	}
	return Buffer;
}
IMPLEMENT_CLASS(UByteProperty);

/*-----------------------------------------------------------------------------
	UIntProperty.
-----------------------------------------------------------------------------*/

void UIntProperty::Link( FArchive& Ar, UProperty* Prev )
{
	Super::Link( Ar, Prev );
	ElementSize = sizeof(INT);
	Offset      = Align( GetOuterUField()->GetPropertiesSize(), sizeof(INT) );
}
void UIntProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(INT*)Dest = *(INT*)Src;
}
void UIntProperty::CopyCompleteValue( void* Dest, void* Src ) const
{
	if( ArrayDim==1 )
		*(INT*)Dest = *(INT*)Src;
	else
		for( INT i=0; i<ArrayDim; i++ )
			((INT*)Dest)[i] = ((INT*)Src)[i];
}
UBOOL UIntProperty::Identical( const void* A, const void* B ) const
{
	return *(INT*)A == (B ? *(INT*)B : 0);
}
void UIntProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar << *(INT*)Value;
}
UBOOL UIntProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	Ar << *(INT*)Data;
	return 1;
}
void UIntProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Log( TEXT("INT") );
}
void UIntProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	appSprintf( ValueStr, TEXT("%i"), *(INT *)PropertyValue );
}
const TCHAR* UIntProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	if( *Buffer=='-' || (*Buffer>='0' && *Buffer<='9') )
		*(INT*)Data = appAtoi( Buffer );
	while( *Buffer=='-' || (*Buffer>='0' && *Buffer<='9') )
		Buffer++;
	return Buffer;
}
IMPLEMENT_CLASS(UIntProperty);

/*-----------------------------------------------------------------------------
	UBoolProperty.
-----------------------------------------------------------------------------*/

void UBoolProperty::Link( FArchive& Ar, UProperty* Prev )
{
	Super::Link( Ar, Prev );
	UBoolProperty* PrevBool = Cast<UBoolProperty>( Prev );
	if( GetOuterUField()->MergeBools() && PrevBool && NEXT_BITFIELD(PrevBool->BitMask) )
	{
		Offset  = Prev->Offset;
		BitMask = NEXT_BITFIELD(PrevBool->BitMask);
	}
	else
	{
		Offset  = Align(GetOuterUField()->GetPropertiesSize(),sizeof(BITFIELD));
		BitMask = FIRST_BITFIELD;
	}
	ElementSize = sizeof(BITFIELD);
}
void UBoolProperty::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	if( !Ar.IsLoading() && !Ar.IsSaving() )
		Ar << BitMask;
}
void UBoolProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Log( TEXT("BITFIELD") );
}
void UBoolProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	TCHAR* Temp
	=	(TCHAR*) ((PortFlags & PPF_Localized)
	?	(((*(BITFIELD*)PropertyValue) & BitMask) ? GTrue  : GFalse )
	:	(((*(BITFIELD*)PropertyValue) & BitMask) ? TEXT("True") : TEXT("False")));
	appSprintf( ValueStr, TEXT("%s"), Temp );
}
const TCHAR* UBoolProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	TCHAR Temp[1024];
	Buffer = ReadToken( Buffer, Temp, ARRAY_COUNT(Temp) );
	if( !Buffer )
		return NULL;
	if( appStricmp(Temp,TEXT("1"))==0 || appStricmp(Temp,TEXT("True"))==0 || appStricmp(Temp,GTrue)==0 )
	{
		*(BITFIELD*)Data |= BitMask;
	}
	else if( appStricmp(Temp,TEXT("0"))==0 || appStricmp(Temp,TEXT("False"))==0  || appStricmp(Temp,GFalse)==0 )
	{
		*(BITFIELD*)Data &= ~BitMask;
	}
	else
	{
		//debugf( "Import: Failed to get bool" );
		return NULL;
	}
	return Buffer;
}
UBOOL UBoolProperty::Identical( const void* A, const void* B ) const
{
	return ((*(BITFIELD*)A ^ (B ? *(BITFIELD*)B : 0)) & BitMask) == 0;
}
void UBoolProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	BYTE B = (*(BITFIELD*)Value & BitMask) ? 1 : 0;
	Ar << B;
	if( B ) *(BITFIELD*)Value |=  BitMask;
	else    *(BITFIELD*)Value &= ~BitMask;
}
UBOOL UBoolProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{

	BYTE Value = ((*(BITFIELD*)Data & BitMask)!=0);
	Ar.SerializeBits( &Value, 1 );
	if( Value )
		*(BITFIELD*)Data |= BitMask;
	else
		*(BITFIELD*)Data &= ~BitMask;
	return 1;
}
void UBoolProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(BITFIELD*)Dest = (*(BITFIELD*)Dest & ~BitMask) | (*(BITFIELD*)Src & BitMask);
}
IMPLEMENT_CLASS(UBoolProperty);

/*-----------------------------------------------------------------------------
	UFloatProperty.
-----------------------------------------------------------------------------*/

void UFloatProperty::Link( FArchive& Ar, UProperty* Prev )
{
	Super::Link( Ar, Prev );
	ElementSize = sizeof(FLOAT);
	Offset      = Align( GetOuterUField()->GetPropertiesSize(), sizeof(FLOAT) );
}
void UFloatProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(FLOAT*)Dest = *(FLOAT*)Src;
}
void UFloatProperty::CopyCompleteValue( void* Dest, void* Src ) const
{
	if( ArrayDim==1 )
		*(FLOAT*)Dest = *(FLOAT*)Src;
	else
		for( INT i=0; i<ArrayDim; i++ )
			((FLOAT*)Dest)[i] = ((FLOAT*)Src)[i];
}
UBOOL UFloatProperty::Identical( const void* A, const void* B ) const
{
	return *(FLOAT*)A == (B ? *(FLOAT*)B : 0);
}
void UFloatProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar << *(FLOAT*)Value;
}
UBOOL UFloatProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	Ar << *(FLOAT*)Data;
	return 1;
}
void UFloatProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Log( TEXT("FLOAT") );
}
void UFloatProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	appSprintf( ValueStr, TEXT("%f"), *(FLOAT*)PropertyValue );
}
const TCHAR* UFloatProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	*(FLOAT*)Data = appAtof(Buffer);
	while( *Buffer && *Buffer!=',' && *Buffer!=')' && *Buffer!=13 && *Buffer!=10 )
		Buffer++;
	return Buffer;
}
IMPLEMENT_CLASS(UFloatProperty);

/*-----------------------------------------------------------------------------
	UObjectProperty.
-----------------------------------------------------------------------------*/

void UObjectProperty::Link( FArchive& Ar, UProperty* Prev )
{
	Super::Link( Ar, Prev );
	ElementSize = sizeof(UObject*);
	Offset      = Align( GetOuterUField()->GetPropertiesSize(), sizeof(UObject*) );
}
void UObjectProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(UObject**)Dest = *(UObject**)Src;
}
void UObjectProperty::CopyCompleteValue( void* Dest, void* Src ) const
{
	if( ArrayDim==1 )
		*(UObject**)Dest = *(UObject**)Src;
	else
		for( INT i=0; i<ArrayDim; i++ )
			((UObject**)Dest)[i] = ((UObject**)Src)[i];
}
UBOOL UObjectProperty::Identical( const void* A, const void* B ) const
{
	return *(UObject**)A == (B ? *(UObject**)B : NULL);
}
void UObjectProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar << *(UObject**)Value;
/*
	if(*(UObject **)Value)
	{
		TCHAR *MyName=(unsigned short *)GetFullName();
		if(!MyName) MyName=TEXT("NULL");
		debugf(_T(">> (%s): References:%s"),MyName,(*(UObject**)Value)->GetFullName());
	}
*/
}
UBOOL UObjectProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	return Map->SerializeObject( Ar, PropertyClass, *(UObject**)Data );
}
void UObjectProperty::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << PropertyClass;

}
void UObjectProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Logf( TEXT("class %s*"), PropertyClass->GetNameCPP() );
}
void UObjectProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	UObject* Temp = *(UObject **)PropertyValue;
	if( Temp != NULL )
		appSprintf( ValueStr, TEXT("%s'%s'"), Temp->GetClass()->GetName(), Temp->GetPathName() );
	else
		appStrcpy( ValueStr, TEXT("None") );
}
const TCHAR* UObjectProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	TCHAR Temp[1024], Other[1024];
	Buffer = ReadToken( Buffer, Temp, ARRAY_COUNT(Temp), 1 );
	if( !Buffer )
	{
		return NULL;
	}
	if( appStricmp( Temp, TEXT("None") )==0 )
	{
		*(UObject**)Data = NULL;
	}
	else
	{
		while( *Buffer == ' ' )
			Buffer++;
		if( *Buffer++ != '\'' )
		{
			*(UObject**)Data = StaticFindObject( PropertyClass, ANY_PACKAGE, Temp );
			if( !*(UObject**)Data )
				return NULL;
		}
		else
		{
			Buffer = ReadToken( Buffer, Other, ARRAY_COUNT(Temp), 1 );
			if( !Buffer )
				return NULL;
			if( *Buffer++ != '\'' )
				return NULL;
			UClass* ObjectClass = FindObject<UClass>( ANY_PACKAGE, Temp );
			if( !ObjectClass )
				return NULL;
			*(UObject**)Data = StaticFindObject( ObjectClass, ANY_PACKAGE, Other );
			if( !*(UObject**)Data )
				return NULL;
		}
	}
	return Buffer;
}
IMPLEMENT_CLASS(UObjectProperty);

/*-----------------------------------------------------------------------------
	UClassProperty.
-----------------------------------------------------------------------------*/

void UClassProperty::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << MetaClass;
	check(MetaClass);
}
const TCHAR* UClassProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	const TCHAR* Result = UObjectProperty::ImportText( Buffer, Data, PortFlags );
	if( Result )
	{
		// Validate metaclass.
		UClass*& C = *(UClass**)Data;
		if( C && C->GetClass()!=UClass::StaticClass() || !C->IsChildOf(MetaClass) )
			C = NULL;
	}
	return Result;
}
IMPLEMENT_CLASS(UClassProperty);

/*-----------------------------------------------------------------------------
	UNameProperty.
-----------------------------------------------------------------------------*/
void UNameProperty::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	if (Ar.LVer() >= 2)
	{
		Ar << NameOptionNameA << NameOptionNameB;
		Ar << NameOptionObjectA << NameOptionObjectB;
	}
	
}
void UNameProperty::Link( FArchive& Ar, UProperty* Prev )
{
	Super::Link( Ar, Prev );
	ElementSize = sizeof(FName);
	Offset      = Align( GetOuterUField()->GetPropertiesSize(), sizeof(FName) );
}
void UNameProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(FName*)Dest = *(FName*)Src;
}
void UNameProperty::CopyCompleteValue( void* Dest, void* Src ) const
{
	if( ArrayDim==1 )
		*(FName*)Dest = *(FName*)Src;
	else
		for( INT i=0; i<ArrayDim; i++ )
			((FName*)Dest)[i] = ((FName*)Src)[i];
}
UBOOL UNameProperty::Identical( const void* A, const void* B ) const
{
	return *(FName*)A == (B ? *(FName*)B : NAME_None);
}
void UNameProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar << *(FName*)Value;
}
void UNameProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Log( TEXT("FName") );
}
void UNameProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	FName Temp = *(FName*)PropertyValue;
	appStrcpy( ValueStr, *Temp );
}
const TCHAR* UNameProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	TCHAR Temp[1024];
	Buffer = ReadToken( Buffer, Temp, ARRAY_COUNT(Temp) );
	if( !Buffer )
		return NULL;
	*(FName*)Data = FName(Temp);
	return Buffer;
	
}
IMPLEMENT_CLASS(UNameProperty);

/*-----------------------------------------------------------------------------
	UStrProperty.
-----------------------------------------------------------------------------*/

void UStrProperty::Link( FArchive& Ar, UProperty* Prev )
{
	Super::Link( Ar, Prev );
	ElementSize    = sizeof(FString);
	Offset         = Align( GetOuterUField()->GetPropertiesSize(), PROPERTY_ALIGNMENT );
	if( !(PropertyFlags & CPF_Native) )
		PropertyFlags |= CPF_NeedCtorLink;
	
}
UBOOL UStrProperty::Identical( const void* A, const void* B ) const
{
	return appStricmp( **(const FString*)A, B ? **(const FString*)B : TEXT("") )==0;
}
void UStrProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
#if DNF
	if (Ar.IsLoading() && (Ar.MergeVer() > 63))
	{
		static char buf[256];
		INT count=0;
		do
		{
			BYTE b;
			Ar << b;
			buf[count++] = b;
		}
		while (buf[count-1]);
		Value = buf;
		return;
	}
#endif	
	Ar << *(FString*)Value;
}
void UStrProperty::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	
}
void UStrProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Log( TEXT("FString") );
	
}
void UStrProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	if( !(PortFlags & PPF_Delimited) )
		appStrcpy( ValueStr, **(FString*)PropertyValue );
	else
		appSprintf( ValueStr, TEXT("\"%s\""), **(FString*)PropertyValue );
	
}
const TCHAR* UStrProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{    
	if( !(PortFlags & PPF_Delimited) )
	{
		*(FString*)Data = Buffer;
	}
	else
	{
		TCHAR Temp[4096];//!!
		Buffer = ReadToken( Buffer, Temp, ARRAY_COUNT(Temp) );
		if( !Buffer )
			return NULL;
		*(FString*)Data = Temp;
	}
	return Buffer;
}
void UStrProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(FString*)Dest = *(FString*)Src;
}
void UStrProperty::DestroyValue( void* Dest ) const
{
	for( INT i=0; i<ArrayDim; i++ )
    {
		(*(FString*)((BYTE*)Dest+i*ElementSize)).~FString();
    }
}
IMPLEMENT_CLASS(UStrProperty);

/*-----------------------------------------------------------------------------
	UFixedArrayProperty.
-----------------------------------------------------------------------------*/

void UFixedArrayProperty::Link( FArchive& Ar, UProperty* Prev )
{
	checkSlow(Count>0);
	Super::Link( Ar, Prev );
	Ar.Preload( Inner );
	Inner->Link( Ar, NULL );
	ElementSize    = Inner->ElementSize * Count;
	Offset         = Align( GetOuterUField()->GetPropertiesSize(), PROPERTY_ALIGNMENT );
	if( !(PropertyFlags & CPF_Native) )
		PropertyFlags |= (Inner->PropertyFlags & CPF_NeedCtorLink);
	
}
UBOOL UFixedArrayProperty::Identical( const void* A, const void* B ) const
{
	checkSlow(Inner);
	for( INT i=0; i<Count; i++ )
		if( !Inner->Identical( (BYTE*)A+i*Inner->ElementSize, B ? ((BYTE*)B+i*Inner->ElementSize) : NULL ) )
			return 0;
	return 1;
}
void UFixedArrayProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	checkSlow(Inner);
	for( INT i=0; i<Count; i++ )
		Inner->SerializeItem( Ar, (BYTE*)Value + i*Inner->ElementSize );
}
UBOOL UFixedArrayProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	return 1;
}
void UFixedArrayProperty::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << Inner << Count;
	checkSlow(Inner);
	
}
void UFixedArrayProperty::ExportCppItem( FOutputDevice& Out ) const
{
	checkSlow(Inner);
	Inner->ExportCppItem( Out );
	Out.Logf( TEXT("[%i]"), Count );
	
}
void UFixedArrayProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	checkSlow(Inner);
	*ValueStr++ = '(';
	for( INT i=0; i<Count; i++ )
	{
		if( i>0 )
			*ValueStr++ = ',';
		Inner->ExportTextItem( ValueStr, PropertyValue + i*Inner->ElementSize, DefaultValue ? (DefaultValue + i*Inner->ElementSize) : NULL, PortFlags|PPF_Delimited );
		ValueStr += appStrlen(ValueStr);
	}
	*ValueStr++ = ')';
	*ValueStr++ = 0;
	
}
const TCHAR* UFixedArrayProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	checkSlow(Inner);
	if( *Buffer++ != '(' )
		return NULL;
	appMemzero( Data, ElementSize );
	for( INT i=0; i<Count; i++ )
	{
		Buffer = Inner->ImportText( Buffer, Data + i*Inner->ElementSize, PortFlags|PPF_Delimited );
		if( !Buffer )
			return NULL;
		if( *Buffer!=',' && i!=Count-1 )
			return NULL;
		Buffer++;
	}
	if( *Buffer++ != ')' )
		return NULL;
	return Buffer;
	
}
void UFixedArrayProperty::AddCppProperty( UProperty* Property, INT InCount )
{
	check(!Inner);
	check(Property);
	check(InCount>0);

	Inner = Property;
	Count = InCount;

	
}
void UFixedArrayProperty::CopySingleValue( void* Dest, void* Src ) const
{
	for( INT i=0; i<Count; i++ )
		Inner->CopyCompleteValue( (BYTE*)Dest + i*Inner->ElementSize, Src ? ((BYTE*)Src + i*Inner->ElementSize) : NULL );
}
void UFixedArrayProperty::DestroyValue( void* Dest ) const
{
	for( INT i=0; i<Count; i++ )
		Inner->DestroyValue( (BYTE*)Dest + i*Inner->ElementSize );
}
IMPLEMENT_CLASS(UFixedArrayProperty);

/*-----------------------------------------------------------------------------
	UArrayProperty.
-----------------------------------------------------------------------------*/

void UArrayProperty::Link( FArchive& Ar, UProperty* Prev )
{
	Super::Link( Ar, Prev );
	Ar.Preload( Inner );
	Inner->Link( Ar, NULL );
	ElementSize    = sizeof(FArray);
	Offset         = Align( GetOuterUField()->GetPropertiesSize(), PROPERTY_ALIGNMENT );
	if( !(PropertyFlags & CPF_Native) )
		PropertyFlags |= CPF_NeedCtorLink;
	
}
UBOOL UArrayProperty::Identical( const void* A, const void* B ) const
{
	checkSlow(Inner);
	INT n = ((FArray*)A)->Num();
	if( n!=(B ? ((FArray*)B)->Num() : 0) )
		return 0;
	INT   c = Inner->ElementSize;
	BYTE* p = (BYTE*)((FArray*)A)->GetData();
	if( B )
	{
		BYTE* q = (BYTE*)((FArray*)B)->GetData();
		for( INT i=0; i<n; i++ )
			if( !Inner->Identical( p+i*c, q+i*c ) )
				return 0;
	}
	else
	{
		for( INT i=0; i<n; i++ )
			if( !Inner->Identical( p+i*c, 0 ) )
				return 0;
	}
	return 1;
}
void UArrayProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	checkSlow(Inner);
	INT   c = Inner->ElementSize;
	INT   n = ((FArray*)Value)->Num();
	Ar << AR_INDEX(n);
	if( Ar.IsLoading() )
	{
		((FArray*)Value)->Empty( c );
		((FArray*)Value)->Add( n, c );
	}
	BYTE* p = (BYTE*)((FArray*)Value)->GetData();
	for( INT i=0; i<n; i++ )
		Inner->SerializeItem( Ar, p+i*c );
}
UBOOL UArrayProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	return 1;

}
void UArrayProperty::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << Inner;
	checkSlow(Inner);
	
}
void UArrayProperty::ExportCppItem( FOutputDevice& Out ) const
{

	checkSlow(Inner);
	Out.Log( TEXT("TArray<") );
	Inner->ExportCppItem( Out );
	Out.Log( TEXT(">") );
	
}
void UArrayProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{

	checkSlow(Inner);
	*ValueStr++ = '(';
	FArray* Array       = (FArray*)PropertyValue;
	FArray* Default     = (FArray*)DefaultValue;
	INT     ElementSize = Inner->ElementSize;
	for( INT i=0; i<Array->Num(); i++ )
	{
		if( i>0 )
			*ValueStr++ = ',';
		Inner->ExportTextItem( ValueStr, (BYTE*)Array->GetData() + i*ElementSize, Default ? (BYTE*)Default->GetData() + i*ElementSize : 0, PortFlags|PPF_Delimited );
		ValueStr += appStrlen(ValueStr);
	}
	*ValueStr++ = ')';
	*ValueStr++ = 0;
	
}
const TCHAR* UArrayProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{

	checkSlow(Inner);
	if( *Buffer++ != '(' )
		return NULL;
	FArray* Array       = (FArray*)Data;
	INT     ElementSize = Inner->ElementSize;
	Array->Empty( ElementSize );
	while( *Buffer != ')' )
	{
		INT Index = Array->Add( 1, ElementSize );
		appMemzero( (BYTE*)Array->GetData() + Index*ElementSize, ElementSize );
		Buffer = Inner->ImportText( Buffer, (BYTE*)Array->GetData() + Index*ElementSize, PortFlags|PPF_Delimited );
		if( !Buffer )
			return NULL;
		if( *Buffer!=',' )
			break;
		Buffer++;
	}
	if( *Buffer++ != ')' )
		return NULL;
	return Buffer;
	
}
void UArrayProperty::AddCppProperty( UProperty* Property )
{
	check(!Inner);
	check(Property);

	Inner = Property;	
}
void UArrayProperty::CopySingleValue( void* Dest, void* Src ) const
{
	FArray* SrcArray  = (FArray*)Src;
	FArray* DestArray = (FArray*)Dest;
	INT     Size      = Inner->ElementSize;
	DestArray->Empty( Size, SrcArray->Num() );//!!must destruct it if really copying
	if( Inner->PropertyFlags & CPF_NeedCtorLink )
	{
		// Copy all the elements.
		DestArray->AddZeroed( Size, SrcArray->Num() );
		BYTE* SrcData  = (BYTE*)SrcArray->GetData();
		BYTE* DestData = (BYTE*)DestArray->GetData();
		for( INT i=0; i<DestArray->Num(); i++ )
			Inner->CopyCompleteValue( DestData+i*Size, SrcData+i*Size );
	}
	else
	{
		// Copy all the elements.
		DestArray->Add( SrcArray->Num(), Size );
		appMemcpy( DestArray->GetData(), SrcArray->GetData(), SrcArray->Num()*Size );
	}
}
void UArrayProperty::DestroyValue( void* Dest ) const
{
	FArray* DestArray = (FArray*)Dest;
	if( Inner->PropertyFlags & CPF_NeedCtorLink )
	{
		BYTE* DestData = (BYTE*)DestArray->GetData();
		INT   Size     = Inner->ElementSize;
		for( INT i=0; i<DestArray->Num(); i++ )
			Inner->DestroyValue( DestData+i*Size );
	}
	DestArray->~FArray();
}
IMPLEMENT_CLASS(UArrayProperty);

/*-----------------------------------------------------------------------------
	UMapProperty.
-----------------------------------------------------------------------------*/

void UMapProperty::Link( FArchive& Ar, UProperty* Prev )
{
	Super::Link( Ar, Prev );
	Ar.Preload( Key );
	Key->Link( Ar, NULL );
	Ar.Preload( Value );
	Value->Link( Ar, NULL );
	ElementSize    = sizeof(TMap<BYTE,BYTE>);
	Offset         = Align( GetOuterUField()->GetPropertiesSize(), PROPERTY_ALIGNMENT );
	if( !(PropertyFlags&CPF_Native) )
		PropertyFlags |= CPF_NeedCtorLink;
	
}
UBOOL UMapProperty::Identical( const void* A, const void* B ) const
{
	checkSlow(Key);
	checkSlow(Value);
	/*
	INT n = ((FArray*)A)->Num();
	if( n!=(B ? ((FArray*)B)->Num() : 0) )
		return 0;
	INT   c = Inner->ElementSize;
	BYTE* p = (BYTE*)((FArray*)A)->GetData();
	if( B )
	{
		BYTE* q = (BYTE*)((FArray*)B)->GetData();
		for( INT i=0; i<n; i++ )
			if( !Inner->Identical( p+i*c, q+i*c ) )
				return 0;
	}
	else
	{
		for( INT i=0; i<n; i++ )
			if( !Inner->Identical( p+i*c, 0 ) )
				return 0;
	}
	*/
	return 1;
}
void UMapProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	checkSlow(Key);
	checkSlow(Value);
	/*
	INT   c = Inner->ElementSize;
	INT   n = ((FArray*)Value)->Num();
	Ar << AR_INDEX(n);
	if( Ar.IsLoading() )
	{
		((FArray*)Value)->Empty( c );
		((FArray*)Value)->Add( n, c );
	}
	BYTE* p = (BYTE*)((FArray*)Value)->GetData();
	for( INT i=0; i<n; i++ )
		Inner->SerializeItem( Ar, p+i*c );
	*/
}
UBOOL UMapProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	return 1;
}
void UMapProperty::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << Key << Value;
	checkSlow(Key);
	checkSlow(Value);
	
}
void UMapProperty::ExportCppItem( FOutputDevice& Out ) const
{
	checkSlow(Key);
	checkSlow(Value);
	Out.Log( TEXT("TMap<") );
	Key->ExportCppItem( Out );
	Out.Log( TEXT(",") );
	Value->ExportCppItem( Out );
	Out.Log( TEXT(">") );
	
}
void UMapProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	checkSlow(Key);
	checkSlow(Value);
	/*
	*ValueStr++ = '(';
	FArray* Array       = (FArray*)PropertyValue;
	FArray* Default     = (FArray*)DefaultValue;
	INT     ElementSize = Inner->ElementSize;
	for( INT i=0; i<Array->Num(); i++ )
	{
		if( i>0 )
			*ValueStr++ = ',';
		Inner->ExportTextItem( ValueStr, (BYTE*)Array->GetData() + i*ElementSize, Default ? (BYTE*)Default->GetData() + i*ElementSize : 0, PortFlags|PPF_Delimited );
		ValueStr += appStrlen(ValueStr);
	}
	*ValueStr++ = ')';
	*ValueStr++ = 0;
	*/
	
}
const TCHAR* UMapProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	checkSlow(Key);
	checkSlow(Value);
	/*
	if( *Buffer++ != '(' )
		return NULL;
	FArray* Array       = (FArray*)Data;
	INT     ElementSize = Inner->ElementSize;
	Array->Empty( ElementSize );
	while( *Buffer != ')' )
	{
		INT Index = Array->Add( 1, ElementSize );
		appMemzero( (BYTE*)Array->GetData() + Index*ElementSize, ElementSize );
		Buffer = Inner->ImportText( Buffer, (BYTE*)Array->GetData() + Index*ElementSize, PortFlags|PPF_Delimited );
		if( !Buffer )
			return NULL;
		if( *Buffer!=',' )
			break;
		Buffer++;
	}
	if( *Buffer++ != ')' )
		return NULL;
	*/
	return Buffer;
	
}
void UMapProperty::CopySingleValue( void* Dest, void* Src ) const
{
	/*
	TMap<BYTE,BYTE>* SrcMap    = (TMap<BYTE,BYTE>*)Src;
	TMap<BYTE,BYTE>* DestMap   = (TMap<BYTE,BYTE>*)Dest;
	INT              KeySize   = Key->ElementSize;
	INT              ValueSize = Value->ElementSize;
	DestMap->Empty( Size, SrcArray->Num() );//must destruct it if really copying
	if( Inner->PropertyFlags & CPF_NeedsCtorLink )
	{
		// Copy all the elements.
		DestArray->AddZeroed( Size, SrcArray->Num() );
		BYTE* SrcData  = (BYTE*)SrcArray->GetData();
		BYTE* DestData = (BYTE*)DestArray->GetData();
		for( INT i=0; i<DestArray->Num(); i++ )
			Inner->CopyCompleteValue( DestData+i*Size, SrcData+i*Size );
	}
	else
	{
		// Copy all the elements.
		DestArray->Add( SrcArray->Num(), Size );
		appMemcpy( DestArray->GetData(), SrcArray->GetData(), SrcArray->Num()*Size );
	}*/
}
void UMapProperty::DestroyValue( void* Dest ) const
{
	/*
	FArray* DestArray = (FArray*)Dest;
	if( Inner->PropertyFlags & CPF_NeedsCtorLink )
	{
		BYTE* DestData = (BYTE*)DestArray->GetData();
		INT   Size     = Inner->ElementSize;
		for( INT i=0; i<DestArray->Num(); i++ )
			Inner->DestroyValue( DestData+i*Size );
	}
	DestArray->~FArray();
	*/
}
IMPLEMENT_CLASS(UMapProperty);

/*-----------------------------------------------------------------------------
	UStructProperty.
-----------------------------------------------------------------------------*/

void UStructProperty::Link( FArchive& Ar, UProperty* Prev )
{
	Super::Link( Ar, Prev );
	Ar.Preload( Struct );
	ElementSize    = Struct->GetPropertiesSize();
	Offset         = Align( GetOuterUField()->GetPropertiesSize(), ElementSize==2 ? 2 : ElementSize>=4 ? 4 : 1 );
	if( Struct->ConstructorLink && !(PropertyFlags & CPF_Native) )
		PropertyFlags |= CPF_NeedCtorLink;
	
}
UBOOL UStructProperty::Identical( const void* A, const void* B ) const
{
	for( TFieldIterator<UProperty> It(Struct); It; ++It )
		for( INT i=0; i<It->ArrayDim; i++ )
			if( !It->Matches(A,B,i) )
				return 0;
	return 1;
}
void UStructProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar.Preload( Struct );
#if DNF
	// CDH: handle DNF version branch
	UBOOL UseTagged = ((Ar.MergeVer() > 63) || (Ar.LVer() >= 1));
	if ((UseTagged) && (Ar.IsLoading() || Ar.IsSaving()))
        Struct->SerializeTaggedProperties(Ar, (BYTE*)Value, NULL);
	else
		Struct->SerializeBin(Ar, (BYTE*)Value);
#else
	Struct->SerializeBin( Ar, (BYTE*)Value );
#endif
}
UBOOL UStructProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	if( Struct->GetFName()==NAME_Vector )
	{
		FVector& V = *(FVector*)Data;
#if ENGINE_VERSION<230 //oldver
		SWORD X(appRound(V.X)), Y(appRound(V.Y)), Z(appRound(V.Z));
		Ar << X << Y << Z;
		if( Ar.IsLoading() )
			V = FVector(X,Y,Z);
#else
		INT X(appRound(V.X)), Y(appRound(V.Y)), Z(appRound(V.Z));
		DWORD Bits = Clamp<DWORD>( appCeilLogTwo(1+Max(Max(Abs(X),Abs(Y)),Abs(Z))), 1, 16 )-1;
		Ar.SerializeInt( Bits, 16 );
		INT   Bias = 1<<(Bits+1);
		DWORD Max  = 1<<(Bits+2);
		DWORD DX(X+Bias), DY(Y+Bias), DZ(Z+Bias);
		Ar.SerializeInt( DX, Max );
		Ar.SerializeInt( DY, Max );
		Ar.SerializeInt( DZ, Max );
		if( Ar.IsLoading() )
			V = FVector((INT)DX-Bias,(INT)DY-Bias,(INT)DZ-Bias);
#endif
	}
	else if( Struct->GetFName()==NAME_Rotator )
	{
		FRotator& R = *(FRotator*)Data;
		BYTE Pitch(R.Pitch>>8), Yaw(R.Yaw>>8), Roll(R.Roll>>8), B;
		B = (Pitch!=0);
		Ar.SerializeBits( &B, 1 );
		if( B )
			Ar << Pitch;
		B = (Yaw!=0);
		Ar.SerializeBits( &B, 1 );
		if( B )
			Ar << Yaw;
		B = (Roll!=0);
		Ar.SerializeBits( &B, 1 );
		if( B )
			Ar << Roll;
		if( Ar.IsLoading() )
			R = FRotator(Pitch<<8,Yaw<<8,Roll<<8);
	}
	else if( Struct->GetFName()==NAME_Plane )
	{
		FPlane& P = *(FPlane*)Data;
		SWORD X(appRound(P.X)), Y(appRound(P.Y)), Z(appRound(P.Z)), W(appRound(P.W));
		Ar << X << Y << Z << W;
		if( Ar.IsLoading() )
			P = FPlane(X,Y,Z,W);
	}
	else
	{
		for( TFieldIterator<UProperty> It(Struct); It; ++It )
			if( Map->ObjectToIndex(*It)!=INDEX_NONE )
				for( INT i=0; i<It->ArrayDim; i++ )
					It->NetSerializeItem( Ar, Map, (BYTE*)Data+It->Offset+i*It->ArrayDim );
	}
	return 1;
}
void UStructProperty::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	Ar << Struct;
	
}
void UStructProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Logf( TEXT("%s"), Struct->GetNameCPP() );
	
}
void UStructProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	INT Count=0;
	for( TFieldIterator<UProperty> It(Struct); It; ++It )
	{
		if( It->Port() )
		{
			for( INT Index=0; Index<It->ArrayDim; Index++ )
			{
				TCHAR Value[65536];
				if( It->ExportText(Index,Value,PropertyValue,DefaultValue,PPF_Delimited) )
				{
					Count++;
					if( Count == 1 )
						*ValueStr++ = '(';
					else
						*ValueStr++ = ',';
					if( It->ArrayDim == 1 )
						ValueStr += appSprintf( ValueStr, TEXT("%s="), It->GetName() );
					else
						ValueStr += appSprintf( ValueStr, TEXT("%s[%i]="), It->GetName(), Index );
					ValueStr += appSprintf( ValueStr, TEXT("%s"), Value );
				}
			}
		}
	}
	if( Count > 0 )
	{
		*ValueStr++ = ')';
		*ValueStr = 0;
	}
	
}
const TCHAR* UStructProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	if( *Buffer++ == '(' )
	{
		// Parse all properties.
		while( *Buffer != ')' )
		{
			// Get key name.
			TCHAR Name[NAME_SIZE];
			int Count=0;
			while( Count<NAME_SIZE-1 && *Buffer && *Buffer!='=' && *Buffer!='[' )
				Name[Count++] = *Buffer++;
			Name[Count++] = 0;

			// Get optional array element.
			INT Element=0;
			if( *Buffer=='[' )
			{
				const TCHAR* Start=++Buffer;
				while( *Buffer>='0' && *Buffer<='9' )
					Buffer++;
				if( *Buffer++ != ']' )
				{
					GWarn->Logf( NAME_Warning, TEXT("ImportText: Illegal array element %s"), Buffer );
					return NULL;
				}
				Element = appAtoi( Start );
			}

			// Verify format.
			if( *Buffer++ != '=' )
			{
				GWarn->Logf( NAME_Warning, TEXT("ImportText: Illegal or missing key name") );
				return NULL;
			}

			// See if the property exists in the struct.
			FName GotName( Name, FNAME_Find );
			UBOOL Parsed = 0;
			if( GotName!=NAME_None )
			{
				for( TFieldIterator<UProperty> It(Struct); It; ++It )
				{
					UProperty* Property = *It;
					if
					(	Property->GetFName()==GotName
					&&	Element>=0
					&&	Element<Property->ArrayDim
					&&	Property->GetSize()!=0
					&&	Property->Port() )
					{
						// Import this property.
						Buffer = Property->ImportText( Buffer, Data + Property->Offset + Element*Property->ElementSize, PortFlags|PPF_Delimited );
						if( Buffer == NULL )
							return NULL;

						// Done with this property.
						Parsed = 1;
					}
				}
			}

			// If not parsed, skip this property in the stream.
			if( !Parsed )
			{
				INT SubCount=0;
				while
				(	*Buffer
				&&	*Buffer!=10
				&&	*Buffer!=13 
				&&	(SubCount>0 || *Buffer!=')')
				&&	(SubCount>0 || *Buffer!=',') )
				{
					if( *Buffer == 0x22 )
					{
						while( *Buffer && *Buffer!=0x22 && *Buffer!=10 && *Buffer!=13 )
							Buffer++;
						if( *Buffer != 0x22 )
						{
							GWarn->Logf( NAME_Warning, TEXT("ImportText: Bad quoted string") );
							return NULL;
						}
					}
					else if( *Buffer == '(' )
					{
						SubCount++;
					}
					else if( *Buffer == ')' )
					{
						SubCount--;
						if( SubCount < 0 )
						{
							debugf( NAME_Warning, TEXT("ImportText: Bad parenthesised struct") );
							return NULL;
						}
					}
					Buffer++;
				}
				if( SubCount > 0 )
				{
					debugf( NAME_Warning, TEXT("ImportText: Incomplete parenthesised struct") );
					return NULL;
				}
			}

			// Skip comma.
			if( *Buffer==',' )
			{
				// Skip comma.
				Buffer++;
			}
			else if( *Buffer!=')' )
			{
				debugf( NAME_Warning, TEXT("ImportText: Bad termination") );
				return NULL;
			}
		}

		// Skip trailing ')'.
		Buffer++;
	}
	else
	{
		debugf( NAME_Warning, TEXT("ImportText: Struct missing '('") );
		return NULL;
	}
	return Buffer;
	
}
void UStructProperty::CopySingleValue( void* Dest, void* Src ) const
{
	for( TFieldIterator<UProperty> It(Struct); It; ++It )
		It->CopyCompleteValue( (BYTE*)Dest + It->Offset, (BYTE*)Src + It->Offset );
	//could just do memcpy + ReinstanceCompleteValue
}
void UStructProperty::DestroyValue( void* Dest ) const
{
	for( UProperty* P=Struct->ConstructorLink; P; P=P->ConstructorLinkNext )
		for( INT i=0; i<ArrayDim; i++ )
			P->DestroyValue( (BYTE*)Dest + i*ElementSize + P->Offset );
}
IMPLEMENT_CLASS(UStructProperty);

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
