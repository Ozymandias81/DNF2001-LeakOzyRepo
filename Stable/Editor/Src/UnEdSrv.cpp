/*=============================================================================
	UnEdSrv.cpp: UEditorEngine implementation, the Unreal editing server
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	What's happening: When the Visual Basic level editor is being used,
	this code exchanges messages with Visual Basic.  This lets Visual Basic
	affect the world, and it gives us a way of sending world information back
	to Visual Basic.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

#include "EditorPrivate.h"
#include "UnRender.h"
#include "../../Engine/Src/UnPath.h"

#pragma DISABLE_OPTIMIZATION /* Not performance-critical */

extern FString GTexNameFilter;
extern TArray<FVertexHit> VertexHitList;
FString GMapExt;

#if 1 //Batch Detail Texture Editing added by Legend on 4/12/2000
static UTexture* CurrentDetailTexture = 0;
#endif

void polygonDeleteMarkers()
{
	if( !GEditor || !GEditor->Level ) return;

	for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
	{
		AActor* pActor = GEditor->Level->Actors(i);
		if( pActor && pActor->IsA(APolyMarker::StaticClass()) )
		{
			pActor->bDeleteMe = 0;	// Make sure they get destroyed!!
			GEditor->Level->DestroyActor( pActor );
		}
	}

	GEditor->RedrawLevel( GEditor->Level );
	GEditor->NoteSelectionChange( GEditor->Level );
}

void brushclipDeleteMarkers()
{
	if( !GEditor || !GEditor->Level ) return;

	for( INT i = 0 ; i < GEditor->Level->Actors.Num() ; i++ )
	{
		AActor* pActor = GEditor->Level->Actors(i);
		if( pActor && pActor->IsA(AClipMarker::StaticClass()) )
		{
			pActor->bDeleteMe = 0;	// Make sure they get destroyed!!
			GEditor->Level->DestroyActor( pActor );
		}
	}

	GEditor->RedrawLevel( GEditor->Level );
	GEditor->NoteSelectionChange( GEditor->Level );
}

// Builds a huge poly aligned with the specified plane.  This poly is
// carved up by the calling routine and used as a capping poly following a clip operation.
//

FPoly edBuildInfiniteFPoly( FPlane* InPlane )
{
	FVector Axis1, Axis2;

	// Find two non-problematic axis vectors.
	InPlane->FindBestAxisVectors( Axis1, Axis2 );

	// Set up the FPoly.
	FPoly EdPoly;
	EdPoly.Init();
	EdPoly.NumVertices = 4;
	EdPoly.Normal.X    = InPlane->X;
	EdPoly.Normal.Y    = InPlane->Y;
	EdPoly.Normal.Z    = InPlane->Z;
	EdPoly.Base        = EdPoly.Normal * InPlane->W;
	EdPoly.Vertex[0]   = EdPoly.Base + Axis1*HALF_WORLD_MAX + Axis2*HALF_WORLD_MAX;
	EdPoly.Vertex[1]   = EdPoly.Base - Axis1*HALF_WORLD_MAX + Axis2*HALF_WORLD_MAX;
	EdPoly.Vertex[2]   = EdPoly.Base - Axis1*HALF_WORLD_MAX - Axis2*HALF_WORLD_MAX;
	EdPoly.Vertex[3]   = EdPoly.Base + Axis1*HALF_WORLD_MAX - Axis2*HALF_WORLD_MAX;

	return EdPoly;
}

// Creates a giant brush, aligned with the specified plane.
void brushclipBuildGiantBrush( ABrush* GiantBrush, FPlane Plane, ABrush* SrcBrush )
{
	//GiantBrush->Modify();
	GiantBrush->Location = FVector(0,0,0);
	GiantBrush->PrePivot = FVector(0,0,0);
	GiantBrush->CsgOper = SrcBrush->CsgOper;
	GiantBrush->SetFlags( RF_Transactional );
	GiantBrush->PolyFlags = 0;

	verify(GiantBrush->Brush);
	verify(GiantBrush->Brush->Polys);

	GiantBrush->Brush->Polys->Element.Empty();

	// Create a list of vertices that can be used for the new brush
	FVector vtxs[8];

	Plane = Plane.Flip();
	FPoly TempPoly = edBuildInfiniteFPoly( &Plane );
	TempPoly.Finalize(0);
	vtxs[0] = TempPoly.Vertex[0];	vtxs[1] = TempPoly.Vertex[1];
	vtxs[2] = TempPoly.Vertex[2];	vtxs[3] = TempPoly.Vertex[3];

	Plane = Plane.Flip();
	FPoly TempPoly2 = edBuildInfiniteFPoly( &Plane );
	vtxs[4] = TempPoly2.Vertex[0] + (TempPoly2.Normal * -(WORLD_MAX));	vtxs[5] = TempPoly2.Vertex[1] + (TempPoly2.Normal * -(WORLD_MAX));
	vtxs[6] = TempPoly2.Vertex[2] + (TempPoly2.Normal * -(WORLD_MAX));	vtxs[7] = TempPoly2.Vertex[3] + (TempPoly2.Normal * -(WORLD_MAX));

	// Create the polys for the new brush.
	FPoly newPoly;

	// TOP
	newPoly.Init();
	newPoly.NumVertices = 4;
	newPoly.Vertex[0] = vtxs[0];	newPoly.Vertex[1] = vtxs[1];	newPoly.Vertex[2] = vtxs[2];	newPoly.Vertex[3] = vtxs[3];
	newPoly.Finalize(0);
	new(GiantBrush->Brush->Polys->Element)FPoly(newPoly);

	// BOTTOM
	newPoly.Init();
	newPoly.NumVertices = 4;
	newPoly.Vertex[0] = vtxs[4];	newPoly.Vertex[1] = vtxs[5];	newPoly.Vertex[2] = vtxs[6];	newPoly.Vertex[3] = vtxs[7];
	newPoly.Finalize(0);
	new(GiantBrush->Brush->Polys->Element)FPoly(newPoly);

	// SIDES
	// 1
	newPoly.Init();
	newPoly.NumVertices = 4;
	newPoly.Vertex[0] = vtxs[1];	newPoly.Vertex[1] = vtxs[0];	newPoly.Vertex[2] = vtxs[7];	newPoly.Vertex[3] = vtxs[6];
	newPoly.Finalize(0);
	new(GiantBrush->Brush->Polys->Element)FPoly(newPoly);

	// 2
	newPoly.Init();
	newPoly.NumVertices = 4;
	newPoly.Vertex[0] = vtxs[2];	newPoly.Vertex[1] = vtxs[1];	newPoly.Vertex[2] = vtxs[6];	newPoly.Vertex[3] = vtxs[5];
	newPoly.Finalize(0);
	new(GiantBrush->Brush->Polys->Element)FPoly(newPoly);

	// 3
	newPoly.Init();
	newPoly.NumVertices = 4;
	newPoly.Vertex[0] = vtxs[3];	newPoly.Vertex[1] = vtxs[2];	newPoly.Vertex[2] = vtxs[5];	newPoly.Vertex[3] = vtxs[4];
	newPoly.Finalize(0);
	new(GiantBrush->Brush->Polys->Element)FPoly(newPoly);

	// 4
	newPoly.Init();
	newPoly.NumVertices = 4;
	newPoly.Vertex[0] = vtxs[0];	newPoly.Vertex[1] = vtxs[3];	newPoly.Vertex[2] = vtxs[4];	newPoly.Vertex[3] = vtxs[7];
	newPoly.Finalize(0);
	new(GiantBrush->Brush->Polys->Element)FPoly(newPoly);

	// Finish creating the new brush.
	GiantBrush->Brush->BuildBound();
}

void ClipBrushAgainstPlane( FPlane InPlane, ABrush* InBrush, UBOOL InSel )
{
	// Create a giant brush to use in the intersection process.
	ABrush* GiantBrush = GEditor->Level->SpawnBrush();
	GiantBrush->Brush = new( InBrush->GetOuter(), NAME_None, RF_NotForClient|RF_NotForServer )UModel( NULL );
	brushclipBuildGiantBrush( GiantBrush, InPlane, InBrush );

	// Create a BSP for the brush that is being clipped.
	GEditor->bspBuild( InBrush->Brush, BSP_Optimal, 0, 1, 0 );
	GEditor->bspRefresh( InBrush->Brush, 1 );
	GEditor->bspBuildBounds( InBrush->Brush );

	// Intersect the giant brush with the source brushes BSP.  This will give us the finished, clipping brush
	// contained inside of the giant brush.
	GEditor->bspBrushCSG( GiantBrush, InBrush->Brush, 0, CSG_Intersect, 0, 0 );
	GEditor->bspUnlinkPolys( GiantBrush->Brush );

	// You need at least 4 polys left over to make a valid brush.
	if( GiantBrush->Brush->Polys->Element.Num() < 4 )
		GEditor->Level->DestroyActor( GiantBrush );
	else
	{
		// Have to special case this if we're clipping the builder brush
		if( InBrush == GEditor->Level->Brush() )
		{
			GiantBrush->CopyPosRotScaleFrom( InBrush );
			GiantBrush->PolyFlags = InBrush->PolyFlags;
			GiantBrush->bSelected = InSel;

			GEditor->Level->Brush()->Modify();
			GEditor->csgCopyBrush( GEditor->Level->Brush(), GiantBrush, 0, 0, 0 );

			GEditor->Level->DestroyActor( GiantBrush );
		}
		else
		{
			// Now we need to insert the giant brush into the actor list where the old brush was in order
			// to preserve brush ordering.

			// Copy all actors into a temp list.
			TArray<AActor*> TempList;
			for( INT i = 2 ; i < GEditor->Level->Actors.Num() - 1; i++ )
				if( GEditor->Level->Actors(i) )
				{
					TempList.AddItem( GEditor->Level->Actors(i) );

					// Once we find the source actor, add the new brush right after it.
					if( (ABrush*)GEditor->Level->Actors(i) == InBrush )
						TempList.AddItem( GiantBrush );
				}

			// Now reload the levels actor list with the templist we created above.
			GEditor->Level->Actors.Remove( 2, GEditor->Level->Actors.Num() - 2 );
			for( INT j = 0; j < TempList.Num() ; j++ )
				GEditor->Level->Actors.AddItem( TempList(j) );

			GiantBrush->CopyPosRotScaleFrom( InBrush );
			GiantBrush->PolyFlags = InBrush->PolyFlags;
			GiantBrush->bSelected = InSel;

			// Clean the brush up.
			for( INT poly = 0 ; poly < GiantBrush->Brush->Polys->Element.Num() ; poly++ )
			{
				FPoly* Poly = &(GiantBrush->Brush->Polys->Element(poly));
				Poly->iLink = poly;
				Poly->Normal = FVector(0,0,0);
				Poly->Finalize(0);
				Poly->Base = Poly->Vertex[0];
			}

			// One final pass to clean the polyflags of all temporary settings.
			for( poly = 0 ; poly < GiantBrush->Brush->Polys->Element.Num() ; poly++ )
			{
				FPoly* Poly = &(GiantBrush->Brush->Polys->Element(poly));
				Poly->PolyFlags &= ~PF_EdCut;
				Poly->PolyFlags &= ~PF_EdProcessed;
			}
		}
	}
}

/*-----------------------------------------------------------------------------
	UnrealEd safe command line.
-----------------------------------------------------------------------------*/

//
// Execute a macro.
//
void UEditorEngine::ExecMacro( const TCHAR* Filename, FOutputDevice& Ar )
{
	// Create text buffer and prevent garbage collection.
	UTextBuffer* Text = ImportObject<UTextBuffer>( GetTransientPackage(), NAME_None, 0, Filename );
	if( Text )
	{
		Text->AddToRoot();
		debugf( TEXT("Execing %s"), Filename );
		TCHAR Temp[256];
		const TCHAR* Data = *Text->Text;
		while( ParseLine( &Data, Temp, ARRAY_COUNT(Temp) ) )
			Exec( Temp, Ar );
		Text->RemoveFromRoot();
		delete Text;
	}
	else Ar.Logf( NAME_ExecWarning, LocalizeError("FileNotFound",TEXT("UEditorEngine")), Filename );
}

//
// Execute a command that is safe for rebuilds.
//
UBOOL UEditorEngine::SafeExec( const TCHAR* InStr, FOutputDevice& Ar )
{
	TCHAR TempFname[256], TempStr[256], TempName[NAME_SIZE];
	const TCHAR* Str=InStr;
	if( ParseCommand(&Str,TEXT("MACRO")) || ParseCommand(&Str,TEXT("EXEC")) )//oldver (exec)
	{
		TCHAR Filename[64];
		if( ParseToken( Str, Filename, ARRAY_COUNT(Filename), 0 ) )
			ExecMacro( Filename, Ar );
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("NEW")) )
	{
		// Generalized object importing.
		DWORD   Flags         = RF_Public|RF_Standalone;
		if( ParseCommand(&Str,TEXT("STANDALONE")) )
			Flags = RF_Public|RF_Standalone;
		else if( ParseCommand(&Str,TEXT("PUBLIC")) )
			Flags = RF_Public;
		else if( ParseCommand(&Str,TEXT("PRIVATE")) )
			Flags = 0;
		FString ClassName     = ParseToken(Str,0);
		UClass* Class         = FindObject<UClass>( ANY_PACKAGE, *ClassName );
		if( !Class )
		{
			Ar.Logf( NAME_ExecWarning, TEXT("Unrecognized or missing factor class %s"), *ClassName );
			return 1;
		}
		FString  PackageName  = ParentContext ? ParentContext->GetName() : TEXT("");
		FString  FileName     = TEXT("");
		FString  ObjectName   = TEXT("");
		UClass*  ContextClass = NULL;
		UObject* Context      = NULL;
		Parse( Str, TEXT("Package="), PackageName );
		Parse( Str, TEXT("File="), FileName );
		ParseObject( Str, TEXT("ContextClass="), UClass::StaticClass(), *(UObject**)&ContextClass, NULL );
		ParseObject( Str, TEXT("Context="), ContextClass, Context, NULL );
		if
		(	!Parse( Str, TEXT("Name="), ObjectName )
		&&	FileName!=TEXT("") )
		{
			// Deduce object name from filename.
			ObjectName = FileName;
			for( ; ; )
			{
				INT i=ObjectName.InStr(PATH_SEPARATOR);
				if( i==-1 )
					i=ObjectName.InStr(TEXT("/"));
				if( i==-1 )
					break;
				ObjectName = ObjectName.Mid( i+1 );
			}
			if( ObjectName.InStr(TEXT("."))>=0 )
				ObjectName = ObjectName.Left( ObjectName.InStr(TEXT(".")) );
		}
		UFactory* Factory = NULL;
		if( Class->IsChildOf(UFactory::StaticClass()) )
			Factory = ConstructObject<UFactory>( Class );
		UObject* Object = UFactory::StaticImportObject
		(
			Factory ? Factory->SupportedClass : Class,
			CreatePackage(NULL,*PackageName),
			*ObjectName,
			Flags,
			*FileName,
			Context,
			Factory,
			Str,
			GWarn
		);
		if( !Object )
			Ar.Logf( NAME_ExecWarning, TEXT("Failed factoring: %s"), InStr );
		GCache.Flush( 0, ~0, 1 );
		return 1;
	}
	else if( ParseCommand( &Str, TEXT("LOAD") ) )
	{
		// Object file loading.
		if( Parse( Str, TEXT("FILE="), TempFname, 80 ) )
		{
			if( !ParentContext )
				Level->RememberActors();
			TCHAR PackageName[256]=TEXT("");
			UObject* Pkg=NULL;
			if( Parse( Str, TEXT("Package="), PackageName, ARRAY_COUNT(PackageName) ) )
			{
				TCHAR Temp[256], *End;
				appStrcpy( Temp, PackageName );
				End = appStrchr(Temp,'.');
				if( End )
					*End++ = 0;
				Pkg = CreatePackage( NULL, PackageName );
			}
			Pkg = LoadPackage( Pkg, TempFname, 0 );
			if( *PackageName )
				ResetLoaders( Pkg, 0, 1 );
			GCache.Flush();
			if( !ParentContext )
			{
				Level->ReconcileActors();
				RedrawLevel(Level);
			}
		}
		else Ar.Log( NAME_ExecWarning, TEXT("Missing filename") );
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("Texture")) )
	{
		if( ParseCommand(&Str,TEXT("Flush")))
		{
			EdCallback( EDC_FlushAllViewports, 1);
			EdCallback( EDC_FlushAllViewports, 0);
			Ar.Log( NAME_ExecWarning, TEXT("Texture information flushed from viewports.") );
			return 1;
		} else
		if( ParseCommand(&Str,TEXT("Import")) )
		{
			// Texture importing.
			//->FACTOR TEXTURE ...
			FName PkgName = ParentContext ? ParentContext->GetFName() : NAME_None;
			Parse( Str, TEXT("Package="), PkgName );
			if( PkgName!=NAME_None && Parse( Str, TEXT("File="), TempFname, ARRAY_COUNT(TempFname) ) )
			{
				UPackage* Pkg = CreatePackage(NULL,*PkgName);
				if( !Parse( Str, TEXT("Name="),  TempName,  NAME_SIZE ) )
				{
					// Deduce package name from filename.
					TCHAR* End = TempFname + appStrlen(TempFname);
					while( End>TempFname && End[-1]!=PATH_SEPARATOR[0] && End[-1]!='/' )
						End--;
					appStrncpy( TempName, End, NAME_SIZE );
					if( appStrchr(TempName,'.') )
						*appStrchr(TempName,'.') = 0;
				}
				GWarn->BeginSlowTask( TEXT("Importing texture"), 1, 0 );
				UBOOL DoMips=1;
				ParseUBOOL( Str, TEXT("Mips="), DoMips );
				extern TCHAR* GFile;
				GFile = TempFname;
				FName GroupName = NAME_None;
				if( Parse( Str, TEXT("GROUP="), GroupName ) && GroupName!=NAME_None )
					Pkg = CreatePackage(Pkg,*GroupName);
				UTexture* Texture = ImportObject<UTexture>( Pkg, TempName, RF_Public|RF_Standalone, TempFname );
				if( Texture )
				{
					DWORD TexFlags=0;
					Parse( Str, TEXT("LODSet="), Texture->LODSet );
					Parse( Str, TEXT("TexFlags="), TexFlags );
					Parse( Str, TEXT("FLAGS="),    Texture->PolyFlags );
					ParseObject<UTexture>( Str, TEXT("DETAIL="), Texture->DetailTexture, ANY_PACKAGE );
					ParseObject<UTexture>( Str, TEXT("MTEX="), Texture->MacroTexture, ANY_PACKAGE );
					ParseObject<UTexture>( Str, TEXT("NEXT="), Texture->AnimNext, ANY_PACKAGE );
					Texture->CreateMips( DoMips, 1 );
					Texture->CreateColorRange();
					UBOOL AlphaTrick=0;
					ParseUBOOL( Str, TEXT("ALPHATRICK="), AlphaTrick );
					if( AlphaTrick )
						for( INT i=0; i<256; i++ )
							Texture->Palette->Colors(i).A = Texture->Palette->Colors(i).B;
					debugf( NAME_Log, TEXT("Imported %s"), Texture->GetFullName() );
				}
				else Ar.Logf( NAME_ExecWarning, TEXT("Import texture %s from %s failed"), TempName, TempFname );
				GWarn->EndSlowTask();
				GCache.Flush( 0, ~0, 1 );

				// NJS: Flush the viewports:
				EdCallback(EDC_FlushAllViewports,1);
				EdCallback(EDC_FlushAllViewports,0);
			}
			else Ar.Logf( NAME_ExecWarning, TEXT("Missing file or name") );
			return 1;
		}
	}
	else if( ParseCommand(&Str,TEXT("FONT")) )//oldver
	{
		if( ParseCommand(&Str,TEXT("IMPORT")) )//oldver
			return SafeExec( *(US+TEXT("NEW FONTFACTORY ")+Str), Ar ); 
	}
	else if( ParseCommand(&Str,TEXT("OBJ")) )//oldver
	{
		UClass* Type;
		if( ParseCommand( &Str, TEXT("LOAD") ) )//oldver
			return SafeExec( *(US+TEXT("LOAD ")+Str), Ar ); 
		else if( ParseCommand(&Str,TEXT("IMPORT")) )//oldver
			if( ParseObject<UClass>( Str, TEXT("TYPE="), Type, ANY_PACKAGE ) )
				return SafeExec( *(US+TEXT("NEW STANDALONE ")+Type->GetName()+TEXT(" ")+Str), Ar ); 
		return 0;
	}
	else if( ParseCommand(&Str,TEXT("STATICMESH")) )
	{
		/*
		if(ParseCommand(&Str,TEXT("ANALYZE"))) // STATICMESH ANALYZE
		{
			//
			// Analyzes the static meshes and logs debug info.
			//

			for(INT ActorIndex = 0;ActorIndex < Level->Actors.Num();ActorIndex++)
			{
				AActor*	Actor = Level->Actors(ActorIndex);

				if(Actor && Actor->bSelected && Actor->StaticMesh)
				{
					int	NumSections = 0,
						NumTriangles = 0;

					for(int Index = 0;Index < Actor->StaticMesh->Sections.Num();Index++)
					{
						NumSections++;
						NumTriangles += Actor->StaticMesh->Sections(Index).NumTriangles;
					}

					debugf(TEXT("Actor: %s"),Actor->GetName());
					debugf(TEXT("	StaticMesh: %s"),Actor->StaticMesh->GetName());
					debugf(TEXT("		%u sections - %u triangles - %f vertices/triangle"),NumSections,NumTriangles,((float) Actor->StaticMesh->VertexBuffer->Vertices.Num()) / ((float) NumTriangles));

					debugf(TEXT("		Sections:"));

					for(INT SectionIndex = 0;SectionIndex < Actor->StaticMesh->Sections.Num();SectionIndex++)
					{
						FStaticMeshSection&	Section = Actor->StaticMesh->Sections(SectionIndex);

						debugf(TEXT("			Texture=%s PolyFlags=%08x FirstIndex=%u NumTriangles=%u MinIndex=%u MaxIndex=%u"),Section.Texture->GetName(),Section.PolyFlags,Section.FirstIndex,Section.NumTriangles,Section.MinIndex,Section.MaxIndex);
					}

					debugf(TEXT("		Light info:"));

					for(INT LightIndex = 0;LightIndex < Actor->StaticMesh->LightInfos.Num();LightIndex++)
						debugf(TEXT("			LightActor=%s Applied=%u"),Actor->StaticMesh->LightInfos(LightIndex).LightActor->GetName(),Actor->StaticMesh->LightInfos(LightIndex).Applied);
				}
			}
		}
		else if( ParseCommand(&Str,TEXT("TOBRUSH")) )	// STATICMESH TOBRUSH
		{
			//
			// Converts all selected static meshes into regular additive brushes
			//

			Trans->Begin(TEXT("TOBRUSH"));
			Level->Modify();
			FinishAllSnaps(Level);

			for(INT x = 0 ; x < Level->Actors.Num() ; x++)
			{
				AActor* Actor = Level->Actors(x);
				if( Actor && Actor->bSelected && Actor->IsA(AStaticMeshActor::StaticClass()) )
				{
					UStaticMesh* StaticMesh = Actor->StaticMesh;
					check(StaticMesh);

					ABrush* NewBrush = GEditor->Level->SpawnBrush();
					NewBrush->Brush = new( Level->GetOuter(), NAME_None, RF_NotForClient|RF_NotForServer )UModel( NULL );
					NewBrush->Location = Actor->Location;
					NewBrush->PrePivot = Actor->PrePivot;
					NewBrush->Rotation = Actor->Rotation;
					NewBrush->CsgOper = CSG_Add;
					NewBrush->SetFlags( RF_Transactional );
					NewBrush->PolyFlags = 0;
					
					for(INT SectionIndex = 0;SectionIndex < StaticMesh->Sections.Num();SectionIndex++)
					{
						FStaticMeshSection*	Section = &(StaticMesh->Sections(SectionIndex));

						for( INT x = 0 ; x < Section->NumTriangles ; x++ )
						{
							FUntransformedVertex Vertex[3];

							Vertex[0] = StaticMesh->VertexBuffer->Vertices(StaticMesh->IndexBuffer->Indices(Section->FirstIndex + (x*3)));
							Vertex[1] = StaticMesh->VertexBuffer->Vertices(StaticMesh->IndexBuffer->Indices(Section->FirstIndex + ((x*3)+1)));
							Vertex[2] = StaticMesh->VertexBuffer->Vertices(StaticMesh->IndexBuffer->Indices(Section->FirstIndex + ((x*3)+2)));

							FPoly newPoly;
							newPoly.Init();
							newPoly.NumVertices = 3;
							newPoly.Vertex[0] = Vertex[0].Position;
							newPoly.Vertex[1] = Vertex[1].Position;
							newPoly.Vertex[2] = Vertex[2].Position;
							newPoly.Finalize(0);
							new(NewBrush->Brush->Polys->Element)FPoly(newPoly);
						}
					}

					NewBrush->Brush->BuildBound();
				}
			}

			Trans->End();
			RedrawLevel(Level);

			return 1;

		}
		*/
	}
	else if( ParseCommand(&Str,TEXT("MESH")) )
	{
		// CDH...
		if( ParseCommand(&Str,TEXT("CREATE")) )
		{
			TCHAR TempName[NAME_SIZE];
			FName PkgName = ParentContext ? ParentContext->GetName() : Level->GetOuter()->GetFName();
			Parse(Str, TEXT("PACKAGE="), PkgName);
			if (!Parse(Str, TEXT("NAME="), TempName, ARRAY_COUNT(TempName)))
			{
				Ar.Log(NAME_ExecWarning, TEXT("Bad MESH CREATE: Missing name"));
				return 1;
			}
			UPackage* Pkg = CreatePackage(NULL,*PkgName);
			FName Group = NAME_None;
			if (Parse(Str, TEXT("GROUP="), Group) && Group!=NAME_None)
				Pkg = CreatePackage(Pkg, *Group);
			UDukeMesh* Mesh = new(Pkg, TempName, RF_Public|RF_Standalone) UDukeMesh;
			Mesh->ConfigName = FString(TEXT("default.cpj\\default"));
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("COMMAND")) )
		{
			UMesh *Mesh;
			if (ParseObject<UMesh>(Str,TEXT("MESH="),Mesh,ANY_PACKAGE))
			{
				TCHAR CmdStr[256];
				if (Mesh && Parse(Str, TEXT("CMD="), CmdStr, ARRAY_COUNT(CmdStr)))
				{
					UMeshInstance* MeshInst = Mesh->GetInstance(NULL);
					if (MeshInst)
						MeshInst->SendStringCommand(CmdStr);
				}
			}
			else Ar.Log( NAME_ExecWarning, TEXT("Bad MESH COMMAND") );
			return 1;
		}
		// ...CDH
		else if( ParseCommand(&Str,TEXT("IMPORT")) )
		{
			// Mesh importing.
			TCHAR TempStr1[256];
			if
			(	Parse( Str, TEXT("MESH="), TempName, ARRAY_COUNT(TempName) )
			&&	Parse( Str, TEXT("ANIVFILE="), TempStr, ARRAY_COUNT(TempStr) )
			&&	Parse( Str, TEXT("DATAFILE="), TempStr1, ARRAY_COUNT(TempStr1) ) )
			{
				UBOOL Unmirror=0, ZeroTex=0; INT UnMirrorTex;

				FMeshLodProcessInfo LODInfo;
				LODInfo.LevelOfDetail = true; 

#if ENGINE_VERSION>=230
				LODInfo.OldAnimFormat = 0;
				if( !Parse(Str,TEXT("REORDER="),LODInfo.OldAnimFormat) )
					LODInfo.OldAnimFormat = 0;
#else
				LODInfo.OldAnimFormat = 1; 
#endif

				LODInfo.Style = 0;				
				LODInfo.SampleFrame = 0;
				LODInfo.NoUVData = false;
				
				ParseUBOOL( Str, TEXT("UNMIRROR="), Unmirror );
				ParseUBOOL( Str, TEXT("ZEROTEX="), ZeroTex );

				ParseUBOOL( Str, TEXT("MLOD="),  LODInfo.LevelOfDetail ); 
				Parse(Str,TEXT("LODSTYLE="),	 LODInfo.Style );
				Parse(Str,TEXT("LODFRAME="),	 LODInfo.SampleFrame );
				ParseUBOOL(Str,TEXT("LODNOTEX="),LODInfo.NoUVData );
				ParseUBOOL(Str,TEXT("LODOLD="),  LODInfo.OldAnimFormat );

				if( !Parse( Str, TEXT("UNMIRRORTEX="), UnMirrorTex ) )
					UnMirrorTex = -1;
				meshImport( TempName, ParentContext, TempStr, TempStr1, Unmirror, ZeroTex, UnMirrorTex, &LODInfo );
			}
			else Ar.Log(NAME_ExecWarning,TEXT("Bad MESH IMPORT"));
			return 1;
		}
		else if( ParseCommand(&Str, TEXT("DROPFRAMES")) )
		{
			UUnrealMesh* Mesh;
			INT StartFrame;
			INT NumFrames;
			if
			(	ParseObject<UUnrealMesh>( Str, TEXT("MESH="), Mesh, ANY_PACKAGE )
			&&	Parse( Str, TEXT("STARTFRAME="), StartFrame )
			&&	Parse( Str, TEXT("NUMFRAMES="), NumFrames ) )
			{
				meshDropFrames(Mesh, StartFrame, NumFrames);
			}
		}
		// LodMeshes: parse LOD specific parameters.
		else if( ParseCommand(&Str,TEXT("LODPARAMS")) )
		{
			// Mesh origin.
			UUnrealMesh *Mesh;
			if( ParseObject<UUnrealMesh>(Str,TEXT("MESH="),Mesh,ANY_PACKAGE) )
			{
				// Ignore the LOD-specific parameters if Mesh is not a true UUnrealLodMesh.
				if( Mesh->IsA(UUnrealLodMesh::StaticClass()))
				{			
					// If not set, they keep their default values.
					UUnrealLodMesh* LodMesh = (UUnrealLodMesh*)Mesh;
					
					Parse(Str,TEXT("MINVERTS="),    LodMesh->LODMinVerts);
					Parse(Str,TEXT("STRENGTH="),    LodMesh->LODStrength);
					Parse(Str,TEXT("MORPH="),		LodMesh->LODMorph);
					Parse(Str,TEXT("HYSTERESIS="),	LodMesh->LODHysteresis);
					Parse(Str,TEXT("ZDISP="),       LodMesh->LODZDisplace);					

					// check validity
					if( (LodMesh->LODMorph < 0.0f) || (LodMesh->LODMorph >1.0f) )
					{
						LodMesh->LODMorph = 0.0f;
						Ar.Log( NAME_ExecWarning, TEXT("Bad LOD MORPH supplied."));	
					}
					if( (LodMesh->LODMinVerts < 0) || (LodMesh->LODMinVerts > LodMesh->FrameVerts) )
					{
						LodMesh->LODMinVerts = Max(10,LodMesh->FrameVerts);
						Ar.Log( NAME_ExecWarning, TEXT("Bad LOD MINVERTS supplied."));	
					}
					if( LodMesh->LODStrength < 0.00001f )
					{
						LodMesh->LODStrength = 0.0f;
					}
				}
				else Ar.Log( NAME_ExecWarning, TEXT("Need a LOD mesh (MLOD=1) for these LODPARAMS."));
			}
			else Ar.Log( NAME_ExecWarning, TEXT("Bad MESH LODPARAMS") );
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("ORIGIN")) )
		{
			// Mesh origin.
			UMesh *Mesh;
			if( ParseObject<UMesh>(Str,TEXT("MESH="),Mesh,ANY_PACKAGE) )
			{
				if (Mesh && Mesh->IsA(UUnrealMesh::StaticClass()))
				{
					UUnrealMesh* UnrMesh = (UUnrealMesh*)Mesh;

					FVector Origin(0,0,0);
					GetFVECTOR ( Str, Origin );
					UnrMesh->Origin = Origin;
					
					FRotator RotOrigin(0,0,0);
					GetFROTATOR( Str, RotOrigin, 256 );
					UnrMesh->RotOrigin = RotOrigin;
				}
			}
			else Ar.Log( NAME_ExecWarning, TEXT("Bad MESH ORIGIN") );
			return 1;
		}
		else if( ParseCommand( &Str, TEXT("SCALE")) )
		{
			// Mesh scaling.
			UMesh* Mesh = NULL;
			if (!ParseObject<UMesh>(Str, TEXT("MESH="), Mesh, ANY_PACKAGE))
				if (!ParseObject<UMesh>(Str, TEXT("MESHMAP="), Mesh, ANY_PACKAGE))//oldver (CDH)
					Mesh=NULL;
			if (Mesh && Mesh->IsA(UUnrealMesh::StaticClass()))
			{
				UUnrealMesh* UnrMesh = (UUnrealMesh*)Mesh;
				FVector Scale(1,1,1);
				GetFVECTOR(Str, Scale);
				UnrMesh->SetScale(Scale);
				FCoords Coords = GMath.UnitCoords * FVector(0,0,0) * UnrMesh->RotOrigin * FScale(UnrMesh->Scale,0.0,SHEER_None);
				TArray<FLOAT> RMS(UnrMesh->TextureLOD.Num()), Count(UnrMesh->TextureLOD.Num());
				{for( INT i=0; i<UnrMesh->TextureLOD.Num(); i++ )
					RMS(i)=Count(i)=0.0;}
				{for( INT n=0; n<UnrMesh->AnimFrames; n++ )
				{
					for( INT i=0; i<UnrMesh->Tris.Num(); i++ )
					{
						FMeshTri& Tri = UnrMesh->Tris(i);
						for( INT j=0,k=2; j<3; k=j++ )
						{
							FLOAT Space  = (UnrMesh->Verts(n*UnrMesh->FrameVerts+Tri.iVertex[j]).Vector()-UnrMesh->Verts(n*UnrMesh->FrameVerts+Tri.iVertex[k]).Vector()).TransformVectorBy(Coords).Size();
							FLOAT Texels = appSqrt(Square((INT)Tri.Tex[j].U-(INT)Tri.Tex[k].U) + Square((INT)Tri.Tex[j].V-(INT)Tri.Tex[k].V));
							RMS  (Tri.TextureIndex) += /*Square*/(Space/(Texels+1.0));
							Count(Tri.TextureIndex) += 1.0;
						}
					}
				}}
				{for( INT i=0; i<UnrMesh->TextureLOD.Num(); i++ )
				{
					UnrMesh->TextureLOD(i) = /*appSqrt*/(RMS(i)/(0.01+Count(i)));
					if( Count(i)>0.0 )
						debugf( TEXT("Texture LOD factor for %s %i = %f"), UnrMesh->GetName(), i, UnrMesh->TextureLOD(i) );
				}}
			}
			else Ar.Log( NAME_ExecWarning, TEXT("Bad MESH SCALE") );
			return 1;
		}
		else if( ParseCommand( &Str, TEXT("SETTEXTURE")) )
		{
			// Mesh texture mapping.
			UUnrealMesh* Mesh = NULL;
			UTexture* Texture;
			INT Num;
			if (!ParseObject<UUnrealMesh>(Str, TEXT("MESH="), Mesh, ANY_PACKAGE))
				if (!ParseObject<UUnrealMesh>(Str, TEXT("MESHMAP="), Mesh, ANY_PACKAGE))//oldver (CDH)
					Mesh=NULL;
			if
			(	Mesh
			&&	ParseObject<UTexture>( Str, TEXT("TEXTURE="), Texture, ANY_PACKAGE )
			&&	Parse( Str, TEXT("NUM="), Num )
			&&	Num<Mesh->Textures.Num() )
			{
				Mesh->Textures( Num ) = Texture;
				FLOAT TextureLod=1.0;
				Parse( Str, TEXT("TLOD="), TextureLod );
				if( Num < Mesh->TextureLOD.Num() )
					Mesh->TextureLOD( Num ) *= TextureLod;
			}
			else Ar.Logf( NAME_ExecWarning, TEXT("Missing mesh, texture, or num (%s)"), Str );
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("SEQUENCE")) )
		{
			// Mesh animation sequences.
			UUnrealMesh *Mesh;
			FMeshAnimSeq Seq;
			if
			(	ParseObject<UUnrealMesh>( Str, TEXT("MESH="), Mesh, ANY_PACKAGE )
			&&	Parse( Str, TEXT("SEQ="), Seq.Name )
			&&	Parse( Str, TEXT("STARTFRAME="), Seq.StartFrame )
			&&	Parse( Str, TEXT("NUMFRAMES="), Seq.NumFrames ) )
			{
				Parse( Str, TEXT("RATE="), Seq.Rate );
				Parse( Str, TEXT("GROUP="), Seq.Group );
				for( INT i=0; i<Mesh->AnimSeqs.Num(); i++ )
					if( Mesh->AnimSeqs(i).Name==Seq.Name )
						break;
				if( i<Mesh->AnimSeqs.Num() )
					Mesh->AnimSeqs(i)=Seq;
				else
					new( Mesh->AnimSeqs )FMeshAnimSeq( Seq );
				Mesh->AnimSeqs.Shrink();
			}
			else Ar.Log(NAME_ExecWarning,TEXT("Bad MESH SEQUENCE"));
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("NOTIFY")) )
		{
			// Mesh notifications.
			UUnrealMesh* Mesh;
			FName SeqName;
			FMeshAnimNotify Notify;
			if
			(	ParseObject<UUnrealMesh>( Str, TEXT("MESH="), Mesh, ANY_PACKAGE )
			&&	Parse( Str, TEXT("SEQ="), SeqName )
			&&	Parse( Str, TEXT("TIME="), Notify.Time )
			&&	Parse( Str, TEXT("FUNCTION="), Notify.Function ) )
			{
				FMeshAnimSeq* Seq = NULL;
				for (INT iSeq=0;iSeq<Mesh->AnimSeqs.Num();iSeq++)
				{
					if (SeqName==Mesh->AnimSeqs(iSeq).Name)
					{
						Seq = &Mesh->AnimSeqs(iSeq);
						break;
					}
				}
				if( Seq ) new( Seq->Notifys )FMeshAnimNotify( Notify );
				else Ar.Log( NAME_ExecWarning, TEXT("Unknown sequence in MESH NOTIFY") );
			}
			else Ar.Log( NAME_ExecWarning, TEXT("Bad MESH NOTIFY") );
			return 1;
		}
	}
	else if( ParseCommand( &Str, TEXT("AUDIO")) )//oldver
	{
		if( ParseCommand(&Str,TEXT("IMPORT")) )//oldver
		{
			FString File, Name, Group;
			Parse(Str,TEXT("FILE="),File);
			FString PkgName = ParentContext ? ParentContext->GetName() : Level->GetOuter()->GetName();
			Parse( Str, TEXT("PACKAGE="), PkgName );
			UPackage* Pkg = CreatePackage(NULL,*PkgName);
			if( Parse(Str,TEXT("GROUP="),Group) && Group!=NAME_None )
				Pkg = CreatePackage( Pkg, *Group );
			FString Cmd = US + TEXT("NEW SOUND FILE=") + File + TEXT(" PACKAGE=") + PkgName;
			if( Parse(Str,TEXT("GROUP="),Group) )
				Cmd = Cmd + TEXT(".") + Group;
			if( Parse(Str,TEXT("NAME="),Name) )
				Cmd = Cmd + TEXT(" NAME=") + Name;
			return SafeExec( *Cmd, Ar ); 
		}
	}
	return 0;
}

/*-----------------------------------------------------------------------------
	UnrealEd command line.
-----------------------------------------------------------------------------*/

//
// Process an incoming network message meant for the editor server
//
UBOOL UEditorEngine::Exec( const TCHAR* Stream, FOutputDevice& Ar )
{
	//debugf("GEditor Exec: %s",Stream);
	TCHAR ErrorTemp[256]=TEXT("Setup: ");
	UBOOL Processed=0;

	_WORD	 		Word1,Word2,Word4;
	INT				Index1;
	TCHAR	 		TempStr[256],TempFname[256],TempName[256],Temp[256];

	if( appStrlen(Stream)<200 )
	{
		appStrcat( ErrorTemp, Stream );
		debugf( NAME_Cmd, Stream );
	}

	UModel* Brush = Level ? Level->Brush()->Brush : NULL;
	//if( Brush ) check(stricmp(Brush->GetName(),"BRUSH")==0);

	appStrncpy( Temp, Stream, 256 );
	const TCHAR* Str = &Temp[0];

	appStrncpy( ErrorTemp, Str, 79 );
	ErrorTemp[79]=0;

	//------------------------------------------------------------------------------------
	// BRUSH
	//
	if( SafeExec( Stream, Ar ) )
	{
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("EDCALLBACK")) )
	{
		if( ParseCommand(&Str,TEXT("SURFPROPS")) )
			EdCallback( EDC_SurfProps, 0 );
	}
	else if( ParseCommand(&Str,TEXT("POLYGON")) )
	{
		if( ParseCommand(&Str,TEXT("DELETE")) )
		{
			polygonDeleteMarkers();
		}
	}
	else if( ParseCommand(&Str,TEXT("BRUSHCLIP")) )		// BRUSHCLIP
	{
		// Locates the first 2 ClipMarkers in the world and flips their locations, which
		// effectively flips the normal of the clipping plane.
		if( ParseCommand(&Str,TEXT("FLIP")) )			// BRUSHCLIP FLIP
		{
			AActor *pActor1, *pActor2;
			pActor1 = pActor2 = NULL;
			for( INT i = 0 ; i < Level->Actors.Num() ; i++ )
			{
				AActor* pActor = Level->Actors(i);
				if( pActor && pActor->IsA(AClipMarker::StaticClass()) )
				{
					if( !pActor1 )
						pActor1 = pActor;
					else
						if( !pActor2 )
							pActor2 = pActor;

					// Once we have 2 valid actors, break out...
					if( pActor2 ) break;
				}
			}

			if( pActor1 && pActor2 )
				Exchange( pActor1->Location, pActor2->Location );

			RedrawLevel( Level );
		}
		// Locate any existing clipping markers and delete them.
		else if( ParseCommand(&Str,TEXT("DELETE")) )	// BRUSHCLIP DELETE
		{
			brushclipDeleteMarkers();
		}
		// Execute the clip based on the current marker positions.
		else
		{
			// Get the current viewport.
			UViewport* CurrentViewport = (UViewport*)GCurrentViewport;

			if( !CurrentViewport )
			{
				debugf(TEXT("BRUSHCLIP : No current viewport - make sure a viewport has the focus before trying this operation."));
				return 1;
			}

			// Gather a list of all the ClipMarkers in the level.
			TArray<AActor*> ClipMarkers;

			for( INT actor = 0 ; actor < Level->Actors.Num() ; actor++ )
			{
				AActor* pActor = Level->Actors(actor);
				if( pActor && pActor->IsA(AClipMarker::StaticClass()) )
					ClipMarkers.AddItem( pActor );
			}

			if( (CurrentViewport->IsOrtho() && ClipMarkers.Num() < 2)
				|| (!CurrentViewport->IsOrtho() && ClipMarkers.Num() < 3))
			{
				debugf(TEXT("BRUSHCLIP : You don't have enough ClipMarkers to perform this operation."));
				return 1;
			}

			// Create a clipping plane based on ClipMarkers present in the level.
			FVector vtx1, vtx2, vtx3;
			FPoly ClippingPlanePoly;

			vtx1 = ClipMarkers(0)->Location;
			vtx2 = ClipMarkers(1)->Location;

			if( ClipMarkers.Num() == 3 )
			{
				// If we have 3 points, just grab the third one to complete the plane.
				vtx3 = ClipMarkers(2)->Location;
			}
			else
			{
				// If we only have 2 points, we will assume the third based on the viewport.
				// (With just 2 points, we can only use ortho viewports)
				vtx3 = vtx1;
				if( CurrentViewport->IsOrtho() )
					switch( CurrentViewport->Actor->RendMap )
					{
						case REN_OrthXY:	vtx3.Z -= 64;	break;
						case REN_OrthXZ:	vtx3.Y -= 64;	break;
						case REN_OrthYZ:	vtx3.X -= 64;	break;
					}
			}

			UBOOL bSplit = ParseCommand(&Str,TEXT("SPLIT"));

			// If we've gotten this far, we're good to go.  Do the clip.
			Trans->Begin( TEXT("Brush Clip") );

			Level->Modify();

			for( actor = 0; actor < Level->Actors.Num() ; actor++ )
			{
				AActor* SrcActor = Level->Actors(actor);
				if( SrcActor && SrcActor->bSelected && SrcActor->IsBrush() )
				{
					ABrush* SrcBrush = (ABrush*)SrcActor;
					UBOOL bBuilderBrush = (SrcBrush == Level->Brush());

					FCoords BrushW(SrcBrush->ToWorld()),
						BrushL(SrcBrush->ToLocal());

					// Create a clipping plane for this brushes coordinate system.
					ClippingPlanePoly.NumVertices = 3;
					ClippingPlanePoly.Vertex[0] = vtx1.TransformVectorBy( BrushL );
					ClippingPlanePoly.Vertex[1] = vtx2.TransformVectorBy( BrushL );
					ClippingPlanePoly.Vertex[2] = vtx3.TransformVectorBy( BrushL );

					if( ClippingPlanePoly.CalcNormal(1) )
					{
						debugf(TEXT("BRUSHCLIP : Unable to compute normal!  Try moving the clip markers further apart."));
						return 1;
					}

					ClippingPlanePoly.Base = ClippingPlanePoly.Vertex[0];
					ClippingPlanePoly.Base -= ( SrcBrush->Location.TransformVectorBy( BrushL ) - SrcBrush->PrePivot.TransformVectorBy( BrushL ) );
					FPlane ClippingPlane( ClippingPlanePoly.Base, ClippingPlanePoly.Normal );

					ClipBrushAgainstPlane( ClippingPlane, SrcBrush, 1 );

					// If we're doing a split instead of just a plain clip.
					// NOTE : You can't do split operations against the builder brush.
					if( bSplit && !bBuilderBrush )
					{
						// Flip the clipping plane first.
						ClippingPlane = ClippingPlane.Flip();

						ClipBrushAgainstPlane( ClippingPlane, SrcBrush, 0 );
					}

					// Clean up
					if( !bBuilderBrush )	// Don't destroy the builder brush!
						Level->DestroyActor( SrcBrush );

					// Option to remove the clip markers after the clip operation is complete.
					if( ParseCommand(&Str,TEXT("DELMARKERS")) )
						brushclipDeleteMarkers();
				}
			}

			Trans->End();
		}
	}
	else if(ParseCommand(&Str,TEXT("STATICMESH")))
	{
	/*
		if(ParseCommand(&Str,TEXT("FROM")))
		{
			if(ParseCommand(&Str,TEXT("BRUSH")))		// STATICMESH FROM BRUSH
			{
				Trans->Begin(TEXT("STATICMESH FROM BRUSH"));
				Level->Modify();
				FinishAllSnaps(Level);

				AStaticMeshActor*	StaticMeshActor = (AStaticMeshActor*) Level->SpawnActor(AStaticMeshActor::StaticClass(),NAME_None,Level->Brush()->Location);
				StaticMeshActor->StaticMesh = CreateStaticMeshFromBrush(Level->GetOuter(),NAME_None,Level->Brush());
				StaticMeshActor->PostEditChange();

				Trans->End();
				RedrawLevel(Level);
				Processed = 1;
			}
			else if(ParseCommand(&Str,TEXT("ACTOR")))	// STATICMESH FROM ACTOR
			{
				Trans->Begin(TEXT("STATICMESH FROM ACTOR"));
				Level->Modify();
				FinishAllSnaps(Level);

				// Find a suitable selected actor.

				for(INT ActorIndex = 0;ActorIndex < Level->Actors.Num();ActorIndex++)
				{
					AActor*	Actor = Level->Actors(ActorIndex);

					if(Actor && Actor->bSelected && Actor->Mesh != NULL)
					{
						AStaticMeshActor*	StaticMeshActor = (AStaticMeshActor*) Level->SpawnActor(AStaticMeshActor::StaticClass(),NAME_None,Actor->Location,Actor->Rotation);
						StaticMeshActor->DrawScale = Actor->DrawScale;
						StaticMeshActor->StaticMesh = CreateStaticMeshFromActor(Level->GetOuter(),NAME_None,Actor);
						StaticMeshActor->PostEditChange();
					}
				}

				Trans->End();
				RedrawLevel(Level);
				Processed = 1;
			}
		}
		else if(ParseCommand(&Str,TEXT("TO")))
		{
			if(ParseCommand(&Str,TEXT("BRUSH")))
			{
				Trans->Begin(TEXT("STATICMESH TO BRUSH"));
				Brush->Modify();

				// Find the first selected static mesh actor.

				AActor*	SelectedActor = NULL;

				for(INT ActorIndex = 0;ActorIndex < Level->Actors.Num();ActorIndex++)
					if(Level->Actors(ActorIndex) && Level->Actors(ActorIndex)->bSelected && Level->Actors(ActorIndex)->StaticMesh != NULL)
					{
						SelectedActor = Level->Actors(ActorIndex);
						break;
					}

				if(SelectedActor)
				{
					Level->Brush()->Location = SelectedActor->Location;
					Level->Brush()->PrePivot = SelectedActor->PrePivot;

					CreateModelFromStaticMesh(Level->Brush()->Brush,SelectedActor);
				}
				else
					Ar.Logf(TEXT("No suitable actors found."));

				Trans->End();
				RedrawLevel(Level);
				Processed = 1;
			}
		}
		*/
	}
	else if( ParseCommand(&Str,TEXT("BRUSH")) )
	{
		if( ParseCommand(&Str,TEXT("APPLYTRANSFORM")) )
		{
			goto ApplyXf;
		}
		else if( ParseCommand(&Str,TEXT("SET")) )
		{
			Trans->Begin( TEXT("Brush Set") );
			Brush->Modify();
			FRotator Temp(0.0f,0.0f,0.0f);
			Constraints.Snap( NULL, Level->Brush()->Location, FVector(0,0,0), Temp );
			FModelCoords TempCoords;
			Level->Brush()->BuildCoords( &TempCoords, NULL );
			Level->Brush()->Location -= Level->Brush()->PrePivot.TransformVectorBy( TempCoords.PointXform );
			Level->Brush()->PrePivot = FVector(0.f,0.f,0.f);
			Brush->Polys->Element.Empty();
			UPolysFactory* It = new UPolysFactory;
			It->FactoryCreateText( UPolys::StaticClass(), Brush->Polys->GetOuter(), Brush->Polys->GetName(), 0, Brush->Polys, TEXT("t3d"), Stream, Stream+appStrlen(Stream), GWarn );
			// Do NOT merge faces.
			bspValidateBrush( Brush, 0, 1 );
			Brush->BuildBound();
			Trans->End();
			RedrawLevel( Level );
			NoteSelectionChange( Level );
			Processed = 1;
		}
		else if( ParseCommand(&Str,TEXT("MORE")) )
		{
			Trans->Continue();
			Brush->Modify();
			UPolysFactory* It = new UPolysFactory;
			It->FactoryCreateText( UPolys::StaticClass(), Brush->Polys->GetOuter(), Brush->Polys->GetName(), 0, Brush->Polys, TEXT("t3d"), Stream, Stream+appStrlen(Stream), GWarn );
			// Do NOT merge faces.
			bspValidateBrush( Level->Brush()->Brush, 0, 1 );
			Brush->BuildBound();
			Trans->End();	
			RedrawLevel( Level );
			Processed = 1;
		}
		else if( ParseCommand(&Str,TEXT("RESET")) )
		{
			Trans->Begin( TEXT("Brush Reset") );
			Level->Brush()->Modify();
			Level->Brush()->InitPosRotScale();
			Trans->End();
			RedrawLevel(Level);
			Processed = 1;
		}
		else if( ParseCommand(&Str,TEXT("SCALE")) )
		{
			Trans->Begin( TEXT("Brush Scale") );

			FVector Scale;
			GetFVECTOR( Str, Scale );
			if( !Scale.X ) Scale.X = 1;
			if( !Scale.Y ) Scale.Y = 1;
			if( !Scale.Z ) Scale.Z = 1;

			FVector InvScale( 1 / Scale.X, 1 / Scale.Y, 1 / Scale.Z );

			for( INT i=0; i<Level->Actors.Num(); i++ )
			{
				ABrush* Brush = Cast<ABrush>(Level->Actors(i));
				if( Brush && Brush->bSelected && Brush->IsBrush() )
				{
					Brush->Brush->Modify();
					for( INT poly = 0 ; poly < Brush->Brush->Polys->Element.Num() ; poly++ )
					{
						FPoly* Poly = &(Brush->Brush->Polys->Element(poly));
						Brush->Brush->Polys->Element.ModifyAllItems();

						Poly->TextureU *= InvScale;
						Poly->TextureV *= InvScale;
						Poly->Base = ((Poly->Base - Brush->PrePivot) * Scale) + Brush->PrePivot;

						for( INT vtx = 0 ; vtx < Poly->NumVertices ; vtx++ )
							Poly->Vertex[vtx] = ((Poly->Vertex[vtx] - Brush->PrePivot) * Scale) + Brush->PrePivot;

						Poly->CalcNormal();
					}

					Brush->Brush->BuildBound();
				}
			}
			
			Trans->End();
			RedrawLevel(Level);
			Processed = 1;
		}
		else if( ParseCommand(&Str,TEXT("MOVETO")) )
		{
			Trans->Begin( TEXT("Brush MoveTo") );
			Level->Brush()->Modify();
			GetFVECTOR( Str, Level->Brush()->Location );
			Trans->End();
			RedrawLevel(Level);
			Processed = 1;
		}
		else if( ParseCommand(&Str,TEXT("MOVEREL")) )
		{
			Trans->Begin( TEXT("Brush MoveRel") );
			Level->Brush()->Modify();
			FVector TempVector( 0, 0, 0 );
			GetFVECTOR( Str, TempVector );
			Level->Brush()->Location.AddBounded( TempVector, HALF_WORLD_MAX1 );
			Trans->End();
			RedrawLevel(Level);
			Processed = 1;
		}
		else if (ParseCommand(&Str,TEXT("ADD")))
		{
			Trans->Begin( TEXT("Brush Add") );
			FinishAllSnaps(Level);
			INT DWord1=0;
			Parse( Str, TEXT("FLAGS="), DWord1 );
			Level->Modify();
			ABrush* NewBrush = csgAddOperation( Level->Brush(), Level, DWord1, CSG_Add );
			if( NewBrush )
				bspBrushCSG( NewBrush, Level->Model, DWord1, CSG_Add, 1 );
			Trans->End();
			RedrawLevel(Level);
			EdCallback(EDC_MapChange,0);
			Processed = 1;
		}
		else if (ParseCommand(&Str,TEXT("ADDMOVER"))) // BRUSH ADDMOVER
		{
			Trans->Begin( TEXT("Brush AddMover") );
			Level->Modify();
			FinishAllSnaps( Level );

			UClass* MoverClass = NULL;
			ParseObject<UClass>( Str, TEXT("CLASS="), MoverClass, ANY_PACKAGE );
			if( !MoverClass || !MoverClass->IsChildOf(AMover::StaticClass()) )
				MoverClass = AMover::StaticClass();

			Level->Modify();
			AMover* Actor = (AMover*)Level->SpawnActor(MoverClass,NAME_None,NULL,NULL,Level->Brush()->Location);
			if( Actor )
			{
				csgCopyBrush( Actor, Level->Brush(), 0, 0, 1 );
				Actor->PostEditChange();
			}
			Trans->End();
			RedrawLevel(Level);
			Processed = 1;
		}
		else if (ParseCommand(&Str,TEXT("SUBTRACT"))) // BRUSH SUBTRACT
			{
			Trans->Begin( TEXT("Brush Subtract") );
			FinishAllSnaps(Level);
			Level->Modify();
			ABrush* NewBrush = csgAddOperation(Level->Brush(),Level,0,CSG_Subtract); // Layer
			if( NewBrush )
				bspBrushCSG( NewBrush, Level->Model, 0, CSG_Subtract, 1 );
			Trans->End();
			RedrawLevel(Level);
			EdCallback(EDC_MapChange,0);
			Processed = 1;
			}
		else if (ParseCommand(&Str,TEXT("FROM"))) // BRUSH FROM ACTOR/INTERSECTION/DEINTERSECTION
		{
			if( ParseCommand(&Str,TEXT("INTERSECTION")) )
			{
				Ar.Log( TEXT("Brush from intersection") );
				Trans->Begin( TEXT("Brush From Intersection") );
				Brush->Modify();
				FinishAllSnaps( Level );
				bspBrushCSG( Level->Brush(), Level->Model, 0, CSG_Intersect, 0 );
				Trans->End();
				RedrawLevel( Level );
				Processed = 1;
			}
			else if( ParseCommand(&Str,TEXT("DEINTERSECTION")) )
			{
				Ar.Log( TEXT("Brush from deintersection") );
				Trans->Begin( TEXT("Brush From Deintersection") );
				Brush->Modify();
				FinishAllSnaps( Level );
				bspBrushCSG( Level->Brush(), Level->Model, 0, CSG_Deintersect, 0 );
				Trans->End();
				RedrawLevel( Level );
				Processed = 1;
			}
		}
		else if( ParseCommand (&Str,TEXT("NEW")) )
		{
			Trans->Begin( TEXT("Brush New") );
			Brush->Modify();
			Brush->Polys->Element.Empty();
			Trans->End();
			RedrawLevel( Level );
			Processed = 1;
		}
		else if( ParseCommand (&Str,TEXT("LOAD")) ) // BRUSH LOAD
		{
			if( Parse( Str, TEXT("FILE="), TempFname, 79 ) )
			{
				Trans->Reset( TEXT("loading brush") );
				FVector TempVector = Level->Brush()->Location;
				LoadPackage( Level->GetOuter(), TempFname, 0 );
				Level->Brush()->Location = TempVector;
				bspValidateBrush( Level->Brush()->Brush, 0, 1 );
				Cleanse( 1, TEXT("loading brush") );
				Processed = 1;
			}
		}
		else if( ParseCommand( &Str, TEXT("SAVE") ) )
		{
			if( Parse(Str,TEXT("FILE="),TempFname,79) )
			{
				Ar.Logf( TEXT("Saving %s"), TempFname );
				SavePackage( Level->GetOuter(), Brush, 0, TempFname, GWarn );
			}
			else Ar.Log( NAME_ExecWarning, TEXT("Missing filename") );
			Processed = 1;
		}
		else if( ParseCommand( &Str, TEXT("IMPORT")) )
		{
			if( Parse(Str,TEXT("FILE="),TempFname,79) )
			{
				GWarn->BeginSlowTask( TEXT("Importing brush"), 1, 0 );
				Trans->Begin( TEXT("Brush Import") );
				Brush->Polys->Modify();
				Brush->Polys->Element.Empty();
				DWORD Flags=0;
				UBOOL Merge=0;
				ParseUBOOL( Str, TEXT("MERGE="), Merge );
				Parse( Str, TEXT("FLAGS="), Flags );
				Brush->Linked = 0;
				ImportObject<UPolys>( Brush->Polys->GetOuter(), Brush->Polys->GetName(), 0, TempFname );
				if( Flags )
					for( Word2=0; Word2<TempModel->Polys->Element.Num(); Word2++ )
						Brush->Polys->Element(Word2).PolyFlags |= Flags;
				for( INT i=0; i<Brush->Polys->Element.Num(); i++ )
					Brush->Polys->Element(i).iLink = i;
				if( Merge )
				{
					bspMergeCoplanars( Brush, 0, 1 );
					bspValidateBrush( Brush, 0, 1 );
				}
				Trans->End();
				GWarn->EndSlowTask();
			}
			else Ar.Log( NAME_ExecWarning, TEXT("Missing filename") );
			Processed=1;
		}
		else if (ParseCommand(&Str,TEXT("EXPORT")))
		{
			if( Parse(Str,TEXT("FILE="),TempFname,79) )
			{
				GWarn->BeginSlowTask( TEXT("Exporting brush"), 1, 0 );
				UExporter::ExportToFile( Brush->Polys, NULL, TempFname );
				GWarn->EndSlowTask();
			}
			else Ar.Log(NAME_ExecWarning,TEXT("Missing filename"));
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("MERGEPOLYS")) ) // BRUSH MERGEPOLYS
		{
			// Merges the polys on all selected brushes
			GWarn->BeginSlowTask( TEXT(""), 1, 0 );
			for( INT i=0; i<Level->Actors.Num(); i++ )
			{
				GWarn->StatusUpdatef( i, Level->Actors.Num(), TEXT("Merging polys on selected brushes") );
				AActor* Actor = Level->Actors(i);
				if( Actor && Actor->bSelected && Actor->IsBrush() )
					bspValidateBrush( Actor->Brush, 1, 1 );
			}
			RedrawLevel( Level );
			GWarn->EndSlowTask();
		}
		else if( ParseCommand(&Str,TEXT("SEPARATEPOLYS")) ) // BRUSH SEPARATEPOLYS
		{
			GWarn->BeginSlowTask( TEXT(""), 1, 0 );
			for( INT i=0; i<Level->Actors.Num(); i++ )
			{
				GWarn->StatusUpdatef( i, Level->Actors.Num(), TEXT("Separating polys on selected brushes") );
				AActor* Actor = Level->Actors(i);
				if( Actor && Actor->bSelected && Actor->IsBrush() )
					bspUnlinkPolys( Actor->Brush );
			}
			RedrawLevel( Level );
			GWarn->EndSlowTask();
		}
	}
	//----------------------------------------------------------------------------------
	// EDIT
	//
	else if( ParseCommand(&Str,TEXT("EDIT")) )
	{
		if( ParseCommand(&Str,TEXT("CUT")) )
		{
			Trans->Begin( TEXT("Cut") );
			edactCopySelected( Level );
			edactDeleteSelected( Level );
			Trans->End();
			RedrawLevel( Level );
		}
		else if( ParseCommand(&Str,TEXT("COPY")) )
		{
			edactCopySelected( Level );
		}
		else if( ParseCommand(&Str,TEXT("PASTE")) )
		{
			Trans->Begin( TEXT("Cut") );
			SelectNone( Level, 1 );
			edactPasteSelected( Level );
			Trans->End();
			RedrawLevel( Level );
		}
	}
	//----------------------------------------------------------------------------------
	// PIVOT
	//
	else if( ParseCommand(&Str,TEXT("PIVOT")) )
	{
		if( ParseCommand(&Str,TEXT("HERE")) )
		{
			NoteActorMovement( Level );
			SetPivot( ClickLocation, 0, 0 );
			FinishAllSnaps( Level );
			RedrawLevel( Level );
		}
		else if( ParseCommand(&Str,TEXT("SNAPPED")) )
		{
			NoteActorMovement( Level );
			SetPivot( ClickLocation, 1, 0 );
			FinishAllSnaps( Level );
			RedrawLevel( Level );
		}
	}
	//----------------------------------------------------------------------------------
	// PATHS
	//
	else if( ParseCommand(&Str,TEXT("PATHS")) )
	{
		if (ParseCommand(&Str,TEXT("BUILD")))
		{
			INT opt = 1; //assume medium
			if (ParseCommand(&Str,TEXT("LOWOPT")))
				opt = 0;
			else if (ParseCommand(&Str,TEXT("HIGHOPT")))
				opt = 2;
			FPathBuilder builder;
			Trans->Reset( TEXT("Paths") );
			Level->Modify();
			INT numpaths = builder.removePaths( Level );
			numpaths = builder.buildPaths( Level, opt );
			RedrawLevel( Level );
			Ar.Logf( TEXT("Built Paths: %d"), numpaths );
			Processed=1;
		}
		else if (ParseCommand(&Str,TEXT("SHOW")))
		{
			FPathBuilder builder;
			Trans->Reset( TEXT("Paths") );
			INT numpaths = builder.showPaths(Level);
			RedrawLevel(Level);
			Ar.Logf( TEXT(" %d Paths are visible!"), numpaths );
			Processed=1;
		}
		else if (ParseCommand(&Str,TEXT("HIDE")))
		{
			FPathBuilder builder;
			Trans->Reset( TEXT("Paths") );
			INT numpaths = builder.hidePaths(Level);
			RedrawLevel(Level);
			Ar.Logf( TEXT(" %d Paths are hidden!"), numpaths);
			Processed=1;
		}
		else if (ParseCommand(&Str,TEXT("REMOVE")))
		{
			FPathBuilder builder;
			Trans->Reset( TEXT("Paths") );
			INT numpaths = builder.removePaths( Level );
			RedrawLevel( Level );
			Ar.Logf( TEXT("Removed %d Paths"), numpaths );
			Processed=1;
		}
		else if (ParseCommand(&Str,TEXT("UNDEFINE")))
		{
			FPathBuilder builder;
			Trans->Reset( TEXT("Paths") );
			builder.undefinePaths( Level );
			RedrawLevel(Level);
			Processed=1;
		}
		else if (ParseCommand(&Str,TEXT("DEFINE")))
		{
			FPathBuilder builder;
			Trans->Reset( TEXT("Paths") );
			GWarn->BeginSlowTask( TEXT("AI Paths"), 1, 0 );
			builder.undefinePaths( Level );
			builder.definePaths( Level );
			GWarn->EndSlowTask();
			RedrawLevel(Level);
			Processed=1;
		}
	}
	//------------------------------------------------------------------------------------
	// Bsp
	//
	else if( ParseCommand( &Str, TEXT("BSP") ) )
	{
		if( ParseCommand( &Str, TEXT("REBUILD")) ) // Bsp REBUILD [LAME/GOOD/OPTIMAL] [BALANCE=0-100] [LIGHTS] [MAPS] [REJECT]
		{
			Trans->Reset( TEXT("rebuilding Bsp") ); // Not tracked transactionally
			Ar.Log(TEXT("Bsp Rebuild"));
			EBspOptimization BspOpt;

			if      (ParseCommand(&Str,TEXT("LAME"))) 		BspOpt=BSP_Lame;
			else if (ParseCommand(&Str,TEXT("GOOD")))		BspOpt=BSP_Good;
			else if (ParseCommand(&Str,TEXT("OPTIMAL")))	BspOpt=BSP_Optimal;
			else											BspOpt=BSP_Good;

			if( !Parse( Str, TEXT("BALANCE="), Word2 ) )
				Word2=50;

#if 1 //PortalBias -- added by Legend on 4/12/2000
			INT PortalBias;
			if( !Parse( Str, TEXT("PORTALBIAS="), PortalBias ) )
				PortalBias=70;
			Word2 |= ( PortalBias << 8 );
#endif

			GWarn->BeginSlowTask( TEXT("Rebuilding Bsp"), 1, 0 );
//			Level->UpdateTerrainArrays();

			GWarn->StatusUpdatef( 0, 0, TEXT("%s"), TEXT("Building polygons") );
			bspBuildFPolys( Level->Model, 1, 0 );

			GWarn->StatusUpdatef( 0, 0, TEXT("%s"), TEXT("Merging planars") );
			bspMergeCoplanars( Level->Model, 0, 0 );

			GWarn->StatusUpdatef( 0, 0, TEXT("%s"), TEXT("Partitioning") );
			bspBuild( Level->Model, BspOpt, Word2, 0, 0 );

			if( Parse( Str, TEXT("ZONES"), TempStr, 1 ) )
			{
				GWarn->StatusUpdatef( 0, 0, TEXT("%s"), TEXT("Building visibility zones") );
				TestVisibility( Level, Level->Model, 0, 0 );
			}
			if( Parse( Str, TEXT("OPTGEOM"), TempStr, 1 ) )
			{
				GWarn->StatusUpdatef( 0, 0, TEXT("%s"), TEXT("Optimizing geometry") );
				bspOptGeom( Level->Model );
			}

			// Empty EdPolys.
			Level->Model->Polys->Element.Empty();

			GWarn->EndSlowTask();
			GCache.Flush();
			RedrawLevel(Level);
			EdCallback( EDC_MapChange, 0 );

			Processed=1;
		}
	}
	//------------------------------------------------------------------------------------
	// LIGHT
	//
	else if( ParseCommand( &Str, TEXT("LIGHT") ) )
	{
		if( ParseCommand( &Str, TEXT("APPLY") ) )
		{
			UBOOL Selected=0;
			ParseUBOOL( Str, TEXT("SELECTED="), Selected );
			shadowIlluminateBsp( Level, Selected );
			//GCache.Flush();
			Client->Flush(0);
			RedrawLevel( Level );
			Processed=1;
		}
	}
#if 1 // toggle showing inventory spots
	//------------------------------------------------------------------------------------
	// DEBUGGING
	//
	else if (ParseCommand(&Str,TEXT("SHOWINV")))
	{
		for (INT i=0; i<Level->Actors.Num(); i++)
		{
			AActor *Actor = Level->Actors(i); 
			if ( Actor && Actor->IsA(AInventorySpot::StaticClass()) )
			{
				Actor->bHiddenEd = !Actor->bHiddenEd;
			}
		}

		RedrawLevel( Level );
	}
#endif
	//------------------------------------------------------------------------------------
	// MAP
	//
	else if (ParseCommand(&Str,TEXT("MAP")))
		{
		//
		// Commands:
		//
		if (ParseCommand(&Str,TEXT("GRID"))) // MAP GRID [SHOW3D=ON/OFF] [SHOW2D=ON/OFF] [X=..] [Y=..] [Z=..]
			{
			//
			// Before changing grid, force editor to current grid position to avoid jerking:
			//
			FinishAllSnaps (Level);
			GetFVECTOR( Str, Constraints.GridSize );
			RedrawLevel(Level);
			Processed=1;
			}
		else if (ParseCommand(&Str,TEXT("ROTGRID"))) // MAP ROTGRID [PITCH=..] [YAW=..] [ROLL=..]
			{
			FinishAllSnaps (Level);
			if( GetFROTATOR( Str, Constraints.RotGridSize, 256 ) )
				RedrawLevel(Level);
			Processed=1;
			}
		else if (ParseCommand(&Str,TEXT("SELECT")))
		{
			Trans->Begin( TEXT("Select") );
			if( ParseCommand(&Str,TEXT("ADDS")) )
				mapSelectOperation( Level, CSG_Add );
			else if( ParseCommand(&Str,TEXT("SUBTRACTS")) )
				mapSelectOperation( Level, CSG_Subtract );
			else if( ParseCommand(&Str,TEXT("SEMISOLIDS")) )
				mapSelectFlags( Level, PF_Semisolid );
			else if( ParseCommand(&Str,TEXT("NONSOLIDS")) )
				mapSelectFlags( Level, PF_NotSolid );
			else if( ParseCommand(&Str,TEXT("FIRST")) )
				mapSelectFirst( Level );
			else if( ParseCommand(&Str,TEXT("LAST")) )
				mapSelectLast( Level );
			Trans->End ();
			RedrawLevel( Level );
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("DELETE")) )
		{
			Exec( TEXT("ACTOR DELETE"), Ar );
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("BRUSH")) )
		{
			if( ParseCommand (&Str,TEXT("GET")) )
			{
				Trans->Begin( TEXT("Brush Get") );
				mapBrushGet( Level );
				Trans->End();
				RedrawLevel( Level );
				Processed=1;
			}
			else if( ParseCommand (&Str,TEXT("PUT")) )
			{
				Trans->Begin( TEXT("Brush Put") );
				mapBrushPut( Level );
				Trans->End();
				RedrawLevel( Level );
				Processed=1;
			}
		}
		else if (ParseCommand(&Str,TEXT("SENDTO")))
		{
			if( ParseCommand(&Str,TEXT("FIRST")) )
			{
				Trans->Begin( TEXT("Map SendTo Front") );
				mapSendToFirst( Level );
				Trans->End();
				RedrawLevel( Level );
				Processed=1;
			}
			else if( ParseCommand(&Str,TEXT("LAST")) )
			{
				Trans->Begin( TEXT("Map SendTo Back") );
				mapSendToLast( Level );
				Trans->End();
				RedrawLevel( Level );
				Processed=1;
			}
			else if( ParseCommand(&Str,TEXT("SWAP")) )
			{
				Trans->Begin( TEXT("Map SendTo Swap") );
				mapSendToSwap( Level );
				Trans->End();
				RedrawLevel( Level );
				Processed=1;
			}
		}
		else if( ParseCommand(&Str,TEXT("REBUILD")) )
		{
			Trans->Reset( TEXT("rebuilding map") );
			GWarn->BeginSlowTask( TEXT("Rebuilding geometry"), 1, 0 );
//			Level->GetLevelInfo()->bPathsRebuilt = 0;

			UBOOL VisibleOnly=0;
			ParseUBOOL( Str, TEXT("VISIBLEONLY="), VisibleOnly );
			csgRebuild( Level, VisibleOnly );

			GWarn->StatusUpdatef( 0, 0, TEXT("%s"), TEXT("Cleaning up...") );

			GCache.Flush();
			RedrawLevel( Level );
			EdCallback( EDC_MapChange, 0 );
			Processed=1;

			GWarn->EndSlowTask();
		}
		else if( ParseCommand (&Str,TEXT("NEW")) )
		{
			Trans->Reset( TEXT("clearing map") );
			Level->RememberActors();
			Level = new( Level->GetOuter(), TEXT("MyLevel") )ULevel( this, 0 );
			Level->ReconcileActors();
			ResetSound();
			RedrawLevel(Level);
			NoteSelectionChange( Level );
			EdCallback(EDC_MapChange,0);
			Cleanse( 1, TEXT("starting new map") );
			Processed=1;
		}
		else if( ParseCommand( &Str, TEXT("LOAD") ) )
		{
			if( Parse( Str, TEXT("FILE="), TempFname, 79 ) )
			{
				Trans->Reset( TEXT("loading map") );
				GWarn->BeginSlowTask( TEXT("Loading map"), 1, 0 );
				Level->RememberActors();
				ResetLoaders( Level->GetOuter(), 0, 0 );
				LoadPackage( Level->GetOuter(), TempFname, 0 );
				Level->Engine = this;
				Level->ReconcileActors();
				ResetSound();
				bspValidateBrush( Level->Brush()->Brush, 0, 1 );
				GWarn->EndSlowTask();
				RedrawLevel(Level);
				EdCallback( EDC_MapChange, 0 );
				NoteSelectionChange( Level );
				Level->SetFlags( RF_Transactional );
				Level->Model->SetFlags( RF_Transactional );
				if( Level->Model->Polys ) Level->Model->Polys->SetFlags( RF_Transactional );
				for( TObjectIterator<AActor> It; It; ++It )
				{
					for( INT i=0; i<Level->Actors.Num(); i++ )
						if( *It==Level->Actors(i) )
							break;
					if( i==Level->Actors.Num() )
					{
						It->bDeleteMe=1;
					}
					else
					{
						It->bDeleteMe=0;
						if( Cast<ACamera>(*It) )
							It->ClearFlags( RF_Transactional );
						else
							It->SetFlags( RF_Transactional );
					}				
				}

				// NJS: Replace obsolete actors without a mesh with the obsolete texture.
				for(INT i=0;i<Level->Actors.Num();i++)
					if(Level->Actors(i))
						if(Level->Actors(i)->GetClass()->ClassFlags&CLASS_Obsolete)
						{

							if((Level->Actors(i)->DrawType==DT_Mesh)&&(!(Level->Actors(i)->Mesh)))
							{
								Level->Actors(i)->DrawType=DT_Sprite;
								Level->Actors(i)->Texture=(UTexture *)StaticLoadObject( UTexture::StaticClass(), NULL, TEXT("engine.S_Obsolete"), NULL, LOAD_NoWarn | (LOAD_Quiet), NULL );
								Level->Actors(i)->bHidden=false;
								Level->Actors(i)->bHiddenEd=false;
								Level->Actors(i)->DrawScale=3.f;
							}
						}

				GCache.Flush();
				Cleanse( 0, TEXT("loading map") );
			}
			else Ar.Log( NAME_ExecWarning, TEXT("Missing filename") );
			Processed=1;
		}
		else if( ParseCommand (&Str,TEXT("SAVE")) )
		{
			if( Parse(Str,TEXT("FILE="),TempFname,79) )
			{
				INT Autosaving = 0;  // Are we autosaving?
				Parse(Str,TEXT("AUTOSAVE="),Autosaving);
				Level->ShrinkLevel();
				Level->CleanupDestroyed( 1 );
				ALevelInfo* OldInfo = FindObject<ALevelInfo>(Level->GetOuter(),TEXT("LevelInfo0"));
				if( OldInfo && OldInfo!=Level->GetLevelInfo() )
					OldInfo->Rename();
				if( Level->GetLevelInfo()!=OldInfo )
					Level->GetLevelInfo()->Rename(TEXT("LevelInfo0"));
				ULevelSummary* Summary = Level->GetLevelInfo()->Summary = new(Level->GetOuter(),TEXT("LevelSummary"),RF_Public)ULevelSummary;
				Summary->Title					= Level->GetLevelInfo()->Title;
				Summary->Author					= Level->GetLevelInfo()->Author;
				Summary->IdealPlayerCount		= Level->GetLevelInfo()->IdealPlayerCount;
				Summary->LevelEnterText			= Level->GetLevelInfo()->LevelEnterText;
				if( !Autosaving )	GWarn->BeginSlowTask( TEXT("Saving map"), 1, 0 );
				SavePackage( Level->GetOuter(), Level, 0, TempFname, GWarn );
				if( !Autosaving )	GWarn->EndSlowTask();
			}
			else Ar.Log( NAME_ExecWarning, TEXT("Missing filename") );
			Processed=1;
		}
		else if( ParseCommand( &Str, TEXT("IMPORT") ) )
		{
			Word1=1;
			DoImportMap:
			if( Parse( Str, TEXT("FILE="), TempFname, 79 ) )
			{
				Trans->Reset( TEXT("importing map") );
				GWarn->BeginSlowTask( TEXT("Importing map"), 1, 0 );
				Level->RememberActors();
				if( Word1 )
					Level = new( Level->GetOuter(), TEXT("MyLevel") )ULevel( this, 0 );
				ImportObject<ULevel>( Level->GetOuter(), Level->GetFName(), RF_Transactional, TempFname );
				GCache.Flush();
				Level->ReconcileActors();
				ResetSound();
				if( Word1 )
					SelectNone( Level, 0 );
				GWarn->EndSlowTask();
				RedrawLevel(Level);
				EdCallback( EDC_MapChange, 0 );
				NoteSelectionChange( Level );
				Cleanse( 1, TEXT("importing map") );
			}
			else Ar.Log(NAME_ExecWarning,TEXT("Missing filename"));
			Processed=1;
		}
		else if( ParseCommand( &Str, TEXT("IMPORTADD") ) )
		{
			Word1=0;
			SelectNone( Level, 0 );
			goto DoImportMap;
		}
		else if (ParseCommand (&Str,TEXT("EXPORT")))
			{
			if (Parse(Str,TEXT("FILE="),TempFname,79))
				{
				GWarn->BeginSlowTask( TEXT("Exporting map"), 1, 0 );
				for( FObjectIterator It; It; ++It )
					It->ClearFlags( RF_TagImp | RF_TagExp );
				UExporter::ExportToFile( Level, NULL, TempFname );
				GWarn->EndSlowTask();
				}
			else Ar.Log(NAME_ExecWarning,TEXT("Missing filename"));
			Processed=1;
			}
		else if (ParseCommand (&Str,TEXT("SETBRUSH"))) // MAP SETBRUSH (set properties of all selected brushes)
			{
			Trans->Begin( TEXT("Set Brush Properties") );
			//
			Word1  = 0;  // Properties mask
			INT DWord1 = 0;  // Set flags
			INT DWord2 = 0;  // Clear flags
			INT CSGOper = 0;  // CSG Operation
			INT DrawType = 0;  // Draw type
			//
			FName GroupName=NAME_None;
			if (Parse(Str,TEXT("CSGOPER="),CSGOper))		Word1 |= MSB_CSGOper;
			if (Parse(Str,TEXT("COLOR="),Word2))			Word1 |= MSB_BrushColor;
			if (Parse(Str,TEXT("GROUP="),GroupName))		Word1 |= MSB_Group;
			if (Parse(Str,TEXT("SETFLAGS="),DWord1))		Word1 |= MSB_PolyFlags;
			if (Parse(Str,TEXT("CLEARFLAGS="),DWord2))		Word1 |= MSB_PolyFlags;
			if (Parse(Str,TEXT("DRAWTYPE="),DrawType))		Word1 |= MSB_DrawType;
			//
			mapSetBrush(Level,(EMapSetBrushFlags)Word1,Word2,GroupName,DWord1,DWord2,CSGOper,DrawType);
			//
			Trans->End			();
			RedrawLevel(Level);
			//
			Processed=1;
			}
		else if (ParseCommand (&Str,TEXT("SAVEPOLYS")))
			{
			if (Parse(Str,TEXT("FILE="),TempFname,79))
				{
				UBOOL DWord2=1;
				ParseUBOOL(Str, TEXT("MERGE="), DWord2 );
				//
				GWarn->BeginSlowTask( TEXT("Exporting map polys"), 1, 0 );
				GWarn->StatusUpdatef( 0, 0, TEXT("%s"), TEXT("Building polygons") );
				bspBuildFPolys( Level->Model, 0, 0 );
				//
				if (DWord2)
					{
					GWarn->StatusUpdatef( 0, 0, TEXT("%s"), TEXT("Merging planars") );
					bspMergeCoplanars	(Level->Model,0,1);
					};
				UExporter::ExportToFile( Level->Model->Polys, NULL, TempFname );
				Level->Model->Polys->Element.Empty();
				//
				GWarn->EndSlowTask 	();
				RedrawLevel(Level);
				}
			else Ar.Log( NAME_ExecWarning, TEXT("Missing filename") );
			Processed=1;
			}
		else if (ParseCommand (&Str,TEXT("CHECK")))
			{
				// Checks the map for common errors

				GWarn->MapErrors_Show();
				GWarn->MapErrors_Clear();

				GWarn->BeginSlowTask( TEXT("Checking map"), 1, 0 );
				for( INT i=0; i<GEditor->Level->Actors.Num(); i++ )
				{
					GWarn->StatusUpdatef( 0, i, TEXT("Checking map") );
					AActor* pActor = GEditor->Level->Actors(i);
					if( pActor )
					{
						if( pActor->IsA( ALight::StaticClass() ) )
						{
							ALight* Light = Cast<ALight>(pActor);

							if( Light->LightRadius > 128 )
								GWarn->MapErrors_Add( 0, pActor, *(FString::Printf(TEXT("Radius is very large (%d)."), Light->LightRadius ) ) );
						}
					}
				}
				GWarn->EndSlowTask();

				Processed=1;
			};
		}
	//------------------------------------------------------------------------------------
	// SELECT: Rerouted to mode-specific command
	//
	else if( ParseCommand(&Str,TEXT("SELECT")) )
	{
		if( ParseCommand(&Str,TEXT("NONE")) )
		{
			Trans->Begin( TEXT("Select None") );
			SelectNone( Level, 1 );
			Trans->End();
			RedrawLevel( Level );
			Processed=1;
		}
		Processed=1;
	}
	//------------------------------------------------------------------------------------
	// DELETE: Rerouted to mode-specific command
	//
	else if (ParseCommand(&Str,TEXT("DELETE")))
	{
		return Exec( TEXT("ACTOR DELETE") );
	}
	//------------------------------------------------------------------------------------
	// DUPLICATE: Rerouted to mode-specific command
	//
	else if (ParseCommand(&Str,TEXT("DUPLICATE")))
	{
		return Exec( TEXT("ACTOR DUPLICATE") );
	}
	//------------------------------------------------------------------------------------
	// ACTOR: Actor-related functions
	//
	else if (ParseCommand(&Str,TEXT("ACTOR")))
	{
		if( ParseCommand(&Str,TEXT("ADD")) )
		{
			UClass* Class;
			if( ParseObject<UClass>( Str, TEXT("CLASS="), Class, ANY_PACKAGE ) )
			{
				AActor* Default   = Class->GetDefaultActor();
				
				FVector Collision = FVector(Default->CollisionRadius,Default->CollisionRadius,Default->CollisionHeight);
				INT bSnap;
				Parse(Str,TEXT("SNAP="),bSnap);
				bSnap=false;
				if( bSnap )		Constraints.Snap( ClickLocation, FVector(0, 0, 0) );
				FVector Location  = ClickLocation + ClickPlane * (FBoxPushOut(ClickPlane,Collision) + 0.1);
				if( bSnap )		Constraints.Snap( Location, FVector(0, 0, 0) );
				AActor* Actor = AddActor( Level, Class, Location );
				UTexture* Texture;
				if( ParseObject<UTexture>( Str, TEXT("TEXTURE="), Texture, ANY_PACKAGE ) )
					Actor->Texture = Texture;
				RedrawLevel(Level);
				Processed = 1;
			}
		}
		else if( ParseCommand(&Str,TEXT("MIRROR")) )
		{
			Trans->Begin( TEXT("Mirroring Actors") );

			FVector V( 1, 1, 1 );
			GetFVECTOR( Str, V );

			for( INT i=0; i<Level->Actors.Num(); i++ )
			{
				ABrush* Brush = Cast<ABrush>(Level->Actors(i));
				if( Brush && Brush->bSelected && Brush->IsBrush() )
				{
					Brush->Brush->Modify();
					for( INT poly = 0 ; poly < Brush->Brush->Polys->Element.Num() ; poly++ )
					{
						FPoly* Poly = &(Brush->Brush->Polys->Element(poly));
						Brush->Brush->Polys->Element.ModifyAllItems();

						Poly->TextureU *= V;
						Poly->TextureV *= V;
						Poly->Base = ((Poly->Base - Brush->PrePivot) * V) + Brush->PrePivot;

						for( INT vtx = 0 ; vtx < Poly->NumVertices ; vtx++ )
							Poly->Vertex[vtx] = ((Poly->Vertex[vtx] - Brush->PrePivot) * V) + Brush->PrePivot;

						Poly->Reverse();
						Poly->CalcNormal();
					}

					Brush->Brush->BuildBound();
				}
			}

			Trans->End();
			RedrawLevel(Level);
			Processed = 1;
		}
		else if( ParseCommand(&Str,TEXT("HIDE")) )
		{
			if( ParseCommand(&Str,TEXT("SELECTED")) ) // ACTOR HIDE SELECTED
			{
				Trans->Begin( TEXT("Hide Selected") );
				Level->Modify();
				edactHideSelected( Level );
				Trans->End();
				RedrawLevel( Level );
				SelectNone( Level, 0 );
				NoteSelectionChange( Level );
				Processed=1;
			}
			else if( ParseCommand(&Str,TEXT("UNSELECTED")) ) // ACTOR HIDE UNSELECTEED
			{
				Trans->Begin( TEXT("Hide Unselected") );
				Level->Modify();
				edactHideUnselected( Level );
				Trans->End();
				RedrawLevel( Level );
				SelectNone( Level, 0 );
				NoteSelectionChange( Level );
				Processed=1;
			}
		}
		else if( ParseCommand(&Str,TEXT("UNHIDE")) ) // ACTOR UNHIDE ALL
		{
			// "ACTOR UNHIDE ALL" = "Drawing Region: Off": also disables the far (Z) clipping plane
			ResetZClipping();
			Trans->Begin( TEXT("UnHide All") );
			Level->Modify();
			edactUnHideAll( Level );
			Trans->End();
			RedrawLevel( Level );
			NoteSelectionChange( Level );
			Processed=1;
		}
		else if( ParseCommand(&Str, TEXT("APPLYTRANSFORM")) )
		{
		ApplyXf:
			Trans->Begin( TEXT("Apply brush transform") );
			Level->Modify();
			edactApplyTransform( Level );
			Trans->End();
			RedrawLevel( Level );
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("CLIP")) ) // ACTOR CLIP Z/XY/XYZ
		{
			if( ParseCommand(&Str,TEXT("Z")) )
			{
				SetZClipping();
				RedrawLevel( Level );
				Processed=1;
			}
		}
		else if( ParseCommand(&Str, TEXT("REPLACE")) )
		{
			UClass* Class;
			if( ParseCommand(&Str, TEXT("BRUSH")) ) // ACTOR REPLACE BRUSH
			{
				Trans->Begin( TEXT("Replace selected brush actors") );
				Level->Modify();
				edactReplaceSelectedBrush( Level );
				Trans->End();
				RedrawLevel( Level );
				NoteSelectionChange( Level );
				Processed=1;
			}
			else if( ParseObject<UClass>( Str, TEXT("CLASS="), Class, ANY_PACKAGE ) ) // ACTOR REPLACE CLASS=<class>
			{
				Trans->Begin( TEXT("Replace selected non-brush actors") );
				Level->Modify();
				edactReplaceSelectedWithClass( Level, Class );
				Trans->End();
				RedrawLevel( Level );
				NoteSelectionChange( Level );
				Processed=1;
			}
		}
		else if( ParseCommand(&Str,TEXT("SELECT")) )
		{
			if( ParseCommand(&Str,TEXT("NONE")) ) // ACTOR SELECT NONE
			{
				return Exec( TEXT("SELECT NONE") );
			}
			else if( ParseCommand(&Str,TEXT("ALL")) ) // ACTOR SELECT ALL
			{
				Trans->Begin( TEXT("Select All") );
				Level->Modify();
				edactSelectAll( Level );
				Trans->End();
				RedrawLevel( Level );
				NoteSelectionChange( Level );
				Processed=1;
			}
			else if( ParseCommand(&Str,TEXT("INSIDE") ) ) // ACTOR SELECT INSIDE
			{
				Trans->Begin( TEXT("Select Inside") );
				Level->Modify();
				edactSelectInside( Level );
				Trans->End();
				RedrawLevel( Level );
				NoteSelectionChange( Level );
				Processed=1;
			}
			else if( ParseCommand(&Str,TEXT("INVERT") ) ) // ACTOR SELECT INVERT
			{
				Trans->Begin( TEXT("Select Invert") );
				Level->Modify();
				edactSelectInvert( Level );
				Trans->End();
				RedrawLevel( Level );
				NoteSelectionChange( Level );
				Processed=1;
			}
			else if( ParseCommand(&Str,TEXT("OFCLASS")) ) // ACTOR SELECT OFCLASS CLASS=<class>
			{
				UClass* Class;
				if( ParseObject<UClass>(Str,TEXT("CLASS="),Class,ANY_PACKAGE) )
				{
					Trans->Begin( TEXT("Select of class") );
					Level->Modify();
					edactSelectOfClass( Level, Class );
					Trans->End();
					RedrawLevel( Level );
					NoteSelectionChange( Level );
				}
				else Ar.Log( NAME_ExecWarning, TEXT("Missing class") );
				Processed=1;
			}
			else if( ParseCommand(&Str,TEXT("OFSUBCLASS")) ) // ACTOR SELECT OFSUBCLASS CLASS=<class>
			{
				UClass* Class;
				if( ParseObject<UClass>(Str,TEXT("CLASS="),Class,ANY_PACKAGE) )
				{
					Trans->Begin( TEXT("Select subclass of class") );
					Level->Modify();
					edactSelectSubclassOf( Level, Class );
					Trans->End();
					RedrawLevel( Level );
					NoteSelectionChange( Level );
				}
				else Ar.Log( NAME_ExecWarning, TEXT("Missing class") );
				Processed=1;
			}
			else if( ParseCommand(&Str,TEXT("DELETED")) ) // ACTOR SELECT DELETED
			{
				Trans->Begin( TEXT("Select deleted") );
				Level->Modify();
				edactSelectDeleted( Level );
				Trans->End();
				RedrawLevel( Level );
				NoteSelectionChange( Level );
				Processed=1;
			}
		}
		else if( ParseCommand(&Str,TEXT("DELETE")) )
		{
			Trans->Begin( TEXT("Delete Actors") );
			Level->Modify();
			edactDeleteSelected( Level );
			Trans->End();
			RedrawLevel( Level );
			NoteSelectionChange( Level );
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("RESET")) )
		{
			Trans->Begin( TEXT("Reset Actors") );
			Level->Modify();
			UBOOL Location=0;
			UBOOL Pivot=0;
			UBOOL Rotation=0;
			UBOOL Scale=0;
			if( ParseCommand(&Str,TEXT("LOCATION")) )
			{
				Location=1;
				ResetPivot();
			}
			else if( ParseCommand(&Str, TEXT("PIVOT")) )
			{
				Pivot=1;
				ResetPivot();
			}
			else if( ParseCommand(&Str,TEXT("ROTATION")) )
			{
				Rotation=1;
			}
			else if( ParseCommand(&Str,TEXT("SCALE")) )
			{
				Scale=1;
			}
			else if( ParseCommand(&Str,TEXT("ALL")) )
			{
				Location=Rotation=Scale=1;
				ResetPivot();
			}
			for( INT i=0; i<Level->Actors.Num(); i++ )
			{
				AActor* Actor=Level->Actors(i);
				if( Actor && Actor->bSelected )
				{
					Actor->Modify();
					if( Location ) Actor->Location  = FVector(0.f,0.f,0.f);
					if( Location ) Actor->PrePivot  = FVector(0.f,0.f,0.f);
					if( Pivot && Cast<ABrush>(Actor) )
					{
						ABrush* Brush = Cast<ABrush>(Actor);
						FModelCoords Coords, Uncoords;
						Brush->BuildCoords( &Coords, &Uncoords );
						Brush->Location -= Brush->PrePivot.TransformVectorBy( Coords.PointXform );
						Brush->PrePivot = FVector(0.f,0.f,0.f);
						Brush->PostEditChange();
					}
					if( Scale    ) Actor->DrawScale = 1.0f;
				}
			}
			Trans->End();
			RedrawLevel( Level );
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("DUPLICATE")) )
		{
			Trans->Begin( TEXT("Duplicate Actors") );
			Level->Modify();
			edactDuplicateSelected( Level );
			Trans->End();
			RedrawLevel( Level );
			NoteSelectionChange( Level );
			Processed=1;
		}
		else if( ParseCommand(&Str, TEXT("ALIGN")) )
		{
			Trans->Begin( TEXT("Align brush vertices") );
			Level->Modify();
			edactAlignVertices( Level );
			Trans->End();
			RedrawLevel( Level );
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("KEYFRAME")) )
		{
			INT Num=0;
			Parse(Str,TEXT("NUM="),Num);
			Trans->Begin( TEXT("Set mover keyframe") );
			Level->Modify();
			for( INT i=0; i<Level->Actors.Num(); i++ )
			{
				AMover* Mover=Cast<AMover>(Level->Actors(i));
				if( Mover && Mover->bSelected )
				{
					Mover->Modify();
					Mover->KeyNum = Num;
					Mover->PostEditChange();
					SetPivot( Mover->Location, 0, 0 );
				}
			}
			Trans->End();
			RedrawLevel( Level );
			Processed=1;
		}
	}
	//------------------------------------------------------------------------------------
	// POLY: Polygon adjustment and mapping
	//
	else if( ParseCommand(&Str,TEXT("POLY")) )
	{
		if( ParseCommand(&Str,TEXT("SELECT")) ) // POLY SELECT [ALL/NONE/INVERSE] FROM [LEVEL/SOLID/GROUP/ITEM/ADJACENT/MATCHING]
		{
			appSprintf( TempStr, TEXT("POLY SELECT %s"), Str );
			if( ParseCommand(&Str,TEXT("NONE")) )
			{
				return Exec( TEXT("SELECT NONE") );
				Processed=1;
			}
			else if( ParseCommand(&Str,TEXT("ALL")) )
			{
				Trans->Begin( TempStr );
				SelectNone( Level, 0 );
				polySelectAll( Level->Model );
				NoteSelectionChange( Level );
				Processed=1;
				Trans->End();
			}
			else if( ParseCommand(&Str,TEXT("REVERSE")) )
			{
				Trans->Begin( TempStr );
				polySelectReverse (Level->Model);
				EdCallback(EDC_SelPolyChange,0);
				Processed=1;
				Trans->End();
			}
			else if( ParseCommand(&Str,TEXT("MATCHING")) )
			{
				Trans->Begin( TempStr );
				if 		(ParseCommand(&Str,TEXT("GROUPS")))		polySelectMatchingGroups(Level->Model);
				else if (ParseCommand(&Str,TEXT("ITEMS")))		polySelectMatchingItems(Level->Model);
				else if (ParseCommand(&Str,TEXT("BRUSH")))		polySelectMatchingBrush(Level->Model);
				else if (ParseCommand(&Str,TEXT("TEXTURE")))	polySelectMatchingTexture(Level->Model);
				EdCallback(EDC_SelPolyChange,0);
				Processed=1;
				Trans->End();
			}
			else if( ParseCommand(&Str,TEXT("ADJACENT")) )
			{
				Trans->Begin( TempStr );
				if 	  (ParseCommand(&Str,TEXT("ALL")))			polySelectAdjacents( Level->Model );
				else if (ParseCommand(&Str,TEXT("COPLANARS")))	polySelectCoplanars( Level->Model );
				else if (ParseCommand(&Str,TEXT("WALLS")))		polySelectAdjacentWalls( Level->Model );
				else if (ParseCommand(&Str,TEXT("FLOORS")))		polySelectAdjacentFloors( Level->Model );
				else if (ParseCommand(&Str,TEXT("CEILINGS")))	polySelectAdjacentFloors( Level->Model );
				else if (ParseCommand(&Str,TEXT("SLANTS")))		polySelectAdjacentSlants( Level->Model );
				EdCallback(EDC_SelPolyChange,0);
				Processed=1;
				Trans->End();
			}
			else if( ParseCommand(&Str,TEXT("MEMORY")) )
			{
				Trans->Begin( TempStr );
				if 		(ParseCommand(&Str,TEXT("SET")))		polyMemorizeSet( Level->Model );
				else if (ParseCommand(&Str,TEXT("RECALL")))		polyRememberSet( Level->Model );
				else if (ParseCommand(&Str,TEXT("UNION")))		polyUnionSet( Level->Model );
				else if (ParseCommand(&Str,TEXT("INTERSECT")))	polyIntersectSet( Level->Model );
				else if (ParseCommand(&Str,TEXT("XOR")))		polyXorSet( Level->Model );
				EdCallback(EDC_SelPolyChange,0);
				Processed=1;
				Trans->End();
			}
#if 1 //LEGEND
			else if( ParseCommand(&Str,TEXT("ZONE")) )
			{
				Trans->Begin( TempStr );
				polySelectZone(Level->Model);
				EdCallback(EDC_SelPolyChange,0);
				Processed=1;
				Trans->End();
			}
#endif
			RedrawLevel(Level);
		}
		else if( ParseCommand(&Str,TEXT("DEFAULT")) ) // POLY DEFAULT <variable>=<value>...
		{
			CurrentTexture=NULL;
			ParseObject<UTexture>(Str,TEXT("TEXTURE="),CurrentTexture,ANY_PACKAGE);
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("EXTRUDE")) )	// POLY EXTRUDE DEPTH=<value>
		{
			Trans->Begin( TEXT("Poly Extrude") );

			INT Depth;
			Parse( Str, TEXT("DEPTH="), Depth );

			Level->Modify();

			// Get a list of all the selected polygons.
			TArray<FPoly> SelectedPolys;	// The selected polygons.
			TArray<AActor*> ActorList;		// The actors that own the polys (in synch with SelectedPolys)

			for( INT x = 0 ; x < Level->Model->Surfs.Num() ; x++ )
			{
				FBspSurf* Surf = &(Level->Model->Surfs(x));
				check(Surf->Actor);
				if( Surf->PolyFlags & PF_Selected )
				{
					FPoly Poly;
					if( polyFindMaster( Level->Model, x, Poly ) )
					{
						new( SelectedPolys )FPoly( Poly );
						ActorList.AddItem( Surf->Actor );
					}
				}
			}

			for( x = 0 ; x < SelectedPolys.Num() ; x++ )
			{
				ActorList(x)->Brush->Polys->Element.ModifyAllItems();

				// Find all the polys which are linked to create this surface.
				TArray<FPoly> PolyList;
				polyGetLinkedPolys( (ABrush*)ActorList(x), &SelectedPolys(x), &PolyList );

				// Get a list of the outer edges of this surface.
				TArray<FEdge> EdgeList;
				polyGetOuterEdgeList( &PolyList, &EdgeList );

				// Create new polys from the edges of the selected surface.
				for( INT edge = 0 ; edge < EdgeList.Num() ; edge++ )
				{
					FEdge* Edge = &EdgeList(edge);

					FVector v1 = Edge->Vertex[0],
						v2 = Edge->Vertex[1];

					FPoly NewPoly;
					NewPoly.Init();
					NewPoly.NumVertices = 4;
					NewPoly.Vertex[0] = v1;
					NewPoly.Vertex[1] = v2;
					NewPoly.Vertex[2] = v2 + (SelectedPolys(x).Normal * Depth);
					NewPoly.Vertex[3] = v1 + (SelectedPolys(x).Normal * Depth);

					new(ActorList(x)->Brush->Polys->Element)FPoly( NewPoly );
				}

				// Create the cap polys.
				for( INT pl = 0 ; pl < PolyList.Num() ; pl++ )
				{
					FPoly* PolyFromList = &PolyList(pl);

					for( INT poly = 0 ; poly < ActorList(x)->Brush->Polys->Element.Num() ; poly++ )
						if( *PolyFromList == ActorList(x)->Brush->Polys->Element(poly) )
						{
							FPoly* Poly = &(ActorList(x)->Brush->Polys->Element(poly));
							for( INT vtx = 0 ; vtx < Poly->NumVertices ; vtx++ )
								Poly->Vertex[vtx] += (SelectedPolys(x).Normal * Depth);
							break;
						}
				}

				// Clean up the polys.
				for( INT poly = 0 ; poly < ActorList(x)->Brush->Polys->Element.Num() ; poly++ )
				{
					FPoly* Poly = &(ActorList(x)->Brush->Polys->Element(poly));
					Poly->iLink = poly;
					Poly->Normal = FVector(0,0,0);
					Poly->Finalize(0);
					Poly->Base = Poly->Vertex[0];
				}

				ActorList(x)->Brush->BuildBound();
			}

			EdCallback( EDC_RedrawAllViewports, 0 );
			Trans->End();
		}
		else if( ParseCommand(&Str,TEXT("BEVEL")) )	// POLY BEVEL DEPTH=<value> BEVEL=<value>
		{
			Trans->Begin( TEXT("Poly Bevel") );

			INT Depth, Bevel;
			Parse( Str, TEXT("DEPTH="), Depth );
			Parse( Str, TEXT("BEVEL="), Bevel );

			Level->Modify();

			// Get a list of all the selected polygons.
			TArray<FPoly> SelectedPolys;	// The selected polygons.
			TArray<AActor*> ActorList;		// The actors that own the polys (in synch with SelectedPolys)

			for( INT x = 0 ; x < Level->Model->Surfs.Num() ; x++ )
			{
				FBspSurf* Surf = &(Level->Model->Surfs(x));
				check(Surf->Actor);
				if( Surf->PolyFlags & PF_Selected )
				{
					FPoly Poly;
					if( polyFindMaster( Level->Model, x, Poly ) )
					{
						new( SelectedPolys )FPoly( Poly );
						ActorList.AddItem( Surf->Actor );
					}
				}
			}

			for( x = 0 ; x < SelectedPolys.Num() ; x++ )
			{
				ActorList(x)->Brush->Polys->Element.ModifyAllItems();

				// Find all the polys which are linked to create this surface.
				TArray<FPoly> PolyList;
				polyGetLinkedPolys( (ABrush*)ActorList(x), &SelectedPolys(x), &PolyList );

				// Get a list of the outer edges of this surface.
				TArray<FEdge> EdgeList;
				polyGetOuterEdgeList( &PolyList, &EdgeList );

				// Figure out where the center of the poly is.
				FVector PolyCenter = FVector(0,0,0);
				for( INT edge = 0 ; edge < EdgeList.Num() ; edge++ )
					PolyCenter += EdgeList(edge).Vertex[0];
				PolyCenter /= EdgeList.Num();

				// Create new polys from the edges of the selected surface.
				for( edge = 0 ; edge < EdgeList.Num() ; edge++ )
				{
					FEdge* Edge = &EdgeList(edge);

					FVector v1 = Edge->Vertex[0],
						v2 = Edge->Vertex[1];

					FPoly NewPoly;
					NewPoly.Init();
					NewPoly.NumVertices = 4;
					NewPoly.Vertex[0] = v1;
					NewPoly.Vertex[1] = v2;

					FVector CenterDir = PolyCenter - v2;
					CenterDir.Normalize();
					NewPoly.Vertex[2] = v2 + (SelectedPolys(x).Normal * Depth) + (CenterDir * Bevel);

					CenterDir = PolyCenter - v1;
					CenterDir.Normalize();
					NewPoly.Vertex[3] = v1 + (SelectedPolys(x).Normal * Depth) + (CenterDir * Bevel);

					new(ActorList(x)->Brush->Polys->Element)FPoly( NewPoly );
				}

				// Create the cap polys.
				for( INT pl = 0 ; pl < PolyList.Num() ; pl++ )
				{
					FPoly* PolyFromList = &PolyList(pl);

					for( INT poly = 0 ; poly < ActorList(x)->Brush->Polys->Element.Num() ; poly++ )
						if( *PolyFromList == ActorList(x)->Brush->Polys->Element(poly) )
						{
							FPoly* Poly = &(ActorList(x)->Brush->Polys->Element(poly));
							for( INT vtx = 0 ; vtx < Poly->NumVertices ; vtx++ )
							{
								FVector CenterDir = PolyCenter - Poly->Vertex[vtx];
								CenterDir.Normalize();
								Poly->Vertex[vtx] += (CenterDir * Bevel);

								Poly->Vertex[vtx] += (SelectedPolys(x).Normal * Depth);
							}
							break;
						}
				}

				// Clean up the polys.
				for( INT poly = 0 ; poly < ActorList(x)->Brush->Polys->Element.Num() ; poly++ )
				{
					FPoly* Poly = &(ActorList(x)->Brush->Polys->Element(poly));
					Poly->iLink = poly;
					Poly->Normal = FVector(0,0,0);
					Poly->Finalize(0);
					Poly->Base = Poly->Vertex[0];
				}

				ActorList(x)->Brush->BuildBound();
			}

			EdCallback( EDC_RedrawAllViewports, 0 );
			Trans->End();
		}
		else if( ParseCommand(&Str,TEXT("SETTEXTURE")) )
		{
			Trans->Begin( TEXT("Poly SetTexture") );
			Level->Model->ModifySelectedSurfs(1);
			for( Index1=0; Index1<Level->Model->Surfs.Num(); Index1++ )
			{
				if( Level->Model->Surfs(Index1).PolyFlags & PF_Selected )
				{
					Level->Model->Surfs(Index1).Texture = CurrentTexture;
					polyUpdateMaster( Level->Model, Index1, 0, 0 );
				}
			}
			Trans->End();
			RedrawLevel(Level);
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("SET")) ) // POLY SET <variable>=<value>...
		{
			Trans->Begin( TEXT("Poly Set") );
			Level->Model->ModifySelectedSurfs( 1 );



			{
				UTexture *Texture;
				if (ParseObject<UTexture>(Str,TEXT("TEXTURE="),Texture,ANY_PACKAGE))
					{

						for (Index1=0; Index1<Level->Model->Surfs.Num(); Index1++)
						{
							if (Level->Model->Surfs(Index1).PolyFlags & PF_Selected)
							{
								Level->Model->Surfs(Index1).Texture  = Texture;
								polyUpdateMaster( Level->Model, Index1, 0, 0 );
							};
						};
					};
			}



			Word4  = 0;
			INT DWord1 = 0;
			INT DWord2 = 0;
			if (Parse(Str,TEXT("SETFLAGS="),DWord1))   Word4=1;
			if (Parse(Str,TEXT("CLEARFLAGS="),DWord2)) Word4=1;
			if (Word4)  polySetAndClearPolyFlags (Level->Model,DWord1,DWord2,1,1); // Update selected polys' flags

			TCHAR SurfaceTag[256];
			if( Parse( Str, TEXT("SURFACETAG="), SurfaceTag, 255 ) )
				polySetSurfaceTags( Level->Model, FName(SurfaceTag), 1, 1);

			//
			Trans->End();
			RedrawLevel(Level);
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("TEXSCALE")) ) // POLY TEXSCALE [U=..] [V=..] [UV=..] [VU=..]
		{
			Trans->Begin( TEXT("Poly Texscale") );
			Level->Model->ModifySelectedSurfs( 1 );
			Word2 = 1; // Scale absolute
			if( ParseCommand(&Str,TEXT("RELATIVE")) )
				Word2=0;
			TexScale:

			FLOAT UU,UV,VU,VV;
			UU=1.0; Parse (Str,TEXT("UU="),UU);
			UV=0.0; Parse (Str,TEXT("UV="),UV);
			VU=0.0; Parse (Str,TEXT("VU="),VU);
			VV=1.0; Parse (Str,TEXT("VV="),VV);

			polyTexScale( Level->Model, UU, UV, VU, VV, Word2 );

			Trans->End();
			RedrawLevel( Level );
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("TEXINFO")) ) // POLY TEXINFO
		{
			for( INT i=0; i<Level->Model->Surfs.Num(); i++ )
			{
				FBspSurf *Poly = &Level->Model->Surfs(i);
				if (Poly->PolyFlags & PF_Selected)
				{
					FVector Base = Level->Model->Points(Poly->pBase);
					FVector OriginalU = Level->Model->Vectors(Poly->vTextureU);
					FVector OriginalV = Level->Model->Vectors(Poly->vTextureV);

					//GLog->Logf( TEXT("TEXINFO : U=%1.5f V=%1.5f"), 1.0 / OriginalU.Size(), 1.0 / OriginalV.Size() );
					GLog->Logf( TEXT("====="));
					GLog->Logf( TEXT("TEXINFO :    B=[%d] %1.1f, %1.1f, %1.1f"), Poly->pBase, Base.X, Base.Y, Base.Z );
					GLog->Logf( TEXT("        :    U=%1.1f, %1.1f, %1.1f"), OriginalU.X, OriginalU.Y, OriginalU.Z );
					GLog->Logf( TEXT("        :    V=%1.1f, %1.1f, %1.1f"), OriginalV.X, OriginalV.Y, OriginalV.Z );
					//GLog->Logf( TEXT("        : PANU=%d, PANV=%d"), Poly->PanU, Poly->PanV );
					GLog->Logf( TEXT("        : Normal=%1.1f, %1.1f, %1.1f"), Level->Model->Vectors(Poly->vNormal).X, Level->Model->Vectors(Poly->vNormal).Y, Level->Model->Vectors(Poly->vNormal).Z );
				}
			}
		}
		else if( ParseCommand(&Str,TEXT("TEXMULT")) ) // POLY TEXMULT [U=..] [V=..]
		{
			Trans->Begin( TEXT("Poly Texmult") );
			Level->Model->ModifySelectedSurfs( 1 );
			Word2 = 0; // Scale relative;
			goto TexScale;
		}
		else if( ParseCommand(&Str,TEXT("TEXPAN")) ) // POLY TEXPAN [RESET] [U=..] [V=..]
		{
			Trans->Begin( TEXT("Poly Texpan") );
			Level->Model->ModifySelectedSurfs( 1 );
			if( ParseCommand (&Str,TEXT("RESET")) )
				polyTexPan( Level->Model, 0, 0, 1 );
			Word1 = 0; Parse (Str,TEXT("U="),Word1);
			Word2 = 0; Parse (Str,TEXT("V="),Word2);
			polyTexPan( Level->Model, Word1, Word2, 0 );
			Trans->End();
			RedrawLevel( Level );
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("TEXALIGN")) ) // POLY TEXALIGN [FLOOR/GRADE/WALL/NONE]
		{
			ETexAlign TexAlign;
			if		(ParseCommand (&Str,TEXT("DEFAULT")))		TexAlign = TEXALIGN_Default;
			else if (ParseCommand (&Str,TEXT("WALLDIR")))		TexAlign = TEXALIGN_WallDir;
			else if (ParseCommand (&Str,TEXT("CYLINDER")))		TexAlign = TEXALIGN_Cylinder;
			else if (ParseCommand (&Str,TEXT("PLANAR")))		TexAlign = TEXALIGN_Planar;
			else if (ParseCommand (&Str,TEXT("PLANARAUTO")))	TexAlign = TEXALIGN_PlanarAuto;
			else if (ParseCommand (&Str,TEXT("PLANARWALL")))	TexAlign = TEXALIGN_PlanarWall;
			else if (ParseCommand (&Str,TEXT("PLANARFLOOR")))	TexAlign = TEXALIGN_PlanarFloor;
			else if (ParseCommand (&Str,TEXT("FACE")))			TexAlign = TEXALIGN_Face;
			else								goto Skip;
			{
				INT DWord1=0;
				DWORD Options=0;
				Parse( Str, TEXT("TEXELS="), DWord1 );
				Parse( Str, TEXT("OPTIONS="), Options );

				Trans->Begin( TEXT("Poly Texalign") );
				Level->Model->ModifySelectedSurfs( 1 );
				polyTexAlign( Level->Model, TexAlign, DWord1, Options );
				Trans->End();
				RedrawLevel( Level );
				Processed=1;
			}
			Skip:;
		}
	}
	//------------------------------------------------------------------------------------
	// TEXTURE management:
	//
	else if( ParseCommand(&Str,TEXT("Texture")) )
	{
		if( ParseCommand(&Str,TEXT("Clear")) )
		{
			UTexture* Texture;
			if( ParseObject<UTexture>(Str,TEXT("NAME="),Texture,ANY_PACKAGE) )
				Texture->Clear( TCLEAR_Temporal );
		}
		else if( ParseCommand(&Str,TEXT("SCALE")) )
		{
			FLOAT DeltaScale;
			Parse( Str, TEXT("DELTA="), DeltaScale );
			if( DeltaScale <= 0 )
			{
				Ar.Logf( NAME_ExecWarning, TEXT("Invalid DeltaScale setting") );
				return 1;
			}

			// get the current viewport
			UViewport* CurrentViewport = NULL;
			for( INT i = 0; i < Client->Viewports.Num(); i++ )
			{
				if( Client->Viewports(i)->Current )
					CurrentViewport = Client->Viewports(i);
			}
			if( CurrentViewport == NULL )
			{
				Ar.Logf( NAME_ExecWarning, TEXT("Current viewport not found") );
				return 1;
			}

			// get the selected texture package
			UObject* Pkg = CurrentViewport->MiscRes;
			if( Pkg && CurrentViewport->Group!=NAME_None )
				Pkg = FindObject<UPackage>( Pkg, *CurrentViewport->Group );

			// Make the list.
			FMemMark Mark(GMem);
			enum {MAX=16384};
			UTexture** List = new(GMem,MAX)UTexture*;
			INT n = 0;
			for( TObjectIterator<UTexture> It; It && n<MAX; ++It )
				if( It->IsIn(Pkg) )
					List[n++] = *It;

			// scale the textures in the list relative to their old values
			for( i=0; i<n; i++ )
			{
				UTexture* Texture = List[i];
				Texture->Scale *= DeltaScale;
			}
			Mark.Pop();
			return 1;
		}
#if 1 //Texture Culling added by Legend on 4/12/2000
		//
		// Editor Command: TEXTURE CULL
		//
		// Build a "ReferencedTextures" list of all textures referenced on surfaces 
		// (Surfs and Mover Polys).  This is the visible texture list.
		//
		// Then, traverse all polys in the level, eliminating textures that
		// are not contained in the ReferencedTextures list.
		//
		// When the level is saved, all back-facing textures (textures that were
		// beling loaded -- consuming memory -- but never visible to the player,
		// will have been removed.)
		//
		else if( ParseCommand(&Str,TEXT("CULL")) )
		{
			TArray<UTexture*> ReferencedTextures;
			TArray<UTexture*> CulledTextures;

			for( TArray<AActor*>::TIterator It1(Level->Actors); It1; ++It1 )
			{
				AActor* Actor = *It1;
				if( Actor )
				{
					UModel* M = Actor->IsA(ALevelInfo::StaticClass()) ? Actor->GetLevel()->Model : Actor->Brush;
					if( M )
					{
//GLog->Logf( TEXT("Actor=%s"), Actor->GetName() );
						for( TArray<FBspSurf>::TIterator ItS(M->Surfs); ItS; ++ItS )
						{
							if( ItS->Texture )
							{
//								GLog->Logf( TEXT("  %s REFERENCED"), ItS->Texture->GetName() );
								ReferencedTextures.AddUniqueItem( ItS->Texture );
							}
						}

						if( M->Polys && Actor->IsA(AMover::StaticClass()) )
						{
//GLog->Logf( TEXT("Actor=%s"), Actor->GetName() );
							for( TArray<FPoly>::TIterator ItP(M->Polys->Element); ItP; ++ItP )
							{
								if( ItP->Texture )
								{
//									GLog->Logf( TEXT("  %s REFERENCED MOVER"), ItP->Texture->GetName() );
									ReferencedTextures.AddUniqueItem( ItP->Texture );
								}
							}
						}
					}
				}
			}
			for( TArray<AActor*>::TIterator It2(Level->Actors); It2; ++It2 )
			{
				AActor* Actor = *It2;
				if( Actor )
				{
					UModel* M = Actor->IsA(ALevelInfo::StaticClass()) ? Actor->GetLevel()->Model : Actor->Brush;
					if( M && M->Polys )
					{
//GLog->Logf( TEXT("Actor=%s"), Actor->GetName() );
						for( TArray<FPoly>::TIterator ItP(M->Polys->Element); ItP; ++ItP )
						{
							if( ItP->Texture )
							{
								// if poly isn't in the list, kill it
								if( ReferencedTextures.FindItemIndex( ItP->Texture ) == INDEX_NONE )
								{
//									GLog->Logf( TEXT("  %s CULLED"), ItP->Texture->GetName() );
									CulledTextures.AddUniqueItem( ItP->Texture );
									ItP->Texture = 0;
								}
							}
						}
					}
				}
			}
			GLog->Logf( TEXT("TEXTURE CULLING SUMMARY") );
			GLog->Logf( TEXT("  REFERENCED") );
			for( TArray<UTexture*>::TIterator ItR(ReferencedTextures); ItR; ++ItR )
			{
				GLog->Logf( TEXT("    %s"), (*ItR)->GetFullName() );
			}
			GLog->Logf( TEXT("  CULLED") );
			for( TArray<UTexture*>::TIterator ItC(CulledTextures); ItC; ++ItC )
			{
				GLog->Logf( TEXT("    %s"), (*ItC)->GetFullName() );
			}
			return 1;
		}
#endif
#if 1 //Batch Detail Texture Editing added by Legend on 4/12/2000
		//
		// Editor Command: TEXTURE CLEARDETAIL
		//
		//		Clear the "current detail texture"
		//
		// Editor Command: TEXTURE SETDETAIL
		//
		//		Set the "current detail texture" to the current the texture browser selection
		//
		// Editor Command: TEXTURE APPLYDETAIL [OVERRIDE]
		//
		//		Apply the "current detail texture" to the texture selected in the texture browser
		//
		// Editor Command: TEXTURE REPLACEDETAIL
		//
		//		Search through all texture packages for occurrences of detail textures that
		//		match the texture currently selected in the texture browser.  If a match
		//		is found, replace the texture's detail texture with the "current detail texture."
		//
		// Editor Command: TEXTURE BATCHAPPLY DETAIL=[DetailTextureName | None]
		//                 [PREFIX=TextureNameMatchingPrefix] [OVERRIDE=[TRUE | FALSE]]
		//
		//		Search through all texture packages optionally searching for matches
		//		against the "TextureNameMatchingPrefix" for all textures found, apply
		//		DetailTextureName as the new detail texture.  If a detail texture already
		//		exists and OVERRIDE=FALSE, then skip the texture.
		//
		else if( ParseCommand(&Str,TEXT("CLEARDETAIL")) )
		{
			CurrentDetailTexture = 0;
			debugf( NAME_Log, TEXT("Detail texture cleared") );
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("SETDETAIL")) )
		{
			CurrentDetailTexture = CurrentTexture;
			debugf( NAME_Log, TEXT("Detail texture set to %s"), CurrentTexture ? CurrentTexture->GetFullName() : TEXT("None") );
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("APPLYDETAIL")) )
		{
			if( CurrentTexture != 0 )
			{
				if( CurrentTexture->DetailTexture == 0 || ParseCommand(&Str,TEXT("OVERRIDE")) )
				{
					CurrentTexture->DetailTexture = CurrentDetailTexture;
					debugf( NAME_Log, TEXT("Detail texture %s applied to %s"), CurrentTexture->DetailTexture->GetFullName(), CurrentTexture->GetFullName() );
				}
				else
				{
					debugf( NAME_Log, TEXT("Detail texture for %s ALREADY set to %s"), CurrentTexture->GetFullName(), CurrentTexture->DetailTexture->GetFullName() );
				}
			}
			else
			{
				debugf( NAME_Log, TEXT("No texture selected") );
			}
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("REPLACEDETAIL")) )
		{
			for( TObjectIterator<UTexture> It; It; ++It )
			{
				if( It->DetailTexture == CurrentTexture )
				{
					It->DetailTexture = CurrentDetailTexture;
					debugf( NAME_Log, TEXT("Detail texture %s replaced with %s on %s"), CurrentTexture->DetailTexture->GetFullName(), CurrentDetailTexture->GetFullName(), It->GetFullName() );
				}
			}
		}
		else if( ParseCommand(&Str,TEXT("BATCHAPPLY")) )
		{
			UTexture* DetailTexture = 0;
			ParseObject<UTexture>(Str,TEXT("DETAIL="),DetailTexture,ANY_PACKAGE);
			debugf( NAME_Log, TEXT("Detail=%s"), DetailTexture ? DetailTexture->GetFullName() : TEXT("<None>") );

			FString TexturePrefix;
			UBOOL bNoPrefix = !Parse( Str, TEXT("PREFIX="), TexturePrefix );
			debugf( NAME_Log, TEXT("Prefix=%s"), bNoPrefix ? TEXT("<None>") : TexturePrefix );

			UBOOL bOverride = 0;
			Parse( Str,TEXT("OVERRIDE="), bOverride );
			debugf( NAME_Log, TEXT("bOverride=%d"), bOverride );

			for( TObjectIterator<UTexture> It; It; ++It )
			{
				if( bNoPrefix || appStrstr( It->GetName(), *TexturePrefix ) == It->GetName() )
				{
					if( bOverride || It->DetailTexture == 0 )
					{
						It->DetailTexture = DetailTexture;
						debugf( NAME_Log, TEXT("Detail texture %s applied to %s"), It->DetailTexture->GetFullName(), It->GetFullName() );
					}
					else
					{
						debugf( NAME_Log, TEXT( "Detail texture for %s ALREADY set to %s"), It->GetFullName(), It->DetailTexture->GetFullName() );
					}
				}
			}
			return 1;
		}
#endif
		else if( ParseCommand(&Str,TEXT("New")) )
		{
			FName GroupName=NAME_None;
			FName PackageName;
			UClass* TextureClass;
			INT USize, VSize;
			if
			(	Parse( Str, TEXT("NAME="),    TempName, NAME_SIZE )
			&&	ParseObject<UClass>( Str, TEXT("CLASS="), TextureClass, ANY_PACKAGE )
			&&	Parse( Str, TEXT("USIZE="),   USize )
			&&	Parse( Str, TEXT("VSIZE="),   VSize )
			&&	Parse( Str, TEXT("PACKAGE="), PackageName )
			&&	TextureClass->IsChildOf( UTexture::StaticClass() ) 
			&&	PackageName!=NAME_None )
			{
				UPackage* Pkg = CreatePackage(NULL,*PackageName);
				if( Parse( Str, TEXT("GROUP="), GroupName ) && GroupName!=NAME_None )
					Pkg = CreatePackage(Pkg,*GroupName);
				if( !StaticFindObject( TextureClass, Pkg, TempName ) )
				{
					// Create new texture object.
					UTexture* Result = (UTexture*)StaticConstructObject( TextureClass, Pkg, TempName, RF_Public|RF_Standalone );
					if( !Result->Palette )
					{
						Result->Palette = new( Result->GetOuter(), NAME_None, RF_Public )UPalette;
						Result->Palette->Colors.Add( 256 );
					}
					Result->Init( USize, VSize );
					Result->PostLoad();
					Result->Clear( TCLEAR_Temporal | TCLEAR_Bitmap );

					CurrentTexture = Result;
				}
				else Ar.Logf( NAME_ExecWarning, TEXT("Texture exists") );
			}
			else Ar.Logf( NAME_ExecWarning, TEXT("Bad TEXTURE NEW") );
			Processed=1;
		}
	}
	//------------------------------------------------------------------------------------
	// MODE management (Global EDITOR mode):
	//
	else if( ParseCommand(&Str,TEXT("MODE")) )
		{
		Word1 = Mode;  // To see if we should redraw
		Word2 = Mode;  // Destination mode to set
		//
		UBOOL DWord1;
		if( ParseUBOOL(Str,TEXT("GRID="), DWord1) )
		{
			FinishAllSnaps (Level);
			Constraints.GridEnabled = DWord1;
			Word1=MAXWORD;
		}
		if( ParseUBOOL(Str,TEXT("ROTGRID="), DWord1) )
		{
			FinishAllSnaps (Level);
			Constraints.RotGridEnabled=DWord1;
			Word1=MAXWORD;
		}
		if( ParseUBOOL(Str,TEXT("SNAPVERTEX="), DWord1) )
		{
			FinishAllSnaps (Level);
			Constraints.SnapVertices=DWord1;
			Word1=MAXWORD;
		}
		Parse(Str,TEXT("MAPEXT="), GMapExt);
		if( Parse(Str,TEXT("USESIZINGBOX="), DWord1) )
		{
			FinishAllSnaps (Level);
			// If -1 is passed in, treat it as a toggle.  Otherwise, use the value as a literal assignment.
			if( DWord1 == -1 )
				Constraints.UseSizingBox=(Constraints.UseSizingBox == 0) ? 1 : 0;
			else
				Constraints.UseSizingBox=DWord1;
			Word1=MAXWORD;
		}
		Parse( Str, TEXT("SPEED="), MovementSpeed );
		Parse( Str, TEXT("SNAPDIST="), Constraints.SnapDistance );
		//
		// Major modes:
		//
		if 		(ParseCommand(&Str,TEXT("CAMERAMOVE")))		Word2 = EM_ViewportMove;
		else if	(ParseCommand(&Str,TEXT("CAMERAZOOM")))		Word2 = EM_ViewportZoom;
		else if	(ParseCommand(&Str,TEXT("BRUSHROTATE")))	Word2 = EM_BrushRotate;
		else if	(ParseCommand(&Str,TEXT("BRUSHSCALE")))		Word2 = EM_BrushScale;
		else if	(ParseCommand(&Str,TEXT("BRUSHSNAP"))) 		Word2 = EM_BrushSnap;
		else if	(ParseCommand(&Str,TEXT("TEXTUREPAN")))		Word2 = EM_TexturePan;
		else if	(ParseCommand(&Str,TEXT("TEXTUREROTATE")))	Word2 = EM_TextureRotate;
		else if	(ParseCommand(&Str,TEXT("TEXTURESCALE"))) 	Word2 = EM_TextureScale;
		else if	(ParseCommand(&Str,TEXT("BRUSHCLIP"))) 		Word2 = EM_BrushClip;
		else if	(ParseCommand(&Str,TEXT("FACEDRAG"))) 		Word2 = EM_FaceDrag;
		else if	(ParseCommand(&Str,TEXT("VERTEXEDIT"))) 	Word2 = EM_VertexEdit;
		else if	(ParseCommand(&Str,TEXT("POLYGON"))) 		Word2 = EM_Polygon;
//		else if (ParseCommand(&Str,TEXT("TERRAINEDIT"))) 	Word2 = EM_TerrainEdit;
		//
		if( Word2 != Word1 )
		{
			if( Word1 == EM_Polygon )
				polygonDeleteMarkers();
			if( Word1 == EM_BrushClip )
				brushclipDeleteMarkers();

			edcamSetMode( Word2 );
			RedrawLevel( Level );
		}
		EdCallback( EDC_RedrawAllViewports, 0 );
		Processed=1;
		}
	//------------------------------------------------------------------------------------
	// Transaction tracking and control
	//
	else if( ParseCommand(&Str,TEXT("TRANSACTION")) )
	{
		if( ParseCommand(&Str,TEXT("UNDO")) )
		{
			if( Trans->Undo() )
				RedrawLevel( Level );
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("REDO")) )
		{
			if( Trans->Redo() )
				RedrawLevel(Level);
			Processed=1;
		}
		NoteSelectionChange( Level );
		EdCallback( EDC_MapChange, 0 );
	}
	//------------------------------------------------------------------------------------
	// General objects
	//
	else if( ParseCommand(&Str,TEXT("OBJ")) )
	{
		if( ParseCommand(&Str,TEXT("EXPORT")) )//oldver
		{
			FName Package=NAME_None;
			UClass* Type;
			UObject* Res;
			Parse( Str, TEXT("PACKAGE="), Package );
			if
			(	ParseObject<UClass>( Str, TEXT("TYPE="), Type, ANY_PACKAGE )
			&&	Parse( Str, TEXT("FILE="), TempFname, 80 )
			&&	ParseObject( Str, TEXT("NAME="), Type, Res, ANY_PACKAGE ) )
			{
				for( FObjectIterator It; It; ++It )
					It->ClearFlags( RF_TagImp | RF_TagExp );
				UExporter* Exporter = UExporter::FindExporter( Res, appFExt(TempFname) );
				if( Exporter )
				{
					Exporter->ParseParms( Str );
					UExporter::ExportToFile( Res, Exporter, TempFname );
					delete Exporter;
				}
			}
			else Ar.Log( NAME_ExecWarning, TEXT("Missing file, name, or type") );
			Processed = 1;
		}
		else if( ParseCommand(&Str,TEXT("SavePackage")) )
		{
			UPackage* Pkg;
			if
			(	Parse( Str, TEXT("File="), TempFname, 79 ) 
			&&	ParseObject<UPackage>( Str, TEXT("Package="), Pkg, NULL ) )
			{
				GWarn->BeginSlowTask( TEXT("Saving package"), 1, 0 );
				SavePackage( Pkg, NULL, RF_Standalone, TempFname, GWarn );
				GWarn->EndSlowTask();
			}
			else Ar.Log( NAME_ExecWarning, TEXT("Missing filename") );
			Processed=1;
		}
	}
	//------------------------------------------------------------------------------------
	// CLASS functions
	//
	else if( ParseCommand(&Str,TEXT("CLASS")) )
	{
		if( ParseCommand(&Str,TEXT("SPEW")) )
		{
			GWarn->BeginSlowTask( TEXT("Exporting scripts"), 0, 0 );

			UBOOL All = ParseCommand(&Str,TEXT("ALL"));
			for( TObjectIterator<UClass> It; It; ++It )
			{
				if( It->ScriptText && (All || (It->GetFlags() & RF_SourceModified)) )
				{
					// Make package directory.
					appStrcpy( TempFname, TEXT("..") PATH_SEPARATOR );
					appStrcat( TempFname, It->GetOuter()->GetName() );
					GFileManager->MakeDirectory( TempFname, 0 );

					// Make package\Classes directory.
					appStrcat( TempFname, PATH_SEPARATOR TEXT("Classes") );
					GFileManager->MakeDirectory( TempFname, 0 );

					// Save file.
					appStrcat( TempFname, PATH_SEPARATOR );
					appStrcat( TempFname, It->GetName() );
					appStrcat( TempFname, TEXT(".uc") );
					debugf( NAME_Log, TEXT("Spewing: %s"), TempFname );
					UExporter::ExportToFile( *It, NULL, TempFname );
				}
			}
			GWarn->EndSlowTask();
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("LOAD")) ) // CLASS LOAD FILE=..
		{
			if( Parse( Str, TEXT("FILE="), TempFname, 80 ) )
			{
				Ar.Logf( TEXT("Loading class from %s..."), TempFname );
				if( appStrfind(TempFname,TEXT("UC")) )
				{
					FName PkgName, ObjName;
					if
					(	Parse(Str,TEXT("PACKAGE="),PkgName)
					&&	Parse(Str,TEXT("NAME="),ObjName) )
					{
						// Import it.
						ImportObject<UClass>( CreatePackage(NULL,*PkgName), ObjName, RF_Public|RF_Standalone, TempFname );
					}
					else Ar.Log(TEXT("Missing package name"));
				}
				else if( appStrfind( TempFname, TEXT("U")) )
				{
					// Load from Unrealfile.
					UPackage* Pkg = Cast<UPackage>(LoadPackage( NULL, TempFname, LOAD_Forgiving ));
					if( Pkg && (Pkg->PackageFlags & PKG_BrokenLinks) )
					{
						debugf( TEXT("Some classes were broken; a recompile is required") );
						for( TObjectIterator<UClass> It; It; ++It )
						{
							if( It->IsIn(Pkg) )
							{
								It->Dependencies.Empty();
								It->Script.Empty();
							}
						}
					}
				}
				else Ar.Log( NAME_ExecWarning, TEXT("Unrecognized file type") );
			}
			else Ar.Log(NAME_ExecWarning,TEXT("Missing filename"));
			Processed=1;
		}
		else if( ParseCommand(&Str,TEXT("NEW")) ) // CLASS NEW
		{
			UClass *Parent;
			FName PackageName;
			if
			(	ParseObject<UClass>( Str, TEXT("PARENT="), Parent, ANY_PACKAGE )
			&&	Parse( Str, TEXT("PACKAGE="), PackageName )
			&&	Parse( Str, TEXT("NAME="), TempStr, NAME_SIZE ) )
			{
				UPackage* Pkg = CreatePackage(NULL,*PackageName);
				UClass* Class = new( Pkg, TempStr, RF_Public|RF_Standalone )UClass( Parent );
				if( Class )
					Class->ScriptText = new( Class->GetOuter(), TempStr, RF_NotForClient|RF_NotForServer )UTextBuffer;
				else
					Ar.Log( NAME_ExecWarning, TEXT("Class not found") );
			}
			Processed=1;
		}
	}
	//------------------------------------------------------------------------------------
	// SCRIPT: script compiler
	//
	else if( ParseCommand(&Str,TEXT("SCRIPT")) )
	{
		if( ParseCommand(&Str,TEXT("MAKE")) )
		{
			GWarn->BeginSlowTask( TEXT("Compiling scripts"), 0, 0 );
			UBOOL All  = ParseCommand(&Str,TEXT("ALL"));
			UBOOL Boot = ParseCommand(&Str,TEXT("BOOT"));
			MakeScripts( UObject::StaticClass(), GWarn, All, Boot, true );
//			MakeScripts( NULL, GWarn, All, Boot, 1 );
			GWarn->EndSlowTask();
			UpdatePropertiesWindows();
			Processed=1;
		}
	}
	//------------------------------------------------------------------------------------
	// CAMERA: cameras
	//
	else if( ParseCommand(&Str,TEXT("CAMERA")) )
	{
		UBOOL DoUpdate = ParseCommand(&Str,TEXT("UPDATE"));
		UBOOL DoOpen   = ParseCommand(&Str,TEXT("OPEN"));
		if( (DoUpdate || DoOpen) && Level )
		{
			UViewport* Viewport;
			UBOOL Temp=0;
			TCHAR TempStr[NAME_SIZE];
			if( Parse( Str, TEXT("NAME="), TempStr, NAME_SIZE ) )
			{
				Viewport = FindObject<UViewport>( Client, TempStr );
				if( !Viewport )
				{
					Viewport = Client->NewViewport( TempStr );
					Level->SpawnViewActor( Viewport );
					Viewport->Input->Init( Viewport );
					DoOpen = 1;
				}
				else Temp=1;
			}
			else
			{
				Viewport = Client->NewViewport( NAME_None );
				Level->SpawnViewActor( Viewport );
				Viewport->Input->Init( Viewport );
				DoOpen = 1;
			}
			check(Viewport->Actor);

			DWORD hWndParent=0;
			Parse( Str, TEXT("HWND="), hWndParent );

			INT NewX=Viewport->SizeX, NewY=Viewport->SizeY;
			Parse( Str, TEXT("XR="), NewX ); if( NewX<0 ) NewX=0;
			Parse( Str, TEXT("YR="), NewY ); if( NewY<0 ) NewY=0;
			Viewport->Actor->FovAngle = FovAngle;

			Viewport->Actor->Misc1=0;
			Viewport->Actor->Misc2=0;
			Viewport->MiscRes=NULL;
			Parse(Str,TEXT("FLAGS="),Viewport->Actor->ShowFlags);
			Parse(Str,TEXT("REN="),  Viewport->Actor->RendMap);
			Parse(Str,TEXT("MISC1="),Viewport->Actor->Misc1);
			Parse(Str,TEXT("MISC2="),Viewport->Actor->Misc2);
			GTexNameFilter.Empty();
			Parse(Str,TEXT("NAMEFILTER="),GTexNameFilter);
			FName GroupName=NAME_None;
			if( Parse(Str,TEXT("GROUP="),GroupName) )
				Viewport->Group = GroupName;
			if( appStricmp(*Viewport->Group,TEXT("(All)"))==0 )
				Viewport->Group = NAME_None;

			switch( Viewport->Actor->RendMap )
			{
				case REN_TexView:
					ParseObject<UTexture>(Str,TEXT("TEXTURE="),*(UTexture **)&Viewport->MiscRes,ANY_PACKAGE); 
					if( !Viewport->MiscRes )
						Viewport->MiscRes = Viewport->Actor->Level->DefaultTexture;
					break;
				case REN_MeshView:
					if( !Temp )
					{
						Viewport->Actor->Location = FVector(100.0,100.0,+60.0);
						Viewport->Actor->ViewRotation.Yaw=0x6000;
					}
					ParseObject<UMesh>( Str, TEXT("MESH="), *(UMesh**)&Viewport->MiscRes, ANY_PACKAGE ); 
					break;
				case REN_TexBrowser:
					ParseObject<UPackage>(Str,TEXT("PACKAGE="),*(UPackage**)&Viewport->MiscRes,NULL);
					break;
			}
			if( DoOpen )
			{
				INT OpenX = INDEX_NONE;
				INT OpenY = INDEX_NONE;
				Parse( Str, TEXT("X="), OpenX );
				Parse( Str, TEXT("Y="), OpenY );
				Viewport->OpenWindow( hWndParent, 0, NewX, NewY, OpenX, OpenY );
				if( appStricmp(Viewport->GetName(),TEXT("U2Viewport0"))==0 
						|| appStricmp(Viewport->GetName(),TEXT("Standard3V"))==0 )
					ResetSound();
			}
			else Draw( Viewport, 1 );
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("HIDESTANDARD")) )
		{
			Client->ShowViewportWindows( SHOW_StandardView, 0 );
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("CLOSE")) )
		{
			if( ParseCommand(&Str,TEXT("ALL")) )
			{
				for( INT i=Client->Viewports.Num()-1; i>=0; i-- )
					delete Client->Viewports(i);
			}
			else if( ParseCommand(&Str,TEXT("FREE")) )
			{
				for( INT i=Client->Viewports.Num()-1; i>=0; i-- )
					if( appStrstr( Client->Viewports(i)->GetName(), TEXT("STANDARD") )==0 )
						delete Client->Viewports(i);
			}
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("ALIGN") ) )
		{
			// select the named actor
			if( Parse( Str, TEXT("NAME="), TempStr, NAME_SIZE ) )
			{
				AActor* Actor = NULL;
				for( INT i=0; i<Level->Actors.Num(); i++ )
				{
					Actor = Level->Actors(i);
					if( Actor && appStricmp( Actor->GetName(), TempStr ) == 0 )
					{
						Actor->Modify();
						Actor->bSelected = 1;
						break;
					}
				}
			}

			FVector NewLocation;
			if( Parse( Str, TEXT("X="), NewLocation.X ) )
			{
				Parse( Str, TEXT("Y="), NewLocation.Y );
				Parse( Str, TEXT("Z="), NewLocation.Z );

				for( INT i = 0; i < Client->Viewports.Num(); i++ )
				{
					AActor* Camera = Client->Viewports(i)->Actor;
					Camera->Location = NewLocation;
				}
			}
			else
			{
				// find the first selected actor as the target for the viewport cameras
				AActor* Target = NULL;
				for( INT i = 0; i < Level->Actors.Num(); i++ )
				{
					if( Level->Actors(i) && Level->Actors(i)->bSelected )
					{
						Target = Level->Actors(i);
						break;
					}
				}
				// if no actor was selected, find the camera for the current viewport
				if( Target == NULL )
				{
					for( i = 0; i < Client->Viewports.Num(); i++ )
					{
						if( Client->Viewports(i)->Current )
						{
							Target = Client->Viewports(i)->Actor;
							break;
						}
					}
				}
				if( Target == NULL )
				{
					Ar.Log( TEXT("Can't find target (viewport or selected actor)") );
					return 0;
				}

				// move all viewport cameras to the target actor, offset if the target isn't a camera (PlayerPawn)
				for( i = 0; i < Client->Viewports.Num(); i++ )
				{
					AActor* Camera = Client->Viewports(i)->Actor;
					if( Target->IsA( APawn::StaticClass() ) )
						Camera->Location = Target->Location;
					else
						Camera->Location = Target->Location - Camera->Rotation.Vector() * 48;
					Camera->Rotation = Target->Rotation;
				}
			}
			Ar.Log( TEXT("Aligned camera on the current target.") );
			NoteSelectionChange( Level );
			RedrawLevel( Level );
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("SELECT") ) )
		{
			if( Parse( Str, TEXT("NAME="), TempStr,NAME_SIZE ) )
			{
				AActor* Actor = NULL;
				for( INT i=0; i<Level->Actors.Num(); i++ )
				{
					Actor = Level->Actors(i);
					if( Actor && appStrcmp( Actor->GetName(), TempStr ) == 0 )
					{
						Actor->Modify();
						Actor->bSelected = 1;
						break;
					}
				}
				if( Actor == NULL )
				{
					Ar.Log( TEXT("Can't find the specified name.") );
					return 0;
				}

				for( i = 0; i < Client->Viewports.Num(); i++ )
				{
					AActor* Camera = Client->Viewports(i)->Actor;
					Camera->Location = Actor->Location - Camera->Rotation.Vector() * 48;
				}
				Ar.Log( TEXT("Aligned camera on named object.") );
				NoteSelectionChange( Level );
				RedrawLevel( Level );
				return 1;
			}
			else return 0;
		}
		else return 0;
	}
	//------------------------------------------------------------------------------------
	// Level.
	//
	if( ParseCommand(&Str,TEXT("LEVEL")) )
	{
		if( ParseCommand(&Str,TEXT("REDRAW")) )
		{
			RedrawLevel(Level);
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("LINKS")) )
		{
			Results->Text.Empty();
			INT Internal=0,External=0;
			Results->Logf( TEXT("Level links:\r\n") );
			for( INT i=0; i<Level->Actors.Num(); i++ )
			{
				if( Cast<ATeleporter>(Level->Actors(i)) )
				{
					ATeleporter& Teleporter = *(ATeleporter *)Level->Actors(i);
					Results->Logf( TEXT("   %s\r\n"), Teleporter.URL );
					if( appStrchr(*Teleporter.URL,'//') )
						External++;
					else
						Internal++;
				}
			}
			Results->Logf( TEXT("End, %i internal link(s), %i external.\r\n"), Internal, External );
			return 1;
		}
		else if( ParseCommand(&Str,TEXT("VALIDATE")) )
		{
			// Validate the level.
			Results->Text.Empty();
			Results->Log( TEXT("Level validation:\r\n") );

			// Make sure it's not empty.
			if( Level->Model->Nodes.Num() == 0 )
			{
				Results->Log( TEXT("Error: Level is empty!\r\n") );
				return 1;
			}

			// Find playerstart.
			for( INT i=0; i<Level->Actors.Num(); i++ )
				if( Cast<APlayerStart>(Level->Actors(i)) )
					break;
			if( i == Level->Actors.Num() )
			{
				Results->Log( TEXT("Error: Missing PlayerStart actor!\r\n") );
				return 1;
			}

			// Make sure PlayerStarts are outside.
			for( i=0; i<Level->Actors.Num(); i++ )
			{
				if( Cast<APlayerStart>(Level->Actors(i)) )
				{
					FCheckResult Hit(0.0);
					if( !Level->Model->PointCheck( Hit, NULL, Level->Actors(i)->Location, FVector(0,0,0), 0 ) )
					{
						Results->Log( TEXT("Error: PlayerStart may not fit.\r\n") );
						return 1;
					}
				}
			}

			// Check scripts.
			if( GEditor && !GEditor->CheckScripts( GWarn, UObject::StaticClass(), *Results ) )
			{
				Results->Logf( TEXT("\r\nError: Scripts need to be rebuilt!\r\n") );
				return 1;
			}

			// Check level title.
			if( Level->GetLevelInfo()->Title==TEXT("") )
			{
				Results->Logf( TEXT("Error: Level is missing a title!") );
				return 1;
			}
			else if( Level->GetLevelInfo()->Title==TEXT("Untitled") )
			{
				Results->Logf( TEXT("Warning: Level is untitled\r\n") );
			}

			// Check actors.
			for( i=0; i<Level->Actors.Num(); i++ )
			{
				AActor* Actor = Level->Actors(i);
				if( Actor )
				{
					check(Actor->GetClass()!=NULL);
					check(Actor->GetStateFrame());
					check(Actor->GetStateFrame()->Object==Actor);
					check(Actor->Level!=NULL);
					check(Actor->GetLevel()!=NULL);
					check(Actor->GetLevel()==Level);
					check(Actor->GetLevel()->Actors(0)!=NULL);
					check(Actor->GetLevel()->Actors(0)==Actor->Level);
				}
			}

			// Success.
			Results->Logf( TEXT("Success: Level validation succeeded!\r\n") );
			return 1;
		}
		else
		{
			return 0;
		}
	}
	/*
	//------------------------------------------------------------------------------------
	// Terrain
	//
	else if( ParseCommand(&Str,TEXT("TERRAIN")) )
	{
		if( ParseCommand(&Str,TEXT("SOFTSELECT") ) )
		{
			FLOAT Radius;
			if( Parse( Str, TEXT("RADIUS="), Radius ) )
			{
				if( GEditor->Mode == EM_TerrainEdit )
				{		
					for( INT i=0;i<Level->Actors.Num();i++ )
					{
						AActor* A = Level->Actors(i);
						if( A && A->IsA(ATerrainInfo::StaticClass()) && A->bSelected )
							Cast<ATerrainInfo>(A)->SoftSelect( Radius );
					}
				}
			}
		}
		if( ParseCommand(&Str,TEXT("SOFTDESELECT") ) )
		{
			if( GEditor->Mode == EM_TerrainEdit )
			{		
				for( INT i=0;i<Level->Actors.Num();i++ )
				{
					AActor* A = Level->Actors(i);
					if( A && A->IsA(ATerrainInfo::StaticClass()) && A->bSelected )
						Cast<ATerrainInfo>(A)->SoftDeselect();
				}
			}
		}
		if( ParseCommand(&Str,TEXT("DESELECT") ) )
		{
			if( GEditor->Mode == EM_TerrainEdit )
			{		
				for( INT i=0;i<Level->Actors.Num();i++ )
				{
					AActor* A = Level->Actors(i);
					if( A && A->IsA(ATerrainInfo::StaticClass()) && A->bSelected )
						Cast<ATerrainInfo>(A)->SelectedVertices.Empty();
				}
			}
		}
		if( ParseCommand(&Str,TEXT("RESETMOVE") ) )
		{
			if( GEditor->Mode == EM_TerrainEdit )
			{		
				for( INT i=0;i<Level->Actors.Num();i++ )
				{
					AActor* A = Level->Actors(i);
					if( A && A->IsA(ATerrainInfo::StaticClass()) && A->bSelected )
						Cast<ATerrainInfo>(A)->ResetMove();
				}
			}
		}
		if( ParseCommand(&Str,TEXT("SHOWGRID") ) )
		{
			if( GEditor->Mode == EM_TerrainEdit )
			{		
				INT LayerMask;
				if( Parse( Str, TEXT("MASK="), LayerMask) )
				{
					for( INT i=0;i<Level->Actors.Num();i++ )
					{
						AActor* A = Level->Actors(i);
						if( A && A->IsA(ATerrainInfo::StaticClass()) && A->bSelected )
						{
							Cast<ATerrainInfo>(A)->ShowGrid = LayerMask;
						}
					}
				}
				else
				{
					LayerMask = 0xFF;
					INT Layer;
					if( Parse( Str, TEXT("LAYER="), Layer ) )
						LayerMask = 1<<Layer;

					for( INT i=0;i<Level->Actors.Num();i++ )
					{
						AActor* A = Level->Actors(i);
						if( A && A->IsA(ATerrainInfo::StaticClass()) && A->bSelected )
						{
							Cast<ATerrainInfo>(A)->ShowGrid ^= LayerMask;
						}
					}
				}
			}
		}
	
		return 1;
	}
	*/
	//------------------------------------------------------------------------------------
	// Other handlers.
	//
	else if( ParseCommand(&Str,TEXT("FIX")) )
	{
		for( INT i=0; i<Level->Actors.Num(); i++ )
			if( Level->Actors(i) )
				Level->Actors(i)->SoundRadius = Clamp(4*(INT)Level->Actors(i)->SoundRadius,0,255);
	}
	else if( ParseCommand(&Str,TEXT("MAYBEAUTOSAVE")) )
	{
		if( AutoSave && ++AutoSaveCount>=AutosaveTimeMinutes )
		{
			AutoSaveIndex = (AutoSaveIndex+1)%10;
			SaveConfig();
			TCHAR Cmd[256];
			appSprintf( Cmd, TEXT("MAP SAVE AUTOSAVE=1 FILE=%s..") PATH_SEPARATOR TEXT("Maps") PATH_SEPARATOR TEXT("Auto%i.%s"), appBaseDir(), AutoSaveIndex, *GMapExt );
			debugf( NAME_Log, TEXT("Autosaving '%s'"), Cmd );
			Exec( Cmd, Ar );
			AutoSaveCount=0;
		}
	}
	else if( ParseCommand(&Str,TEXT("HOOK")) )
	{
		return HookExec( Str, Ar );
	}
	else if( HookExec( Str, Ar ) )
	{
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("AUDIO")) )
	{
		if( ParseCommand(&Str,TEXT("PLAY")) )
		{
			UViewport* Viewport = NULL;
			for( INT vp = 0 ; vp < dED_MAX_VIEWPORTS && !Viewport ; vp++ )
			{
				Viewport = FindObject<UViewport>( ANY_PACKAGE, *(FString::Printf(TEXT("U2Viewport%d"), vp) ) );
				// We don't want orthographic viewports
				if( Viewport && Viewport->IsOrtho() )
					Viewport = NULL;
			}
			if( !Viewport ) Viewport = FindObject<UViewport>( ANY_PACKAGE, TEXT("Standard3V") );
			if( Viewport && Audio )
			{
				USound* Sound;
				if( ParseObject<USound>( Str, TEXT("NAME="), Sound, ANY_PACKAGE ) )
				{
					// Make sure the audio system has a valid viewport
					if( Audio->GetViewport() != Viewport )
					{
						GWarn->BeginSlowTask( TEXT("Setting up Galaxy viewport"), 1, 0 );
						Audio->SetViewport( Viewport );
						GWarn->EndSlowTask();
					}
					Audio->PlaySound( Viewport->Actor, 2*SLOT_Misc, Sound ? Sound : (USound*)-1, Viewport->Actor->Location, 1.0, 4096.0, 1.0, false );
				}
			}
			else Ar.Logf( TEXT("Can't find viewport for sound! Open a 2D viewport and try again.") );
			Processed = 1;
		}
	}
	else if( ParseCommand(&Str,TEXT("SETCURRENTCLASS")) )
	{
		ParseObject<UClass>( Str, TEXT("CLASS="), CurrentClass, ANY_PACKAGE );
		Ar.Logf( TEXT("CurrentClass=%s"), CurrentClass->GetName() );
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("MUSIC")) )
	{
		UViewport* Viewport=NULL;
		for( INT vp = 0 ; vp < dED_MAX_VIEWPORTS && !Viewport ; vp++ )
		{
			Viewport = FindObject<UViewport>( ANY_PACKAGE, *(FString::Printf(TEXT("U2Viewport%d"), vp) ) );
			// We don't want orthographic viewports
			if( Viewport && Viewport->IsOrtho() )
				Viewport = NULL;
		}
		if( !Viewport || !Audio )
		{
			Ar.Logf( TEXT("Can't find viewport for music") );
		}
		else if( ParseCommand(&Str,TEXT("PLAY")) )
		{
			// Make sure the audio system has a valid viewport
			if( Audio->GetViewport() != Viewport )
			{
				GWarn->BeginSlowTask( TEXT("Setting up Galaxy viewport"), 1, 0 );
				Audio->SetViewport( Viewport );
				GWarn->EndSlowTask();
			}

			UMusic* Music;
			if( ParseObject<UMusic>(Str,TEXT("NAME="),Music,ANY_PACKAGE) )
			{
				Viewport->Actor->Song        = Music;
				Viewport->Actor->SongSection = 0;
				Viewport->Actor->Transition  = MTRAN_Fade;
			}
		}
		Processed = 1;
	}
	else if( Level && Level->Exec(Stream,Ar) )
	{
		// The level handled it.
		Processed = 1;
	}
	else if( UEngine::Exec(Stream,Ar) )
	{
		// The engine handled it.
		Processed = 1;
	}
	else if( ParseCommand(&Str,TEXT("SELECTNAME")) )
	{
		FName FindName=NAME_None;
		Parse( Str, TEXT("NAME="), FindName );
		for( INT i=0; i<Level->Actors.Num(); i++ )
			if( Level->Actors(i) )
				Level->Actors(i)->bSelected = Level->Actors(i)->GetFName()==FindName;
		Processed = 1;
	}
	else if( ParseCommand(&Str,TEXT("DUMPINT")) )
	{
		while( *Str==' ' )
			Str++;
		UObject* Pkg = LoadPackage( NULL, Str, LOAD_AllowDll );
		if( Pkg )
		{
			TCHAR Tmp[256],Loc[256];
			appStrcpy( Tmp, Str );
			if( appStrchr(Tmp,'.') )
				*appStrchr(Tmp,'.') = 0;
			appStrcat( Tmp, TEXT(".int") );
			appStrcpy( Loc, appBaseDir() );
			appStrcat( Loc, Tmp );
			for( FObjectIterator It; It; ++It )
			{
				if( It->IsIn(Pkg) )
				{
					TCHAR Temp[1024], TempKey[1024], TempValue[1024], *Value;
					UClass* Class = Cast<UClass>( *It );
					if( Class )
					{
						// Generate localizable class defaults.
						for( TFieldIterator<UProperty> ItP(Class); ItP; ++ItP )
						{
							if(!(ItP->PropertyFlags & CPF_Localized))
								continue;
							for( INT i=0; i<ItP->ArrayDim; i++ )
							{
                                if( ItP->ExportText( i, Value=Temp, &Class->Defaults[CPD_Normal](0), ItP->GetOuter()!=Class ? &Class->GetSuperClass()->Defaults[CPD_Normal](0) : NULL, 0 ) )
								{
									const TCHAR* Key = ItP->GetName();
									if( ItP->ArrayDim!=1 )
									{
										appSprintf( TempKey, TEXT("%s[%i]"), ItP->GetName(), i );
										Key = TempKey;
									}
									if( Value[0]==' ' || (*Value&&Value[appStrlen(TempValue)-1]==' ') )
									{
										appSprintf( TempValue, TEXT("\"%s\""), Value );
										Value = TempValue;
									}
									GConfig->SetString( Class->GetName(), Key, Value, Loc );
								}
							}
						}
					}
					else
					{
						// Generate localizable object properties.
						for( TFieldIterator<UProperty> ItP(It->GetClass()); ItP; ++ItP )
						{
							if(!(ItP->PropertyFlags & CPF_Localized))
								continue;
							for( INT i=0; i<ItP->ArrayDim; i++ )
							{
								if( ItP->ExportText( i, Value=Temp, (BYTE*)*It, &It->GetClass()->Defaults[CPD_Normal](0), 0 ) )
								{
									const TCHAR* Key = ItP->GetName();
									if( ItP->ArrayDim!=1 )
									{
										appSprintf( TempKey, TEXT("%s[%i]"), ItP->GetName(), i );
										Key = TempKey;
									}
									if( Value[0]==' ' || (*Value&&Value[appStrlen(TempValue)-1]==' ') )
									{
										appSprintf( TempValue, TEXT("\"%s\""), Value );
										Value = TempValue;
									}
									GConfig->SetString( It->GetName(), Key, Value, Loc );
								}
							}
						}
					}
				}
			}
			GConfig->Flush( 0 );
			Ar.Logf( TEXT("Generated %s"), Loc );
		}
		else Ar.Logf( TEXT("LoadPackage failed") );
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("JUMPTO")) )
	{
		TCHAR A[32], B[32], C[32];
		ParseToken( Str, A, ARRAY_COUNT(A), 0 );
		ParseToken( Str, B, ARRAY_COUNT(B), 0 );
		ParseToken( Str, C, ARRAY_COUNT(C), 0 );
		for( INT i=0; i<Client->Viewports.Num(); i++ )
			Client->Viewports(i)->Actor->Location = FVector(appAtoi(A),appAtoi(B),appAtoi(C));
		return 1;
	}
	else if( ParseCommand(&Str,TEXT("LSTAT")) )
	{
		TArray<FVector> Sizes;
		for( INT i=0; i<Level->Model->LightMap.Num(); i++ )
			new(Sizes)FVector(Level->Model->LightMap(i).UClamp,Level->Model->LightMap(i).VClamp,0);
		/*for( i=0; i<Sizes.Num(); i++ )
			for( INT j=0; j<i; j++ )
				if
				(	(Sizes(j).X>Sizes(i).X)
				||	(Sizes(j).X==Sizes(i).X && Sizes(j).Y>Sizes(i).Y) )
					Exchange( Sizes(i), Sizes(j) );*/
		debugf( TEXT("LightMap Sizes: ") );
		INT DX[17], DY[17], Size=0, Under32=0, Under64=0;
		for( i=0; i<9; i++ )
			DX[i]=DY[i]=0;
		for( i=0; i<Sizes.Num(); i++ )
		{
			DX[appCeilLogTwo(Sizes(i).X)]++;
			DY[appCeilLogTwo(Sizes(i).Y)]++;
			Size += Sizes(i).X*Sizes(i).Y;
			if( Sizes(i).X<=32 && Sizes(i).Y<=32 )
				Under32++;
			if( Sizes(i).X<=64 && Sizes(i).Y<=64 )
				Under64++;
		}
		debugf( TEXT("Size=%iK elements"), Size/1024);
		debugf( TEXT("Under32=%f%% Under64=%f%%"), 100.0*Under32/Sizes.Num(), 100.0*Under64/Sizes.Num() );
		for( i=0; i<9; i++ )
		{
			debugf
			(
				TEXT("Distribution (%i..%i) X=%f%% Y=%f%%"),
				(1<<i)/2+1,
				(1<<i),
				100.0*DX[i]/Sizes.Num(),
				100.0*DY[i]/Sizes.Num()
			);
		}
		debugf( TEXT("Collision hulls=%i"), Level->Model->LeafHulls.Num() );
		return 1;
	}
	//------------------------------------------------------------------------------------
	// Brandon's custom handlers.
	//
	else if ( ParseCommand( &Str, TEXT("MASTERBROWSER") ) )
	{
		if ( ParseCommand( &Str, TEXT("TOGGLE") ) )
			EdCallback( EDC_MasterBrowser, 0 );
		return 1;
	}
	return Processed;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
