/*=============================================================================
	UnCorSc.cpp: UnrealScript execution and support code.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

Description:
	UnrealScript execution and support code.

Revision history:
	* Created by Tim Sweeney 

=============================================================================*/

#include "..\..\Engine\Src\EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Globals.
-----------------------------------------------------------------------------*/

CORE_API Native GNatives[EX_Max];

//CORE_API void (__fastcall UObject::*GNatives[EX_Max])( FFrame &Stack, RESULT_DECL );
CORE_API INT GNativeDuplicate=0;

#define RUNAWAY_LIMIT 10000000
#define RECURSE_LIMIT 250

#if DO_GUARD
	static INT Runaway=0;
	static INT Recurse=0;
	#define CHECK_RUNAWAY {if( ++Runaway > RUNAWAY_LIMIT ) {if(!ParseParam(appCmdLine(),TEXT("norunaway"))) Stack.Logf( NAME_Critical, TEXT("Runaway loop detected (over %i iterations)"), RUNAWAY_LIMIT ); Runaway=0;}}
	CORE_API void GInitRunaway() {Recurse=Runaway=0;}
#else
	#define CHECK_RUNAWAY
	CORE_API void GInitRunaway() {}
#endif

/*-----------------------------------------------------------------------------
	FFrame implementation.
-----------------------------------------------------------------------------*/

//
// Error or warning handler.
//
void FFrame::Serialize( const TCHAR* V, EName Event )
{
	if( Event==NAME_Critical || GIsStrict ) appErrorf
	(
		TEXT("%s (%s:%04X) %s"),
		Object->GetFullName(),
		Node->GetFullName(),
		Code - &Node->Script(0),
		V
	);
	else debugf
	(
		NAME_ScriptWarning,
		TEXT("%s (%s:%04X) %s"),
		Object->GetFullName(),
		Node->GetFullName(),
		Code - &Node->Script(0),
		V
	);
}

#define MAX_CALL_STACK 256
struct StackNode 
{
	UObject *Object;
	UFunction *Function;
};

StackNode CallStack[MAX_CALL_STACK];
int CallStackPointer=0;

/*-----------------------------------------------------------------------------
	Global script execution functions.
-----------------------------------------------------------------------------*/

//
// Have an object go to a named state, and idle at no label.
// If state is NAME_None or was not found, goes to no state.
// Returns 1 if we went to a state, 0 if went to no state.
//
EGotoState __fastcall UObject::GotoState( FName NewState, UBOOL PurgeStack )
{
	CallStackPointer=0;

	if( !StateFrame )
		return GOTOSTATE_NotFound;

	if (PurgeStack)
	{
		// CDH: eliminate child states
		// Note that this does not send endstate notifications to the child states, they are simply wiped out,
		// as any notification would bring a risk of changing the state stack in a way that cannot be allowed
		// when the children are slated to be purged in the end.
		while (StateFrame->StateStack)
		{
			FStateFrame* Fr = StateFrame;
			StateFrame = Fr->StateStack;
			Fr->StateStack = NULL;
			delete Fr;
		}
	}

	StateFrame->LatentAction = 0;
	UState* StateNode = NULL;
	FName OldStateName = StateFrame->StateNode!=Class ? StateFrame->StateNode->GetFName() : NAME_None;
	if( NewState != NAME_Auto )
	{
		// Find regular state.
		StateNode = FindState( NewState );
	}
	else
	{
		// Find auto state.
		for( TFieldIterator<UState> It(GetClass()); It && !StateNode; ++It )
			if( It->StateFlags & STATE_Auto )
			{
				StateNode = *It;
				break;				// NJS: Shouldn't need to search any further after it finds the auto state.
			}
	}

	if( !StateNode )
	{
		// Going nowhere.
		NewState  = NAME_None;
		StateNode = GetClass();
	}
	else if( NewState == NAME_Auto )
	{
		// Going to auto state.
		NewState = StateNode->GetFName();
	}

	// Send EndState notification.
	if
	(	OldStateName!=NAME_None
	&&	NewState!=OldStateName
	&&	IsProbing(NAME_EndState) 
	&&	!(GetFlags() & RF_InEndState) )
	{
		ClearFlags( RF_StateChanged );
		SetFlags( RF_InEndState );
		eventEndState();
		ClearFlags( RF_InEndState );
		if( GetFlags() & RF_StateChanged )
			return GOTOSTATE_Preempted;
	}

	// Go there.
	StateFrame->Node	   = StateNode;
	StateFrame->StateNode  = StateNode;
	StateFrame->Code	   = NULL;
	StateFrame->ProbeMask  = (StateNode->ProbeMask | GetClass()->ProbeMask) & StateNode->IgnoreMask;

	// Send BeginState notification.
	if( NewState!=NAME_None && NewState!=OldStateName && IsProbing(NAME_BeginState) )
	{
		ClearFlags( RF_StateChanged );
		eventBeginState();
		if( GetFlags() & RF_StateChanged )
			return GOTOSTATE_Preempted;
	}

	// Return result.
	if( NewState != NAME_None )
	{
		SetFlags( RF_StateChanged );
		return GOTOSTATE_Success;
	}
	else return GOTOSTATE_NotFound;

}

//
// Goto a label in the current state.
// Returns 1 if went, 0 if not found.
//
UBOOL UObject::GotoLabel( FName FindLabel )
{
	if( StateFrame )
	{
		StateFrame->LatentAction = 0;
		if( FindLabel != NAME_None )
		{
			for( UState* SourceState=StateFrame->StateNode; SourceState; SourceState=SourceState->GetSuperState() )
			{
				if( SourceState->LabelTableOffset != MAXWORD )
				{
					for( FLabelEntry* Label = (FLabelEntry *)&SourceState->Script(SourceState->LabelTableOffset); Label->Name!=NAME_None; Label++ )
					{
						if( Label->Name==FindLabel )
						{
							StateFrame->Node = SourceState;
							StateFrame->Code = &SourceState->Script(Label->iCode);
							return 1;
						}
					}
				}
			}
		}
		StateFrame->Code = NULL;
	}
	return 0;
}

/*-----------------------------------------------------------------------------
	Natives.
-----------------------------------------------------------------------------*/

//////////////////////////////
// Undefined native handler //
//////////////////////////////

void __fastcall UObject::execUndefined( FFrame& Stack, RESULT_DECL  )
{
	Stack.Logf( NAME_Critical, TEXT("Unknown code token %02X"), Stack.Code[-1] );
}

///////////////
// Variables //
///////////////
void __fastcall UObject::execLocalVariable( FFrame& Stack, RESULT_DECL )
{
	GProperty = (UProperty*)Stack.ReadObject();
	GPropAddr = Stack.Locals + GProperty->Offset;
	if( Result )
		GProperty->CopyCompleteValue( Result, GPropAddr );
}
IMPLEMENT_FUNCTION( UObject, EX_LocalVariable, execLocalVariable );

void __fastcall UObject::execInstanceVariable( FFrame& Stack, RESULT_DECL )
{
	GProperty = (UProperty*)Stack.ReadObject();	
    GPropAddr = (BYTE*)this + GProperty->Offset;
	if( Result )
		GProperty->CopyCompleteValue( Result, GPropAddr );
}
IMPLEMENT_FUNCTION( UObject, EX_InstanceVariable, execInstanceVariable );

void __fastcall UObject::execDefaultVariable( FFrame& Stack, RESULT_DECL )
{
	GProperty = (UProperty*)Stack.ReadObject();
	GPropAddr = &GetClass()->Defaults[CPD_Normal](GProperty->Offset);
	if( Result )
		GProperty->CopyCompleteValue( Result, GPropAddr );
}
IMPLEMENT_FUNCTION( UObject, EX_DefaultVariable, execDefaultVariable );

void __fastcall UObject::execClassContext( FFrame& Stack, RESULT_DECL )
{
	// Get class expression.
	UClass* ClassContext=NULL;
	Stack.Step( Stack.Object, &ClassContext );

	// Execute expression in class context.
	if( ClassContext )
	{
		Stack.Code += 4; // CDH: Was 3, before size was changed to 16 bits
		Stack.Step( ClassContext->GetDefaultObject(), Result );
	}
	else
	{
		Stack.Logf( TEXT("Accessed null class context") );
		INT wSkip = Stack.ReadWord();
		INT bSize = Stack.ReadWord(); //BYTE bSize = *Stack.Code++; // CDH size changed
		Stack.Code += wSkip;
		GPropAddr = NULL;
		GProperty = NULL;
		if( Result )
			appMemzero( Result, bSize );
	}
}
IMPLEMENT_FUNCTION( UObject, EX_ClassContext, execClassContext );

void __fastcall UObject::execArrayElement( FFrame& Stack, RESULT_DECL )
{

	// Get array index expression.
	INT Index=0;
	Stack.Step( Stack.Object, &Index );

	// Get base element (must be a variable!!).
	GProperty = NULL;
	Stack.Step( this, NULL );

	// Add scaled offset to base pointer.
	if( GProperty && GPropAddr )
	{
		// Bounds check.
		if( Index>=GProperty->ArrayDim || Index<0 )
		{
			// Display out-of-bounds warning and continue on with index clamped to valid range.
			Stack.Logf( TEXT("Accessed array out of bounds (%i/%i)"), Index, GProperty->ArrayDim );
			Index = Clamp( Index, 0, GProperty->ArrayDim - 1 );
		}

		// Update address.
		GPropAddr += Index * GProperty->ElementSize;
		if( Result )//!!
			GProperty->CopySingleValue( Result, GPropAddr );
	}
}
IMPLEMENT_FUNCTION( UObject, EX_ArrayElement, execArrayElement );

void __fastcall UObject::execDynArrayElement( FFrame& Stack, RESULT_DECL )
{
	// Get array index expression.
	INT Index=0;
	Stack.Step( Stack.Object, &Index );

	// Get FArray (only works with variables that have a GProperty!!) This is experimental and doesn't work yet.
	FArray* Array=NULL;
	Stack.Step( this, *(BYTE**)&Array );
	check(GProperty);
	check(GProperty->IsA(UArrayProperty::StaticClass()));
	check(Array);//!!
	check(Array->Num()!=0);//!! Needs to handle zero-element arrays gracefully.

	// Bounds check.
	if( Index>=Array->Num() || Index<0 )
	{
		// Display out-of-bounds warning and continue on with index clamped to valid range.
		//!!must work like null-context expressions.
		Stack.Logf( TEXT("Accessed array out of bounds (%i/%i)"), Index, GProperty->ArrayDim );
		Index = Clamp( Index, 0, Array->Num() - 1 );
	}

	// Add scaled offset to base pointer.
	//if( Result )
	//	Result = (BYTE*)Array->GetData() + *(INT*)Addr * ((UArrayProperty*)GProperty)->Inner->ElementSize;
}
IMPLEMENT_FUNCTION( UObject, EX_DynArrayElement, execDynArrayElement );

void __fastcall UObject::execBoolVariable( FFrame& Stack, RESULT_DECL )
{
	// Get bool variable.
	BYTE B = *Stack.Code++;
	UBoolProperty* Property = *(UBoolProperty**)Stack.Code;
	(this->*GNatives[B])( Stack, NULL );
	GProperty = Property;

	// Note that we're not returning an in-place pointer to to the bool, so EX_Let 
	// must take special precautions with bools.
	if( Result )
		*(BITFIELD*)Result = (GPropAddr && (*(BITFIELD*)GPropAddr & ((UBoolProperty*)GProperty)->BitMask)) ? 1 : 0;

}
IMPLEMENT_FUNCTION( UObject, EX_BoolVariable, execBoolVariable );

void UObject::execStructMember( FFrame& Stack, RESULT_DECL )
{
	// Get structure element.
	UProperty* Property = (UProperty*)Stack.ReadObject();

	// Get struct expression.
	UStruct* Struct = CastChecked<UStruct>(Property->GetOuter());
	BYTE* Buffer = (BYTE*)appAlloca(Struct->GetPropertiesSize());
	appMemzero( Buffer, Struct->GetPropertiesSize() );
	GPropAddr = NULL;
	Stack.Step( this, Buffer );

	// Set result.
	GProperty = Property;
	if( GPropAddr )
		GPropAddr += Property->Offset;
	if( Result )
		Property->CopyCompleteValue( Result, Buffer+Property->Offset );
	for( UProperty* P=Struct->ConstructorLink; P; P=P->ConstructorLinkNext )
		P->DestroyValue( Buffer + P->Offset );
}
IMPLEMENT_FUNCTION( UObject, EX_StructMember, execStructMember );

/////////////
// Nothing //
/////////////

void __fastcall UObject::execNothing( FFrame& Stack, RESULT_DECL )
{
	// Do nothing.
}
IMPLEMENT_FUNCTION( UObject, EX_Nothing, execNothing );

void __fastcall UObject::execNativeParm( FFrame& Stack, RESULT_DECL )
{
	UProperty* Property = (UProperty*)Stack.ReadObject();
    if( Result )
	{
		GPropAddr = Stack.Locals + Property->Offset;
		Property->CopyCompleteValue( Result, Stack.Locals + Property->Offset );
	}
}
IMPLEMENT_FUNCTION( UObject, EX_NativeParm, execNativeParm );

void __fastcall UObject::execEndFunctionParms( FFrame& Stack, RESULT_DECL )
{
	// For skipping over optional function parms without values specified.
	Stack.Code--;
}
IMPLEMENT_FUNCTION( UObject, EX_EndFunctionParms, execEndFunctionParms );

//////////////
// Commands //
//////////////

void __fastcall UObject::execStop( FFrame& Stack, RESULT_DECL )
{
	Stack.Code = NULL;
}
IMPLEMENT_FUNCTION( UObject, EX_Stop, execStop );

//!!warning: Does not support UProperty's fully, will break
// when TArray's are supported in UnrealScript!
void __fastcall UObject::execSwitch( FFrame& Stack, RESULT_DECL )
{

	// Get switch size.
	INT bSize = Stack.ReadWord(); //BYTE bSize = *Stack.Code++; // CDH size changed

	// Get switch expression.
	BYTE SwitchBuffer[1024], Buffer[1024];
	appMemzero( Buffer,       sizeof(FString) );
	appMemzero( SwitchBuffer, sizeof(FString) );
	Stack.Step( Stack.Object, SwitchBuffer );

	// Check each case clause till we find a match.
	for( ; ; )
	{
		// Skip over case token.
		checkSlow(*Stack.Code==EX_Case);
		Stack.Code++;

		// Get address of next handler.
		INT wNext = Stack.ReadWord();
		if( wNext == MAXWORD ) // Default case or end of cases.
			break;

		// Get case expression.
		Stack.Step( Stack.Object, Buffer );

		// Compare.
		if( bSize ? (appMemcmp(SwitchBuffer,Buffer,bSize)==0) : (*(FString*)SwitchBuffer==*(FString*)Buffer) )
			break;

		// Jump to next handler.
		Stack.Code = &Stack.Node->Script(wNext);
	}
	if( !bSize )
	{
		(*(FString*)SwitchBuffer).~FString();
		(*(FString*)Buffer      ).~FString();
	}
}
IMPLEMENT_FUNCTION( UObject, EX_Switch, execSwitch );

void __fastcall UObject::execCase( FFrame& Stack, RESULT_DECL )
{
	INT wNext = Stack.ReadWord();
	if( wNext != MAXWORD )
	{
		// Skip expression.
		BYTE Buffer[1024];
		appMemzero( Buffer, sizeof(FString) );
		Stack.Step( Stack.Object, Buffer );
	}
}
IMPLEMENT_FUNCTION( UObject, EX_Case, execCase );

void __fastcall UObject::execJump( FFrame& Stack, RESULT_DECL )
{
	CHECK_RUNAWAY;

	// Jump immediate.
	Stack.Code = &Stack.Node->Script(Stack.ReadWord() );

}
IMPLEMENT_FUNCTION( UObject, EX_Jump, execJump );

void __fastcall UObject::execJumpIfNot( FFrame& Stack, RESULT_DECL )
{
	CHECK_RUNAWAY;

	// Get code offset.
	INT wOffset = Stack.ReadWord();

	// Get boolean test value.
	UBOOL Value=0;
	Stack.Step( Stack.Object, &Value );

	// Jump if false.
	if( !Value )
		Stack.Code = &Stack.Node->Script( wOffset );

}
IMPLEMENT_FUNCTION( UObject, EX_JumpIfNot, execJumpIfNot );

void __fastcall UObject::execAssert( FFrame& Stack, RESULT_DECL )
{
	// Get line number.
	INT wLine = Stack.ReadWord();

	// Get boolean assert value.
	DWORD Value=0;
	Stack.Step( Stack.Object, &Value );

	// Check it.
	if( !Value )
		Stack.Logf( NAME_Critical, TEXT("Assertion failed, line %i"), wLine );

}
IMPLEMENT_FUNCTION( UObject, EX_Assert, execAssert );

void __fastcall UObject::execGotoLabel( FFrame& Stack, RESULT_DECL )
{

	P_GET_NAME(N);
	if( !GotoLabel( N ) )
		Stack.Logf( TEXT("GotoLabel (%s): Label not found"), N );

}
IMPLEMENT_FUNCTION( UObject, EX_GotoLabel, execGotoLabel );

////////////////
// Assignment //
////////////////

void __fastcall UObject::execLet( FFrame& Stack, RESULT_DECL )
{
	checkSlow(!IsA(UBoolProperty::StaticClass()));

	// Get variable address.
	GPropAddr = NULL;
	Stack.Step( Stack.Object, NULL ); // Evaluate variable.
	if( !GPropAddr )
	{
		Stack.Logf( NAME_ScriptWarning, TEXT("Attempt to assigned variable through None") );
		static BYTE Crud[1024];//!!temp
		GPropAddr = Crud;
		appMemzero( GPropAddr, sizeof(FString) );
	}
	Stack.Step( Stack.Object, GPropAddr ); // Evaluate expression into variable.

}
IMPLEMENT_FUNCTION( UObject, EX_Let, execLet );

void __fastcall UObject::execLetBool( FFrame& Stack, RESULT_DECL )
{

	// Get variable address.
	GPropAddr = NULL;
	GProperty = NULL;
	Stack.Step( Stack.Object, NULL ); // Variable.
	BITFIELD*      BoolAddr     = (BITFIELD*)GPropAddr;
	UBoolProperty* BoolProperty = (UBoolProperty*)GProperty;
	BITFIELD Value=0;
	Stack.Step( Stack.Object, &Value );
	if( BoolAddr )
	{
		check(BoolProperty->IsA(UBoolProperty::StaticClass()));
		if( Value ) *BoolAddr |=  BoolProperty->BitMask;
		else        *BoolAddr &= ~BoolProperty->BitMask;
	}

}
IMPLEMENT_FUNCTION( UObject, EX_LetBool, execLetBool );

/////////////////////////
// Context expressions //
/////////////////////////

void __fastcall UObject::execSelf( FFrame& Stack, RESULT_DECL )
{

	// Get Self actor for this context.
	*(UObject**)Result = this;

}
IMPLEMENT_FUNCTION( UObject, EX_Self, execSelf );

void __fastcall UObject::execContext( FFrame& Stack, RESULT_DECL )
{

	// Get actor variable.
	UObject* NewContext=NULL;
	Stack.Step( this, &NewContext );

	// Execute or skip the following expression in the actor's context.
	if( NewContext != NULL )
	{
		Stack.Code += 4; // CDH: Was 3, before size was changed to 16 bits
		Stack.Step( NewContext, Result );
	}
	else
	{
		Stack.Logf( TEXT("Accessed None") );
		INT wSkip = Stack.ReadWord();
		INT bSize = Stack.ReadWord(); //BYTE bSize = *Stack.Code++; // CDH size changed
		Stack.Code += wSkip;
		GPropAddr = NULL;
		GProperty = NULL;
		if( Result )
			appMemzero( Result, bSize );
	}
}
IMPLEMENT_FUNCTION( UObject, EX_Context, execContext );

////////////////////
// Function calls //
////////////////////

void __fastcall UObject::execVirtualFunction( FFrame& Stack, RESULT_DECL )
{
	// Call the virtual function.
	CallFunction( Stack, Result, FindFunctionChecked(Stack.ReadName()) );
}
IMPLEMENT_FUNCTION( UObject, EX_VirtualFunction, execVirtualFunction );

void __fastcall UObject::execFinalFunction( FFrame& Stack, RESULT_DECL )
{

	// Call the final function.
	CallFunction( Stack, Result, (UFunction*)Stack.ReadObject() );

}
IMPLEMENT_FUNCTION( UObject, EX_FinalFunction, execFinalFunction );

void __fastcall UObject::execGlobalFunction( FFrame& Stack, RESULT_DECL )
{

	// Call global version of virtual function.
	CallFunction( Stack, Result, FindFunctionChecked(Stack.ReadName(),1) );

}
IMPLEMENT_FUNCTION( UObject, EX_GlobalFunction, execGlobalFunction );

///////////////////////
// Struct comparison //
///////////////////////

void __fastcall UObject::execStructCmpEq( FFrame& Stack, RESULT_DECL )
{
	UStruct* Struct  = (UStruct*)Stack.ReadObject();
	BYTE*    Buffer1 = (BYTE*)appAlloca(Struct->GetPropertiesSize());
	BYTE*    Buffer2 = (BYTE*)appAlloca(Struct->GetPropertiesSize());
	appMemzero( Buffer1, Struct->GetPropertiesSize() );
	appMemzero( Buffer2, Struct->GetPropertiesSize() );
	Stack.Step( this, Buffer1 );
	Stack.Step( this, Buffer2 );
	*(DWORD*)Result  = Struct->StructCompare( Buffer1, Buffer2 );
}
IMPLEMENT_FUNCTION( UObject, EX_StructCmpEq, execStructCmpEq );

void __fastcall UObject::execStructCmpNe( FFrame& Stack, RESULT_DECL )
{
	UStruct* Struct = (UStruct*)Stack.ReadObject();
	BYTE*    Buffer1 = (BYTE*)appAlloca(Struct->GetPropertiesSize());
	BYTE*    Buffer2 = (BYTE*)appAlloca(Struct->GetPropertiesSize());
	appMemzero( Buffer1, Struct->GetPropertiesSize() );
	appMemzero( Buffer2, Struct->GetPropertiesSize() );
	Stack.Step( this, Buffer1 );
	Stack.Step( this, Buffer2 );
	*(DWORD*)Result = !Struct->StructCompare(Buffer1,Buffer2);
}
IMPLEMENT_FUNCTION( UObject, EX_StructCmpNe, execStructCmpNe );

///////////////
// Constants //
///////////////

void __fastcall UObject::execIntConst( FFrame& Stack, RESULT_DECL )
{
	*(INT*)Result = Stack.ReadInt();
}
IMPLEMENT_FUNCTION( UObject, EX_IntConst, execIntConst );

void __fastcall UObject::execFloatConst( FFrame& Stack, RESULT_DECL )
{
	*(FLOAT*)Result = Stack.ReadFloat();
}
IMPLEMENT_FUNCTION( UObject, EX_FloatConst, execFloatConst );

void __fastcall UObject::execStringConst( FFrame& Stack, RESULT_DECL )
{
	*(FString*)Result = appFromAnsi((ANSICHAR*)Stack.Code);
	while( *Stack.Code )
		Stack.Code++;
	Stack.Code++;
}
IMPLEMENT_FUNCTION( UObject, EX_StringConst, execStringConst );

void __fastcall UObject::execUnicodeStringConst( FFrame& Stack, RESULT_DECL )
{
	*(FString*)Result = appFromUnicode((UNICHAR*)Stack.Code);
	while( *(_WORD*)Stack.Code )
		Stack.Code+=sizeof(_WORD);
	Stack.Code+=sizeof(_WORD);
}
IMPLEMENT_FUNCTION( UObject, EX_UnicodeStringConst, execUnicodeStringConst );

void __fastcall UObject::execObjectConst( FFrame& Stack, RESULT_DECL )
{
	*(UObject**)Result = (UObject*)Stack.ReadObject();
}
IMPLEMENT_FUNCTION( UObject, EX_ObjectConst, execObjectConst );

void __fastcall UObject::execNameConst( FFrame& Stack, RESULT_DECL )
{
	*(FName*)Result = Stack.ReadName();
}
IMPLEMENT_FUNCTION( UObject, EX_NameConst, execNameConst );

void __fastcall UObject::execByteConst( FFrame& Stack, RESULT_DECL )
{
	*(BYTE*)Result = *Stack.Code++;
}
IMPLEMENT_FUNCTION( UObject, EX_ByteConst, execByteConst );

void __fastcall UObject::execIntZero( FFrame& Stack, RESULT_DECL )
{
	*(INT*)Result = 0;
}
IMPLEMENT_FUNCTION( UObject, EX_IntZero, execIntZero );

void __fastcall UObject::execIntOne( FFrame& Stack, RESULT_DECL )
{
	*(INT*)Result = 1;
}
IMPLEMENT_FUNCTION( UObject, EX_IntOne, execIntOne );

void __fastcall UObject::execTrue( FFrame& Stack, RESULT_DECL )
{
	*(INT*)Result = 1;
}
IMPLEMENT_FUNCTION( UObject, EX_True, execTrue );

void __fastcall UObject::execFalse( FFrame& Stack, RESULT_DECL )
{
	*(DWORD*)Result = 0;
}
IMPLEMENT_FUNCTION( UObject, EX_False, execFalse );

void __fastcall UObject::execNoObject( FFrame& Stack, RESULT_DECL )
{
	*(UObject**)Result = NULL;
}
IMPLEMENT_FUNCTION( UObject, EX_NoObject, execNoObject );

void __fastcall UObject::execIntConstByte( FFrame& Stack, RESULT_DECL )
{
	*(INT*)Result = *Stack.Code++;
}
IMPLEMENT_FUNCTION( UObject, EX_IntConstByte, execIntConstByte );

/////////////////
// Conversions //
/////////////////

void __fastcall UObject::execDynamicCast( FFrame& Stack, RESULT_DECL )
{
	// Get destination class of dynamic actor class.
	UClass* Class = (UClass *)Stack.ReadObject();

	// Compile object expression.
	UObject* Castee = NULL;
	Stack.Step( Stack.Object, &Castee );
	*(UObject**)Result = (Castee && Castee->IsA(Class)) ? Castee : NULL;
}
IMPLEMENT_FUNCTION( UObject, EX_DynamicCast, execDynamicCast );

void __fastcall UObject::execMetaCast( FFrame& Stack, RESULT_DECL )
{
	// Get destination class of dynamic actor class.
	UClass* MetaClass = (UClass*)Stack.ReadObject();

	// Compile actor expression.
	UObject* Castee=NULL;
	Stack.Step( Stack.Object, &Castee );
	*(UObject**)Result = (Castee && Castee->IsA(UClass::StaticClass()) && ((UClass*)Castee)->IsChildOf(MetaClass)) ? Castee : NULL;

}
IMPLEMENT_FUNCTION( UObject, EX_MetaCast, execMetaCast );

void __fastcall UObject::execByteToInt( FFrame& Stack, RESULT_DECL )
{
	BYTE B=0;
	Stack.Step( Stack.Object, &B );
	*(INT*)Result = B;
}
IMPLEMENT_FUNCTION( UObject, EX_ByteToInt, execByteToInt );

void __fastcall UObject::execByteToBool( FFrame& Stack, RESULT_DECL )
{
	BYTE B=0;
	Stack.Step( Stack.Object, &B );
	*(DWORD*)Result = B ? 1 : 0;
}
IMPLEMENT_FUNCTION( UObject, EX_ByteToBool, execByteToBool );

void __fastcall UObject::execByteToFloat( FFrame& Stack, RESULT_DECL )
{
	BYTE B=0;
	Stack.Step( Stack.Object, &B );
	*(FLOAT*)Result = B;
}
IMPLEMENT_FUNCTION( UObject, EX_ByteToFloat, execByteToFloat );

void __fastcall UObject::execByteToString( FFrame& Stack, RESULT_DECL )
{
	P_GET_BYTE(B);
	*(FString*)Result = FString::Printf(TEXT("%i"),B);
}
IMPLEMENT_FUNCTION( UObject, EX_ByteToString, execByteToString );

void __fastcall UObject::execIntToByte( FFrame& Stack, RESULT_DECL )
{
	INT I=0;
	Stack.Step( Stack.Object, &I );
	*(BYTE*)Result = I;
}
IMPLEMENT_FUNCTION( UObject, EX_IntToByte, execIntToByte );

void __fastcall UObject::execIntToBool( FFrame& Stack, RESULT_DECL )
{
	INT I=0;
	Stack.Step( Stack.Object, &I );
	*(INT*)Result = I ? 1 : 0;
}
IMPLEMENT_FUNCTION( UObject, EX_IntToBool, execIntToBool );

void __fastcall UObject::execIntToFloat( FFrame& Stack, RESULT_DECL )
{
	INT I=0;
	Stack.Step( Stack.Object, &I );
	*(FLOAT*)Result = I;
}
IMPLEMENT_FUNCTION( UObject, EX_IntToFloat, execIntToFloat );

void __fastcall UObject::execIntToString( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT(I);
	*(FString*)Result = FString::Printf(TEXT("%i"),I);
}
IMPLEMENT_FUNCTION( UObject, EX_IntToString, execIntToString );

void __fastcall UObject::execBoolToByte( FFrame& Stack, RESULT_DECL )
{
	UBOOL B=0;
	Stack.Step( Stack.Object, &B );
	*(BYTE*)Result = B & 1;
}
IMPLEMENT_FUNCTION( UObject, EX_BoolToByte, execBoolToByte );

void __fastcall UObject::execBoolToInt( FFrame& Stack, RESULT_DECL )
{
	UBOOL B=0;
	Stack.Step( Stack.Object, &B );
	*(INT*)Result = B & 1;
}
IMPLEMENT_FUNCTION( UObject, EX_BoolToInt, execBoolToInt );

void __fastcall UObject::execBoolToFloat( FFrame& Stack, RESULT_DECL )
{
	UBOOL B=0;
	Stack.Step( Stack.Object, &B );
	*(FLOAT*)Result = B & 1;
}
IMPLEMENT_FUNCTION( UObject, EX_BoolToFloat, execBoolToFloat );

void __fastcall UObject::execBoolToString( FFrame& Stack, RESULT_DECL )
{
	P_GET_UBOOL(B);
	*(FString*)Result = B ? GTrue : GFalse;
}
IMPLEMENT_FUNCTION( UObject, EX_BoolToString, execBoolToString );

void __fastcall UObject::execFloatToByte( FFrame& Stack, RESULT_DECL )
{
	FLOAT F=0.f;
	Stack.Step( Stack.Object, &F );
	*(BYTE*)Result = (BYTE)F;
}
IMPLEMENT_FUNCTION( UObject, EX_FloatToByte, execFloatToByte );

void __fastcall UObject::execFloatToInt( FFrame& Stack, RESULT_DECL )
{
	FLOAT F=0.f;
	Stack.Step( Stack.Object, &F );
	*(INT*)Result = (INT)F;
}
IMPLEMENT_FUNCTION( UObject, EX_FloatToInt, execFloatToInt );

void __fastcall UObject::execFloatToBool( FFrame& Stack, RESULT_DECL )
{
	FLOAT F=0.f;
	Stack.Step( Stack.Object, &F );
	*(DWORD*)Result = F!=0.0 ? 1 : 0;
}
IMPLEMENT_FUNCTION( UObject, EX_FloatToBool, execFloatToBool );

void __fastcall UObject::execFloatToString( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(F);
	*(FString*)Result = FString::Printf(TEXT("%f"),F);
}
IMPLEMENT_FUNCTION( UObject, EX_FloatToString, execFloatToString );

void __fastcall UObject::execObjectToBool( FFrame& Stack, RESULT_DECL )
{
	UObject* Obj=NULL;
	Stack.Step( Stack.Object, &Obj );
	*(DWORD*)Result = Obj!=NULL;
}
IMPLEMENT_FUNCTION( UObject, EX_ObjectToBool, execObjectToBool );

void __fastcall UObject::execObjectToString( FFrame& Stack, RESULT_DECL )
{
	P_GET_OBJECT(UObject,Obj);
	*(FString*)Result = Obj ? Obj->GetPathName() : TEXT("None");
}
IMPLEMENT_FUNCTION( UObject, EX_ObjectToString, execObjectToString );

void __fastcall UObject::execNameToBool( FFrame& Stack, RESULT_DECL )
{
	FName N=NAME_None;
	Stack.Step( Stack.Object, &N );
	*(DWORD*)Result = N!=NAME_None ? 1 : 0;
}
IMPLEMENT_FUNCTION( UObject, EX_NameToBool, execNameToBool );

void __fastcall UObject::execNameToString( FFrame& Stack, RESULT_DECL )
{
	P_GET_NAME(N);
	*(FString*)Result = *N;
}
IMPLEMENT_FUNCTION( UObject, EX_NameToString, execNameToString );

void __fastcall UObject::execStringToByte( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Str);
	*(BYTE*)Result = appAtoi( *Str );
}
IMPLEMENT_FUNCTION( UObject, EX_StringToByte, execStringToByte );

void __fastcall UObject::execStringToInt( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Str);
	*(INT*)Result = appAtoi( *Str );
}
IMPLEMENT_FUNCTION( UObject, EX_StringToInt, execStringToInt );

void __fastcall UObject::execStringToBool( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Str);
	if( appStricmp(*Str,TEXT("True") )==0 || appStricmp(*Str,GTrue)==0 )
	{
		*(INT*)Result = 1;
	}
	else if( appStricmp(*Str,TEXT("False"))==0 || appStricmp(*Str,GFalse)==0 )
	{
		*(INT*)Result = 0;
	}
	else
	{
		*(INT*)Result = appAtoi(*Str) ? 1 : 0;
	}
}
IMPLEMENT_FUNCTION( UObject, EX_StringToBool, execStringToBool );

void __fastcall UObject::execStringToFloat( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Str);
	*(FLOAT*)Result = appAtof( *Str );
}
IMPLEMENT_FUNCTION( UObject, EX_StringToFloat, execStringToFloat );

/////////////////////////////////////////
// Native bool operators and functions //
/////////////////////////////////////////

void __fastcall UObject::execNot_PreBool( FFrame& Stack, RESULT_DECL )
{

	P_GET_UBOOL(A);
	P_FINISH;

	*(DWORD*)Result = !A;

}
IMPLEMENT_FUNCTION( UObject, 129, execNot_PreBool );

void __fastcall UObject::execEqualEqual_BoolBool( FFrame& Stack, RESULT_DECL )
{

	P_GET_UBOOL(A);
	P_GET_UBOOL(B);
	P_FINISH;

	*(DWORD*)Result = ((!A) == (!B));
}
IMPLEMENT_FUNCTION( UObject, 242, execEqualEqual_BoolBool );

void __fastcall UObject::execNotEqual_BoolBool( FFrame& Stack, RESULT_DECL )
{

	P_GET_UBOOL(A);
	P_GET_UBOOL(B);
	P_FINISH;

	*(DWORD*)Result = ((!A) != (!B));

}
IMPLEMENT_FUNCTION( UObject, 243, execNotEqual_BoolBool );

void __fastcall UObject::execAndAnd_BoolBool( FFrame& Stack, RESULT_DECL )
{

	P_GET_UBOOL(A);
	P_GET_SKIP_OFFSET(W);

	if( A )
	{
		P_GET_UBOOL(B);
		*(DWORD*)Result = A && B;
		P_FINISH;
	}
	else
	{
		*(DWORD*)Result = 0;
		Stack.Code += W;
	}
}
IMPLEMENT_FUNCTION( UObject, 130, execAndAnd_BoolBool );

void __fastcall UObject::execXorXor_BoolBool( FFrame& Stack, RESULT_DECL )
{

	P_GET_UBOOL(A);
	P_GET_UBOOL(B);
	P_FINISH;

	*(DWORD*)Result = !A ^ !B;

}
IMPLEMENT_FUNCTION( UObject, 131, execXorXor_BoolBool );

void __fastcall UObject::execOrOr_BoolBool( FFrame& Stack, RESULT_DECL )
{
	P_GET_UBOOL(A);
	P_GET_SKIP_OFFSET(W);
	if( !A )
	{
		P_GET_UBOOL(B);
		*(DWORD*)Result = A || B;
		P_FINISH;
	}
	else
	{
		*(DWORD*)Result = 1;
		Stack.Code += W;
	}
}
IMPLEMENT_FUNCTION( UObject, 132, execOrOr_BoolBool );

/////////////////////////////////////////
// Native byte operators and functions //
/////////////////////////////////////////

void __fastcall UObject::execMultiplyEqual_ByteByte( FFrame& Stack, RESULT_DECL )
{

	P_GET_BYTE_REF(A);
	P_GET_BYTE(B);
	P_FINISH;

	*(BYTE*)Result = (*A *= B);

}
IMPLEMENT_FUNCTION( UObject, 133, execMultiplyEqual_ByteByte );

void __fastcall UObject::execDivideEqual_ByteByte( FFrame& Stack, RESULT_DECL )
{

	P_GET_BYTE_REF(A);
	P_GET_BYTE(B);
	P_FINISH;

	*(BYTE*)Result = B ? (*A /= B) : 0;

}
IMPLEMENT_FUNCTION( UObject, 134, execDivideEqual_ByteByte );

void __fastcall UObject::execAddEqual_ByteByte( FFrame& Stack, RESULT_DECL )
{

	P_GET_BYTE_REF(A);
	P_GET_BYTE(B);
	P_FINISH;

	*(BYTE*)Result = (*A += B);

}
IMPLEMENT_FUNCTION( UObject, 135, execAddEqual_ByteByte );

void __fastcall UObject::execSubtractEqual_ByteByte( FFrame& Stack, RESULT_DECL )
{

	P_GET_BYTE_REF(A);
	P_GET_BYTE(B);
	P_FINISH;

	*(BYTE*)Result = (*A -= B);

}
IMPLEMENT_FUNCTION( UObject, 136, execSubtractEqual_ByteByte );

void __fastcall UObject::execAddAdd_PreByte( FFrame& Stack, RESULT_DECL )
{

	P_GET_BYTE_REF(A);
	P_FINISH;

	*(BYTE*)Result = ++(*A);

}
IMPLEMENT_FUNCTION( UObject, 137, execAddAdd_PreByte );

void __fastcall UObject::execSubtractSubtract_PreByte( FFrame& Stack, RESULT_DECL )
{

	P_GET_BYTE_REF(A);
	P_FINISH;

	*(BYTE*)Result = --(*A);

}
IMPLEMENT_FUNCTION( UObject, 138, execSubtractSubtract_PreByte );

void __fastcall UObject::execAddAdd_Byte( FFrame& Stack, RESULT_DECL )
{

	P_GET_BYTE_REF(A);
	P_FINISH;

	*(BYTE*)Result = (*A)++;

}
IMPLEMENT_FUNCTION( UObject, 139, execAddAdd_Byte );

void __fastcall UObject::execSubtractSubtract_Byte( FFrame& Stack, RESULT_DECL )
{

	P_GET_BYTE_REF(A);
	P_FINISH;

	*(BYTE*)Result = (*A)--;

}
IMPLEMENT_FUNCTION( UObject, 140, execSubtractSubtract_Byte );

/////////////////////////////////
// Int operators and functions //
/////////////////////////////////

void __fastcall UObject::execComplement_PreInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_FINISH;

	*(INT*)Result = ~A;

}
IMPLEMENT_FUNCTION( UObject, 141, execComplement_PreInt );

void __fastcall UObject::execGreaterGreaterGreater_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = ((DWORD)A) >> B;

}
IMPLEMENT_FUNCTION( UObject, 196, execGreaterGreaterGreater_IntInt );

void __fastcall UObject::execSubtract_PreInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_FINISH;

	*(INT*)Result = -A;

}
IMPLEMENT_FUNCTION( UObject, 143, execSubtract_PreInt );

void __fastcall UObject::execMultiply_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = A * B;

}
IMPLEMENT_FUNCTION( UObject, 144, execMultiply_IntInt );

void __fastcall UObject::execDivide_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = B ? A / B : 0;

}
IMPLEMENT_FUNCTION( UObject, 145, execDivide_IntInt );

void __fastcall UObject::execAdd_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = A + B;

}
IMPLEMENT_FUNCTION( UObject, 146, execAdd_IntInt );

void __fastcall UObject::execSubtract_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = A - B;

}
IMPLEMENT_FUNCTION( UObject, 147, execSubtract_IntInt );

void __fastcall UObject::execLessLess_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = A << B;

}
IMPLEMENT_FUNCTION( UObject, 148, execLessLess_IntInt );

void __fastcall UObject::execGreaterGreater_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = A >> B;

}
IMPLEMENT_FUNCTION( UObject, 149, execGreaterGreater_IntInt );

void __fastcall UObject::execLess_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(DWORD*)Result = A < B;

}
IMPLEMENT_FUNCTION( UObject, 150, execLess_IntInt );

void __fastcall UObject::execGreater_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(DWORD*)Result = A > B;

}
IMPLEMENT_FUNCTION( UObject, 151, execGreater_IntInt );

void __fastcall UObject::execLessEqual_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(DWORD*)Result = A <= B;

}
IMPLEMENT_FUNCTION( UObject, 152, execLessEqual_IntInt );

void __fastcall UObject::execGreaterEqual_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(DWORD*)Result = A >= B;

}
IMPLEMENT_FUNCTION( UObject, 153, execGreaterEqual_IntInt );

void __fastcall UObject::execEqualEqual_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(DWORD*)Result = A == B;

}
IMPLEMENT_FUNCTION( UObject, 154, execEqualEqual_IntInt );

void __fastcall UObject::execNotEqual_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(DWORD*)Result = A != B;

}
IMPLEMENT_FUNCTION( UObject, 155, execNotEqual_IntInt );

void __fastcall UObject::execAnd_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = A & B;

}
IMPLEMENT_FUNCTION( UObject, 156, execAnd_IntInt );

void __fastcall UObject::execXor_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = A ^ B;

}
IMPLEMENT_FUNCTION( UObject, 157, execXor_IntInt );

void __fastcall UObject::execOr_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = A | B;

}
IMPLEMENT_FUNCTION( UObject, 158, execOr_IntInt );

void __fastcall UObject::execMultiplyEqual_IntFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT_REF(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(INT*)Result = *A = (INT)(*A * B);

}
IMPLEMENT_FUNCTION( UObject, 159, execMultiplyEqual_IntFloat );

void __fastcall UObject::execDivideEqual_IntFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT_REF(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(INT*)Result = *A = (INT)(B ? *A/B : 0.f);

}
IMPLEMENT_FUNCTION( UObject, 160, execDivideEqual_IntFloat );

void __fastcall UObject::execAddEqual_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT_REF(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = (*A += B);

}
IMPLEMENT_FUNCTION( UObject, 161, execAddEqual_IntInt );

void __fastcall UObject::execSubtractEqual_IntInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT_REF(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = (*A -= B);

}
IMPLEMENT_FUNCTION( UObject, 162, execSubtractEqual_IntInt );

void __fastcall UObject::execAddAdd_PreInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT_REF(A);
	P_FINISH;

	*(INT*)Result = ++(*A);

}
IMPLEMENT_FUNCTION( UObject, 163, execAddAdd_PreInt );

void __fastcall UObject::execSubtractSubtract_PreInt( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT_REF(A);
	P_FINISH;

	*(INT*)Result = --(*A);

}
IMPLEMENT_FUNCTION( UObject, 164, execSubtractSubtract_PreInt );

void __fastcall UObject::execAddAdd_Int( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT_REF(A);
	P_FINISH;

	*(INT*)Result = (*A)++;

}
IMPLEMENT_FUNCTION( UObject, 165, execAddAdd_Int );

void __fastcall UObject::execSubtractSubtract_Int( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT_REF(A);
	P_FINISH;

	*(INT*)Result = (*A)--;

}
IMPLEMENT_FUNCTION( UObject, 166, execSubtractSubtract_Int );

void __fastcall UObject::execSeed( FFrame& Stack, RESULT_DECL )
{
	P_GET_INT(Seed);
	P_FINISH;

	appSrand( Seed );

}
IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execSeed );

void __fastcall UObject::execRand( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_FINISH;

	*(INT*)Result = A>0 ? (appRand() % A) : 0;

}
IMPLEMENT_FUNCTION( UObject, 167, execRand );

void __fastcall UObject::execMin( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = Min(A,B);

}
IMPLEMENT_FUNCTION( UObject, 249, execMin );

void __fastcall UObject::execMax( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = Max(A,B);

}
IMPLEMENT_FUNCTION( UObject, 250, execMax );

void __fastcall UObject::execClamp( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(V);
	P_GET_INT(A);
	P_GET_INT(B);
	P_FINISH;

	*(INT*)Result = Clamp(V,A,B);

}
IMPLEMENT_FUNCTION( UObject, 251, execClamp );

void __fastcall UObject::execRound( FFrame& Stack, RESULT_DECL )
{
	P_GET_FLOAT(A);
	P_FINISH;

	*(INT*)Result = appRound(A);

}
IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execRound );

///////////////////////////////////
// Float operators and functions //
///////////////////////////////////

void __fastcall UObject::execSubtract_PreFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_FINISH;

	*(FLOAT*)Result = -A;

}	
IMPLEMENT_FUNCTION( UObject, 169, execSubtract_PreFloat );

void __fastcall UObject::execMultiplyMultiply_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = appPow(A,B);

}	
IMPLEMENT_FUNCTION( UObject, 170, execMultiplyMultiply_FloatFloat );

void __fastcall UObject::execMultiply_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = A * B;

}	
IMPLEMENT_FUNCTION( UObject, 171, execMultiply_FloatFloat );

void __fastcall UObject::execDivide_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = A / B;

}	
IMPLEMENT_FUNCTION( UObject, 172, execDivide_FloatFloat );

void __fastcall UObject::execPercent_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = appFmod(A,B);

}	
IMPLEMENT_FUNCTION( UObject, 173, execPercent_FloatFloat );

void __fastcall UObject::execAdd_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = A + B;

}	
IMPLEMENT_FUNCTION( UObject, 174, execAdd_FloatFloat );

void __fastcall UObject::execSubtract_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = A - B;

}	
IMPLEMENT_FUNCTION( UObject, 175, execSubtract_FloatFloat );

void __fastcall UObject::execLess_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(DWORD*)Result = A < B;

}	
IMPLEMENT_FUNCTION( UObject, 176, execLess_FloatFloat );

void __fastcall UObject::execGreater_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(DWORD*)Result = A > B;

}	
IMPLEMENT_FUNCTION( UObject, 177, execGreater_FloatFloat );

void __fastcall UObject::execLessEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(DWORD*)Result = A <= B;

}	
IMPLEMENT_FUNCTION( UObject, 178, execLessEqual_FloatFloat );

void __fastcall UObject::execGreaterEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(DWORD*)Result = A >= B;

}	
IMPLEMENT_FUNCTION( UObject, 179, execGreaterEqual_FloatFloat );

void __fastcall UObject::execEqualEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(DWORD*)Result = A == B;

}	
IMPLEMENT_FUNCTION( UObject, 180, execEqualEqual_FloatFloat );

void __fastcall UObject::execNotEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(DWORD*)Result = A != B;

}	
IMPLEMENT_FUNCTION( UObject, 181, execNotEqual_FloatFloat );

void __fastcall UObject::execComplementEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(DWORD*)Result = Abs(A - B) < (1.e-4);

	
}	
IMPLEMENT_FUNCTION( UObject, 210, execComplementEqual_FloatFloat );

void __fastcall UObject::execMultiplyEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT_REF(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = (*A *= B);

	
}	
IMPLEMENT_FUNCTION( UObject, 182, execMultiplyEqual_FloatFloat );

void __fastcall UObject::execDivideEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT_REF(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = (*A /= B);

	
}	
IMPLEMENT_FUNCTION( UObject, 183, execDivideEqual_FloatFloat );

void __fastcall UObject::execAddEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT_REF(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = (*A += B);

	
}	
IMPLEMENT_FUNCTION( UObject, 184, execAddEqual_FloatFloat );

void __fastcall UObject::execSubtractEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT_REF(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = (*A -= B);

	
}	
IMPLEMENT_FUNCTION( UObject, 185, execSubtractEqual_FloatFloat );

void __fastcall UObject::execAbs( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_FINISH;

	*(FLOAT*)Result = Abs(A);

	
}	
IMPLEMENT_FUNCTION( UObject, 186, execAbs );

void __fastcall UObject::execSin( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_FINISH;

	*(FLOAT*)Result = appSin(A);

	
}	
IMPLEMENT_FUNCTION( UObject, 187, execSin );

void __fastcall UObject::execCos( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_FINISH;

	*(FLOAT*)Result = appCos(A);

	
}	
IMPLEMENT_FUNCTION( UObject, 188, execCos );

void __fastcall UObject::execAcos( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_FINISH;

	*(FLOAT*)Result = appAcos(A);

	
}	
IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execAcos );

void __fastcall UObject::execTan( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_FINISH;

	*(FLOAT*)Result = appTan(A);

	
}	
IMPLEMENT_FUNCTION( UObject, 189, execTan );

void __fastcall UObject::execAtan( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_FINISH;

	*(FLOAT*)Result = appAtan(A);

	
}	
IMPLEMENT_FUNCTION( UObject, 190, execAtan );

void __fastcall UObject::execAtan2( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(Y);
	P_GET_FLOAT(X);
	P_FINISH;

	*(FLOAT*)Result = appAtan2(Y, X);

	
}	
IMPLEMENT_FUNCTION( UObject, 207, execAtan2 );

void __fastcall UObject::execExp( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_FINISH;

	*(FLOAT*)Result = appExp(A);

	
}	
IMPLEMENT_FUNCTION( UObject, 191, execExp );

void __fastcall UObject::execLoge( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_FINISH;

	*(FLOAT*)Result = appLoge(A);

	
}	
IMPLEMENT_FUNCTION( UObject, 192, execLoge );

void __fastcall UObject::execSqrt( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_FINISH;

	*(FLOAT*)Result = appSqrt(A);

	
}	
IMPLEMENT_FUNCTION( UObject, 193, execSqrt );

void __fastcall UObject::execSquare( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_FINISH;

	*(FLOAT*)Result = Square(A);

	
}	
IMPLEMENT_FUNCTION( UObject, 194, execSquare );

void __fastcall UObject::execFRand( FFrame& Stack, RESULT_DECL )
{

	P_FINISH;

	*(FLOAT*)Result = appFrand();

	
}	
IMPLEMENT_FUNCTION( UObject, 195, execFRand );

void __fastcall UObject::execFMin( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = Min(A,B);

	
}	
IMPLEMENT_FUNCTION( UObject, 244, execFMin );

void __fastcall UObject::execFMax( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = Max(A,B);

	
}	
IMPLEMENT_FUNCTION( UObject, 245, execFMax );

void __fastcall UObject::execFClamp( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(V);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = Clamp(V,A,B);

	
}	
IMPLEMENT_FUNCTION( UObject, 246, execFClamp );

void __fastcall UObject::execLerp( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(V);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = A + V*(B-A);

	
}	
IMPLEMENT_FUNCTION( UObject, 247, execLerp );

void __fastcall UObject::execSmerp( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(V);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FLOAT*)Result = A + (3.0*V*V - 2.0*V*V*V)*(B-A);

	
}
IMPLEMENT_FUNCTION( UObject, 248, execSmerp );

void __fastcall UObject::execSlerp( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(Alpha);
	P_GET_ROTATOR(A);
	P_GET_ROTATOR(B);
	P_FINISH;

	FCoords CoordsA(GMath.UnitCoords / A);
	FCoords CoordsB(GMath.UnitCoords / B);
	FQuat QuatA(CoordsA);
	FQuat QuatB(CoordsB);

	FQuat QuatR; QuatR.Slerp(QuatA, QuatB, 1.f-Alpha, Alpha, false);
	FCoords CoordsR(QuatR);
	*(FRotator*)Result = CoordsR.OrthoRotation();

	
}
IMPLEMENT_FUNCTION( UObject, 208, execSlerp );

void __fastcall UObject::execRotationConst( FFrame& Stack, RESULT_DECL )
{
	((FRotator*)Result)->Pitch = Stack.ReadInt();
	((FRotator*)Result)->Yaw   = Stack.ReadInt();
	((FRotator*)Result)->Roll  = Stack.ReadInt();
	
}
IMPLEMENT_FUNCTION( UObject, EX_RotationConst, execRotationConst );

void __fastcall UObject::execVectorConst( FFrame& Stack, RESULT_DECL )
{
	*(FVector*)Result = *(FVector*)Stack.Code;
	Stack.Code += sizeof(FVector);
	
}
IMPLEMENT_FUNCTION( UObject, EX_VectorConst, execVectorConst );

/////////////////
// Conversions //
/////////////////

void __fastcall UObject::execStringToVector( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Str);

	const TCHAR* Stream = *Str;
	FVector Value(0,0,0);
	Value.X = appAtof(Stream);
	Stream = appStrchr(Stream,',');
	if( Stream )
	{
		Value.Y = appAtof(++Stream);
		Stream = appStrchr(Stream,',');
		if( Stream )
			Value.Z = appAtof(++Stream);
	}
	*(FVector*)Result = Value;

	
}
IMPLEMENT_FUNCTION( UObject, EX_StringToVector, execStringToVector );

void __fastcall UObject::execStringToRotator( FFrame& Stack, RESULT_DECL )
{
	P_GET_STR(Str);

	const TCHAR* Stream = *Str;
	FRotator Rotation(0,0,0);
	Rotation.Pitch = appAtoi(Stream);
	Stream = appStrchr(Stream,',');
	if( Stream )
	{
		Rotation.Yaw = appAtoi(++Stream);
		Stream = appStrchr(Stream,',');
		if( Stream )
			Rotation.Roll = appAtoi(++Stream);
	}
	*(FRotator*)Result = Rotation;

	
}
IMPLEMENT_FUNCTION( UObject, EX_StringToRotator, execStringToRotator );

void __fastcall UObject::execVectorToBool( FFrame& Stack, RESULT_DECL )
{
	FVector V(0,0,0);
	Stack.Step( Stack.Object, &V );
	*(DWORD*)Result = V.IsZero() ? 0 : 1;
	
}
IMPLEMENT_FUNCTION( UObject, EX_VectorToBool, execVectorToBool );

void __fastcall UObject::execVectorToString( FFrame& Stack, RESULT_DECL )
{
	P_GET_VECTOR(V);
	*(FString*)Result = FString::Printf( TEXT("%f,%f,%f"), V.X, V.Y, V.Z );
	
}
IMPLEMENT_FUNCTION( UObject, EX_VectorToString, execVectorToString );

void __fastcall UObject::execVectorToRotator( FFrame& Stack, RESULT_DECL )
{
	FVector V(0,0,0);
	Stack.Step( Stack.Object, &V );
	*(FRotator*)Result = V.Rotation();
	
}
IMPLEMENT_FUNCTION( UObject, EX_VectorToRotator, execVectorToRotator );

void __fastcall UObject::execRotatorToBool( FFrame& Stack, RESULT_DECL )
{
	FRotator R(0,0,0);
	Stack.Step( Stack.Object, &R );
	*(DWORD*)Result = R.IsZero() ? 0 : 1;
	
}
IMPLEMENT_FUNCTION( UObject, EX_RotatorToBool, execRotatorToBool );

void __fastcall UObject::execRotatorToVector( FFrame& Stack, RESULT_DECL )
{
	FRotator R(0,0,0);
	Stack.Step( Stack.Object, &R );
	*(FVector*)Result = R.Vector();
	
}
IMPLEMENT_FUNCTION( UObject, EX_RotatorToVector, execRotatorToVector );

void __fastcall UObject::execRotatorToString( FFrame& Stack, RESULT_DECL )
{
	P_GET_ROTATOR(R);
	*(FString*)Result = FString::Printf( TEXT("%i,%i,%i"), R.Pitch&65535, R.Yaw&65535, R.Roll&65535 );
	
}
IMPLEMENT_FUNCTION( UObject, EX_RotatorToString, execRotatorToString );

////////////////////////////////////
// Vector operators and functions //
////////////////////////////////////

void __fastcall UObject::execVect( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT_OPTX(X,0);
	P_GET_FLOAT_OPTX(Y,0);
	P_GET_FLOAT_OPTX(Z,0);
	P_FINISH;

	*(FVector*)Result = FVector(X,Y,Z);

	
}
IMPLEMENT_FUNCTION( UObject, 204, execVect );

void __fastcall UObject::execSubtract_PreVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_FINISH;

	*(FVector*)Result = -A;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 83, execSubtract_PreVector );

void __fastcall UObject::execMultiply_VectorFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_FLOAT (B);
	P_FINISH;

	*(FVector*)Result = A*B;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 84, execMultiply_VectorFloat );

void __fastcall UObject::execMultiply_FloatVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT (A);
	P_GET_VECTOR(B);
	P_FINISH;

	*(FVector*)Result = A*B;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 85, execMultiply_FloatVector );

void __fastcall UObject::execMultiply_VectorVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	P_FINISH;

	*(FVector*)Result = A*B;

	
}	
IMPLEMENT_FUNCTION( UObject, 296, execMultiply_VectorVector );

void __fastcall UObject::execDivide_VectorFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_FLOAT (B);
	P_FINISH;

	*(FVector*)Result = A/B;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 86, execDivide_VectorFloat );

void __fastcall UObject::execAdd_VectorVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	P_FINISH;

	*(FVector*)Result = A+B;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 87, execAdd_VectorVector );

void __fastcall UObject::execSubtract_VectorVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	P_FINISH;

	*(FVector*)Result = A-B;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 88, execSubtract_VectorVector );

void __fastcall UObject::execLessLess_VectorRotator( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_ROTATOR(B);
	P_FINISH;

	*(FVector*)Result = A.TransformVectorBy(GMath.UnitCoords / B);

	
}	
IMPLEMENT_FUNCTION( UObject, 275, execLessLess_VectorRotator );

void __fastcall UObject::execGreaterGreater_VectorRotator( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_ROTATOR(B);
	P_FINISH;

	*(FVector*)Result = A.TransformVectorBy(GMath.UnitCoords * B);

	
}	
IMPLEMENT_FUNCTION( UObject, 276, execGreaterGreater_VectorRotator );

void __fastcall UObject::execEqualEqual_VectorVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	P_FINISH;

	*(DWORD*)Result = A.X==B.X && A.Y==B.Y && A.Z==B.Z;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 89, execEqualEqual_VectorVector );

void __fastcall UObject::execNotEqual_VectorVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	P_FINISH;

	*(DWORD*)Result = A.X!=B.X || A.Y!=B.Y || A.Z!=B.Z;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 90, execNotEqual_VectorVector );

void __fastcall UObject::execDot_VectorVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	P_FINISH;

	*(FLOAT*)Result = A|B;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 91, execDot_VectorVector );

void __fastcall UObject::execCross_VectorVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	P_FINISH;

	*(FVector*)Result = A^B;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 92, execCross_VectorVector );

void __fastcall UObject::execMultiplyEqual_VectorFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR_REF(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FVector*)Result = (*A *= B);

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 93, execMultiplyEqual_VectorFloat );

void __fastcall UObject::execMultiplyEqual_VectorVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR_REF(A);
	P_GET_VECTOR(B);
	P_FINISH;

	*(FVector*)Result = (*A *= B);

	
}	
IMPLEMENT_FUNCTION( UObject, 297, execMultiplyEqual_VectorVector );

void __fastcall UObject::execDivideEqual_VectorFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR_REF(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FVector*)Result = (*A /= B);

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 94, execDivideEqual_VectorFloat );

void __fastcall UObject::execAddEqual_VectorVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR_REF(A);
	P_GET_VECTOR(B);
	P_FINISH;

	*(FVector*)Result = (*A += B);

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 95, execAddEqual_VectorVector );

void __fastcall UObject::execSubtractEqual_VectorVector( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR_REF(A);
	P_GET_VECTOR(B);
	P_FINISH;

	*(FVector*)Result = (*A -= B);

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 96, execSubtractEqual_VectorVector );

void __fastcall UObject::execVSize( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_FINISH;

	*(FLOAT*)Result = A.Size();

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 97, execVSize );

void __fastcall UObject::execNormal( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_FINISH;

	*(FVector*)Result = A.SafeNormal();

	
}
IMPLEMENT_FUNCTION( UObject, 0x80 + 98, execNormal );

void __fastcall UObject::execInvert( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR_REF(X);
	P_GET_VECTOR_REF(Y);
	P_GET_VECTOR_REF(Z);
	P_FINISH;

	FCoords Temp = FCoords( FVector(0,0,0), *X, *Y, *Z ).Inverse();
	*X           = Temp.XAxis;
	*Y           = Temp.YAxis;
	*Z           = Temp.ZAxis;

	
}
IMPLEMENT_FUNCTION( UObject, 0x80 + 99, execInvert );

void __fastcall UObject::execVRand( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	*((FVector*)Result) = VRand();
	
}
IMPLEMENT_FUNCTION( UObject, 0x80 + 124, execVRand );

void __fastcall UObject::execRotRand( FFrame& Stack, RESULT_DECL )
{
	P_GET_UBOOL_OPTX(bRoll, 0);
	P_FINISH;

	FRotator RRot;
	RRot.Yaw = ((2 * appRand()) % 65535);
	RRot.Pitch = ((2 * appRand()) % 65535);
	if ( bRoll )
		RRot.Roll = ((2 * appRand()) % 65535);
	else
		RRot.Roll = 0;
	*((FRotator*)Result) = RRot;
	
}
IMPLEMENT_FUNCTION( UObject, 320, execRotRand );

void __fastcall UObject::execMirrorVectorByNormal( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	P_FINISH;

	B = B.SafeNormal();
	*(FVector*)Result = A - 2.f * B * (B | A);

	
}
IMPLEMENT_FUNCTION( UObject, 300, execMirrorVectorByNormal );

//////////////////////////////////////
// Rotation operators and functions //
//////////////////////////////////////

void __fastcall UObject::execRot( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT_OPTX(Pitch,0);
	P_GET_INT_OPTX(Yaw,0);
	P_GET_INT_OPTX(Roll,0);
	P_FINISH;

	*(FRotator*)Result = FRotator(Pitch,Yaw,Roll);

	
}
IMPLEMENT_FUNCTION( UObject, 205, execRot );

void __fastcall UObject::execEqualEqual_RotatorRotator( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR(A);
	P_GET_ROTATOR(B);
	P_FINISH;

	*(DWORD*)Result = A.Pitch==B.Pitch && A.Yaw==B.Yaw && A.Roll==B.Roll;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 14, execEqualEqual_RotatorRotator );

void __fastcall UObject::execNotEqual_RotatorRotator( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR(A);
	P_GET_ROTATOR(B);
	P_FINISH;

	*(DWORD*)Result = A.Pitch!=B.Pitch || A.Yaw!=B.Yaw || A.Roll!=B.Roll;

	
}	
IMPLEMENT_FUNCTION( UObject, 0x80 + 75, execNotEqual_RotatorRotator );

void __fastcall UObject::execMultiply_RotatorFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FRotator*)Result = A * B;

	
}	
IMPLEMENT_FUNCTION( UObject, 287, execMultiply_RotatorFloat );

void __fastcall UObject::execMultiply_FloatRotator( FFrame& Stack, RESULT_DECL )
{

	P_GET_FLOAT(A);
	P_GET_ROTATOR(B);
	P_FINISH;

	*(FRotator*)Result = B * A;

	
}	
IMPLEMENT_FUNCTION( UObject, 288, execMultiply_FloatRotator );

void __fastcall UObject::execDivide_RotatorFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FRotator*)Result = A * (1.f/B);

	
}	
IMPLEMENT_FUNCTION( UObject, 289, execDivide_RotatorFloat );

void __fastcall UObject::execMultiplyEqual_RotatorFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR_REF(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FRotator*)Result = (*A *= B);

	
}	
IMPLEMENT_FUNCTION( UObject, 290, execMultiplyEqual_RotatorFloat );

void __fastcall UObject::execDivideEqual_RotatorFloat( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR_REF(A);
	P_GET_FLOAT(B);
	P_FINISH;

	*(FRotator*)Result = (*A *= (1.0/B));

	
}	
IMPLEMENT_FUNCTION( UObject, 291, execDivideEqual_RotatorFloat );

void __fastcall UObject::execAdd_RotatorRotator( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR(A);
	P_GET_ROTATOR(B);
	P_FINISH;

	*(FRotator*)Result = A + B;

}
IMPLEMENT_FUNCTION( UObject, 316, execAdd_RotatorRotator );

void __fastcall UObject::execSubtract_RotatorRotator( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR(A);
	P_GET_ROTATOR(B);
	P_FINISH;

	*(FRotator*)Result = A - B;

	
}
IMPLEMENT_FUNCTION( UObject, 317, execSubtract_RotatorRotator );

void __fastcall UObject::execAddEqual_RotatorRotator( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR_REF(A);
	P_GET_ROTATOR(B);
	P_FINISH;

	*(FRotator*)Result = (*A += B);

	
}
IMPLEMENT_FUNCTION( UObject, 318, execAddEqual_RotatorRotator );

void __fastcall UObject::execSubtractEqual_RotatorRotator( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR_REF(A);
	P_GET_ROTATOR(B);
	P_FINISH;

	*(FRotator*)Result = (*A -= B);

	
}
IMPLEMENT_FUNCTION( UObject, 319, execSubtractEqual_RotatorRotator );

void __fastcall UObject::execGetAxes( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR(A);
	P_GET_VECTOR_REF(X);
	P_GET_VECTOR_REF(Y);
	P_GET_VECTOR_REF(Z);
	P_FINISH;

	FCoords Coords = GMath.UnitCoords / A;
	*X = Coords.XAxis;
	*Y = Coords.YAxis;
	*Z = Coords.ZAxis;

	
}
IMPLEMENT_FUNCTION( UObject, 0x80 + 101, execGetAxes );

void __fastcall UObject::execGetUnAxes( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR(A);
	P_GET_VECTOR_REF(X);
	P_GET_VECTOR_REF(Y);
	P_GET_VECTOR_REF(Z);
	P_FINISH;

	FCoords Coords = GMath.UnitCoords * A;
	*X = Coords.XAxis;
	*Y = Coords.YAxis;
	*Z = Coords.ZAxis;

	
}
IMPLEMENT_FUNCTION( UObject, 0x80 + 102, execGetUnAxes );

void __fastcall UObject::execOrthoRotation( FFrame& Stack, RESULT_DECL )
{

	P_GET_VECTOR(X);
	P_GET_VECTOR(Y);
	P_GET_VECTOR(Z);
	P_FINISH;

	FCoords Coords( FVector(0,0,0), X, Y, Z );
	*(FRotator*)Result = Coords.OrthoRotation();

	
}
IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execOrthoRotation );

void __fastcall UObject::execNormalize( FFrame& Stack, RESULT_DECL )
{

	P_GET_ROTATOR(Rot);
	P_FINISH;

	Rot.Pitch = Rot.Pitch & 0xFFFF; if( Rot.Pitch > 32767 ) Rot.Pitch -= 0x10000;
	Rot.Roll  = Rot.Roll  & 0xFFFF; if( Rot.Roll  > 32767 )	Rot.Roll  -= 0x10000;
	Rot.Yaw   = Rot.Yaw   & 0xFFFF; if( Rot.Yaw   > 32767 )	Rot.Yaw   -= 0x10000;
	*(FRotator*)Result = Rot;

	
}
IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execNormalize );

////////////////////////////////////
// Str operators and functions //
////////////////////////////////////

void __fastcall UObject::execEatString( FFrame& Stack, RESULT_DECL )
{

	// Call function returning a string, then discard the result.
	FString String;
	Stack.Step( this, &String );

	
}
IMPLEMENT_FUNCTION( UObject, EX_EatString, execEatString );

void __fastcall UObject::execConcat_StringString( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_STR(B);
	P_FINISH;

	*(FString*)Result = (A+B);

	
}
IMPLEMENT_FUNCTION( UObject, 112, execConcat_StringString );

void __fastcall UObject::execAt_StringString( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_STR(B);
	P_FINISH;

	*(FString*)Result = (A+TEXT(" ")+B);

	
}
IMPLEMENT_FUNCTION( UObject, 168, execAt_StringString );

void __fastcall UObject::execLess_StringString( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_STR(B);
	P_FINISH;

	*(DWORD*)Result = appStrcmp(*A,*B)<0;;

	
}
IMPLEMENT_FUNCTION( UObject, 115, execLess_StringString );

void __fastcall UObject::execGreater_StringString( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_STR(B);
	P_FINISH;

	*(DWORD*)Result = appStrcmp(*A,*B)>0;

	
}
IMPLEMENT_FUNCTION( UObject, 116, execGreater_StringString );

void __fastcall UObject::execLessEqual_StringString( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_STR(B);
	P_FINISH;

	*(DWORD*)Result = appStrcmp(*A,*B)<=0;

	
}
IMPLEMENT_FUNCTION( UObject, 120, execLessEqual_StringString );

void __fastcall UObject::execGreaterEqual_StringString( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_STR(B);
	P_FINISH;

	*(DWORD*)Result = appStrcmp(*A,*B)>=0;

	
}
IMPLEMENT_FUNCTION( UObject, 121, execGreaterEqual_StringString );

void __fastcall UObject::execEqualEqual_StringString( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_STR(B);
	P_FINISH;

	*(DWORD*)Result = appStrcmp(*A,*B)==0;

	
}
IMPLEMENT_FUNCTION( UObject, 122, execEqualEqual_StringString );

void __fastcall UObject::execNotEqual_StringString( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_STR(B);
	P_FINISH;

	*(DWORD*)Result = appStrcmp(*A,*B)!=0;

	
}
IMPLEMENT_FUNCTION( UObject, 123, execNotEqual_StringString );

void __fastcall UObject::execComplementEqual_StringString( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_STR(B);
	P_FINISH;

	*(DWORD*)Result = appStricmp(*A,*B)==0;

	
}
IMPLEMENT_FUNCTION( UObject, 124, execComplementEqual_StringString );

void __fastcall UObject::execLen( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(S);
	P_FINISH;

	*(INT*)Result = S.Len();

	
}
IMPLEMENT_FUNCTION( UObject, 125, execLen );

void __fastcall UObject::execInStr( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(S);
	P_GET_STR(A);
	P_FINISH;

	*(INT*)Result = S.InStr(A);

	
}
IMPLEMENT_FUNCTION( UObject, 126, execInStr );

void __fastcall UObject::execMid( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_INT(I);
	P_GET_INT_OPTX(C,65535);
	P_FINISH;

	*(FString*)Result = A.Mid(I,C);

	
}
IMPLEMENT_FUNCTION( UObject, 127, execMid );

void __fastcall UObject::execLeft( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_INT(N);
	P_FINISH;

	*(FString*)Result = A.Left(N);

	
}
IMPLEMENT_FUNCTION( UObject, 128, execLeft );

void __fastcall UObject::execRight( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_GET_INT(N);
	P_FINISH;

	*(FString*)Result = A.Right(N);

	
}
IMPLEMENT_FUNCTION( UObject, 234, execRight );

void __fastcall UObject::execCaps( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(A);
	P_FINISH;

	*(FString*)Result = A.Caps();

	
}
IMPLEMENT_FUNCTION( UObject, 235, execCaps );

void __fastcall UObject::execChr( FFrame& Stack, RESULT_DECL )
{

	P_GET_INT(i);
	P_FINISH;

	TCHAR Temp[2];
	Temp[0] = i;
	Temp[1] = 0;
	*(FString*)Result = Temp;

	
}
IMPLEMENT_FUNCTION( UObject, 236, execChr );

void __fastcall UObject::execAsc( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(S);
	P_FINISH;

	*(INT*)Result = **S;	

	
}
IMPLEMENT_FUNCTION( UObject, 237, execAsc );

void __fastcall UObject::execIsValidString( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(S);
	P_FINISH;

	const UBOOL bValidString = (UBOOL) S;
	*(DWORD*)Result = bValidString;	

	
}
IMPLEMENT_FUNCTION( UObject, 198, execIsValidString );

/////////////////////////////////////////
// Native name operators and functions //
/////////////////////////////////////////

void __fastcall UObject::execEqualEqual_NameName( FFrame& Stack, RESULT_DECL )
{

	P_GET_NAME(A);
	P_GET_NAME(B);
	P_FINISH;

	*(DWORD*)Result = A == B;

	
}
IMPLEMENT_FUNCTION( UObject, 254, execEqualEqual_NameName );

void __fastcall UObject::execNotEqual_NameName( FFrame& Stack, RESULT_DECL )
{

	P_GET_NAME(A);
	P_GET_NAME(B);
	P_FINISH;

	*(DWORD*)Result = A != B;

	
}
IMPLEMENT_FUNCTION( UObject, 255, execNotEqual_NameName );

////////////////////////////////////
// Object operators and functions //
////////////////////////////////////

void __fastcall UObject::execEqualEqual_ObjectObject( FFrame& Stack, RESULT_DECL )
{

	P_GET_OBJECT(UObject,A);
	P_GET_OBJECT(UObject,B);
	P_FINISH;

	*(DWORD*)Result = A == B;

	
}
IMPLEMENT_FUNCTION( UObject, 114, execEqualEqual_ObjectObject );

void __fastcall UObject::execNotEqual_ObjectObject( FFrame& Stack, RESULT_DECL )
{

	P_GET_OBJECT(UObject,A);
	P_GET_OBJECT(UObject,B);
	P_FINISH;

	*(DWORD*)Result = A != B;

	
}
IMPLEMENT_FUNCTION( UObject, 119, execNotEqual_ObjectObject );

/////////////////////////////
// Log and error functions //
/////////////////////////////

void __fastcall UObject::execLog( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(S);
	P_GET_NAME_OPTX(N,NAME_ScriptLog);
	P_FINISH;

	debugf( (EName)N.GetIndex(), TEXT("%s"), *S );

	
}
IMPLEMENT_FUNCTION( UObject, 231, execLog );

void __fastcall UObject::execWarn( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(S);
	P_FINISH;

	Stack.Logf( TEXT("%s"), *S );

	
}
IMPLEMENT_FUNCTION( UObject, 232, execWarn );

void __fastcall UObject::execLocalize( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(SectionName);
	P_GET_STR(KeyName);
	P_GET_STR(PackageName);
	P_FINISH;

	*(FString*)Result = Localize( *SectionName, *KeyName, *PackageName );

	
}
IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execLocalize );

//////////////////
// High natives //
//////////////////

#define HIGH_NATIVE(n) \
void __fastcall UObject::execHighNative##n( FFrame& Stack, RESULT_DECL ) \
{ \
	BYTE B = *Stack.Code++; \
	(this->*GNatives[ n*0x100 + B ])( Stack, Result ); \
	 \
} \
IMPLEMENT_FUNCTION( UObject, 0x60 + n, execHighNative##n );

HIGH_NATIVE(0);
HIGH_NATIVE(1);
HIGH_NATIVE(2);
HIGH_NATIVE(3);
HIGH_NATIVE(4);
HIGH_NATIVE(5);
HIGH_NATIVE(6);
HIGH_NATIVE(7);
HIGH_NATIVE(8);
HIGH_NATIVE(9);
HIGH_NATIVE(10);
HIGH_NATIVE(11);
HIGH_NATIVE(12);
HIGH_NATIVE(13);
HIGH_NATIVE(14);
HIGH_NATIVE(15);
#undef HIGH_NATIVE

/////////////////////////
// Object construction //
/////////////////////////

void __fastcall UObject::execNew( FFrame& Stack, RESULT_DECL )
{

	// Get parameters.
	P_GET_OBJECT_OPTX(UObject,Outer,GetIndex()!=INDEX_NONE ? this : NULL);
	P_GET_NAME_OPTX(Name,NAME_None);
	P_GET_INT_OPTX(Flags,0);
	P_GET_OBJECT_OPTX(UClass,Cls,NULL);

	// Validate parameters.
	if( Flags & ~RF_ScriptMask )
		Stack.Logf( TEXT("new: Flags %08X not allowed"), Flags & ~RF_ScriptMask );

	// Construct new object.
	if( !Outer )
		Outer = GetTransientPackage();
	*(UObject**)Result = StaticConstructObject( Cls, Outer, Name, Flags&RF_ScriptMask, NULL, &Stack );

	
}
IMPLEMENT_FUNCTION( UObject, EX_New, execNew );

/////////////////////////////
// Class related functions //
/////////////////////////////

void __fastcall UObject::execClassIsChildOf( FFrame& Stack, RESULT_DECL )
{

	P_GET_OBJECT(UClass,K);
	P_GET_OBJECT(UClass,C);
	P_FINISH;

	*(DWORD*)Result = (C && K) ? K->IsChildOf(C) : 0;

	
}
IMPLEMENT_FUNCTION( UObject, 258, execClassIsChildOf );

void __fastcall UObject::execClassForName( FFrame& Stack, RESULT_DECL )
{

	P_GET_NAME(ClassName);
	P_FINISH;

	for (TObjectIterator<UClass> ItC; ItC; ++ItC)
	{
		if (ItC->GetFName() == ClassName)
		{
			*(UClass**)Result = *ItC;
			return;
		}
	}
	*(UClass**)Result = NULL;

	
}
IMPLEMENT_FUNCTION( UObject, 206, execClassForName );

///////////////////////////////
// State and label functions //
///////////////////////////////

void __fastcall UObject::execGotoState( FFrame& Stack, RESULT_DECL )
{

	// Get parameters.
	FName CurrentStateName = (StateFrame && StateFrame->StateNode!=Class) ? StateFrame->StateNode->GetFName() : NAME_None;
	P_GET_NAME_OPTX( S, CurrentStateName );
	P_GET_NAME_OPTX( L, NAME_None );
	P_FINISH;

	// Go to the state.
	{
		EGotoState Result = GOTOSTATE_Success;
		if( S!=CurrentStateName )
			Result = GotoState( S, true );

		// Handle success.
		if( Result==GOTOSTATE_Success )
		{
			// Now go to the label.
			if( !GotoLabel( L==NAME_None ? NAME_Begin : L ) && L!=NAME_None )
				Stack.Logf( TEXT("GotoState (%s %s): Label not found"), *S, *L );
		}
		else if( Result==GOTOSTATE_NotFound )
		{
			// Warning.
			if( S!=NAME_None && S!=NAME_Auto )
				Stack.Logf( TEXT("GotoState (%s %s): State not found"), *S, *L );
		}
		else
		{
			// Safely preempted by another GotoState.
		}
	}	
}
IMPLEMENT_FUNCTION( UObject, 113, execGotoState );

void __fastcall UObject::execIsInState( FFrame& Stack, RESULT_DECL )
{

	P_GET_NAME(StateName);
	P_FINISH;

	for (FStateFrame* Fr = StateFrame; Fr; Fr = Fr->StateStack)
		for( UState* Test=Fr->StateNode; Test; Test=Test->GetSuperState() )
			if( Test->GetFName()==StateName )
				{*(DWORD*)Result=1; return;}
	*(DWORD*)Result = 0;

	
}
IMPLEMENT_FUNCTION( UObject, 281, execIsInState );

void __fastcall UObject::execGetStateName( FFrame& Stack, RESULT_DECL )
{
	
	P_GET_INT_OPTX(Depth,0);
	P_FINISH;
	
	for (FStateFrame* Fr = StateFrame; Depth && Fr; Depth--, Fr = Fr->StateStack)
		;
	*(FName*)Result = (Fr && Fr->StateNode) ? Fr->StateNode->GetFName() : NAME_None;
	
	
}
IMPLEMENT_FUNCTION( UObject, 284, execGetStateName );

void __fastcall UObject::execChangeState( FFrame& Stack, RESULT_DECL )
{

	// Get parameters.
	FName CurrentStateName = (StateFrame && StateFrame->StateNode!=Class) ? StateFrame->StateNode->GetFName() : NAME_None;
	P_GET_NAME_OPTX( S, CurrentStateName );
	P_GET_NAME_OPTX( L, NAME_None );
	P_FINISH;

	// Go to the state.
	{
		EGotoState Result = GOTOSTATE_Success;
		if( S!=CurrentStateName )
			Result = GotoState( S, false );

		// Handle success.
		if( Result==GOTOSTATE_Success )
		{
			// Now go to the label.
			if( !GotoLabel( L==NAME_None ? NAME_Begin : L ) && L!=NAME_None )
				Stack.Logf( TEXT("ChangeState (%s %s): Label not found"), *S, *L );
		}
		else if( Result==GOTOSTATE_NotFound )
		{
			// Warning.
			if( S!=NAME_None && S!=NAME_Auto )
				Stack.Logf( TEXT("ChangeState (%s %s): State not found"), *S, *L );
		}
		else
		{
			// Safely preempted by another GotoState.
		}
	}	
}
IMPLEMENT_FUNCTION( UObject, 199, execChangeState );

void __fastcall UObject::execChildState( FFrame& Stack, RESULT_DECL )
{

	// Get parameters.
	FName CurrentStateName = (StateFrame && StateFrame->StateNode!=Class) ? StateFrame->StateNode->GetFName() : NAME_None;
	P_GET_NAME_OPTX( S, CurrentStateName );
	P_GET_NAME_OPTX( L, NAME_None );
	P_FINISH;

	// Push the current state
	FStateFrame* Fr = new(TEXT("ObjectStateFrame"))FStateFrame(this);
	Fr->StateStack = StateFrame;
	StateFrame = Fr;

	// Go to the state.
	{
		EGotoState Result = GOTOSTATE_Success;
	//if( S!=CurrentStateName )
		Result = GotoState( S, false );

		// Handle success.
		if( Result==GOTOSTATE_Success )
		{
			// Now go to the label.
			if( !GotoLabel( L==NAME_None ? NAME_Begin : L ) && L!=NAME_None )
				Stack.Logf( TEXT("ChildState (%s %s): Label not found"), *S, *L );
		}
		else if( Result==GOTOSTATE_NotFound )
		{
			// Warning.
			if( S!=NAME_None && S!=NAME_Auto )
				Stack.Logf( TEXT("ChildState (%s %s): State not found"), *S, *L );
		}
		else
		{
			// Safely preempted by another GotoState.
		}
	}	
}
IMPLEMENT_FUNCTION( UObject, 200, execChildState );

void __fastcall UObject::execEndChildState( FFrame& Stack, RESULT_DECL )
{

	P_FINISH;

	// Make sure we have something to pop
	if (StateFrame->StateStack)
	{
		// Go to the none state (so child state will get endstate notification before it dies)
		GotoState(NAME_None, false);

		// Pop to the previous state
		FStateFrame* Fr = StateFrame;
		StateFrame = Fr->StateStack;
		Fr->StateStack = NULL;
		delete Fr;
	}
	else
	{
		Stack.Logf(TEXT("EndChildState: Not in a child state"));
	}
	
}
IMPLEMENT_FUNCTION( UObject, 201, execEndChildState );

void __fastcall UObject::execGetStateDepth( FFrame& Stack, RESULT_DECL )
{
	
	P_FINISH;
	
	INT Depth = 0;
	for (FStateFrame* Fr = StateFrame; Fr; Fr = Fr->StateStack)
		Depth++;
	*(INT*)Result = Depth;
	
	
}
IMPLEMENT_FUNCTION( UObject, 202, execGetStateDepth );

void __fastcall UObject::execEnable( FFrame& Stack, RESULT_DECL )
{

	P_GET_NAME(N);
	if( N.GetIndex()>=NAME_PROBEMIN && N.GetIndex()<NAME_PROBEMAX && StateFrame )
	{
		QWORD BaseProbeMask = (GetStateFrame()->StateNode->ProbeMask | GetClass()->ProbeMask) & GetStateFrame()->StateNode->IgnoreMask;
		GetStateFrame()->ProbeMask |= (BaseProbeMask & ((QWORD)1<<(N.GetIndex()-NAME_PROBEMIN)));
	}
	else Stack.Logf( TEXT("Enable: '%s' is not a probe function"), *N );
	P_FINISH;

	
}
IMPLEMENT_FUNCTION( UObject, 117, execEnable );

void __fastcall UObject::execDisable( FFrame& Stack, RESULT_DECL )
{

	P_GET_NAME(N);
	P_FINISH;

	if( N.GetIndex()>=NAME_PROBEMIN && N.GetIndex()<NAME_PROBEMAX && StateFrame )
		GetStateFrame()->ProbeMask &= ~((QWORD)1<<(N.GetIndex()-NAME_PROBEMIN));
	else
		Stack.Logf( TEXT("Enable: '%s' is not a probe function"), *N );

	
}
IMPLEMENT_FUNCTION( UObject, 118, execDisable );

///////////////////
// Property text //
///////////////////

void __fastcall UObject::execGetPropertyText( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(PropName);
	P_FINISH;

	UProperty* Property=FindField<UProperty>( Class, *PropName );
	if( Property && (Property->GetFlags() & RF_Public) )
	{
		TCHAR Temp[1024]=TEXT("");//!!
		Property->ExportText( 0, Temp, (BYTE*)this, (BYTE*)this, PPF_Localized );
		*(FString*)Result = Temp;
	}
	else *(FString*)Result = TEXT("");

	
}
IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execGetPropertyText );

void __fastcall UObject::execSetPropertyText( FFrame& Stack, RESULT_DECL )
{
    P_GET_STR(PropName);
	P_GET_STR(PropValue);
	P_FINISH;

	UProperty* Property=FindField<UProperty>( Class, *PropName );
	if
	(	(Property)
	&&	(Property->GetFlags() & RF_Public)
	&&	!(Property->PropertyFlags & CPF_Const) )
	{
		Property->ImportText( *PropValue, (BYTE*)this + Property->Offset, PPF_Localized );		
	}
}
IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execSetPropertyText );

void __fastcall UObject::execSaveConfig( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	SaveConfig();
}
IMPLEMENT_FUNCTION( UObject, 536, execSaveConfig);

void __fastcall UObject::execStaticSaveConfig( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	Class->GetDefaultObject()->SaveConfig();
}
IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execStaticSaveConfig);

void __fastcall UObject::execResetConfig( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	ResetConfig(GetClass());
}
IMPLEMENT_FUNCTION( UObject, 543, execResetConfig);

void __fastcall UObject::execGetEnum( FFrame& Stack, RESULT_DECL )
{

	P_GET_OBJECT(UObject,E);
	P_GET_INT(i);
	P_FINISH;

	*(FName*)Result = NAME_None;
	if( Cast<UEnum>(E) && i>=0 && i<Cast<UEnum>(E)->Names.Num() )
		*(FName*)Result = Cast<UEnum>(E)->Names(i);

}
IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execGetEnum);

void __fastcall UObject::execDynamicLoadObject( FFrame& Stack, RESULT_DECL )
{

	P_GET_STR(Name);
	P_GET_OBJECT(UClass,Class);
	P_GET_UBOOL_OPTX(bMayFail,0);
	P_FINISH;

	*(UObject**)Result = StaticLoadObject( Class, NULL, *Name, NULL, LOAD_NoWarn | (bMayFail?LOAD_Quiet:0), NULL );

	
}
IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execDynamicLoadObject );

void __fastcall UObject::execIsA( FFrame& Stack, RESULT_DECL )
{

	P_GET_NAME(ClassName);
	P_FINISH;

	UClass* TempClass;
	for( TempClass=GetClass(); TempClass; TempClass=TempClass->GetSuperClass() )
		if( TempClass->GetFName() == ClassName )
			break;
	*(DWORD*)Result = (TempClass!=NULL);

	
}
IMPLEMENT_FUNCTION(UObject,303,execIsA);

/*-----------------------------------------------------------------------------
	Native iterator functions.
-----------------------------------------------------------------------------*/

void __fastcall UObject::execIterator( FFrame& Stack, RESULT_DECL )
{}
IMPLEMENT_FUNCTION( UObject, EX_Iterator, execIterator );

/*-----------------------------------------------------------------------------
	Native registry.
-----------------------------------------------------------------------------*/

//
// Register a native function.
// Warning: Called at startup time, before engine initialization.
//
BYTE CORE_API GRegisterNative( INT iNative, const Native& Func )
{
	static int Initialized = 0;
	if( !Initialized )
	{
		Initialized = 1;
		for( int i=0; i<ARRAY_COUNT(GNatives); i++ )
			GNatives[i] = &UObject::execUndefined;
	}
	if( iNative != INDEX_NONE )
	{
		if( iNative<0 || iNative>ARRAY_COUNT(GNatives) || GNatives[iNative]!=&UObject::execUndefined) 
			GNativeDuplicate = iNative;
		GNatives[iNative] = Func;
	}
	return 0;
}

/*-----------------------------------------------------------------------------
	Script processing function.
-----------------------------------------------------------------------------*/

UFunction *ParentFunction=NULL;

void __fastcall UObject::execLogStackTrace( FFrame& Stack, RESULT_DECL )
{
	P_FINISH;
	for(int index=0;index<CallStackPointer;index++)
	{
		debugf
		(
			TEXT("%s -  %s"),
			CallStack[index].Object->GetFullName(),
			CallStack[index].Function->GetPathName()
		);
	}
}

IMPLEMENT_FUNCTION( UObject, INDEX_NONE, execLogStackTrace);

#define ENTER_FUNCTION_CALL	\
	UFunction *SavedParentFunction=ParentFunction;\
	ParentFunction=Function; \
	DWORD Cycles=0; clock(Cycles); \
	CallStack[CallStackPointer].Object=this; \
	CallStack[CallStackPointer].Function=Function; 

    //CallStackPointer++; \
	//if(CallStackPointer>=MAX_CALL_STACK) appErrorf(TEXT("CallStack Overflow!"));

#define EXIT_FUNCTION_CALL \
	unclock(Cycles);		\
	Function->ProfileCycles += Cycles; \
	ParentFunction=SavedParentFunction; \
	if(ParentFunction) ParentFunction->ProfileChildrenCycles+=Cycles; \
	Function->ProfileCalls++; 

//	CallStackPointer--; \
//	if(CallStackPointer<0) CallStackPointer=0;
 

// Information remembered about an Out parameter.
struct FOutParmRec
{
	UProperty* Property;
	BYTE*      PropAddr;
};

// Call a function.
void UObject::CallFunction( FFrame& Stack, RESULT_DECL, UFunction* Function )
{	
	ENTER_FUNCTION_CALL

	// Found it.
	UBOOL SkipIt = 0;
	if( Function->iNative )
	{
		// Call native final function.
		(this->*Function->Func)( Stack, Result );
	}
	else if( Function->FunctionFlags & FUNC_Native )
	{
		// Call native networkable function.
		BYTE Buffer[1024];
		if( !ProcessRemoteFunction( Function, Buffer, &Stack ) )
		{
			// Call regular native function.
			(this->*Function->Func)( Stack, Result );
		}
		else
		{
			// Eat up the remaining parameters in the stream.
			SkipIt = 1;
			goto Temporary;
		}
	}
	else
	{
		// Make new stack frame in the current context.
		Temporary:
        BYTE* Frame = (BYTE*)appAlloca(Function->GetPropertiesSize());
		appMemzero( Frame, Function->GetPropertiesSize() );
		FFrame NewStack( this, Function, 0, Frame );
		FOutParmRec Outs[MAX_FUNC_PARMS], *Out = Outs;
		
        for( UProperty* Property=(UProperty*)Function->Children; *Stack.Code!=EX_EndFunctionParms; Property=(UProperty*)Property->Next )
		{
			GPropAddr = NULL;
			Stack.Step( Stack.Object, NewStack.Locals + Property->Offset );
			if( (Property->PropertyFlags & CPF_OutParm) && GPropAddr )
			{
				Out->PropAddr = GPropAddr;
				Out->Property = Property;
				Out++;
			}
		}
		Stack.Code++;

		// Execute the code.
		if( !SkipIt )
			ProcessInternal( NewStack, Result );

		// Copy back outparms.
		while( --Out >= Outs )
				Out->Property->CopyCompleteValue( Out->PropAddr, NewStack.Locals + Out->Property->Offset );

		// Destruct properties on the stack.
		for( UProperty* Destruct=Function->ConstructorLink; Destruct; Destruct=Destruct->ConstructorLinkNext )
			Destruct->DestroyValue( NewStack.Locals + Destruct->Offset );
	}
	EXIT_FUNCTION_CALL
}

//
// Internal function call processing.
//!!might not write anything to Result if singular or proper type isn't returned.
//
void UObject::ProcessInternal( FFrame& Stack, RESULT_DECL )
{
	DWORD SingularFlag = ((UFunction*)Stack.Node)->FunctionFlags & FUNC_Singular;
	if
	(	!ProcessRemoteFunction( (UFunction*)Stack.Node, Stack.Locals, NULL )
	&&	IsProbing( Stack.Node->GetFName() )
	&&	!(ObjectFlags & SingularFlag) )
	{
		ObjectFlags |= SingularFlag;
		BYTE Buffer[1024];//!!hardcoded size
		appMemzero( Buffer, sizeof(FString) );//!!
#if DO_GUARD
		if( ++Recurse > RECURSE_LIMIT )
			Stack.Logf( NAME_Critical, TEXT("Infinite script recursion (%i calls) detected"), RECURSE_LIMIT );
#endif
		while( *Stack.Code != EX_Return )
			Stack.Step( Stack.Object, Buffer );
		Stack.Code++;
		Stack.Step( Stack.Object, Result );
		ObjectFlags &= ~SingularFlag;
#if DO_GUARD
		--Recurse;
#endif
	}
	
}

//
// Script processing function.
//
void UObject::ProcessEvent( UFunction* Function, void* Parms, void* UnusedResult )
{
	ENTER_FUNCTION_CALL

	// Reject.
	if
	(	!GIsScriptable
	||	!IsProbing( Function->GetFName() )
	||	IsPendingKill()
	||	Function->iNative
	||	((Function->FunctionFlags & FUNC_Native) && ProcessRemoteFunction( Function, Parms, NULL )) )
		return;
	checkSlow(Function->ParmsSize==0 || Parms!=NULL);

	// Start timer.
	if( ++GScriptEntryTag == 1 )
		clock(GScriptCycles);

	// Create a new local execution stack.
	FFrame NewStack( this, Function, 0, appAlloca(Function->GetPropertiesSize()) );
	appMemcpy( NewStack.Locals, Parms, Function->ParmsSize );
    appMemzero( NewStack.Locals+Function->ParmsSize, Function->GetPropertiesSize()-Function->ParmsSize );

	// Call native function or UObject::ProcessInternal.
	(this->*Function->Func)( NewStack, NewStack.Locals+Function->ReturnValueOffset );

	// Copy everything back.
	appMemcpy( Parms, NewStack.Locals, Function->ParmsSize );

	// Destroy local variables except function parameters.!! see also UObject::ScriptConsoleExec
	for( UProperty* P=Function->ConstructorLink; P; P=P->ConstructorLinkNext )
		if( P->Offset >= Function->ParmsSize )
			P->DestroyValue( NewStack.Locals + P->Offset );

	// Stop timer.
	if( --GScriptEntryTag == 0 )
		unclock(GScriptCycles);

	EXIT_FUNCTION_CALL	
}

//
// Execute the state code of the object.
//
void UObject::ProcessState( FLOAT DeltaSeconds )
{}

//
// Process a remote function; returns 1 if remote, 0 if local.
//
UBOOL UObject::ProcessRemoteFunction( UFunction* Function, void* Parms, FFrame* Stack )
{
	return 0;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
