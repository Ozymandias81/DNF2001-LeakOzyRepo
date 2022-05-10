/*=============================================================================
	UnEdExp.cpp: Editor exporters.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

#include "EditorPrivate.h"

/*------------------------------------------------------------------------------
	UTextBufferExporterTXT implementation.
------------------------------------------------------------------------------*/

void UTextBufferExporterTXT::StaticConstructor()
{
	SupportedClass = UTextBuffer::StaticClass();
	bText = 1;
	new(Formats)FString(TEXT("TXT"));
}
UBOOL UTextBufferExporterTXT::ExportText( UObject* Object, const TCHAR* Type, FOutputDevice& Ar, FFeedbackContext* Warn )
{
	UTextBuffer* TextBuffer = CastChecked<UTextBuffer>( Object );
	FString Str( TextBuffer->Text );

	TCHAR* Start = const_cast<TCHAR*>(*Str);
	TCHAR* End   = Start + Str.Len();
	while( Start<End && (Start[0]=='\r' || Start[0]=='\n' || Start[0]==' ') )
		Start++;
	while( End>Start && (End [-1]=='\r' || End [-1]=='\n' || End [-1]==' ') )
		End--;
	*End = 0;

	Ar.Log( Start );

	return 1;
}
IMPLEMENT_CLASS(UTextBufferExporterTXT);

/*------------------------------------------------------------------------------
	USoundExporterWAV implementation.
------------------------------------------------------------------------------*/

void USoundExporterWAV::StaticConstructor()
{
	SupportedClass = USound::StaticClass();
	bText = 0;
	new(Formats)FString(TEXT("WAV"));
}
UBOOL USoundExporterWAV::ExportBinary( UObject* Object, const TCHAR* Type, FArchive& Ar, FFeedbackContext* Warn )
{
	USound* Sound = CastChecked<USound>( Object );
	Sound->Data.Load();
	Ar.Serialize( &Sound->Data(0), Sound->Data.Num() );
	return 1;
}
IMPLEMENT_CLASS(USoundExporterWAV);

/*------------------------------------------------------------------------------
	UMusicExporterTracker implementation.
------------------------------------------------------------------------------*/

void UMusicExporterTracker::StaticConstructor()
{
	SupportedClass = UMusic::StaticClass();
	bText = 0;
	new(Formats)FString(TEXT("*"));
}
UBOOL UMusicExporterTracker::ExportBinary( UObject* Object, const TCHAR* Type, FArchive& Ar, FFeedbackContext* Warn )
{
	UMusic* Music = CastChecked<UMusic>( Object );
	Music->Data.Load();
	Ar.Serialize( &Music->Data(0), Music->Data.Num() );
	return 1;
}
IMPLEMENT_CLASS(UMusicExporterTracker);

/*------------------------------------------------------------------------------
	UClassExporterH implementation.
------------------------------------------------------------------------------*/

static void RecursiveTagNames( UClass* Class )
{
	for( TObjectIterator<UClass> It; It; ++It )
	{
		UClass* C=*It;
		if(C->IsChildOf(Class) && (C->GetFlags() & RF_TagExp) && (C->GetFlags() & RF_Native))
			for(TFieldIterator<UFunction> Function(C); Function && Function.GetStruct()==C; ++Function)
				if( (Function->FunctionFlags & FUNC_Event) && !Function->GetSuperFunction() )
					Function->GetFName().SetFlags(RF_TagExp);
	}
}

void UClassExporterH::StaticConstructor()
{
	SupportedClass = UClass::StaticClass();
	bText = 1;
	new(Formats)FString(TEXT("H"));
}

// JEP..
static void WriteStruct(UStruct *ItS, TCHAR *API, INT TextIndent, FOutputDevice& Ar)
{
	if(!(ItS->GetFlags() & RF_Native ) && !(ItS->StructFlags & STRUCT_Native)) 
		return;		// Not supposed to be exported

	if (ItS->StructFlags & STRUCT_Exported)
		return;		// Already been exported

	// Look for any struct dependencies
	for( TFieldIterator<UProperty> It2(ItS); It2; ++It2 )
	{
		if( It2.GetStruct()==ItS )
		{
			if (It2->IsA(UStructProperty::StaticClass()))
			{
				// Recurse and tag
				UStruct *Struct = ((UStructProperty*)*It2)->Struct;
				WriteStruct(Struct, API, TextIndent, Ar);
			}
		}
	}

	// Export struct.
	Ar.Logf( TEXT("struct %s_API %s"), API, ItS->GetNameCPP() );

	if( ItS->SuperField )
		Ar.Logf(TEXT(" : public %s\r\n"), ItS->GetSuperStruct()->GetNameCPP() );

	Ar.Logf( TEXT("\r\n{\r\n") );
				
	TFieldIterator<UProperty> LastIt = NULL;

	{for( TFieldIterator<UProperty> It2(ItS); It2; ++It2 )
	{
		if( It2.GetStruct()==ItS )
		{
			Ar.Logf( appSpc(TextIndent+4) );
			It2->ExportCpp( Ar, 0, 0 );
			if (It2->IsA(UBoolProperty::StaticClass()))
			{
				if (LastIt == NULL || !LastIt->IsA(UBoolProperty::StaticClass()))
					Ar.Logf( TEXT(" GCC_PACK(%i)"), PROPERTY_ALIGNMENT );
			} 
			else 
			{
				if (LastIt != NULL && LastIt->IsA(UBoolProperty::StaticClass()))
					Ar.Logf( TEXT(" GCC_PACK(%i)"), PROPERTY_ALIGNMENT );
			}
			
			Ar.Logf(TEXT(";\r\n"));
			LastIt = It2;
		}
	}}
	Ar.Logf( TEXT("};\r\n\r\n") );
	
	ItS->StructFlags |= STRUCT_Exported;		// Mark as written
}
// ...JEP

UBOOL UClassExporterH::ExportText( UObject* Object, const TCHAR* Type, FOutputDevice& Ar, FFeedbackContext* Warn )
{
	UClass* Class = CastChecked<UClass>( Object );

	TCHAR API[256];
	appStrcpy( API, Class->GetOuter()->GetName() );
	appStrupr( API );

	// Export as C++ header.
	if( RecursionDepth==0 )
	{
		DidTop = 0;
		RecursiveTagNames( Class );
	}

	// Export this.
	if( Class->GetFlags() & RF_TagExp )
	{
		// Top of file.
		if( !DidTop )
		{
			DidTop = 1;
			Ar.Logf
			(
				TEXT("/*===========================================================================\r\n")
				TEXT("    C++ class definitions exported from UnrealScript.\r\n")
				TEXT("    This is automatically generated by the tools.\r\n")
				TEXT("    DO NOT modify this manually! Edit the corresponding .uc files instead!\r\n")
				TEXT("===========================================================================*/\r\n")
				TEXT("#if _MSC_VER\r\n")
				TEXT("#pragma pack (push,%i)\r\n")
				TEXT("#endif\r\n")
				TEXT("\r\n")
				TEXT("#ifndef %s_API\r\n")
				TEXT("#define %s_API DLL_IMPORT\r\n")
				TEXT("#endif\r\n")
				TEXT("\r\n")
				TEXT("#ifndef NAMES_ONLY\r\n")
				TEXT("#define AUTOGENERATE_NAME(name) extern %s_API FName %s_##name;\r\n")
				TEXT("#define AUTOGENERATE_FUNCTION(cls,idx,name)\r\n")
				TEXT("#endif\r\n")
				TEXT("\r\n"),
				PROPERTY_ALIGNMENT,
				API,
				API,
				API,
				API
			);
			for( INT i=0; i<FName::GetMaxNames(); i++ )
				if( FName::GetEntry(i) && (FName::GetEntry(i)->Flags & RF_TagExp) )
					Ar.Logf( TEXT("AUTOGENERATE_NAME(%s)\r\n"), *FName((EName)(i)) );
			for( i=0; i<FName::GetMaxNames(); i++ )
				if( FName::GetEntry(i) )
					FName::GetEntry(i)->Flags &= ~RF_TagExp;
			Ar.Logf( TEXT("\r\n#ifndef NAMES_ONLY\r\n\r\n") );
		}

		// Enum definitions.
		for( TFieldIterator<UEnum> ItE(Class); ItE && ItE.GetStruct()==Class; ++ItE )
		{
			// Export enum.
			if( ItE->GetOuter()==Class )
			{
				Ar.Logf( TEXT("%senum %s\r\n{\r\n"), appSpc(TextIndent), ItE->GetName() );
				for( INT i=0; i<ItE->Names.Num(); i++ )
					Ar.Logf( TEXT("%s    %-24s=%i,\r\n"), appSpc(TextIndent), *ItE->Names(i), i );
				if( appStrchr(*ItE->Names(0),'_') )
				{
					// Include tag_MAX enumeration.
					TCHAR Temp[256];
					appStrcpy( Temp, *ItE->Names(0) );
					appStrcpy( appStrchr(Temp,'_'),TEXT("_MAX"));
					Ar.Logf( TEXT("%s    %-24s=%i,\r\n"), appSpc(TextIndent), Temp, i );
				}
				Ar.Logf( TEXT("};\r\n") );
			}
			else Ar.Logf( TEXT("%senum %s;\r\n"), appSpc(TextIndent), ItE->GetName() );
		}

		// Struct definitions.
		for( TFieldIterator<UStruct> ItS(Class); ItS && ItS.GetStruct()==Class; ++ItS )
		{
		#if 1		// JEP
			WriteStruct(*ItS, API, TextIndent, Ar);
		#else
			if(( ItS->GetFlags() & RF_Native )
			 || (ItS->StructFlags & STRUCT_Native)) // CDH
			{
				// Export struct.
				Ar.Logf( TEXT("struct %s_API %s"), API, ItS->GetNameCPP() );
				if( ItS->SuperField )
					Ar.Logf(TEXT(" : public %s\r\n"), ItS->GetSuperStruct()->GetNameCPP() );
				Ar.Logf( TEXT("\r\n{\r\n") );
				
				TFieldIterator<UProperty> LastIt = NULL;

				for( TFieldIterator<UProperty> It2(*ItS); It2; ++It2 )
				{
	                if( It2.GetStruct()==*ItS )
					{
						Ar.Logf( appSpc(TextIndent+4) );
						It2->ExportCpp( Ar, 0, 0 );
						if (It2->IsA(UBoolProperty::StaticClass()))
						{
							if (LastIt == NULL || !LastIt->IsA(UBoolProperty::StaticClass()))
								Ar.Logf( TEXT(" GCC_PACK(%i)"), PROPERTY_ALIGNMENT );
						} else {
							if (LastIt != NULL && LastIt->IsA(UBoolProperty::StaticClass()))
								Ar.Logf( TEXT(" GCC_PACK(%i)"), PROPERTY_ALIGNMENT );
						}
						Ar.Logf(TEXT(";\r\n"));
						LastIt = It2;
					}
				}
				Ar.Logf( TEXT("};\r\n\r\n") );
			}
		#endif
		}

		// Constants.
		for( TFieldIterator<UConst> ItC(Class); ItC && ItC.GetStruct()==Class; ++ItC )
		{
			FString V = ItC->Value;
			while( V.Left(1)==TEXT(" ") )
				V=V.Mid(1);
			if( V.Len()>1 && V.Left(1)==TEXT("'") && V.Right(1)==TEXT("'") )
				V = V.Mid(1,V.Len()-2);
			Ar.Logf( TEXT("#define UCONST_%s %s\r\n"), ItC->GetName(), *V );
		}
		if( TFieldIterator<UConst>(Class) )
			Ar.Logf( TEXT("\r\n") );

		// Parms struct definitions.
		TFieldIterator<UFunction> Function(Class);
		TFieldIterator<UProperty> It(Class);
		for( Function = TFieldIterator<UFunction>(Class); Function && Function.GetStruct()==Class; ++Function )
		{
			if
			(	(Function->FunctionFlags & FUNC_Event)
			&&	(!Function->GetSuperFunction()) )
			{
				Ar.Logf( TEXT("struct %s_event%s_Parms\r\n"), Class->GetNameCPP(), Function->GetName() );
				Ar.Log( TEXT("{\r\n") );
				for( It=TFieldIterator<UProperty>(*Function); It && (It->PropertyFlags&CPF_Parm); ++It )
				{
					Ar.Log( TEXT("    ") );
					It->ExportCpp( Ar, 1, 0 );
					Ar.Log( TEXT(";\r\n") );
				}
				Ar.Log( TEXT("};\r\n") );
			}
		}
		
		// Class definition.
		Ar.Logf( TEXT("class %s_API %s"), API, Class->GetNameCPP() );
		if( Class->GetSuperClass() )
			Ar.Logf( TEXT(" : public %s\r\n"), Class->GetSuperClass()->GetNameCPP() );
		Ar.Logf( TEXT("{\r\npublic:\r\n") );

		// All per-object properties defined in this class.
		TFieldIterator<UProperty> LastIt = NULL;
		for( It = TFieldIterator<UProperty>(Class); It; ++It )
		{
			if( It.GetStruct()==Class )
			{
				Ar.Logf( appSpc(TextIndent+4) );
				It->ExportCpp( Ar, 0, 0 );
				if (It->IsA(UBoolProperty::StaticClass()))
				{
					if (LastIt == NULL || !LastIt->IsA(UBoolProperty::StaticClass()))
						Ar.Logf( TEXT(" GCC_PACK(%i)"), PROPERTY_ALIGNMENT );
				} else {
					if (LastIt != NULL && LastIt->IsA(UBoolProperty::StaticClass()))
						Ar.Logf( TEXT(" GCC_PACK(%i)"), PROPERTY_ALIGNMENT );
				}
				Ar.Logf( TEXT(";\r\n") );
				LastIt = It;
			}
		}

		// C++ -> UnrealScript stubs.
		for( Function = TFieldIterator<UFunction>(Class); Function && Function.GetStruct()==Class; ++Function )
			if( Function->FunctionFlags & FUNC_Native )
				Ar.Logf( TEXT("    DECLARE_FUNCTION(exec%s);\r\n"), Function->GetName() );

		// UnrealScript -> C++ proxies.
		for( Function = TFieldIterator<UFunction>(Class); Function && Function.GetStruct()==Class; ++Function )
		{
			if
			(	(Function->FunctionFlags & FUNC_Event)
			&&	(!Function->GetSuperFunction()) )
			{
				// Return type.
				UProperty* Return = Function->GetReturnProperty();
				Ar.Log( TEXT("    inline ") );
				if( !Return )
					Ar.Log( TEXT("void") );
				else
					Return->ExportCppItem( Ar );

				// Function name and parms.
				INT ParmCount=0;
				Ar.Logf( _T(" __fastcall event%s("), Function->GetName() );	// NJS: These things are relly just stubs and should always be inlined.
				for( TFieldIterator<UProperty> It(*Function); It && (It->PropertyFlags&(CPF_Parm|CPF_ReturnParm))==CPF_Parm; ++It )
				{
					if( ParmCount++ )
						Ar.Log(TEXT(", "));
					It->ExportCpp( Ar, 0, 1 );
				}
				Ar.Log( TEXT(")\r\n") );

				// Function call.
				Ar.Log( TEXT("    {\r\n") );
				UBOOL ProbeOptimization = (Function->GetFName().GetIndex()>=NAME_PROBEMIN && Function->GetFName().GetIndex()<NAME_PROBEMAX);
				if( ParmCount || Return )
				{
					Ar.Logf( TEXT("        %s_event%s_Parms Parms;\r\n"), Class->GetNameCPP(), Function->GetName() );
					if( Return && !Cast<UStrProperty>(Return) )
						Ar.Logf( TEXT("        Parms.%s=0;\r\n"), Return->GetName() );
				}
				if( ProbeOptimization )
					Ar.Logf(TEXT("        if(IsProbing(NAME_%s)) {\r\n"),Function->GetName());
				if( ParmCount || Return )
				{
					// Parms struct initialization.
					for( It=TFieldIterator<UProperty>(*Function); It && (It->PropertyFlags&(CPF_Parm|CPF_ReturnParm))==CPF_Parm; ++It )
					{
						if( It->ArrayDim>1 )
							Ar.Logf( TEXT("        appMemcpy(&Parms.%s,&%s,sizeof(Parms.%s));\r\n"), It->GetName(), It->GetName(), It->GetName() );
						else
							Ar.Logf( TEXT("        Parms.%s=%s;\r\n"), It->GetName(), It->GetName() );
					}
					Ar.Logf( TEXT("        ProcessEvent(FindFunctionChecked(%s_%s),&Parms);\r\n"), API, Function->GetName() );
				}
				else Ar.Logf( TEXT("        ProcessEvent(FindFunctionChecked(%s_%s),NULL);\r\n"), API, Function->GetName() );
				if( ProbeOptimization )
					Ar.Logf(TEXT("        }\r\n"));

				// Out parm copying.
				for( It=TFieldIterator<UProperty>(*Function); It && (It->PropertyFlags&(CPF_Parm|CPF_ReturnParm))==CPF_Parm; ++It )
				{
					if( It->PropertyFlags & CPF_OutParm )
					{
						if( It->ArrayDim>1 )
							Ar.Logf( TEXT("        appMemcpy(&%s,&Parms.%s,sizeof(%s));\r\n"), It->GetName(), It->GetName(), It->GetName() );
						else
							Ar.Logf( TEXT("        %s=Parms.%s;\r\n"), It->GetName(), It->GetName() );
					}
				}

				// Return value.
				if( Return )
					Ar.Logf( TEXT("        return Parms.%s;\r\n"), Return->GetName() );
				Ar.Log( TEXT("    }\r\n") );
			}
		}

		// Code.
		Ar.Logf( TEXT("    DECLARE_CLASS(%s,"), Class->GetNameCPP() ); //warning: GetNameCPP uses static storage.
		Ar.Logf( TEXT("%s,0"), Class->GetSuperClass()->GetNameCPP() );
		if( Class->ClassFlags & CLASS_Transient      )
			Ar.Log( TEXT("|CLASS_Transient") );
		if( Class->ClassFlags & CLASS_Config )
			Ar.Log( TEXT("|CLASS_Config") );
		if( Class->ClassFlags & CLASS_NativeReplication )
			Ar.Log( TEXT("|CLASS_NativeReplication") );
		Ar.Logf( TEXT(")\r\n") );
		FString Filename = FString(TEXT("..")) * Class->GetOuter()->GetName() * TEXT("Inc") * Class->GetNameCPP() + TEXT(".h");
		if( GFileManager->FileSize(*Filename) > 0 )
			Ar.Logf( TEXT("    #include \"%s.h\"\r\n"), Class->GetNameCPP() );
		else
			Ar.Logf( TEXT("    NO_DEFAULT_CONSTRUCTOR(%s)\r\n"), Class->GetNameCPP() );

		// End of class.
		Ar.Logf( TEXT("};\r\n") );

		// End.
		Ar.Logf( TEXT("\r\n") );
	}

	// Export all child classes that are tagged for export.
	RecursionDepth++;
	for( TObjectIterator<UClass> It; It; ++It )
		if( It->GetSuperClass()==Class )
			UExporter::ExportToOutputDevice( *It, this, Ar, TEXT("H"), TextIndent );
	RecursionDepth--;

	// Finish C++ header.
	if( RecursionDepth==0 )
	{
		Ar.Logf( TEXT("#endif\r\n") );
		Ar.Logf( TEXT("\r\n") );

		for( TObjectIterator<UClass> It; It; ++It )
			if( It->GetFlags() & RF_TagExp )
				for( TFieldIterator<UFunction> Function(*It); Function && Function.GetStruct()==*It; ++Function )
					if( Function->FunctionFlags & FUNC_Native )
						Ar.Logf( TEXT("AUTOGENERATE_FUNCTION(%s,%i,exec%s);\r\n"), It->GetNameCPP(), Function->iNative ? Function->iNative : -1, Function->GetName() );

		Ar.Logf( TEXT("\r\n") );
		Ar.Logf( TEXT("#ifndef NAMES_ONLY\r\n") );
		Ar.Logf( TEXT("#undef AUTOGENERATE_NAME\r\n") );
		Ar.Logf( TEXT("#undef AUTOGENERATE_FUNCTION\r\n") );
		Ar.Logf( TEXT("#endif NAMES_ONLY\r\n") );

		Ar.Logf( TEXT("\r\n") );
		Ar.Logf( TEXT("#if _MSC_VER\r\n") );
		Ar.Logf( TEXT("#pragma pack (pop)\r\n") );
		Ar.Logf( TEXT("#endif\r\n") );
	}

	return 1;
}
IMPLEMENT_CLASS(UClassExporterH);

/*------------------------------------------------------------------------------
	UClassExporterUC implementation.
------------------------------------------------------------------------------*/

void UClassExporterUC::StaticConstructor()
{
	SupportedClass = UClass::StaticClass();
	bText = 1;
	new(Formats)FString(TEXT("UC"));
}
UBOOL UClassExporterUC::ExportText( UObject* Object, const TCHAR* Type, FOutputDevice& Ar, FFeedbackContext* Warn )
{
	UClass* Class = CastChecked<UClass>( Object );

	// Export script text.
	check(Class->GetDefaultObject());
	check(Class->ScriptText);
	UExporter::ExportToOutputDevice( Class->ScriptText, NULL, Ar, TEXT("txt"), TextIndent );

	// Export default properties that differ from parent's.
	Ar.Log( TEXT("\r\n\r\ndefaultproperties\r\n{\r\n") );
	ExportProperties
	(
		Ar,
		Class,
		&Class->Defaults[CPD_Normal](0),
		TextIndent+4,
		Class->GetSuperClass(),
		Class->GetSuperClass() ? &Class->GetSuperClass()->Defaults[CPD_Normal](0) : NULL
	);
	Ar.Log( TEXT("}\r\n") );

	return 1;
}
IMPLEMENT_CLASS(UClassExporterUC);

/*------------------------------------------------------------------------------
	USoundExporterWAV implementation.
------------------------------------------------------------------------------*/

void UPolysExporterT3D::StaticConstructor()
{
	SupportedClass = UPolys::StaticClass();
	bText = 1;
	new(Formats)FString(TEXT("T3D"));
}
UBOOL UPolysExporterT3D::ExportText( UObject* Object, const TCHAR* Type, FOutputDevice& Ar, FFeedbackContext* Warn )
{
	UPolys* Polys = CastChecked<UPolys>( Object );

	Ar.Logf( TEXT("%sBegin PolyList\r\n"), appSpc(TextIndent) );
	for( INT i=0; i<Polys->Element.Num(); i++ )
	{
		FPoly* Poly = &Polys->Element(i);
		TCHAR TempStr[256];

		// Start of polygon plus group/item name if applicable.
		Ar.Logf( TEXT("%s   Begin Polygon"), appSpc(TextIndent) );
		if( Poly->ItemName != NAME_None )
			Ar.Logf( TEXT(" Item=%s"), *Poly->ItemName );
		if( Poly->Texture )
			Ar.Logf( TEXT(" Texture=%s"), Poly->Texture->GetName() );
		if( Poly->PolyFlags != 0 )
			Ar.Logf( TEXT(" Flags=%i"), Poly->PolyFlags );
		if( Poly->iLink != INDEX_NONE )
			Ar.Logf( TEXT(" Link=%i"), Poly->iLink );
		Ar.Logf( TEXT("\r\n") );

		// All coordinates.
		Ar.Logf( TEXT("%s      Origin   %s\r\n"), appSpc(TextIndent), SetFVECTOR(TempStr,&Poly->Base) );
		Ar.Logf( TEXT("%s      Normal   %s\r\n"), appSpc(TextIndent), SetFVECTOR(TempStr,&Poly->Normal) );
		if( Poly->PanU!=0 || Poly->PanV!=0 )
			Ar.Logf( TEXT("%s      Pan      U=%i V=%i\r\n"), appSpc(TextIndent), Poly->PanU, Poly->PanV );
		Ar.Logf( TEXT("%s      TextureU %s\r\n"), appSpc(TextIndent), SetFVECTOR(TempStr,&Poly->TextureU) );
		Ar.Logf( TEXT("%s      TextureV %s\r\n"), appSpc(TextIndent), SetFVECTOR(TempStr,&Poly->TextureV) );
		for( INT j=0; j<Poly->NumVertices; j++ )
			Ar.Logf( TEXT("%s      Vertex   %s\r\n"), appSpc(TextIndent), SetFVECTOR(TempStr,&Poly->Vertex[j]) );
		Ar.Logf( TEXT("%s   End Polygon\r\n"), appSpc(TextIndent) );
	}
	Ar.Logf( TEXT("%sEnd PolyList\r\n"), appSpc(TextIndent) );

	return 1;
}
IMPLEMENT_CLASS(UPolysExporterT3D);

/*------------------------------------------------------------------------------
	UModelExporterT3D implementation.
------------------------------------------------------------------------------*/

void UModelExporterT3D::StaticConstructor()
{
	SupportedClass = UModel::StaticClass();
	bText = 1;
	new(Formats)FString(TEXT("T3D"));
}
UBOOL UModelExporterT3D::ExportText( UObject* Object, const TCHAR* Type, FOutputDevice& Ar, FFeedbackContext* Warn )
{
	UModel* Model = CastChecked<UModel>( Object );

	Ar.Logf( TEXT("%sBegin Brush Name=%s\r\n"), appSpc(TextIndent), Model->GetName() );
	UExporter::ExportToOutputDevice( Model->Polys, NULL, Ar, Type, TextIndent+3 );
	Ar.Logf( TEXT("%sEnd Brush\r\n"), appSpc(TextIndent) );

	return 1;
}
IMPLEMENT_CLASS(UModelExporterT3D);

/*------------------------------------------------------------------------------
	ULevelExporterT3D implementation.
------------------------------------------------------------------------------*/

void ULevelExporterT3D::StaticConstructor()
{
	SupportedClass = ULevel::StaticClass();
	bText = 1;
	new(Formats)FString(TEXT("T3D"));
	new(Formats)FString(TEXT("COPY"));
}
UBOOL ULevelExporterT3D::ExportText( UObject* Object, const TCHAR* Type, FOutputDevice& Ar, FFeedbackContext* Warn )
{
	ULevel* Level = CastChecked<ULevel>( Object );

	Ar.Logf( TEXT("%sBegin Map\r\n"), appSpc(TextIndent) );
	UBOOL AllSelected = appStricmp(Type,TEXT("COPY"))!=0;
	for( INT iActor=0; iActor<Level->Actors.Num(); iActor++ )
	{
		AActor* Actor = Level->Actors(iActor);
		if( Actor && !Cast<ACamera>(Actor) && (AllSelected ||Actor->bSelected) )
		{
			Ar.Logf( TEXT("%sBegin Actor Class=%s Name=%s\r\n"), appSpc(TextIndent), Actor->GetClass()->GetName(), Actor->GetName() );
			ExportProperties( Ar, Actor->GetClass(), (BYTE*)Actor, TextIndent+3, Actor->GetClass(), &Actor->GetClass()->Defaults[CPD_Normal](0) );
			Ar.Logf( TEXT("%sEnd Actor\r\n"), appSpc(TextIndent) );
		}
	}
	Ar.Logf( TEXT("%sEnd Map\r\n"), appSpc(TextIndent) );

	return 1;
}
IMPLEMENT_CLASS(ULevelExporterT3D);

/*------------------------------------------------------------------------------
	The end.
------------------------------------------------------------------------------*/
