/*=============================================================================
	UnTerrain.cpp: Unreal objects
	Copyright 1997-2000 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Jack Porter
=============================================================================*/

#include "EnginePrivate.h"

#define TERRAINSECTORSIZE 16
/*------------------------------------------------------------------------------
    UTerrainSector Implementation.
------------------------------------------------------------------------------*/

UTerrainSector::UTerrainSector( ATerrainInfo* InInfo, INT InOffsetX, INT InOffsetY, INT InQuadsX, INT InQuadsY )
:	Info		( InInfo )
,	OffsetX		( InOffsetX )
,	OffsetY		( InOffsetY )
,	QuadsX		( InQuadsX )
,	QuadsY		( InQuadsY )
{
	guard(UTerrainSector::UTerrainSector);
	VertexBuffer = new(this) UVertexBuffer;
	unguard;
}

void UTerrainSector::Serialize(FArchive& Ar)
{
	guard(UTerrainSector::Serialize);
	Super::Serialize(Ar);
	Ar	<< Info 
		<< VertexBuffer 
		<< QuadsX << QuadsY
		<< OffsetX << OffsetY
		<< Layers;

	for( INT i=0;i<ARRAY_COUNT(Bounds);i++ )
		Ar << Bounds[i];

	if( Ar.Ver()>=70 )
		Ar << LightInfos;

	unguard;
}

void UTerrainSector::UpdateVertexBuffer()
{
	guard(UTerrainSector::UpdateVertexBuffer);
	if( !Info->Heightmap.Num() )
		return;

	debugf(TEXT("Recreating vertex and index buffers"));

	// Create index buffers if necessary.
	for( INT i=0;i<ARRAY_COUNT(Info->Layers);i++ )
	{
		if( !Info->Layers[i].AlphaMap || !Info->Layers[i].Texture )
		{
			while( i < Layers.Num() )
				Layers.Remove( Layers.Num()-1 );
			break;
		}
		if( i >= Layers.Num() )
			Layers.AddZeroed();

		FTextureInfo TexInfo;
		Info->Layers[i].AlphaMap->Lock( TexInfo, 0.0, 0, NULL );
		Info->Layers[i].AlphaMap->Unlock( TexInfo );

		if( Info->Layers[i].AlphaMap->USize != Info->HeightmapX ||Info->Layers[i].AlphaMap->VSize != Info->HeightmapY )
			debugf(TEXT("Warning: alpha and heightmap are different sizes for layer %d"), i);

		UBOOL LayerEmpty = 1;
		UBOOL LayerSolid = 1;
	
		for( INT y=0;y<=QuadsY;y++ )
		{
			for( INT x=0;x<=QuadsX;x++ )
			{				
				BYTE A = Info->GetLayerAlpha( (x+OffsetX), (y+OffsetY), i );
				if( A != 255 )
					LayerSolid = 0;
				if( A != 0 )
					LayerEmpty = 0;
				if( !LayerEmpty && !LayerSolid )
					goto DoneAlphaCheck;
			}
		}
DoneAlphaCheck:
		if( LayerSolid )
		{
			if( Layers.Num() )
				debugf(TEXT("Layer %d is solid: occluding lower layers"), i );
			for( INT j=0;j<i;j++)
				Layers(j).Visible = 0;
		}
		Layers(i).Visible = !LayerEmpty;
		if( LayerEmpty )
			debugf(TEXT("Layer %d is empty"), i );
	}

	for( i=Layers.Num()-1;i>=0;i-- )
	{
		// If layer is visible, build index buffer for it.
		if( Layers(i).Visible )
		{
			if( !Layers(i).IndexBuffer )
				Layers(i).IndexBuffer = new(this) UIndexBuffer;
			else
				Layers(i).IndexBuffer->Indices.Empty();
			Layers(i).IndexBuffer->Revision++;
			Layers(i).NumTriangles = 0;

			UBOOL ContStrip = 0;
			INT PrevIndex = 0;
			UBOOL FirstTri = 1;
			for( INT y=0;y<QuadsY;y++ )
			{
				for( INT x=0;x<QuadsX;x++ )
				{				
					INT V1 = GetLocalVertex( x, y );
					INT V2 = GetLocalVertex( x+1, y );
					INT V3 = GetLocalVertex( x, y+1 );
					INT V4 = GetLocalVertex( x+1, y+1 );
					BYTE A1 = Info->GetLayerAlpha( (x+OffsetX), (y+OffsetY), i );
					BYTE A2 = Info->GetLayerAlpha( (x+OffsetX)+1, (y+OffsetY), i );
					BYTE A3 = Info->GetLayerAlpha( (x+OffsetX), (y+OffsetY)+1, i );
					BYTE A4 = Info->GetLayerAlpha( (x+OffsetX)+1, (y+OffsetY)+1, i );

					// check for totally occluding layers above us
					UBOOL SolidAbove = 0;
					for( INT j=i+1;j<Layers.Num();j++ )
					{
						if( Layers(j).Visible )
						{
							if( 
								Info->GetLayerAlpha( (x+OffsetX), (y+OffsetY), j ) == 255 &&
								Info->GetLayerAlpha( (x+OffsetX)+1, (y+OffsetY), j ) == 255 &&
								Info->GetLayerAlpha( (x+OffsetX), (y+OffsetY)+1, j ) == 255 && 
								Info->GetLayerAlpha( (x+OffsetX)+1, (y+OffsetY)+1, j ) == 255
							  )
							{
								SolidAbove = 1;
								break;
							}
						}
					}

					// triangle 1
					if( (A3 || A1 || A4) && !SolidAbove )
					{
						if( ContStrip )
						{
							// continuous stripping, just add the vertex.
							Layers(i).IndexBuffer->Indices.AddItem(V4);
							Layers(i).NumTriangles++;
							PrevIndex = V4;
						}
						else
						{
							if( FirstTri )
							{
								FirstTri = 0;
								Layers(i).IndexBuffer->Indices.AddItem(V3);
								Layers(i).IndexBuffer->Indices.AddItem(V3);
								Layers(i).IndexBuffer->Indices.AddItem(V1);
								Layers(i).NumTriangles++;
							}
							else
							{
								// add triangles get us to location.
								Layers(i).NumTriangles+=4;
								Layers(i).IndexBuffer->Indices.AddItem(PrevIndex);
								Layers(i).IndexBuffer->Indices.AddItem(V3);
								Layers(i).IndexBuffer->Indices.AddItem(V3);
								// backface culling
								if( !(Layers(i).NumTriangles&1) )
								{
									Layers(i).IndexBuffer->Indices.AddItem(V3);
									Layers(i).NumTriangles++;
								}
								Layers(i).IndexBuffer->Indices.AddItem(V1);
							}
							Layers(i).IndexBuffer->Indices.AddItem(V4);
							Layers(i).NumTriangles++;
							PrevIndex = V4;
							ContStrip = 1;
						}
					}
					else
						ContStrip = 0;

					// triangle 2
					if( (A1 || A4 || A2) && !SolidAbove )
					{
						if( ContStrip )
						{
							// continuous stripping, just add the vertex.
							Layers(i).IndexBuffer->Indices.AddItem(V2);
							Layers(i).NumTriangles++;
							PrevIndex = V2;
						}
						else
						{
							if( FirstTri )
							{
								FirstTri = 0;
								Layers(i).IndexBuffer->Indices.AddItem(V1);
								Layers(i).IndexBuffer->Indices.AddItem(V4);
							}
							else
							{
								// add triangles get us to location.
								Layers(i).NumTriangles+=4;
								Layers(i).IndexBuffer->Indices.AddItem(PrevIndex);
								Layers(i).IndexBuffer->Indices.AddItem(V1);
								Layers(i).IndexBuffer->Indices.AddItem(V1);
								// backface culling
								if( Layers(i).NumTriangles&1 )
								{
									Layers(i).IndexBuffer->Indices.AddItem(V1);
									Layers(i).NumTriangles++;
								}
								Layers(i).IndexBuffer->Indices.AddItem(V4);
							}

							Layers(i).IndexBuffer->Indices.AddItem(V2);
							Layers(i).NumTriangles++;
							PrevIndex = V2;
							ContStrip = 1;
						}
					}
					else
						ContStrip = 0;
				}
				ContStrip = 0;
			}
			Layers(i).NumIndices = Layers(i).IndexBuffer->Indices.Num();
			if( !Layers(i).NumIndices )
			{
				Layers(i).IndexBuffer = NULL;
				Layers(i).Visible = 0;
			}
		}
		else
			Layers(i).IndexBuffer = NULL;
		debugf( TEXT("Layer %d: Triangles: %d Indicies: %d"), i, Layers(i).NumTriangles, Layers(i).NumIndices );
	}

	VertexBuffer->Vertices.Empty();
	VertexBuffer->Vertices.AddZeroed( (QuadsX+1) * (QuadsY+1) );

	// Add to vertex buffer
	INT MaxZ = 0;
	INT MinZ = 65536;

	INT v = 0;
	for( INT y=0;y<=QuadsY;y++ )
	{
		for( INT x=0;x<=QuadsX;x++ )
		{
			INT GlobalVertex = GetGlobalVertex(x,y);
			INT Z = Info->Heightmap(GlobalVertex);
			if( Z < MinZ )
				MinZ = Z;
			if( Z > MaxZ )
				MaxZ = Z;
			FUntransformedVertex& Vd = VertexBuffer->Vertices(v++);
			Vd.Position = Info->Vertices( GlobalVertex );
			Vd.Color = GET_COLOR_DWORD(FColor(Info->Lighting( GlobalVertex )));
			Vd.Normal = Info->Normals( GlobalVertex ).Normal1; //!!
			Vd.U = (x+OffsetX);
			Vd.V = (y+OffsetY);
			Vd.U2 = ((FLOAT)(x+OffsetX) + 0.5f) / (FLOAT)Info->HeightmapX;
			Vd.V2 = ((FLOAT)(y+OffsetY) + 0.5f) / (FLOAT)Info->HeightmapY;
		}
	}
	VertexBuffer->Revision++;

	// Calculate bounding box
	Bounds[0] = Info->HeightmapToWorld( FVector(OffsetX,OffsetY,MinZ) );
	Bounds[1] = Info->HeightmapToWorld( FVector(OffsetX+QuadsX,OffsetY,MinZ) );
	Bounds[2] = Info->HeightmapToWorld( FVector(OffsetX,OffsetY+QuadsY,MinZ) );
	Bounds[3] = Info->HeightmapToWorld( FVector(OffsetX+QuadsX,OffsetY+QuadsY,MinZ));
	Bounds[4] = Info->HeightmapToWorld( FVector(OffsetX,OffsetY,MaxZ) );
	Bounds[5] = Info->HeightmapToWorld( FVector(OffsetX+QuadsX,OffsetY,MaxZ) );
	Bounds[6] = Info->HeightmapToWorld( FVector(OffsetX,OffsetY+QuadsY,MaxZ) );
	Bounds[7] = Info->HeightmapToWorld( FVector(OffsetX+QuadsX,OffsetY+QuadsY,MaxZ) );

	unguard;
}

inline INT UTerrainSector::GetGlobalVertex( INT x, INT y )
{
	return (x+OffsetX)+(y+OffsetY)*Info->HeightmapX;
}

//
// UPrimitive interface
//
UBOOL UTerrainSector::LineCheck( FCheckResult &Result,AActor* Owner,FVector End,FVector Start,FVector Extent,DWORD ExtraNodeFlags )
{
	guard(UTerrainSector::LineCheck);
	return Info->LineCheck( Result, End, Start, Extent );
	unguard;
}

FBox UTerrainSector::GetRenderBoundingBox( const AActor* Owner, UBOOL Exact )
{
	guard(UTerrainSector::GetRenderBoundingBox);
	FBox B(0);
	for( INT i=0;i<Info->Sectors.Num();i++ )
	{
		B += Info->Sectors(i)->Bounds[0];
		B += Info->Sectors(i)->Bounds[1];
		B += Info->Sectors(i)->Bounds[2];
		B += Info->Sectors(i)->Bounds[3];
		B += Info->Sectors(i)->Bounds[4];
		B += Info->Sectors(i)->Bounds[5];
		B += Info->Sectors(i)->Bounds[6];
		B += Info->Sectors(i)->Bounds[7];
	}
	return B;		
	unguard;
}

void UTerrainSector::Raytrace( FRaytracerInterface* Raytracer,AActor* Owner )
{
	guard(UTerrainSector::Raytrace);

	LightInfos.Empty();

	// Propagate raytrace request to all the other terrain sectors.
	if( Info->Sectors(0) == this )
	{
		debugf(TEXT("Raytracing Terrain"));
		for( INT i=1;i<Info->Sectors.Num();i++ )
		{
			GWarn->StatusUpdatef(i,Info->Sectors.Num(),TEXT("Raytracing Terrain..."));
			Info->Sectors(i)->Raytrace( Raytracer, Owner );
		}
	}

	// Setup LightInfos
	INT		NumLights = Raytracer->GetNumLights();
	for( INT LightIndex=0; LightIndex<NumLights; LightIndex++ )
	{
		FTerrainSectorLightInfo*	LightInfo = new(LightInfos) FTerrainSectorLightInfo(Raytracer->GetLightActor(LightIndex));
		LightInfo->VisibilityBitmap.AddZeroed((VertexBuffer->Vertices.Num() + 7) / 8);
	}
	
	INT		BitmapIndex = 0;
	BYTE	BitMask = 1;
	debugf( TEXT("NumLights is %d"), NumLights );
	for(INT Index = 0;Index < VertexBuffer->Vertices.Num();Index++)
	{
		FVector	SamplePoint = VertexBuffer->Vertices(Index).Position,
				SampleNormal = VertexBuffer->Vertices(Index).Normal;

		SamplePoint += SampleNormal;
		for(LightIndex = 0;LightIndex < NumLights;LightIndex++)
		{
			AActor* LightActor = LightInfos(LightIndex).LightActor;
			FLOAT WorldLightRadiusSquared = LightActor->WorldLightRadius();
			WorldLightRadiusSquared *= WorldLightRadiusSquared;

			if(
				(LightActor->Location - SamplePoint).SizeSquared() < WorldLightRadiusSquared &&
				(SampleNormal | (LightActor->Location - SamplePoint)) > 0.0 && 
				Raytracer->Raytrace(SamplePoint,LightIndex,0)
			  )
				LightInfos(LightIndex).VisibilityBitmap(BitmapIndex) |= BitMask;
		}
		BitMask <<= 1;
		if(!BitMask)
		{
			BitmapIndex++;
			BitMask = 1;
		}
	}

	for( INT i=0;i<LightInfos.Num();i++ )
	{
		for( INT j=0;j<LightInfos(i).VisibilityBitmap.Num(); j++ )
			if( LightInfos(i).VisibilityBitmap(j) )
				goto LightVisible;

		// Light is not visible to this sector, remove.
		LightInfos(i).VisibilityBitmap.Empty();
		LightInfos.Remove(i);
		i--;
LightVisible:
		;
	}

	StaticLight(1);

	unguard;
}

//!!move this somewhere better!
static FColor LightTerrainVertex( FVector SamplePoint, FVector SampleNormal, AActor* LightActor )
{
	// Diffuse lighting.
	FVector	LightVector		= LightActor->Location - SamplePoint;
	FLOAT	LightSquared	= LightVector.SizeSquared();
	FLOAT	LightSize		= appSqrt( LightSquared );
	FLOAT	G				= Square(1.0 + (LightVector | SampleNormal) / LightSize) - 1.5;
	FLOAT	RRadius			= 1.0/Max((FLOAT)1.0,LightActor->WorldLightRadius());
	FLOAT	Brightness      = LightActor->LightBrightness/255.f;
	FPlane	FloatColor		= FGetHSV( LightActor->LightHue, LightActor->LightSaturation, 255 ) * Brightness * LightActor->Level->Brightness;

	if(G < 0.0)
		G = 0.0;
	else
	{
		// Radial falloff.
		G *= 1.0 - LightSize * RRadius;
		G *= 255.0f;
	}

	// Update result color.
	if(G > 0.0)
		return FColor((BYTE) Min<INT>(FloatColor.Z * G,255),(BYTE) Min<INT>(FloatColor.Y * G,255),(BYTE) Min<INT>(FloatColor.X * G,255),255);
	else
		return FColor(0,0,0,0);
}

void UTerrainSector::StaticLight( UBOOL Force )
{
	if( !Force )
	{
		UBOOL TerrainLightingChanged = 0;
		for( INT light=0; light<LightInfos.Num();light++ )
		{
			if( LightInfos(light).LightActor->bDynamicLight )
			{
				TerrainLightingChanged = 1;
				break;
			}
		}

		if( !TerrainLightingChanged )
			return;
	}

	TArray<FColor>	VertexLight;
	VertexLight.Add(VertexBuffer->Vertices.Num());

	//!! FIXME calculate sunlight.
	for( INT y=0;y<=QuadsY;y++ )
		for( INT x=0;x<=QuadsX;x++ )
			VertexLight( x + y*(QuadsX+1) ) = Info->Lighting( GetGlobalVertex(x,y) );

	for( INT InfoIndex=0; InfoIndex<LightInfos.Num();InfoIndex++ )
	{
		TArray<BYTE>&	VisibilityBitmap = LightInfos(InfoIndex).VisibilityBitmap;
		INT				BitmapIndex = 0;
		BYTE			BitMask = 1;

		for(INT VertexIndex = 0;VertexIndex < VertexBuffer->Vertices.Num();VertexIndex++)
		{
			FUntransformedVertex&	V = VertexBuffer->Vertices(VertexIndex);

			if(VisibilityBitmap(BitmapIndex) & BitMask)
			{
				FColor Color = LightTerrainVertex(V.Position, V.Normal, LightInfos(InfoIndex).LightActor);
				VertexLight(VertexIndex).R = Min(VertexLight(VertexIndex).R + Color.R,255);
				VertexLight(VertexIndex).G = Min(VertexLight(VertexIndex).G + Color.G,255);
				VertexLight(VertexIndex).B = Min(VertexLight(VertexIndex).B + Color.B,255);
			}

			BitMask <<= 1;

			if(!BitMask)
			{
				BitmapIndex++;
				BitMask = 1;
			}
		}
	}
	for(INT VertexIndex = 0;VertexIndex < VertexBuffer->Vertices.Num();VertexIndex++)
		VertexBuffer->Vertices(VertexIndex).Color = GET_COLOR_DWORD(VertexLight(VertexIndex));
	VertexBuffer->Revision++;
}

IMPLEMENT_CLASS(UTerrainSector);

/*------------------------------------------------------------------------------
    ATerrainInfo Implementation.
------------------------------------------------------------------------------*/

inline INT ATerrainInfo::GetGlobalVertex( INT x, INT y )
{
	return x + y * HeightmapX;
}
ATerrainInfo::ATerrainInfo()
{
	guard(ATerrainInfo::ATerrainInfo);
	CalcCoords();
	unguard;
}
void ATerrainInfo::PostEditChange()
{
	guard(ATerrainInfo::PostEditChange);
	Super::PostEditChange();
	Level->XLevel->UpdateTerrainArrays();
	SetupSectors();
	CalcCoords();
	Update(0.f);
	unguard;
}
void ATerrainInfo::Serialize(FArchive& Ar)
{
	guard(ATerrainInfo::Serialize);
	Super::Serialize(Ar);

	Ar	<< Sectors
		<< Vertices
		<< SectorsX << SectorsY
		<< Normals
		<< Lighting
		<< ToWorld
		<< ToHeightmap
		<< Heightmap
		<< HeightmapX << HeightmapY;

	// Stuff not saved to disk
	if( !Ar.IsSaving() && !Ar.IsLoading() )
		Ar	<< DetailVertexBuffer
			<< SelectedVertices
			<< ShowGrid
			<< OldTerrainMap;

	// Set OldTerrainMap on load
	if( Ar.IsLoading() )
		OldTerrainMap = TerrainMap;

	unguard;
}

void ATerrainInfo::CalcCoords()
{
	ToWorld = FCoords(	FVector( -Location.X/TerrainScale.X, -Location.Y/TerrainScale.Y, -256.f*Location.Z/TerrainScale.Z),
						FVector( TerrainScale.X,0,0), FVector(0,TerrainScale.Y,0), FVector(0,0,TerrainScale.Z/256.f) );
	if( Heightmap.Num() )
		ToWorld /= FVector( HeightmapX/2, HeightmapY/2, 32767 );

	ToHeightmap = ToWorld.Inverse();
}

inline BYTE ATerrainInfo::GetLayerAlpha( INT x, INT y, INT Layer )
{
	x = x * Layers[Layer].AlphaMap->USize / HeightmapX;
	y = y * Layers[Layer].AlphaMap->VSize / HeightmapY;
	return Layers[Layer].AlphaMap->Palette->Colors(Layers[Layer].AlphaMap->Mips(0).DataArray( x + y*Layers[Layer].AlphaMap->USize )).R;
}

inline void ATerrainInfo::SetLayerAlpha( INT x, INT y, INT Layer, BYTE Alpha )
{
	x = x * Layers[Layer].AlphaMap->USize / HeightmapX;
	y = y * Layers[Layer].AlphaMap->VSize / HeightmapY;
	Layers[Layer].AlphaMap->Mips(0).DataArray( x + y*Layers[Layer].AlphaMap->USize ) = Alpha;
}

void ATerrainInfo::CalcVertices( FLOAT Time, INT StartX, INT StartY, INT EndX, INT EndY )
{
	guard(ATerrainInfo::CalcVertices);

	if( !Heightmap.Num() )
		return;

	if( Vertices.Num() < HeightmapX*HeightmapY )
		Vertices.Add( HeightmapX*HeightmapY - Vertices.Num() );
	if( Normals.Num() < HeightmapX*HeightmapY )
		Normals.Add( HeightmapX*HeightmapY - Normals.Num() );
	if( Lighting.Num() < HeightmapX*HeightmapY )
		Lighting.Add( HeightmapX*HeightmapY - Lighting.Num() );
	
	for( INT y=StartY; y<EndY; y++ )
	{
		for( INT x=StartX; x<EndX; x++ )
		{
			Vertices(GetGlobalVertex(x, y)) = HeightmapToWorld( FVector(x, y, Heightmap(GetGlobalVertex(x, y))) );

			if( x>1 && y>1 )
			{
				Normals(GetGlobalVertex(x-1, y-1)).Normal1 = FPlane( Vertices(GetGlobalVertex(x-1, y-1)), Vertices(GetGlobalVertex(x, y-1)), Vertices(GetGlobalVertex(x, y)) );
				Normals(GetGlobalVertex(x-1, y-1)).Normal2 = FPlane( Vertices(GetGlobalVertex(x-1, y-1)), Vertices(GetGlobalVertex(x, y)), Vertices(GetGlobalVertex(x-1, y)) );
			}
		}
	}

	FVector L = TerrainLightDir.Vector();
	FPlane LightColor = FGetHSV( TerrainLightHue, TerrainLightSaturation, TerrainLightBrightness );
	INT Count;
	FLOAT Dot;
	INT MaxLayer = 0;
	for( INT Layer=0;Layer<32&&Layers[Layer].Texture&&Layers[Layer].AlphaMap;Layer++ )
	{
		Layers[Layer].AlphaMap->Mips(0).DataArray.Load();
		MaxLayer++;
	}

	for( y=Max<INT>(StartY-1,0); y<Min<INT>(EndY+1,HeightmapY); y++ )
	{
		for( INT x=Max<INT>(StartX-1,0); x<Min<INT>(EndX+1,HeightmapX); x++ )
		{
			Count = 0;
			Dot = 0;

			if( x<HeightmapX-1 && y<HeightmapY-1 )
			{
				Dot += Normals(GetGlobalVertex(x,y)).Normal1 | L;
				Dot += Normals(GetGlobalVertex(x,y)).Normal2 | L;
				Count += 2;
			}
			if( x>0 && y<HeightmapY-1 )
			{
				Dot += Normals(GetGlobalVertex(x-1,y)).Normal1 | L;
				Dot += Normals(GetGlobalVertex(x-1,y)).Normal2 | L;
				Count += 2;
			}

			if( y>0 && x<HeightmapX-1 )
			{
				Dot += Normals(GetGlobalVertex(x,y-1)).Normal1 | L;
				Dot += Normals(GetGlobalVertex(x,y-1)).Normal2 | L;
				Count += 2;
			}

			if( x>0 && y>0 )
			{
				Dot += Normals(GetGlobalVertex(x-1,y-1)).Normal1 | L;
				Dot += Normals(GetGlobalVertex(x-1,y-1)).Normal2 | L;
				Count += 2;
			}
			if( Count )
				Dot = Dot / Count;

			Dot = Clamp<FLOAT>(Dot, 0.2f, 1);
			Lighting(GetGlobalVertex(x,y)) = FPlane( Dot*LightColor.X, Dot*LightColor.Y, Dot*LightColor.Z, 1);
		}
	}
	
	unguard;
}

void ATerrainInfo::SetupSectors()
{
	guard(ATerrainInfo::SetupSectors);

	if( TerrainMap != OldTerrainMap )
	{
		if( TerrainMap )
		{
			FTextureInfo TexInfo;
			TerrainMap->Lock( TexInfo, 0.0, 0, NULL );
			HeightmapX = TerrainMap->USize;
			HeightmapY = TerrainMap->VSize;

			Heightmap.Empty();
			Heightmap.Add(HeightmapX*HeightmapY);

			for( INT i=0;i<HeightmapX*HeightmapY;i++ )
				Heightmap(i) = 256*TerrainMap->Mips(0).DataArray(i);
			
			TerrainMap->Unlock( TexInfo );
		}
		else
		{
			Heightmap.Empty();
			HeightmapX = 0;
			HeightmapY = 0;
		}
		OldTerrainMap = TerrainMap;
	}

	if( Heightmap.Num() )
	{
		SectorsX = HeightmapX / TERRAINSECTORSIZE;
		SectorsY = HeightmapY / TERRAINSECTORSIZE;
	}
	else
		SectorsX = SectorsY = 0;

	if( Sectors.Num() == SectorsX*SectorsY )
		return;
	Sectors.Empty();

	for( INT y=0;y<SectorsY;y++ )
		for( INT x=0;x<SectorsX;x++ )
			Sectors.AddItem( new(this) UTerrainSector	(	this, 
															x*TERRAINSECTORSIZE, y*TERRAINSECTORSIZE,
															x<SectorsX-1?TERRAINSECTORSIZE:TERRAINSECTORSIZE-1,
															y<SectorsY-1?TERRAINSECTORSIZE:TERRAINSECTORSIZE-1
														) );
	unguard;
}

void ATerrainInfo::Update( FLOAT Time, INT StartX, INT StartY, INT EndX, INT EndY )
{
	guard(ATerrainInfo::Update);

	if( EndX==0 )
		EndX = HeightmapX;
	if( EndY==0 )
		EndY = HeightmapY;

	CalcVertices(Time, StartX, StartY, EndX, EndY );
	UpdateVertexBuffers( StartX, StartY, EndX, EndY );
	unguard;	
}

void ATerrainInfo::UpdateVertexBuffers( INT StartX, INT StartY, INT EndX, INT EndY )
{
	guard(ATerrainInfo::UpdateVertexBuffers);

	//!! make this faster
	for( INT i=0;i<Sectors.Num();i++ )
	{
		if( 
			Sectors(i)->OffsetX > EndX ||
			Sectors(i)->OffsetY > EndY ||
			Sectors(i)->OffsetX+Sectors(i)->QuadsX < StartX ||
			Sectors(i)->OffsetY+Sectors(i)->QuadsY < StartY 
		  )
			continue;

		Sectors(i)->UpdateVertexBuffer();
	}

	unguard;
}

/*------------------------------------------------------------------------------
    Terrain	Collision
------------------------------------------------------------------------------*/

UBOOL ATerrainInfo::LineCheckWithQuad( INT X, INT Y, FCheckResult &Result, FVector End, FVector Start, FVector Extent )
{
	guard(ATerrainInfo::LineCheckWithQuad);
	UBOOL ret = 0;

	INT v1 = GetGlobalVertex(X,Y);
	INT v2 = v1+1;
	INT v3 = GetGlobalVertex(X+1,Y+1);
	INT v4 = v3-1;

	Extent = 1.1f*Extent;
	FVector V1 = Vertices(v1) - FVector( 0, 0, -Extent.Z );
	FVector V2 = Vertices(v2) - FVector( 0, 0, -Extent.Z );
	FVector V3 = Vertices(v3) - FVector( 0, 0, -Extent.Z );
	FVector V4 = Vertices(v4) - FVector( 0, 0, -Extent.Z );
	
	FVector StartEnd = End - Start;

	FVector N = FPlane( V1, V2, V3 );
	if( (N|StartEnd) < 0.0001f )
	{
		FVector Int = FLinePlaneIntersection( End, Start, FPlane(V1, N) );

		if( Result.Actor == NULL ||
			((Int-Start).SizeSquared() < (Result.Location-Start).SizeSquared()) )  
		{
			FLOAT T = ((Int-Start|StartEnd)/(StartEnd|StartEnd)) / StartEnd.Size();
			if( T >=0.f && T<=1.f )
			{
				FPlane P1( V1, (V2-V1)^N );
				FPlane P2( V2, (V3-V2)^N );
				FPlane P3( V3, (V1-V3)^N );
				
				FLOAT Dot1 = P1.PlaneDot(Int);
				FLOAT Dot2 = P2.PlaneDot(Int);
				FLOAT Dot3 = P3.PlaneDot(Int);

				if( Dot1<=Extent.X && Dot2<=Extent.X && Dot3<=Extent.X )
				{
					FVector Dir = End - Start;
					Dir.Normalize();
					Result.Location = Int;
					Result.Normal	= N;
					FVector V       = End-Start;
					Result.Time     = ((Result.Location-Start)|V)/(V|V);
					Result.Time		= Clamp( Result.Time - 0.5f / V.Size(), 0.f, 1.f );
					Result.Location	= Start + V * Result.Time;
					Result.Actor	= this;
					if ( Owner )
						Result.Normal = Result.Normal.TransformVectorBy(Owner->ToWorld());
					ret = 1;
				}
			}
		}
	}

	N = FPlane( V1, V3, V4 );
	if( (N|StartEnd) < 0.0001f )
	{
		FVector Int = FLinePlaneIntersection( End, Start, FPlane(V1, N) );
		if( Result.Actor == NULL ||
			((Int-Start).SizeSquared() < (Result.Location-Start).SizeSquared()) )  
		{
			FLOAT T = ((Int-Start|StartEnd)/(StartEnd|StartEnd)) / StartEnd.Size();
			if( T >=0.f && T<=1.f )
			{
				FPlane P1 = FPlane( V1, (V3-V1)^N );
				FPlane P2 = FPlane( V3, (V4-V3)^N );
				FPlane P3 = FPlane( V4, (V1-V4)^N );
				
				FLOAT Dot1 = P1.PlaneDot(Int);
				FLOAT Dot2 = P2.PlaneDot(Int);
				FLOAT Dot3 = P3.PlaneDot(Int);
				if( Dot1<=Extent.X && Dot2<=Extent.X && Dot3<=Extent.X )
				{
					FVector Dir = End - Start;
					Dir.Normalize();
					Result.Location = Int;
					Result.Normal	= N;
					FVector V       = End-Start;
					Result.Time     = ((Result.Location-Start)|V)/(V|V);
					Result.Time		= Clamp( Result.Time - 0.5f / V.Size(), 0.f, 1.f );
					Result.Location	= Start + V * Result.Time;
					Result.Actor	= this;
					if ( Owner )
						Result.Normal = Result.Normal.TransformVectorBy(Owner->ToWorld());
					ret = 1;
				}
			}
		}
	}

	return ret;
	unguard;
}
UBOOL ATerrainInfo::LineCheck( FCheckResult &Result, FVector InEnd, FVector InStart, FVector InExtent )
{
	guard(ATerrainInfo::LineCheck);

	if( Heightmap.Num()==0 || Vertices.Num()==0 )
		return 0;
	
	UBOOL ret = 0;
	Result.Actor = NULL;
	
	FVector End = InEnd.TransformPointBy( ToHeightmap );
	FVector Start = InStart.TransformPointBy( ToHeightmap );
	FVector Extent = InExtent.TransformPointBy( ToHeightmap );


	INT X1 = Max<INT>( Min<INT>( Start.X, End.X ) - 2, 0 );
	INT Y1 = Max<INT>( Min<INT>( Start.Y, End.Y ) - 2, 0 );
	INT X2 = Min<INT>( Max<INT>( Start.X, End.X ) + 2, HeightmapX - 1);
	INT Y2 = Min<INT>( Max<INT>( Start.Y, End.Y ) + 2, HeightmapY - 1);

	for( INT X=X1;X<X2;X++ )
		for( INT Y=Y1;Y<Y2;Y++ )
			if( LineCheckWithQuad( X, Y, Result, InEnd, InStart, InExtent ) )
				ret = 1;

	return ret;
	unguard;
}

/*------------------------------------------------------------------------------
    Terrain	Editor stuff
------------------------------------------------------------------------------*/
UBOOL ATerrainInfo::SelectVertex( FVector Location )
{
	guard(ATerrainInfo::SelectVertex);

	FVector H = Location.TransformPointBy( ToHeightmap );
	INT X = appRound(H.X);
	INT Y = appRound(H.Y);

	if( X<0 || Y<0 || X>=HeightmapX || Y>=HeightmapY )
		return 0;

	for( INT i=0;i<SelectedVertices.Num();i++ )
	{
		if( SelectedVertices(i).X==X && SelectedVertices(i).Y==Y )
		{
			SelectedVertices.Remove(i);
			return 0;
		}
	}

	i = SelectedVertices.Add();
	SelectedVertices(i).X = X;
	SelectedVertices(i).Y = Y;
	SelectedVertices(i).Weight = 1;	
	SelectedVertices(i).OldHeight = Heightmap(GetGlobalVertex(X,Y));
	SelectedVertices(i).Delta = 0;
	return 1;
	unguard;
}
void ATerrainInfo::SoftSelect( FLOAT Radius )
{
	guard(ATerrainInfo::SoftSelect);

	// Reset deltas
	for( INT i=0;i<SelectedVertices.Num();i++ )
	{
		SelectedVertices(i).Delta = 0.f;
		SelectedVertices(i).OldHeight = Heightmap(GetGlobalVertex(SelectedVertices(i).X,SelectedVertices(i).Y));
	}

	FVector R = (Rotation.Vector() * Radius).TransformVectorBy( ToHeightmap );
	INT Delta = R.Size() + 1;
	INT Num = SelectedVertices.Num();

	for( i=0;i<Num;i++ )
	{
		FVector Vertex = Vertices( GetGlobalVertex(SelectedVertices(i).X,SelectedVertices(i).Y) );

		INT MaxDist=0.f;
		for( INT y=Max<INT>(0,SelectedVertices(i).Y-Delta);y<=Min<INT>(SelectedVertices(i).Y+Delta,HeightmapY-1); y++ )
			for( INT x=Max<INT>(0,SelectedVertices(i).X-Delta);x<=Min<INT>(SelectedVertices(i).X+Delta,HeightmapX-1); x++ )
			{
				FLOAT Dist = (Vertex-Vertices(GetGlobalVertex(x,y))).Size();
				if( Dist<Radius && Dist>MaxDist )
					MaxDist = Dist;
			}

		for( y=Max<INT>(0,SelectedVertices(i).Y-Delta);y<=Min<INT>(SelectedVertices(i).Y+Delta,HeightmapY-1); y++ )
		{
			for( INT x=Max<INT>(0,SelectedVertices(i).X-Delta);x<=Min<INT>(SelectedVertices(i).X+Delta,HeightmapX-1); x++ )
			{
				INT GlobalVertex = GetGlobalVertex(x,y);
				FLOAT Dist = (Vertex-Vertices(GlobalVertex)).Size();
				if(Dist > MaxDist)
					continue;
				FLOAT Weight = SelectedVertices(i).Weight * (0.5+(0.5f*appCos(PI*Dist/MaxDist)));
							
				if( Weight > 0 )
				{
					UBOOL bFound = 0;
					for( INT j=0;j<SelectedVertices.Num();j++ )
					{
						if( SelectedVertices(j).X==x && 
							SelectedVertices(j).Y==y )
						{
							bFound = 1;
							if( SelectedVertices(j).Weight < Weight )
								SelectedVertices(j).Weight = Weight;
						}
					}
					if( !bFound )
					{
						j = SelectedVertices.Add();
						SelectedVertices(j).X = x;
						SelectedVertices(j).Y = y;
						SelectedVertices(j).Weight = Weight;
						SelectedVertices(j).OldHeight = Heightmap(GlobalVertex);
						SelectedVertices(j).Delta = 0;
					}
				}
			}
		}
	}
	unguard;
}
void ATerrainInfo::SoftDeselect()
{
	guard(ATerrainInfo::SoftDeselect);
	for( INT i=0;i<SelectedVertices.Num();i++ )
	{
		if( SelectedVertices(i).Weight != 1.f )
		{
			SelectedVertices.Remove(i);
			--i;
		}
	}
	unguard;
}
void ATerrainInfo::MoveVertices( FLOAT Delta )
{
	guard(ATerrainInfo::MoveVertices);
	if( !SelectedVertices.Num() )
		return;
	INT MinX=HeightmapX, MinY=HeightmapY, MaxX=0, MaxY=0;
	for( INT i=0;i<SelectedVertices.Num();i++ )
	{
		if( SelectedVertices(i).X < MinX )
			MinX = SelectedVertices(i).X;
		if( SelectedVertices(i).Y < MinY )
			MinY = SelectedVertices(i).Y;
		if( SelectedVertices(i).X+1 > MaxX )
			MaxX = SelectedVertices(i).X+1;
		if( SelectedVertices(i).Y+1 > MaxY )
			MaxY = SelectedVertices(i).Y+1;

		SelectedVertices(i).Delta += Delta;

		Heightmap(GetGlobalVertex(SelectedVertices(i).X, SelectedVertices(i).Y)) 
			= Clamp<INT>( SelectedVertices(i).OldHeight - 8.f * SelectedVertices(i).Delta * SelectedVertices(i).Weight, 0, 65535 );
	}
	Update( 0, MinX, MinY, MaxX, MaxY );
	unguard;
}
void ATerrainInfo::ResetMove()
{
	guard(ATerrainInfo::ResetMove);
	if( !SelectedVertices.Num() )
		return;
	INT MinX=HeightmapX, MinY=HeightmapY, MaxX=0, MaxY=0;
	for( INT i=0;i<SelectedVertices.Num();i++ )
	{
		if( SelectedVertices(i).X < MinX )
			MinX = SelectedVertices(i).X;
		if( SelectedVertices(i).Y < MinY )
			MinY = SelectedVertices(i).Y;
		if( SelectedVertices(i).X+1 > MaxX )
			MaxX = SelectedVertices(i).X+1;
		if( SelectedVertices(i).Y+1 > MaxY )
			MaxY = SelectedVertices(i).Y+1;

		SelectedVertices(i).Delta = 0;
		Heightmap(GetGlobalVertex(SelectedVertices(i).X, SelectedVertices(i).Y)) = SelectedVertices(i).OldHeight;
	}
	Update( 0, MinX, MinY, MaxX, MaxY );
	unguard;
}

IMPLEMENT_CLASS(ATerrainInfo);

/*------------------------------------------------------------------------------
	The End.
------------------------------------------------------------------------------*/
