/*=============================================================================
	TwoDeeShapeEditor : 2D Shape Editor
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

extern FString GLastDir[eLASTDIR_MAX];

INT GGridSize = 16, GGridSizeZoom = 16;
INT GDefaultDetailLevel = 5;
struct {
	FLOAT Factor;
	FLOAT Mouse;
} GZoom[] =
{
	8.0f,	12.5f,
	4.0f,	25.0f,
	2.0f,	50.0f,
	1.0f,	100.0f,
	0.5f,	200.0f,
	0.25f,	400.0f,
	0.125f,	800.0f,
};

// --------------------------------------------------------------
//
// DATA TYPES
//
// --------------------------------------------------------------

class F2DSEVector : public FVector
{
public:
	F2DSEVector()
	{
		X = Y = Z = 0;
		bSelected = 0;
	}
	F2DSEVector( FLOAT x, FLOAT y, FLOAT z)
		: FVector( x, y, z )
	{
		bSelected = 0;
	}
	~F2DSEVector()
	{}

	inline F2DSEVector operator=( F2DSEVector Other )
	{
		X = Other.X;
		Y = Other.Y;
		Z = Other.Z;
		bSelected = Other.bSelected;
		return *this;
	}
	inline F2DSEVector operator=( FVector Other )
	{
		X = Other.X;
		Y = Other.Y;
		Z = Other.Z;
		return *this;
	}
	inline UBOOL operator!=( F2DSEVector Other )
	{
		return (X != Other.X && Y != Other.Y && Z != Other.Z);
	}
	inline UBOOL operator==( F2DSEVector Other )
	{
		return (X == Other.X && Y == Other.Y && Z == Other.Z);
	}
	void SelectToggle()
	{
		bSelected = !bSelected;
		if( bSelected )
			SetTempPos();
	}
	void Select( BOOL bSel )
	{
		bSelected = bSel;
		if( bSelected )
			SetTempPos();
	}
	BOOL IsSel( void )
	{
		return bSelected;
	}
	void SetTempPos()
	{
		TempX = X;
		TempY = Y;
	}

	FLOAT TempX, TempY;

private:
	UBOOL bSelected;
};

enum eSEGTYPE {
	eSEGTYPE_LINEAR	= 0,
	eSEGTYPE_BEZIER	= 1
};

// A segment represents the line drawn between 2 vertices on a shape.
class FSegment
{
public:
	FSegment()
	{
		SegType = eSEGTYPE_LINEAR;
		DetailLevel = 10;
	}
	FSegment( F2DSEVector vtx1, F2DSEVector vtx2 )
	{
		Vertex[0] = vtx1;
		Vertex[1] = vtx2;
		SegType = eSEGTYPE_LINEAR;
		DetailLevel = 10;
	}
	FSegment( FVector vtx1, FVector vtx2 )
	{
		Vertex[0] = vtx1;
		Vertex[1] = vtx2;
		SegType = eSEGTYPE_LINEAR;
		DetailLevel = 10;
	}
	~FSegment()
	{}

	inline FSegment operator=( FSegment Other )
	{
		Vertex[0] = Other.Vertex[0];
		Vertex[1] = Other.Vertex[1];
		ControlPoint[0] = Other.ControlPoint[0];
		ControlPoint[1] = Other.ControlPoint[1];
		return *this;
	}
	inline UBOOL operator==( FSegment Other )
	{
		return( Vertex[0] == Other.Vertex[0] && Vertex[1] == Other.Vertex[1] );
	}
	FVector GetHalfwayPoint()
	{
		FVector Dir = Vertex[1] - Vertex[0];
		INT Size = Dir.Size();
		Dir.Normalize();

		FVector HalfWay = Vertex[0] + (Dir * (Size / 2));
		HalfWay = HalfWay.GridSnap( FVector( GGridSize, GGridSize, GGridSize ) );
		return HalfWay;
	}
	void GenerateControlPoint()
	{
		FVector Dir = Vertex[1] - Vertex[0];
		INT Size = Dir.Size();
		Dir.Normalize();

		ControlPoint[0] = Vertex[0] + (Dir * (Size / 3.0f));
		ControlPoint[1] = Vertex[1] - (Dir * (Size / 3.0f));
	}
	void SetSegType( INT InType )
	{
		if( InType == SegType ) return;
		SegType = InType;
		if( InType == eSEGTYPE_BEZIER )
		{
			GenerateControlPoint();
			DetailLevel = GDefaultDetailLevel;
		}
	}
	UBOOL IsSel()
	{
		return ( Vertex[0].IsSel() || ControlPoint[0].IsSel() || ControlPoint[1].IsSel() );
	}
	void GetBezierPoints( TArray<FVector>* pBezierPoints )
	{
		F2DSEVector ccp[4];
		ccp[0] = Vertex[0];
		ccp[1] = ControlPoint[0];
		ccp[2] = ControlPoint[1];
		ccp[3] = Vertex[1];
		F2DSEVector pt;

		pBezierPoints->Empty();
		(*pBezierPoints)(pBezierPoints->Add()) = Vertex[0];
		for( INT n = 1 ; n <= DetailLevel ; ++n )
		{
			double nD = (double)n / (DetailLevel + 1);
			Curve( nD, ccp, pt );
			(*pBezierPoints)(pBezierPoints->Add()) = pt;
		}
		(*pBezierPoints)(pBezierPoints->Add()) = Vertex[1];
	}
	// Get point on cubic bezier curve (slow)
	void Curve( double nP, F2DSEVector ControlPoint[4], F2DSEVector& Position )
	{
		double bf[4];
		CurveBlendingFunction( nP, bf );
		Position.X = Position.Y = 0;
		for( INT n = 0 ; n < 4 ; ++n )
			Position += ControlPoint[n] * bf[n];
	}
	// Evaluate Bernstein polynomials B_0^3(p) ... B_3^3(p)
	void CurveBlendingFunction( double nP, double pBf[4] )
	{
		double nQ = 1 - nP;
		double nP2 = nP * nP;
		double nQ2 = nQ * nQ;
		pBf[0] = nQ2 * nQ;
		pBf[1] = 3 * nQ2 * nP;
		pBf[2] = 3 * nP2 * nQ;
		pBf[3] = nP2 * nP;
	}

	F2DSEVector Vertex[2], ControlPoint[2];
	INT SegType,		// eSEGTYPE_
		DetailLevel;	// Detail of bezier curve
	UBOOL bUsed;
};

// A shape is a closed series of segments (i.e. a triangle is 3 segments).
class FShape
{
public:
	FShape()
	{
	}
	~FShape()
	{}

	F2DSEVector Handle;
	TArray<FSegment> Segments;
	TArray<FVector> Verts;

	void ComputeHandlePosition()
	{
		Handle = F2DSEVector(0,0,0);
		for( INT seg = 0 ; seg < Segments.Num() ; seg++ )
			Handle += Segments(seg).Vertex[0];
		Handle /= Segments.Num();
	}
	// Breaks the shape down into convex polys.
	void Breakdown( F2DSEVector InOrigin, FPolyBreaker* InBreaker )
	{
		Verts.Empty();
		for( INT seg = 1 ; seg < Segments.Num() ; seg++ )
			Segments(seg).bUsed = 0;

		// Use up the first segment before going into the loop.
		if( Segments(0).SegType == eSEGTYPE_BEZIER )
		{
			TArray<FVector> BezierPoints;
			Segments(0).GetBezierPoints( &BezierPoints );
			for( INT bz = BezierPoints.Num() - 1 ; bz > 0 ; bz-- )
			{
				Verts(Verts.Add()) = BezierPoints(bz) - InOrigin;
			}
		}
		else
		{
			Verts(Verts.Add()) = Segments(0).Vertex[1] - InOrigin;
		}
		Segments(0).bUsed = 1;

		F2DSEVector Match = Segments(0).Vertex[0];

		for( seg = 0 ; seg < Segments.Num() ; seg++ )
		{
			if( !Segments(seg).bUsed
					&& Segments(seg).Vertex[1] == Match )
			{
				if( Segments(seg).SegType == eSEGTYPE_BEZIER )
				{
					TArray<FVector> BezierPoints;
					Segments(seg).GetBezierPoints( &BezierPoints );
					for( INT bz = BezierPoints.Num() - 1 ; bz > 0 ; bz-- )
					{
						Verts(Verts.Add()) = BezierPoints(bz) - InOrigin;
					}
				}
				else
				{
					Verts(Verts.Add()) = Segments(seg).Vertex[1] - InOrigin;
				}

				Segments(seg).bUsed = 1;
				Match = Segments(seg).Vertex[0];

				seg = 0;
			}
		}

		// Reverse the vertex winding -- this seems to make things work more reliably.
		TArray<FVector> Reverse;
		for( INT x = Verts.Num()-1 ; x > -1 ; x-- )
			new(Reverse)FVector(Verts(x));

		InBreaker->Process( &Reverse, FVector(0,0,1) );
	}
};

#define d2dSE_SELECT_TOLERANCE 4

// --------------------------------------------------------------
//
// W2DSHAPEEDITOR
//
// --------------------------------------------------------------

#define ID_2DSE_TOOLBAR	29002
TBBUTTON tb2DSEButtons[] = {
	{ 0, IDMN_2DSE_NEW, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 1, IDMN_2DSE_FileOpen, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 2, IDMN_2DSE_FileSave, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 3, IDMN_2DSE_ROTATE90, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 4, IDMN_2DSE_ROTATE45, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 5, IDMN_2DSE_FLIP_VERT, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 6, IDMN_2DSE_FLIP_HORIZ, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 7, IDMN_2DSE_SCALE_UP, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 8, IDMN_2DSE_SCALE_DOWN, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 9, IDMN_2DSE_ZOOM_IN, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 10, IDMN_2DSE_ZOOM_OUT, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 11, IDMN_2DSE_SPLIT_SIDE, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 12, IDMN_2DSE_DELETE, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 13, IDMN_SEGMENT_LINEAR, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 14, IDMN_SEGMENT_BEZIER, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 0, 0, TBSTATE_ENABLED, TBSTYLE_SEP, 0L, 0}
	, { 15, IDMN_2DSE_PROCESS_SHEET, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 16, IDMN_2DSE_PROCESS_REVOLVE, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 17, IDMN_2DSE_PROCESS_EXTRUDE, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 18, IDMN_2DSE_PROCESS_EXTRUDETOPOINT, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
	, { 19, IDMN_2DSE_PROCESS_EXTRUDETOBEVEL, TBSTATE_ENABLED, TBSTYLE_BUTTON, 0L, 0}
};
struct {
	TCHAR ToolTip[64];
	INT ID;
} ToolTips_2DSE[] = {
	TEXT("New"), IDMN_2DSE_NEW,
	TEXT("Open"), IDMN_2DSE_FileOpen,
	TEXT("Save"), IDMN_2DSE_FileSave,
	TEXT("Rotate 90 Degrees"), IDMN_2DSE_ROTATE90,
	TEXT("Rotate 45 Degrees"), IDMN_2DSE_ROTATE45,
	TEXT("Flip Vertically"), IDMN_2DSE_FLIP_VERT,
	TEXT("Flip Horizontally"), IDMN_2DSE_FLIP_HORIZ,
	TEXT("Create a Sheet"), IDMN_2DSE_PROCESS_SHEET,
	TEXT("Extruded Shape"), IDMN_2DSE_PROCESS_EXTRUDE,
	TEXT("Revolved Shape"), IDMN_2DSE_PROCESS_REVOLVE,
	TEXT("Extude to Point"), IDMN_2DSE_PROCESS_EXTRUDETOPOINT,
	TEXT("Extude to Bevel"), IDMN_2DSE_PROCESS_EXTRUDETOBEVEL,
	TEXT("Scale Up"), IDMN_2DSE_SCALE_UP,
	TEXT("Scale Down"), IDMN_2DSE_SCALE_DOWN,
	TEXT("Split Segment(s)"), IDMN_2DSE_SPLIT_SIDE,
	TEXT("Delete"), IDMN_2DSE_DELETE,
	TEXT("Linear Segment"), IDMN_SEGMENT_LINEAR,
	TEXT("Bezier Segment"), IDMN_SEGMENT_BEZIER,
	TEXT("Zoom In"), IDMN_2DSE_ZOOM_IN,
	TEXT("Zoom Out"), IDMN_2DSE_ZOOM_OUT,
	NULL, 0
};

class W2DShapeEditor : public WWindow
{
	DECLARE_WINDOWCLASS(W2DShapeEditor,WWindow,Window)

	// Structors.
	W2DShapeEditor( FName InPersistentName, WWindow* InOwnerWindow )
	:	WWindow( InPersistentName, InOwnerWindow )
	{
		New();
		m_bDraggingCamera = m_bDraggingVerts = m_bBoxSel = FALSE;
		::ZeroMemory( MapFilename, sizeof(TCHAR) * 256);
		hImage = NULL;
		hWndToolBar = NULL;
		Zoom = 3;
		mrulist = NULL;
	}

	WToolTip* ToolTipCtrl;
	HWND hWndToolBar;
	FVector m_camera;			// The viewing camera position
	F2DSEVector m_origin;		// The origin point used for revolves and such
	FPoint BoxSelStart, BoxSelEnd;
	BOOL m_bDraggingCamera, m_bDraggingVerts, m_bBoxSel, m_bMouseHasMoved;
	FPoint m_pointOldPos;
	TCHAR MapFilename[256];
	HBITMAP hImage;
	RECT m_rcWnd;
	POINT m_ContextPos;
	INT Zoom;
	MRUList* mrulist;

	HMENU ShapeEditorMenu;
	HMENU ShapeEditorContext;

	TArray<FShape> m_shapes;

	// WWindow interface.
	void OpenWindow()
	{
		MdiChild = 0;

		PerformCreateWindowEx
		(
			0,
			NULL,
			WS_OVERLAPPEDWINDOW | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS,
			0,
			0,
			320,
			200,
			OwnerWindow ? OwnerWindow->hWnd : NULL,
			NULL,
			hInstance
		);
		SetCaption();
	}
	void OnDestroy()
	{
		mrulist->WriteINI();
		delete mrulist;
		delete ToolTipCtrl;
		::DestroyWindow( hWndToolBar );
		DestroyMenu( ShapeEditorMenu );
		DestroyMenu( ShapeEditorContext );
		WWindow::OnDestroy();
	}
	INT OnSetCursor()
	{
		WWindow::OnSetCursor();
		SetCursor(LoadCursorIdX(NULL,IDC_CROSS));
		return 0;
	}
	void OnCreate()
	{
		WWindow::OnCreate();

		ShapeEditorMenu = LoadMenuIdX(hInstance, IDMENU_2DShapeEditor);
		SetMenu( hWnd, ShapeEditorMenu );

		ShapeEditorContext = LoadMenuIdX(hInstance, IDMENU_2DShapeEditor_Context);

		// TOOLBAR
		HWND hWndToolBar = CreateToolbarEx( 
			hWnd,
			WS_CHILD | WS_BORDER | WS_VISIBLE | CCS_ADJUSTABLE,
			ID_2DSE_TOOLBAR,
			20,
			hInstance,
			IDB_2DSE_TOOLBAR,
			(LPCTBBUTTON)&tb2DSEButtons,
			27,
			18,18,
			18,18,
			sizeof(TBBUTTON));

		if( !hWndToolBar )
			appMsgf( TEXT("Toolbar not created!") );

		ToolTipCtrl = new WToolTip(this);
		ToolTipCtrl->OpenWindow();

		for( INT tooltip = 0 ; ToolTips_2DSE[tooltip].ID > 0 ; tooltip++ )
		{
			INT index = SendMessageX( hWndToolBar, TB_COMMANDTOINDEX, ToolTips_2DSE[tooltip].ID, 0 );
			RECT rect;
			SendMessageX( hWndToolBar, TB_GETITEMRECT, index, (LPARAM)&rect);

			ToolTipCtrl->AddTool( hWndToolBar, ToolTips_2DSE[tooltip].ToolTip, tooltip, &rect );
		}

		mrulist = new MRUList( *PersistentName );
		mrulist->ReadINI();
		mrulist->AddToMenu( hWnd, GetMenu( hWnd ) );
	}
	void OnPaint()
	{
		PAINTSTRUCT PS;
		HDC hDC = BeginPaint( *this, &PS );

		HDC hdcWnd, hdcMem;
		HBITMAP hBitmap;
		HBRUSH l_brush, l_brushOld = NULL;

		::GetClientRect( hWnd, &m_rcWnd );

		hdcWnd = GetDC(hWnd);
		hdcMem = CreateCompatibleDC(hdcWnd);
		hBitmap = CreateCompatibleBitmap(hdcWnd, m_rcWnd.right, m_rcWnd.bottom );
		SelectObject(hdcMem, hBitmap);

		l_brush = CreateSolidBrush( RGB(255, 255, 255) );
		SelectObject( hdcMem, l_brush);
		FillRect( hdcMem, GetClientRect(), l_brush );
		l_brushOld = (HBRUSH)SelectObject( hdcMem, l_brushOld);

		DrawGrid( hdcMem );
		DrawImage( hdcMem );
		DrawOrigin( hdcMem );
		DrawSegments( hdcMem );
		DrawShapeHandles( hdcMem );
		DrawVertices( hdcMem );
		DrawBoxSel( hdcMem );

		BitBlt(hDC,
			   0, 0,
			   m_rcWnd.right, m_rcWnd.bottom,
			   hdcMem,
			   0, 0,
			   SRCCOPY);

		EndPaint( *this, &PS );

		DeleteObject( l_brush );
		DeleteDC(hdcMem);
		ReleaseDC( hWnd, hdcWnd );
		DeleteObject( hBitmap );
	}
	void ScaleShapes( FLOAT InScale )
	{
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
			{
				for( INT vertex = 0 ; vertex < 2 ; vertex++ )
				{
					m_shapes(shape).Segments(seg).Vertex[vertex].X *= InScale;
					m_shapes(shape).Segments(seg).Vertex[vertex].Y *= InScale;
					m_shapes(shape).Segments(seg).ControlPoint[vertex].X *= InScale;
					m_shapes(shape).Segments(seg).ControlPoint[vertex].Y *= InScale;
				}
			}
		}

		ComputeHandlePositions(1);
		InvalidateRect( hWnd, NULL, FALSE );
	}
	void OnCommand( INT Command )
	{
		switch( Command )
		{
			case IDMN_2DSE_MOVE_TO_ORIGIN:
				m_camera.X =  m_camera.Y = 0;
				InvalidateRect( hWnd, NULL, FALSE );
				break;

			case ID_FileExit:
				SendMessageX( hWnd, WM_CLOSE, 0, 0 );
				break;

			case IDMN_2DSE_ZOOM_IN:
				Zoom--;
				if( Zoom < 0) Zoom = 0;
				GGridSizeZoom = GGridSize * GZoom[Zoom].Factor;
				InvalidateRect( hWnd, NULL, FALSE );
				break;

			case IDMN_2DSE_ZOOM_OUT:
				Zoom++;
				if( Zoom > 6) Zoom = 6;
				GGridSizeZoom = GGridSize * GZoom[Zoom].Factor;
				InvalidateRect( hWnd, NULL, FALSE );
				break;

			case IDMN_2DSE_SCALE_UP:
				ScaleShapes(2.0f);
				break;

			case IDMN_2DSE_SCALE_DOWN:
				ScaleShapes(0.5f);
				break;

			case IDMN_2DSE_ROTATE90:
				RotateShape( 90 );
				break;

			case IDMN_2DSE_ROTATE45:
				RotateShape( 45 );
				break;

			case IDMN_DETAIL_1:
				SetSegmentDetail(1);
				break;

			case IDMN_DETAIL_2:
				SetSegmentDetail(2);
				break;

			case IDMN_DETAIL_3:
				SetSegmentDetail(3);
				break;

			case IDMN_DETAIL_4:
				SetSegmentDetail(4);
				break;

			case IDMN_DETAIL_5:
				SetSegmentDetail(5);
				break;

			case IDMN_DETAIL_10:
				SetSegmentDetail(10);
				break;

			case IDMN_DETAIL_15:
				SetSegmentDetail(15);
				break;

			case IDMN_DETAIL_20:
				SetSegmentDetail(20);
				break;

			case IDMN_DETAIL_CUSTOM:
				{
					UOptions2DShaperBezierDetail* Proxy = Cast<UOptions2DShaperBezierDetail>(GProxies(PROXY_OPTIONS2DSHAPERBEZIERDETAIL));
					WDlgGeneric dlg( NULL, this, Proxy );
					if( dlg.DoModal() )
						SetSegmentDetail( Proxy->DetailLevel );
				}
				break;

			case IDMN_2DSE_FLIP_VERT:
				Flip(0);
				break;

			case IDMN_2DSE_FLIP_HORIZ:
				Flip(1);
				break;

			case IDMN_SEGMENT_LINEAR:
				ChangeSegmentTypes(eSEGTYPE_LINEAR);
				break;

			case IDMN_SEGMENT_BEZIER:
				ChangeSegmentTypes(eSEGTYPE_BEZIER);
				break;

			case IDMN_MRU1:
			case IDMN_MRU2:
			case IDMN_MRU3:
			case IDMN_MRU4:
			case IDMN_MRU5:
			case IDMN_MRU6:
			case IDMN_MRU7:
			case IDMN_MRU8:
			{
				FString Filename = mrulist->Items[Command - IDMN_MRU1];
				appStrcpy( MapFilename, *Filename );
				ReadShape( MapFilename );
				SetCaption();
				InvalidateRect( hWnd, NULL, 0 );
			}
			break;

			case IDMN_2DSE_NEW:
				appStrcpy( MapFilename, TEXT("") );
				SetCaption();
				New();
				break;

			case IDMN_2DSE_SPLIT_SIDE:
				SplitSides();
				break;

			case IDMN_2DSE_NEW_SHAPE:
				InsertNewShape();
				break;

			case IDMN_2DSE_DELETE:
				Delete();
				break;

			case IDMN_2DSE_FileSave:
				FileSave( hWnd );
				break;

			case IDMN_2DSE_FileSaveAs:
				FileSaveAs( hWnd );
				break;

			case IDMN_2DSE_FileOpen:
				FileOpen( hWnd );
				break;

			case IDMN_2DSEC_SET_ORIGIN:
				SetOrigin();
				break;

			case IDMN_2DSE_PROCESS_SHEET:
				{
					UOptions2DShaperSheet* Proxy = Cast<UOptions2DShaperSheet>(GProxies(PROXY_OPTIONS2DSHAPERSHEET));
					WDlgGeneric dlg( NULL, this, Proxy );
					if( dlg.DoModal() )
					{
						ProcessSheet();
						RotateBuilderBrush( Proxy->Axis );
					}
				}
				break;

			case IDMN_2DSE_PROCESS_EXTRUDE:
				{
					UOptions2DShaperExtrude* Proxy = Cast<UOptions2DShaperExtrude>(GProxies(PROXY_OPTIONS2DSHAPEREXTRUDE));
					WDlgGeneric dlg( NULL, this, Proxy );
					if( dlg.DoModal() )
					{
						ProcessExtrude( Proxy->Depth );
						RotateBuilderBrush( Proxy->Axis );
					}
				}
				break;

			case IDMN_2DSE_PROCESS_EXTRUDETOPOINT:
				{
					UOptions2DShaperExtrudeToPoint* Proxy = Cast<UOptions2DShaperExtrudeToPoint>(GProxies(PROXY_OPTIONS2DSHAPEREXTRUDETOPOINT));
					WDlgGeneric dlg( NULL, this, Proxy );
					if( dlg.DoModal() )
					{
						ProcessExtrudeToPoint( Proxy->Depth );
						RotateBuilderBrush( Proxy->Axis );
					}
				}
				break;

			case IDMN_2DSE_PROCESS_EXTRUDETOBEVEL:
				{
					UOptions2DShaperExtrudeToBevel* Proxy = Cast<UOptions2DShaperExtrudeToBevel>(GProxies(PROXY_OPTIONS2DSHAPEREXTRUDETOBEVEL));
					WDlgGeneric dlg( NULL, this, Proxy );
					if( dlg.DoModal() )
					{
						ProcessExtrudeToBevel( Proxy->Height, Proxy->CapHeight );
						RotateBuilderBrush( Proxy->Axis );
					}
				}
				break;

			case IDMN_2DSE_PROCESS_REVOLVE:
				{
					UOptions2DShaperRevolve* Proxy = Cast<UOptions2DShaperRevolve>(GProxies(PROXY_OPTIONS2DSHAPERREVOLVE));
					WDlgGeneric dlg( NULL, this, Proxy );
					if( dlg.DoModal() )
					{
						ProcessRevolve( Proxy->Per360, Proxy->Use );
						RotateBuilderBrush( Proxy->Axis );
					}
				}
				break;

			case IDMN_GRID_1:	
				GGridSize = 1;	
				GGridSizeZoom = GGridSize * GZoom[Zoom].Factor;
				InvalidateRect( hWnd, NULL, FALSE );
				break;
			case IDMN_GRID_2:	
				GGridSize = 2;	
				GGridSizeZoom = GGridSize * GZoom[Zoom].Factor;
				InvalidateRect( hWnd, NULL, FALSE );
				break;
			case IDMN_GRID_4:	
				GGridSize = 4;	
				GGridSizeZoom = GGridSize * GZoom[Zoom].Factor;
				InvalidateRect( hWnd, NULL, FALSE );
				break;
			case IDMN_GRID_8:	
				GGridSize = 8;	
				GGridSizeZoom = GGridSize * GZoom[Zoom].Factor;
				InvalidateRect( hWnd, NULL, FALSE );
				break;
			case IDMN_GRID_16:	
				GGridSize = 16;	
				GGridSizeZoom = GGridSize * GZoom[Zoom].Factor;
				InvalidateRect( hWnd, NULL, FALSE );
				break;
			case IDMN_GRID_32:	
				GGridSize = 32;	
				GGridSizeZoom = GGridSize * GZoom[Zoom].Factor;
				InvalidateRect( hWnd, NULL, FALSE );
				break;
			case IDMN_GRID_64:	
				GGridSize = 64;	
				GGridSizeZoom = GGridSize * GZoom[Zoom].Factor;
				InvalidateRect( hWnd, NULL, FALSE );
				break;

			case IDMN_2DSE_GET_IMAGE:
				{
					if( !GEditor->CurrentTexture )
					{
						appMsgf( TEXT("Select a texture first.") );
						break;
					}

					BITMAPINFO bmi;
					BYTE* pBits = NULL;

					::ZeroMemory( &bmi, sizeof(BITMAPINFOHEADER) );
					bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
					bmi.bmiHeader.biWidth = GEditor->CurrentTexture->USize;
					bmi.bmiHeader.biHeight = -GEditor->CurrentTexture->VSize;
					bmi.bmiHeader.biPlanes = 1;
					bmi.bmiHeader.biBitCount = 24;
					bmi.bmiHeader.biCompression = BI_RGB;

					if( hImage ) 
						DeleteObject( hImage );
					hImage = CreateDIBSection( ::GetDC( hWnd ), &bmi, DIB_RGB_COLORS, (void**)&pBits, NULL, 0 );
					check( hImage );
					check( pBits );

					// RGB DATA
					FColor* Palette = GEditor->CurrentTexture->GetColors();
					check(Palette);
					BYTE* pSrc = GEditor->CurrentTexture->GetMip(0)->DataPtr;
					BYTE* pDst = pBits;
					for( INT x = 0 ; x < GEditor->CurrentTexture->USize * GEditor->CurrentTexture->VSize; x++ )
					{
						FColor color = Palette[ *pSrc ];
						*pDst = color.B;	pDst++;
						*pDst = color.G;	pDst++;
						*pDst = color.R;	pDst++;
						pSrc++;
					}
				}
				break;

			case IDMN_2DSE_OPEN_IMAGE:
				{
					OPENFILENAMEA ofn;
					char File[8192] = "\0";

					ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
					ofn.lStructSize = sizeof(OPENFILENAMEA);
					ofn.hwndOwner = hWnd;
					ofn.lpstrFile = File;
					ofn.nMaxFile = sizeof(char) * 8192;
					ofn.lpstrFilter = "Bitmaps (*.bmp)\0*.bmp\0All Files\0*.*\0\0";
					ofn.lpstrInitialDir = "..\\maps";
					ofn.lpstrTitle = "Open Image";
					ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_DTX]) );
					ofn.lpstrDefExt = "bmp";
					ofn.Flags = OFN_NOCHANGEDIR;

					// Display the Open dialog box. 
					//
					if( GetOpenFileNameA(&ofn) )
					{
						if( hImage ) 
							DeleteObject( hImage );

						hImage = (HBITMAP)LoadImageA( hInstance, File, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE );

						if( !hImage )
							appMsgf ( TEXT("Error loading bitmap.") );

						FString S = appFromAnsi( File );
						GLastDir[eLASTDIR_DTX] = S.Left( S.InStr( TEXT("\\"), 1 ) );
					}

					InvalidateRect( hWnd, NULL, FALSE );
				}
				break;

			case IDMN_2DSE_DELETE_IMAGE:
				DeleteObject( hImage );
				hImage = NULL;
				InvalidateRect( hWnd, NULL, FALSE );
				break;

			default:
				WWindow::OnCommand(Command);
				break;
		}
	}
	void OnRightButtonDown()
	{
		m_bDraggingCamera = TRUE;
		m_pointOldPos = GetCursorPos();
		SetCapture( hWnd );
		m_bMouseHasMoved = FALSE;

		WWindow::OnRightButtonDown();
	}
	void OnRightButtonUp()
	{
		ReleaseCapture();
		m_bDraggingCamera = FALSE;

		if( !m_bMouseHasMoved )
		{
			::GetCursorPos( &m_ContextPos );
			HMENU l_menu = GetSubMenu( ShapeEditorContext, 0 );

			CheckMenuItem( l_menu, IDMN_GRID_1, MF_BYCOMMAND | ((GGridSize == 1) ? MF_CHECKED : MF_UNCHECKED) );
			CheckMenuItem( l_menu, IDMN_GRID_2, MF_BYCOMMAND | ((GGridSize == 2) ? MF_CHECKED : MF_UNCHECKED) );
			CheckMenuItem( l_menu, IDMN_GRID_4, MF_BYCOMMAND | ((GGridSize == 4) ? MF_CHECKED : MF_UNCHECKED) );
			CheckMenuItem( l_menu, IDMN_GRID_8, MF_BYCOMMAND | ((GGridSize == 8) ? MF_CHECKED : MF_UNCHECKED) );
			CheckMenuItem( l_menu, IDMN_GRID_16, MF_BYCOMMAND | ((GGridSize == 16) ? MF_CHECKED : MF_UNCHECKED) );
			CheckMenuItem( l_menu, IDMN_GRID_32, MF_BYCOMMAND | ((GGridSize == 32) ? MF_CHECKED : MF_UNCHECKED) );
			CheckMenuItem( l_menu, IDMN_GRID_64, MF_BYCOMMAND | ((GGridSize == 64) ? MF_CHECKED : MF_UNCHECKED) );

			INT SegType, DetailLevel;
			GetSegmentDetails( &SegType, &DetailLevel );

			if( SegType != -1 )
			{
				CheckMenuItem( l_menu, IDMN_SEGMENT_BEZIER, MF_BYCOMMAND | ((SegType == eSEGTYPE_BEZIER) ? MF_CHECKED : MF_UNCHECKED) );
				CheckMenuItem( l_menu, IDMN_SEGMENT_LINEAR, MF_BYCOMMAND | ((SegType == eSEGTYPE_LINEAR) ? MF_CHECKED : MF_UNCHECKED) );
			}
			if( DetailLevel != -1 )
			{
				CheckMenuItem( l_menu, IDMN_DETAIL_1, MF_BYCOMMAND | ((DetailLevel == 1) ? MF_CHECKED : MF_UNCHECKED) );
				CheckMenuItem( l_menu, IDMN_DETAIL_2, MF_BYCOMMAND | ((DetailLevel == 2) ? MF_CHECKED : MF_UNCHECKED) );
				CheckMenuItem( l_menu, IDMN_DETAIL_3, MF_BYCOMMAND | ((DetailLevel == 3) ? MF_CHECKED : MF_UNCHECKED) );
				CheckMenuItem( l_menu, IDMN_DETAIL_4, MF_BYCOMMAND | ((DetailLevel == 4) ? MF_CHECKED : MF_UNCHECKED) );
				CheckMenuItem( l_menu, IDMN_DETAIL_5, MF_BYCOMMAND | ((DetailLevel == 5) ? MF_CHECKED : MF_UNCHECKED) );
				CheckMenuItem( l_menu, IDMN_DETAIL_10, MF_BYCOMMAND | ((DetailLevel == 10) ? MF_CHECKED : MF_UNCHECKED) );
				CheckMenuItem( l_menu, IDMN_DETAIL_15, MF_BYCOMMAND | ((DetailLevel == 15) ? MF_CHECKED : MF_UNCHECKED) );
				CheckMenuItem( l_menu, IDMN_DETAIL_20, MF_BYCOMMAND | ((DetailLevel == 20) ? MF_CHECKED : MF_UNCHECKED) );
			}

			TrackPopupMenu( l_menu,
				TPM_LEFTALIGN | TPM_TOPALIGN | TPM_RIGHTBUTTON,
				m_ContextPos.x, m_ContextPos.y, 0,
				hWnd, NULL);

			::ScreenToClient( hWnd, &m_ContextPos );
		}

		WWindow::OnRightButtonUp();
	}
	void GetSegmentDetails( int* InSegType, int* InDetailLevel )
	{
		// "-2" indicates the value hasn't been set yet
		// "-1" means there's more than one value

		INT SegType = -2, DetailLevel = -2;

		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
			{
				if( m_shapes(shape).Segments(seg).IsSel() )
				{
					if(SegType != -1 )
						if( SegType == -2 )
							SegType = m_shapes(shape).Segments(seg).SegType;
						else
							if( SegType != m_shapes(shape).Segments(seg).SegType )
								SegType = -1;

					if(DetailLevel != -1 )
						if( DetailLevel == -2 )
							DetailLevel = m_shapes(shape).Segments(seg).DetailLevel;
						else
							if( DetailLevel != m_shapes(shape).Segments(seg).DetailLevel )
								DetailLevel = -1;
				}
			}
		}

		*InSegType = SegType;
		*InDetailLevel = DetailLevel;
	}
	void OnMouseMove( DWORD Flags, FPoint MouseLocation )
	{
		m_bMouseHasMoved = TRUE;

		FLOAT pct = GZoom[Zoom].Mouse / 100.0f;

		POINT Delta;
		Delta.x = (MouseLocation.X - m_pointOldPos.X) * pct;
		Delta.y = (MouseLocation.Y - m_pointOldPos.Y) * pct;

		if( m_bBoxSel )
		{
			BoxSelEnd.X += Delta.x;
			BoxSelEnd.Y -= Delta.y;
			InvalidateRect( hWnd, NULL, FALSE );
		}
		else if( m_bDraggingCamera )
		{
			m_camera.X += MouseLocation.X - m_pointOldPos.X;
			m_camera.Y += MouseLocation.Y - m_pointOldPos.Y;

			m_pointOldPos = MouseLocation;
			InvalidateRect( hWnd, NULL, FALSE );
		}
		else
		{
			if( m_bDraggingVerts )
			{
				// Origin...
				if( m_origin.IsSel() )
				{
					// Adjust temp positions
					m_origin.TempX += Delta.x;
					m_origin.TempY -= Delta.y;

					// Snap real positions to the grid.
					m_origin.X = m_origin.TempX;
					m_origin.Y = m_origin.TempY;
					m_origin = m_origin.GridSnap( FVector(GGridSize, GGridSize, GGridSize) );
				}

				// Handles...
				for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
				{
					if( m_shapes(shape).Handle.IsSel() )
					{
						// Adjust temp positions
						m_shapes(shape).Handle.TempX += Delta.x;
						m_shapes(shape).Handle.TempY -= Delta.y;

						// Snap real positions to the grid.
						m_shapes(shape).Handle.X = m_shapes(shape).Handle.TempX;
						m_shapes(shape).Handle.Y = m_shapes(shape).Handle.TempY;

						// Also move all of this shapes vertices.
						for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
							for( INT vertex = 0 ; vertex < 2 ; vertex++ )
							{
								F2DSEVector* Vertex = &(m_shapes(shape).Segments(seg).Vertex[vertex]);

								// Adjust temp positions
								Vertex->TempX += Delta.x;
								Vertex->TempY -= Delta.y;

								// Snap real positions to the grid.
								Vertex->X = Vertex->TempX;
								Vertex->Y = Vertex->TempY;
								*Vertex = Vertex->GridSnap( FVector(GGridSize, GGridSize, GGridSize) );

								if( m_shapes(shape).Segments(seg).SegType == eSEGTYPE_BEZIER )
								{
									F2DSEVector* Vertex = &(m_shapes(shape).Segments(seg).ControlPoint[vertex]);

									// Adjust temp positions
									Vertex->TempX += Delta.x;
									Vertex->TempY -= Delta.y;

									// Snap real positions to the grid.
									Vertex->X = Vertex->TempX;
									Vertex->Y = Vertex->TempY;
									*Vertex = Vertex->GridSnap( FVector(GGridSize, GGridSize, GGridSize) );
								}
							}
					}
				}

				// Vertices...
				for( shape = 0 ; shape < m_shapes.Num() ; shape++ )
					if( !m_shapes(shape).Handle.IsSel() )
						for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
						{
							for( INT vertex = 0 ; vertex < 2 ; vertex++ )
							{
								if( m_shapes(shape).Segments(seg).Vertex[vertex].IsSel() )
								{
									F2DSEVector* Vertex = &(m_shapes(shape).Segments(seg).Vertex[vertex]);

									// Adjust temp positions
									Vertex->TempX += Delta.x;
									Vertex->TempY -= Delta.y;

									// Snap real positions to the grid.
									Vertex->X = Vertex->TempX;
									Vertex->Y = Vertex->TempY;
									*Vertex = Vertex->GridSnap( FVector(GGridSize, GGridSize, GGridSize) );
								}
								if( m_shapes(shape).Segments(seg).SegType == eSEGTYPE_BEZIER
										&& m_shapes(shape).Segments(seg).ControlPoint[vertex].IsSel() )
								{
									F2DSEVector* Vertex = &(m_shapes(shape).Segments(seg).ControlPoint[vertex]);

									// Adjust temp positions
									Vertex->TempX += Delta.x;
									Vertex->TempY -= Delta.y;

									// Snap real positions to the grid.
									Vertex->X = Vertex->TempX;
									Vertex->Y = Vertex->TempY;
									*Vertex = Vertex->GridSnap( FVector(GGridSize, GGridSize, GGridSize) );
								}
							}
						}

			}
		}

		m_pointOldPos = MouseLocation;
		ComputeHandlePositions();
		InvalidateRect( hWnd, NULL, FALSE );

		InvalidateRect( hWnd, NULL, FALSE );

		WWindow::OnMouseMove( Flags, MouseLocation );
	}
	void ComputeHandlePositions( UBOOL bAlwaysCompute = FALSE)
	{
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
			if( !m_shapes(shape).Handle.IsSel() || bAlwaysCompute )
				m_shapes(shape).ComputeHandlePosition();
		InvalidateRect( hWnd, NULL, FALSE );
	}
	void ChangeSegmentTypes( INT InType )
	{
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
				if( m_shapes(shape).Segments(seg).IsSel() )
					m_shapes(shape).Segments(seg).SetSegType(InType);

		InvalidateRect( hWnd, NULL, FALSE );
	}
	void SetSegmentDetail( INT InDetailLevel )
	{
		GDefaultDetailLevel = InDetailLevel;
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
				if( m_shapes(shape).Segments(seg).IsSel() )
					m_shapes(shape).Segments(seg).DetailLevel = InDetailLevel;

		InvalidateRect( hWnd, NULL, FALSE );
	}
	void OnLeftButtonDown()
	{
		SetCapture( hWnd );
		
		m_bDraggingVerts = TRUE;
		m_pointOldPos = GetCursorPos();

		if( GetAsyncKeyState(VK_CONTROL) & 0x8000 && GetAsyncKeyState(VK_MENU) & 0x8000 )
		{
			m_bBoxSel = 1;
			FLOAT pct = GZoom[Zoom].Mouse / 100.0f;
			BoxSelStart = BoxSelEnd = ToWorld( m_pointOldPos );

			BoxSelStart.X *= pct;
			BoxSelStart.Y *= pct;
			BoxSelStart.Y *= -1;

			BoxSelEnd.X *= pct;
			BoxSelEnd.Y *= pct;
			BoxSelEnd.Y *= -1;
		}
		else if( GetAsyncKeyState(VK_CONTROL) & 0x8000 )
			ProcessHits( 0, TRUE );
		else 
		{
			// If the user has clicked on a vertex, then select that vertex and put them into drag mode.  Otherwise,
			// leave the current selections alone and just drag them.
			if( ProcessHits( 1, TRUE ) )
				ProcessHits( 0, FALSE );
			else
				DeselectAllVerts();
		}

		// Set the temp positions on all vertices.
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			m_shapes(shape).Handle.SetTempPos();
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
				for( INT vertex = 0 ; vertex < 2 ; vertex++ )
				{
					m_shapes(shape).Segments(seg).Vertex[vertex].SetTempPos();
					m_shapes(shape).Segments(seg).ControlPoint[vertex].SetTempPos();
				}
		}

		InvalidateRect( hWnd, NULL, FALSE );

		WWindow::OnLeftButtonDown();
	}
	void OnLeftButtonUp()
	{
		ReleaseCapture();
		m_bDraggingVerts = FALSE;

		if( m_bBoxSel )
		{
			// Select everything inside the box.
			ProcessBoxSelHits( GetAsyncKeyState(VK_SHIFT) & 0x8000 );
		}
		else if( !m_bMouseHasMoved && !(GetAsyncKeyState(VK_CONTROL) & 0x8000) )
			DeselectAllVerts();
		ComputeHandlePositions();

		m_bBoxSel = 0;

		WWindow::OnLeftButtonUp();
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		PositionChildControls();
		WWindow::OnSize(Flags, NewX, NewY);
		InvalidateRect( hWnd, NULL, FALSE );
	}
	void PositionChildControls( void )
	{
		if( !::IsWindow( GetDlgItem( hWnd, ID_2DSE_TOOLBAR )))	return;

		LockWindowUpdate( hWnd );

		FRect CR = GetClientRect();
		RECT R;
		::GetWindowRect( GetDlgItem( hWnd, ID_2DSE_TOOLBAR ), &R );
		::MoveWindow( GetDlgItem( hWnd, ID_2DSE_TOOLBAR ), 0, 0, CR.Max.X, R.bottom, TRUE );

		LockWindowUpdate( NULL );
	}
	virtual void OnKeyDown( TCHAR Ch )
	{
		// Hot keys from old version
		if( Ch == 'I' && GetKeyState(VK_CONTROL) & 0x8000)
			SplitSides();
		if( Ch == VK_DELETE )
			Delete();
	}
	// Rotate the shapes by the speifued angle, around the origin,
	void RotateShape( INT _Angle )
	{
		FVector l_vec;
		FRotator StepRotation( 0, (65536.0f / 360.0f)  * _Angle, 0 );

		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
				for( INT vertex = 0 ; vertex < 2 ; vertex++ )
				{
					l_vec.X = m_shapes(shape).Segments(seg).Vertex[vertex].X;	l_vec.Y = m_shapes(shape).Segments(seg).Vertex[vertex].Y;	l_vec.Z = m_shapes(shape).Segments(seg).Vertex[vertex].Z;
					l_vec = m_origin + ( l_vec - m_origin ).TransformVectorBy( GMath.UnitCoords * StepRotation);

					m_shapes(shape).Segments(seg).Vertex[vertex].X = l_vec.X;	m_shapes(shape).Segments(seg).Vertex[vertex].Y = l_vec.Y;	m_shapes(shape).Segments(seg).Vertex[vertex].Z = l_vec.Z;
					m_shapes(shape).Segments(seg).Vertex[vertex] = m_shapes(shape).Segments(seg).Vertex[vertex].GridSnap( FVector( GGridSize, GGridSize, GGridSize ) );

					m_shapes(shape).Segments(seg).ControlPoint[vertex].X = l_vec.X;	m_shapes(shape).Segments(seg).ControlPoint[vertex].Y = l_vec.Y;	m_shapes(shape).Segments(seg).ControlPoint[vertex].Z = l_vec.Z;
					m_shapes(shape).Segments(seg).ControlPoint[vertex] = m_shapes(shape).Segments(seg).ControlPoint[vertex].GridSnap( FVector( GGridSize, GGridSize, GGridSize ) );
				}

		ComputeHandlePositions(1);
		InvalidateRect( hWnd, NULL, FALSE );
	}
	// Flips the shape across the origin.
	void Flip( BOOL _bHoriz )
	{
		// Flip the vertices across the origin.
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
			{
				for( INT vertex = 0 ; vertex < 2 ; vertex++ )
				{
					FVector Dist = m_shapes(shape).Segments(seg).Vertex[vertex] - m_origin;
					FVector CPDist = m_shapes(shape).Segments(seg).ControlPoint[vertex] - m_origin;

					if( _bHoriz )
					{
						m_shapes(shape).Segments(seg).Vertex[vertex].X -= (Dist.X * 2);
						m_shapes(shape).Segments(seg).ControlPoint[vertex].X -= (CPDist.X * 2);
					}
					else
					{
						m_shapes(shape).Segments(seg).Vertex[vertex].Y -= (Dist.Y * 2);
						m_shapes(shape).Segments(seg).ControlPoint[vertex].Y -= (CPDist.Y * 2);
					}
				}
				Exchange( m_shapes(shape).Segments(seg).Vertex[0], m_shapes(shape).Segments(seg).Vertex[1] );
				Exchange( m_shapes(shape).Segments(seg).ControlPoint[0], m_shapes(shape).Segments(seg).ControlPoint[1] );
			}
		}


		ComputeHandlePositions(1);
		InvalidateRect( hWnd, NULL, FALSE );
	}
	void DeselectAllVerts()
	{
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			m_shapes(shape).Handle.Select(0);
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
			{
				m_shapes(shape).Segments(seg).Vertex[0].Select(0);
				m_shapes(shape).Segments(seg).Vertex[1].Select(0);
				m_shapes(shape).Segments(seg).ControlPoint[0].Select(0);
				m_shapes(shape).Segments(seg).ControlPoint[1].Select(0);
			}
		}
		m_origin.Select(0);
	}
	FPoint ToWorld( FPoint InPoint )
	{
		FPoint WorldPoint = InPoint;
		WorldPoint.X += -m_camera.X - (m_rcWnd.right / 2);
		WorldPoint.Y += -m_camera.Y - (m_rcWnd.bottom / 2);
		return WorldPoint;
	}
	BOOL ProcessHits( BOOL bJustChecking, BOOL _bCumulative )
	{
		if( !_bCumulative )
			DeselectAllVerts();

		// Get the click position in world space.
		//
		FPoint l_click = GetCursorPos();
		l_click = ToWorld( l_click );

		//
		// See if any vertex comes within the selection radius to this point.  If so, select it...
		//

		// Check origin ...
		F2DSEVector l_vtxTest;
		l_vtxTest.X = (FLOAT)l_click.X - (m_origin.X * GZoom[Zoom].Factor);
		l_vtxTest.Y = (FLOAT)l_click.Y + (m_origin.Y * GZoom[Zoom].Factor);
		if( l_vtxTest.Size() <= d2dSE_SELECT_TOLERANCE )
		{
			if( !bJustChecking )
				m_origin.SelectToggle();
			return TRUE;
		}

		// Check shape handles...
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			l_vtxTest.X = (FLOAT)l_click.X - (m_shapes(shape).Handle.X * GZoom[Zoom].Factor);
			l_vtxTest.Y = (FLOAT)l_click.Y + (m_shapes(shape).Handle.Y * GZoom[Zoom].Factor);

			if( l_vtxTest.Size() <= d2dSE_SELECT_TOLERANCE )
			{
				if( !bJustChecking )
					m_shapes(shape).Handle.SelectToggle();
				return TRUE;
			}
		}

		// Check vertices...
		for( shape = 0 ; shape < m_shapes.Num() ; shape++ )
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
				for( INT vertex = 0 ; vertex < 2 ; vertex++ )
				{
					l_vtxTest.X = (FLOAT)l_click.X - (m_shapes(shape).Segments(seg).Vertex[vertex].X * GZoom[Zoom].Factor);
					l_vtxTest.Y = (FLOAT)l_click.Y + (m_shapes(shape).Segments(seg).Vertex[vertex].Y * GZoom[Zoom].Factor);

					if( l_vtxTest.Size() <= d2dSE_SELECT_TOLERANCE )
						if( bJustChecking )
							return TRUE;
						else
							m_shapes(shape).Segments(seg).Vertex[vertex].SelectToggle();

					l_vtxTest.X = (FLOAT)l_click.X - (m_shapes(shape).Segments(seg).ControlPoint[vertex].X * GZoom[Zoom].Factor);
					l_vtxTest.Y = (FLOAT)l_click.Y + (m_shapes(shape).Segments(seg).ControlPoint[vertex].Y * GZoom[Zoom].Factor);

					if( l_vtxTest.Size() <= d2dSE_SELECT_TOLERANCE )
						if( bJustChecking )
							return TRUE;
						else
							m_shapes(shape).Segments(seg).ControlPoint[vertex].SelectToggle();
				}

		return FALSE;
	}
	// Checks for hits inside the drag box
	BOOL IsInsideBox( F2DSEVector InVtx )
	{
		RECT rect = {
			BoxSelStart.X * GZoom[Zoom].Factor,
			BoxSelStart.Y * GZoom[Zoom].Factor,
			BoxSelEnd.X * GZoom[Zoom].Factor,
			BoxSelEnd.Y * GZoom[Zoom].Factor };
		if( rect.left > rect.right ) Exchange( rect.left, rect.right );
		if( rect.top > rect.bottom ) Exchange( rect.top, rect.bottom );

		if( InVtx.X >= rect.left
				&& InVtx.X <= rect.right
				&& InVtx.Y >= rect.top
				&& InVtx.Y <= rect.bottom )
			return TRUE;

		return FALSE;
	}
	void ProcessBoxSelHits( BOOL _bCumulative )
	{
		if( !_bCumulative )
			DeselectAllVerts();

		// Check origin ...
		F2DSEVector l_vtxTest;
		l_vtxTest.X = m_origin.X * GZoom[Zoom].Factor;
		l_vtxTest.Y = m_origin.Y * GZoom[Zoom].Factor;
		m_origin.Select( IsInsideBox( l_vtxTest ) || (_bCumulative && m_origin.IsSel()) );

		// Check shape handles...
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			l_vtxTest.X = m_shapes(shape).Handle.X * GZoom[Zoom].Factor;
			l_vtxTest.Y = m_shapes(shape).Handle.Y * GZoom[Zoom].Factor;
			m_shapes(shape).Handle.Select( IsInsideBox( l_vtxTest ) || (_bCumulative && m_shapes(shape).Handle.IsSel()) );
		}

		// Check vertices...
		for( shape = 0 ; shape < m_shapes.Num() ; shape++ )
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
				for( INT vertex = 0 ; vertex < 2 ; vertex++ )
				{
					l_vtxTest.X = m_shapes(shape).Segments(seg).Vertex[vertex].X * GZoom[Zoom].Factor;
					l_vtxTest.Y = m_shapes(shape).Segments(seg).Vertex[vertex].Y * GZoom[Zoom].Factor;
					m_shapes(shape).Segments(seg).Vertex[vertex].Select( IsInsideBox( l_vtxTest ) || (_bCumulative && m_shapes(shape).Segments(seg).Vertex[vertex].IsSel()) );

					l_vtxTest.X = m_shapes(shape).Segments(seg).ControlPoint[vertex].X * GZoom[Zoom].Factor;
					l_vtxTest.Y = m_shapes(shape).Segments(seg).ControlPoint[vertex].Y * GZoom[Zoom].Factor;
					m_shapes(shape).Segments(seg).ControlPoint[vertex].Select( IsInsideBox( l_vtxTest ) || (_bCumulative && m_shapes(shape).Segments(seg).ControlPoint[vertex].IsSel()) );
				}

	}
	void New( void )
	{
		m_camera.X = m_camera.Y = 0;
		m_origin.X = 0; m_origin.Y = 0;

		m_shapes.Empty();
		InsertNewShape();

		InvalidateRect( hWnd, NULL, FALSE );
	}
	void InsertNewShape()
	{
		F2DSEVector A(-128,-128,0), B(-128,128,0), C(128,128,0), D(128,-128,0);
		new(m_shapes)FShape();
		new(m_shapes(m_shapes.Num()-1).Segments)FSegment(A, B);
		new(m_shapes(m_shapes.Num()-1).Segments)FSegment(B, C);
		new(m_shapes(m_shapes.Num()-1).Segments)FSegment(C, D);
		new(m_shapes(m_shapes.Num()-1).Segments)FSegment(D, A);
		ComputeHandlePositions();
	}
	void DrawGrid( HDC _hdc )
	{
		INT l_iXStart, l_iYStart, l_iXEnd, l_iYEnd;
		FVector l_vecTopLeft;
		HPEN l_penOriginLines, l_penMajorLines, l_penMinorLines, l_penOld;

		FLOAT GGridSizeZoomSave = GGridSizeZoom;
		GGridSizeZoom = max( (GGridSizeZoom * (Zoom <= 1 ? Zoom : 1)), 8.0f);
		
		l_vecTopLeft.X = (m_camera.X * -1) - (m_rcWnd.right / 2);
		l_vecTopLeft.Y = (m_camera.Y * -1) - (m_rcWnd.bottom / 2);

		l_penMinorLines = CreatePen( PS_SOLID, 1, RGB( 235, 235, 235 ) );
		l_penMajorLines = CreatePen( PS_SOLID, 1, RGB( 215, 215, 215 ) );
		l_penOriginLines = CreatePen( PS_SOLID, 3, RGB( 225, 225, 225 ) );

		// Snap the starting position to the grid size.
		//
		l_iXStart = GGridSizeZoom - (int)l_vecTopLeft.X % GGridSizeZoom;
		l_iYStart = GGridSizeZoom - (int)l_vecTopLeft.Y % GGridSizeZoom;

		l_iXEnd = l_iXStart + m_rcWnd.right;
		l_iYEnd = l_iYStart + m_rcWnd.bottom;
		
		// Draw the lines.
		//
		l_penOld = (HPEN)SelectObject( _hdc, l_penMinorLines );

		for( INT y = l_iYStart ; y < l_iYEnd ; y += GGridSizeZoom )
		{
			if( l_vecTopLeft.Y + y == 0 )
				SelectObject( _hdc, l_penOriginLines );
			else
				if( !((int)(l_vecTopLeft.Y + y) % (int)(128 * GZoom[Zoom].Factor)) )
					SelectObject( _hdc, l_penMajorLines );
				else
					SelectObject( _hdc, l_penMinorLines );

			::MoveToEx( _hdc, 0, y, NULL );
			::LineTo( _hdc, m_rcWnd.right, y );
		}

		for( INT x = l_iXStart ; x < l_iXEnd ; x += GGridSizeZoom )
		{
			if( l_vecTopLeft.X + x == 0 )
				SelectObject( _hdc, l_penOriginLines );
			else
				if( !((int)(l_vecTopLeft.X + x) % (int)(128 * GZoom[Zoom].Factor)) )
					SelectObject( _hdc, l_penMajorLines );
				else
					SelectObject( _hdc, l_penMinorLines );

			::MoveToEx( _hdc, x, 0, NULL );
			::LineTo( _hdc, x, m_rcWnd.bottom );
		}

		GGridSizeZoom = GGridSizeZoomSave;

		SelectObject( _hdc, l_penOld );
		DeleteObject( l_penOriginLines );
		DeleteObject( l_penMinorLines );
		DeleteObject( l_penMajorLines );
	}
	void DrawImage( HDC _hdc )
	{
		if( !hImage ) return;

		HDC hdcMem;
		HBITMAP hbmOld;
		BITMAP bitmap;
		FVector l_vecLoc;

		l_vecLoc.X = m_camera.X + (m_rcWnd.right / 2);
		l_vecLoc.Y = m_camera.Y + (m_rcWnd.bottom / 2);

		// Prepare the bitmap.
		//
		GetObjectA( hImage, sizeof(BITMAP), (LPSTR)&bitmap );
		hdcMem = CreateCompatibleDC(_hdc);
		hbmOld = (HBITMAP)SelectObject(hdcMem, hImage);

		// Display it.
		//
		StretchBlt(_hdc,
			   l_vecLoc.X - ((bitmap.bmWidth * GZoom[Zoom].Factor) / 2), l_vecLoc.Y - ((bitmap.bmHeight * GZoom[Zoom].Factor) / 2),
			   bitmap.bmWidth * GZoom[Zoom].Factor, bitmap.bmHeight * GZoom[Zoom].Factor,
			   hdcMem,
			   0, 0,
			   bitmap.bmWidth, bitmap.bmHeight,
			   SRCCOPY);

		// Clean up.
		//
		SelectObject(hdcMem, hbmOld);
		DeleteDC(hdcMem);
	}
	void DrawOrigin( HDC _hdc )
	{
		HPEN l_pen, l_penSel, l_penOld;

		FVector l_vecLoc = m_camera;
		l_vecLoc.X += m_rcWnd.right / 2;
		l_vecLoc.Y += m_rcWnd.bottom / 2;

		l_pen = CreatePen( PS_SOLID, 2, RGB( 0, 255, 0 ) );
		l_penSel = CreatePen( PS_SOLID, 4, RGB( 255, 0, 0 ) );

		l_penOld = (HPEN)SelectObject( _hdc, (m_origin.IsSel() ? l_penSel : l_pen) );
		Rectangle( _hdc,
			l_vecLoc.X + (m_origin.X * GZoom[Zoom].Factor) - 4,
			l_vecLoc.Y - (m_origin.Y * GZoom[Zoom].Factor) + 4,
			l_vecLoc.X + (m_origin.X * GZoom[Zoom].Factor) + 4,
			l_vecLoc.Y - (m_origin.Y * GZoom[Zoom].Factor) - 4 );

		SelectObject( _hdc, l_penOld );
		DeleteObject( l_pen );
		DeleteObject( l_penSel );
	}
	void DrawSegments( HDC _hdc )
	{
		FVector l_vecLoc = m_camera;
		HPEN l_penLine, l_penBold, l_penCP, l_penCPBold, l_penOld;

		l_penLine = CreatePen( PS_SOLID, 1, RGB( 128, 128, 128 ) );
		l_penBold = CreatePen( PS_SOLID, 3, RGB( 128, 128, 128 ) );
		l_penCP = CreatePen( PS_SOLID, 1, RGB( 0, 0, 255 ) );
		l_penCPBold = CreatePen( PS_SOLID, 2, RGB( 0, 0, 255 ) );

		// Figure out where the top left corner of the window is in world coords.
		//
		l_vecLoc.X += m_rcWnd.right / 2;
		l_vecLoc.Y += m_rcWnd.bottom / 2;

		l_penOld = (HPEN)SelectObject( _hdc, l_penLine );

		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
			{
				switch( m_shapes(shape).Segments(seg).SegType )
				{
					case eSEGTYPE_LINEAR:
						SelectObject( _hdc, (m_shapes(shape).Segments(seg).IsSel() ? l_penBold : l_penLine) );
						::MoveToEx( _hdc,
							l_vecLoc.X + (m_shapes(shape).Segments(seg).Vertex[0].X * GZoom[Zoom].Factor),
							l_vecLoc.Y - (m_shapes(shape).Segments(seg).Vertex[0].Y * GZoom[Zoom].Factor), NULL );
						::LineTo( _hdc,
							l_vecLoc.X + (m_shapes(shape).Segments(seg).Vertex[1].X * GZoom[Zoom].Factor),
							l_vecLoc.Y - (m_shapes(shape).Segments(seg).Vertex[1].Y * GZoom[Zoom].Factor) );
						break;

					case eSEGTYPE_BEZIER:

						// Generate list of vertices for bezier curve and render them as a line.
						TArray<FVector> BezierPoints;
						m_shapes(shape).Segments(seg).GetBezierPoints( &BezierPoints );
						SelectObject( _hdc, (m_shapes(shape).Segments(seg).IsSel() ? l_penBold : l_penLine) );

						for( INT bz = 0 ; bz < BezierPoints.Num() - 1 ; bz++ )
						{
							::MoveToEx( _hdc,
								l_vecLoc.X + (BezierPoints(bz).X * GZoom[Zoom].Factor),
								l_vecLoc.Y - (BezierPoints(bz).Y * GZoom[Zoom].Factor), NULL );
							::LineTo( _hdc,
								l_vecLoc.X + (BezierPoints(bz+1) * GZoom[Zoom].Factor).X,
								l_vecLoc.Y - (BezierPoints(bz+1) * GZoom[Zoom].Factor).Y );
						}

						// Render the control points and connecting lines.
						SelectObject( _hdc, (m_shapes(shape).Segments(seg).ControlPoint[0].IsSel() ? l_penCPBold : l_penCP) );
						::MoveToEx( _hdc,
							l_vecLoc.X + (m_shapes(shape).Segments(seg).Vertex[0].X * GZoom[Zoom].Factor),
							l_vecLoc.Y - (m_shapes(shape).Segments(seg).Vertex[0].Y * GZoom[Zoom].Factor), NULL );
						::LineTo( _hdc,
							l_vecLoc.X + (m_shapes(shape).Segments(seg).ControlPoint[0].X * GZoom[Zoom].Factor),
							l_vecLoc.Y - (m_shapes(shape).Segments(seg).ControlPoint[0].Y * GZoom[Zoom].Factor) );

						SelectObject( _hdc, (m_shapes(shape).Segments(seg).ControlPoint[1].IsSel() ? l_penCPBold : l_penCP) );
						::MoveToEx( _hdc,
							l_vecLoc.X + (m_shapes(shape).Segments(seg).Vertex[1].X * GZoom[Zoom].Factor),
							l_vecLoc.Y - (m_shapes(shape).Segments(seg).Vertex[1].Y * GZoom[Zoom].Factor), NULL );
						::LineTo( _hdc,
							l_vecLoc.X + (m_shapes(shape).Segments(seg).ControlPoint[1].X * GZoom[Zoom].Factor),
							l_vecLoc.Y - (m_shapes(shape).Segments(seg).ControlPoint[1].Y * GZoom[Zoom].Factor) );
						break;
				}
			}
		}

		SelectObject( _hdc, l_penOld );
		DeleteObject( l_penLine );
		DeleteObject( l_penBold );
		DeleteObject( l_penCP );
		DeleteObject( l_penCPBold );
	}
	void DrawShapeHandles( HDC _hdc )
	{
		FVector l_vecLoc = m_camera;
		HPEN l_penLine, l_penBold, l_penOld;

		l_penLine = CreatePen( PS_SOLID, 1, RGB( 255, 128, 0 ) );
		l_penBold = CreatePen( PS_SOLID, 3, RGB( 255, 128, 0 ) );

		// Figure out where the top left corner of the window is in world coords.
		//
		l_vecLoc.X += m_rcWnd.right / 2;
		l_vecLoc.Y += m_rcWnd.bottom / 2;

		l_penOld = (HPEN)SelectObject( _hdc, l_penLine );

		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			SelectObject( _hdc, (m_shapes(shape).Handle.IsSel() ? l_penBold : l_penLine) );
			Rectangle( _hdc,
				l_vecLoc.X + (m_shapes(shape).Handle.X * GZoom[Zoom].Factor) - 4,
				l_vecLoc.Y - (m_shapes(shape).Handle.Y * GZoom[Zoom].Factor) + 4,
				l_vecLoc.X + (m_shapes(shape).Handle.X * GZoom[Zoom].Factor) + 4,
				l_vecLoc.Y - (m_shapes(shape).Handle.Y * GZoom[Zoom].Factor) - 4 );
		}

		SelectObject( _hdc, l_penOld );
		DeleteObject( l_penLine );
		DeleteObject( l_penBold );
	}
	void DrawVertices( HDC _hdc )
	{
		FVector l_vecLoc = m_camera;
		HPEN l_penVertex, l_penVertexBold, l_penCP, l_penCPBold, l_penOld;

		l_penVertex = CreatePen( PS_SOLID, 1, RGB( 0, 0, 0 ) );
		l_penVertexBold = CreatePen( PS_SOLID, 3, RGB( 255, 0, 0 ) );
		l_penCP = CreatePen( PS_SOLID, 1, RGB( 0, 0, 255 ) );
		l_penCPBold = CreatePen( PS_SOLID, 3, RGB( 0, 0, 255 ) );

		// Figure out where the top left corner of the window is in world coords.
		//
		l_vecLoc.X += m_rcWnd.right / 2;
		l_vecLoc.Y += m_rcWnd.bottom / 2;

		// Draw the vertices.
		//
		l_penOld = (HPEN)SelectObject( _hdc, l_penVertex );
		HBRUSH OldBrush = (HBRUSH)SelectObject( _hdc, GetStockObject(WHITE_BRUSH) );

		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
				for( INT vertex = 0 ; vertex < 2 ; vertex++ )
				{
					SelectObject( _hdc, (m_shapes(shape).Segments(seg).Vertex[vertex].IsSel() ? l_penVertexBold : l_penVertex) );
					Rectangle( _hdc,
						l_vecLoc.X + (m_shapes(shape).Segments(seg).Vertex[vertex].X * GZoom[Zoom].Factor) - 4,
						l_vecLoc.Y - (m_shapes(shape).Segments(seg).Vertex[vertex].Y * GZoom[Zoom].Factor) + 4,
						l_vecLoc.X + (m_shapes(shape).Segments(seg).Vertex[vertex].X * GZoom[Zoom].Factor) + 4,
						l_vecLoc.Y - (m_shapes(shape).Segments(seg).Vertex[vertex].Y * GZoom[Zoom].Factor) - 4 );

					if( m_shapes(shape).Segments(seg).SegType == eSEGTYPE_BEZIER )
					{
						SelectObject( _hdc, (m_shapes(shape).Segments(seg).ControlPoint[vertex].IsSel() ? l_penCPBold : l_penCP) );
						Rectangle( _hdc,
							l_vecLoc.X + (m_shapes(shape).Segments(seg).ControlPoint[vertex].X * GZoom[Zoom].Factor) - 4,
							l_vecLoc.Y - (m_shapes(shape).Segments(seg).ControlPoint[vertex].Y * GZoom[Zoom].Factor) + 4,
							l_vecLoc.X + (m_shapes(shape).Segments(seg).ControlPoint[vertex].X * GZoom[Zoom].Factor) + 4,
							l_vecLoc.Y - (m_shapes(shape).Segments(seg).ControlPoint[vertex].Y * GZoom[Zoom].Factor) - 4 );
					}
				}

		SelectObject( _hdc, l_penOld );
		SelectObject( _hdc, OldBrush );
		DeleteObject( l_penVertex );
		DeleteObject( l_penVertexBold );
		DeleteObject( l_penCP );
		DeleteObject( l_penCPBold );
	}
	void DrawBoxSel( HDC _hdc )
	{
		if( !m_bBoxSel ) return;

		FVector l_vecLoc = m_camera;
		HPEN l_pen, l_penOld;

		l_pen = CreatePen( PS_SOLID, 1, RGB( 255, 0, 0 ) );

		// Figure out where the top left corner of the window is in world coords.
		//
		l_vecLoc.X += m_rcWnd.right / 2;
		l_vecLoc.Y += m_rcWnd.bottom / 2;

		// Draw the box.
		//
		l_penOld = (HPEN)SelectObject( _hdc, l_pen );
		HBRUSH OldBrush = (HBRUSH)SelectObject( _hdc, GetStockObject(NULL_BRUSH) );

		SelectObject( _hdc, l_pen );
		RECT rect =
		{
			l_vecLoc.X + BoxSelStart.X * GZoom[Zoom].Factor,
			l_vecLoc.Y - BoxSelStart.Y * GZoom[Zoom].Factor,
			l_vecLoc.X + BoxSelEnd.X * GZoom[Zoom].Factor,
			l_vecLoc.Y - BoxSelEnd.Y * GZoom[Zoom].Factor
		};
		// Rectangle must be normalized before being passed to DrawFocusRect
		if( rect.left > rect.right ) Exchange( rect.left, rect.right );
		if( rect.top > rect.bottom ) Exchange( rect.top, rect.bottom );
		DrawFocusRect( _hdc, &rect );

		SelectObject( _hdc, l_penOld );
		SelectObject( _hdc, OldBrush );
		DeleteObject( l_pen );
	}
	// Splits all selected sides in half.
	void SplitSides( void )
	{
		// Break each selected segment into two.
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
				if( m_shapes(shape).Segments(seg).IsSel() )
				{
					// Create a new segment half the size of this one, starting from the middle and extending
					// to the second vertex.
					FVector HalfWay = m_shapes(shape).Segments(seg).GetHalfwayPoint();
					new(m_shapes(shape).Segments)FSegment( HalfWay, m_shapes(shape).Segments(seg).Vertex[1] );

					// Move the original segments ending point to the halfway point.
					m_shapes(shape).Segments(seg).Vertex[1] = HalfWay;
				}

		ComputeHandlePositions();
		InvalidateRect( hWnd, NULL, FALSE );
	}
	void Delete( void )
	{
		// Delete any vertices which are selected on the current shape.
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			if( m_shapes(shape).Handle.IsSel() )
			{
				m_shapes.Remove(shape);
				shape = 0;
			}
			else
				if( m_shapes(shape).Segments.Num() > 3 )
					for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
						if( m_shapes(shape).Segments(seg).IsSel() )
						{
							FVector HalfWay = m_shapes(shape).Segments(seg).GetHalfwayPoint();
							F2DSEVector v1, v2;

							v1 = m_shapes(shape).Segments(seg).Vertex[0];
							v2 = m_shapes(shape).Segments(seg).Vertex[1];

							m_shapes(shape).Segments.Remove(seg);

							for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
							{
								if( m_shapes(shape).Segments(seg).Vertex[0] == v2 )
									m_shapes(shape).Segments(seg).Vertex[0] = HalfWay;
								if( m_shapes(shape).Segments(seg).Vertex[1] == v1 )
									m_shapes(shape).Segments(seg).Vertex[1] = HalfWay;
							}
						}
		}
				
		ComputeHandlePositions();
		InvalidateRect( hWnd, NULL, FALSE );
	}
	void FileSaveAs( HWND hWnd )
	{
		OPENFILENAMEA ofn;
		char File[8192] = "\0";
		strcpy( File, TCHAR_TO_ANSI( MapFilename ) );

		ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
		ofn.lStructSize = sizeof(OPENFILENAMEA);
		ofn.hwndOwner = hWnd;
		ofn.lpstrFile = File;
		ofn.nMaxFile = sizeof(char) * 8192;
		ofn.lpstrFilter = "2D Shapes (*.2ds)\0*.2ds\0All Files\0*.*\0\0";
		ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_2DS]) );
		ofn.lpstrDefExt = "2ds";
		ofn.lpstrTitle = "Save 2D Shape";
		ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR | OFN_OVERWRITEPROMPT;

		// Display the Open dialog box. 
		//
		if( GetSaveFileNameA(&ofn) )
		{
			appStrcpy( MapFilename, appFromAnsi( File ) );
			WriteShape( MapFilename );

			FString S = MapFilename;
			GLastDir[eLASTDIR_2DS] = S.Left( S.InStr( TEXT("\\"), 1 ) );

			mrulist->AddItem( S );
			mrulist->AddToMenu( hWnd, GetMenu( hWnd ) );
		}

		SetCaption();
	}
	void FileSave( HWND hWnd )
	{
		if( ::appStrlen( MapFilename ) )
			WriteShape( MapFilename );
		else
			FileSaveAs( hWnd );
	}
	void FileOpen( HWND hWnd )
	{
		OPENFILENAMEA ofn;
		char File[8192] = "\0";

		ZeroMemory(&ofn, sizeof(OPENFILENAMEA));
		ofn.lStructSize = sizeof(OPENFILENAMEA);
		ofn.hwndOwner = hWnd;
		ofn.lpstrFile = File;
		ofn.nMaxFile = sizeof(char) * 8192;
		ofn.lpstrFilter = "2D Shapes (*.2ds)\0*.2ds\0All Files\0*.*\0\0";
		ofn.lpstrInitialDir = appToAnsi( *(GLastDir[eLASTDIR_2DS]) );
		ofn.lpstrDefExt = "2ds";
		ofn.lpstrTitle = "Open 2D Shape";
		ofn.Flags = OFN_HIDEREADONLY | OFN_NOCHANGEDIR;

		// Display the Open dialog box. 
		//
		if( GetOpenFileNameA(&ofn) )
		{
			appStrcpy( MapFilename, appFromAnsi( File ) );
			ReadShape( MapFilename );
			SetCaption();

			FString S = MapFilename;
			GLastDir[eLASTDIR_2DS] = S.Left( S.InStr( TEXT("\\"), 1 ) );

			mrulist->AddItem( S );
			mrulist->AddToMenu( hWnd, GetMenu( hWnd ) );
		}
	}
	void SetCaption( void )
	{
		TCHAR l_chCaption[256];

		appSprintf( l_chCaption, TEXT("2D Shape Editor - [%s]"), MapFilename );
		SetText( l_chCaption );
	}
	void WriteShape( TCHAR* Filename )
	{
		FArchive* Archive;
		Archive = GFileManager->CreateFileWriter( Filename );

		if( Archive )
		{
			// Origin
			//
			*Archive << m_origin.X << m_origin.Y;

			// Shapes
			//
			INT Num = m_shapes.Num();
			*Archive << Num;
			for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
			{
				Num = m_shapes(shape).Segments.Num();
				*Archive << Num;
				for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
				{
					FSegment* pSeg = &(m_shapes(shape).Segments(seg));
					*Archive 
						<< pSeg->Vertex[0].X
						<< pSeg->Vertex[0].Y
						<< pSeg->Vertex[0].Z
						<< pSeg->Vertex[1].X
						<< pSeg->Vertex[1].Y
						<< pSeg->Vertex[1].Z
						<< pSeg->ControlPoint[0].X
						<< pSeg->ControlPoint[0].Y
						<< pSeg->ControlPoint[0].Z
						<< pSeg->ControlPoint[1].X
						<< pSeg->ControlPoint[1].Y
						<< pSeg->ControlPoint[1].Z
						<< pSeg->SegType
						<< pSeg->DetailLevel;
				}
			}

			Archive->Close();
		}
	}
	void ReadShape( TCHAR* Filename )
	{
		FArchive* Archive;
		Archive = GFileManager->CreateFileReader( Filename );

		if( Archive )
		{
			m_camera.X = m_camera.Y = 0;
			m_shapes.Empty();

			// Origin
			//
			Archive->Serialize( &m_origin.X, sizeof(FLOAT) );
			Archive->Serialize( &m_origin.Y, sizeof(FLOAT) );
			

			// Shapes
			//
			INT NumShapes;
			Archive->Serialize( &NumShapes, sizeof(int) );

			for( INT shape = 0 ; shape < NumShapes ; shape++ )
			{
				new(m_shapes)FShape();

				INT NumSegments;
				Archive->Serialize( &NumSegments, sizeof(int) );

				for( INT seg = 0 ; seg < NumSegments ; seg++ )
				{
					new(m_shapes(shape).Segments)FSegment;
					FSegment* pSeg = &(m_shapes(shape).Segments(seg));
					Archive->Serialize( &(pSeg->Vertex[0].X), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->Vertex[0].Y), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->Vertex[0].Z), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->Vertex[1].X), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->Vertex[1].Y), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->Vertex[1].Z), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->ControlPoint[0].X), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->ControlPoint[0].Y), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->ControlPoint[0].Z), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->ControlPoint[1].X), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->ControlPoint[1].Y), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->ControlPoint[1].Z), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->SegType), sizeof(FLOAT) );
					Archive->Serialize( &(pSeg->DetailLevel), sizeof(FLOAT) );
				}
				ComputeHandlePositions();
			}

			Archive->Close();
		}

		InvalidateRect( hWnd, NULL, FALSE );
	}
	void SetOrigin( void )
	{
		POINT l_click = m_ContextPos;

		l_click.x += -m_camera.X - (m_rcWnd.right / 2);
		l_click.y += -m_camera.Y - (m_rcWnd.bottom / 2);

		l_click.x -= l_click.x % GGridSize;
		l_click.y -= l_click.y % GGridSize;

		m_origin.X = l_click.x;
		m_origin.Y = -l_click.y;

		InvalidateRect( hWnd, NULL, FALSE );
	}
	void RotateBuilderBrush( INT Axis )
	{

		// Rotate the builder brush to match the axis requested.
		FRotator Rot;
		switch(Axis)
		{
			case AXIS_X:	Rot = FRotator(0,16384,16384);	break;
			case AXIS_Y:	Rot = FRotator(0,0,16384);		break;
			case AXIS_Z:	Rot = FRotator(0,0,0);			break;
		};

		ABrush* Brush = GEditor->Level->Brush();
		for( INT poly = 0 ; poly < GEditor->Level->Brush()->Brush->Polys->Element.Num() ; poly++ )
		{
			FPoly* Poly = &(Brush->Brush->Polys->Element(poly));
			for( INT vtx = 0 ; vtx < Poly->NumVertices ; vtx++ )
				Poly->Vertex[vtx] = Brush->PrePivot + ( Poly->Vertex[vtx] - Brush->PrePivot ).TransformVectorBy( GMath.UnitCoords * Rot );
			Poly->Base = Poly->Vertex[0];

			Poly->TextureU = FVector(0,0,0);
			Poly->TextureV = FVector(0,0,0);
		}
		GEditor->edactApplyTransformToBrush( Brush );
		Brush->Brush->BuildBound();
		GEditor->RedrawLevel( GEditor->Level );
	}
	void ProcessSheet()
	{
		FString Cmd;

		// Reverse the Y Axis
		Flip(0);

		Cmd += TEXT("BRUSH SET\n\n");

		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			FPolyBreaker breaker;
			m_shapes(shape).Breakdown(m_origin, &breaker);

			for( INT poly = 0 ; poly < breaker.FinalPolys.Num() ; poly++ )
			{
				Cmd += TEXT("Begin Polygon Flags=8\n");
				for( INT vtx = 0 ; vtx < breaker.FinalPolys(poly).NumVertices ; vtx++ )
				{
					Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
						breaker.FinalPolys(poly).Vertex[vtx].X,
						breaker.FinalPolys(poly).Vertex[vtx].Y,
						breaker.FinalPolys(poly).Vertex[vtx].Z ) );
				}
				Cmd += TEXT("End Polygon\n");
			}
		}

		Flip(0);

		GEditor->Exec( *Cmd );
	}
	void ProcessExtrude( INT Depth )
	{
		// Reverse the Y Axis
		Flip(0);

		FString Cmd;

		Cmd += TEXT("BRUSH SET\n\n");

		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			FPolyBreaker breaker;
			m_shapes(shape).Breakdown(m_origin, &breaker);

			for( INT poly = 0 ; poly < breaker.FinalPolys.Num() ; poly++ )
			{
				Cmd += TEXT("Begin Polygon Flags=0\n");
				for( INT vtx = 0 ; vtx < breaker.FinalPolys(poly).NumVertices ; vtx++ )
				{
					Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
						breaker.FinalPolys(poly).Vertex[vtx].X,
						breaker.FinalPolys(poly).Vertex[vtx].Y,
						Depth / 2.0f ) );
				}
				Cmd += TEXT("End Polygon\n");

				Cmd += TEXT("Begin Polygon Flags=0\n");
				for( vtx = breaker.FinalPolys(poly).NumVertices-1 ; vtx > -1 ; vtx-- )
				{
					Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
						breaker.FinalPolys(poly).Vertex[vtx].X,
						breaker.FinalPolys(poly).Vertex[vtx].Y,
						-(Depth / 2.0f) ) );
				}
				Cmd += TEXT("End Polygon\n");
			}

			// Sides ...
			//
			for( INT vtx = 0 ; vtx < m_shapes(shape).Verts.Num() ; vtx++ )
			{
				Cmd += TEXT("Begin Polygon Flags=0\n");

				FVector* pvtxPrev = &m_shapes(shape).Verts( (vtx ? vtx - 1 : m_shapes(shape).Verts.Num() - 1 ) );
				FVector* pvtx = &m_shapes(shape).Verts(vtx);

				Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
					pvtx->X, pvtx->Y, Depth / 2.0f ) );

				Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
					 pvtxPrev->X, pvtxPrev->Y, Depth / 2.0f ) );

				Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
					 pvtxPrev->X, pvtxPrev->Y, -(Depth / 2.0f) ) );

				Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
					 pvtx->X, pvtx->Y, -(Depth / 2.0f) ) );

				Cmd += TEXT("End Polygon\n");
			}
		}

		GEditor->Exec( *Cmd );

		Flip(0);
	}
	void ProcessExtrudeToPoint( INT Depth )
	{
		// Flip the Y Axis
		Flip(0);

		FString Cmd;

		Cmd += TEXT("BRUSH SET\n\n");

		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			FPolyBreaker breaker;
			m_shapes(shape).Breakdown(m_origin, &breaker);

			for( INT poly = 0 ; poly < breaker.FinalPolys.Num() ; poly++ )
			{
				Cmd += TEXT("Begin Polygon Flags=0\n");
				for( INT vtx = breaker.FinalPolys(poly).NumVertices-1 ; vtx > -1 ; vtx-- )
				{
					Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
						breaker.FinalPolys(poly).Vertex[vtx].X,
						breaker.FinalPolys(poly).Vertex[vtx].Y,
						0.0f ) );
				}
				Cmd += TEXT("End Polygon\n");
			}

			// Sides ...
			//
			for( INT vtx = 0 ; vtx < m_shapes(shape).Verts.Num() ; vtx++ )
			{
				Cmd += TEXT("Begin Polygon Flags=0\n");

				FVector* pvtxPrev = &( m_shapes(shape).Verts( (vtx ? vtx - 1 : m_shapes(shape).Verts.Num() - 1 ) ) );
				FVector* pvtx = &( m_shapes(shape).Verts(vtx) );

				Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
					pvtxPrev->X, pvtxPrev->Y, pvtxPrev->Z ));
				Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
					pvtx->X, pvtx->Y, pvtx->Z ));
				Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
					0.0f, 0.0f, (FLOAT)Depth ));

				Cmd += TEXT("End Polygon\n");
			}
		}

		GEditor->Exec( *Cmd );

		Flip(0);
	}
	void ProcessExtrudeToBevel( INT Depth, INT CapHeight )
	{
		// Flip the Y Axis
		Flip(0);

		FString Cmd;
		FLOAT Dist = 1.0f - (CapHeight / (FLOAT)Depth);

		Cmd += TEXT("BRUSH SET\n\n");

		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			FPolyBreaker breaker;
			m_shapes(shape).Breakdown(m_origin, &breaker);

			for( INT poly = 0 ; poly < breaker.FinalPolys.Num() ; poly++ )
			{
				Cmd += TEXT("Begin Polygon Flags=0\n");
				for( INT vtx = breaker.FinalPolys(poly).NumVertices-1 ; vtx > -1 ; vtx-- )
				{
					Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
						breaker.FinalPolys(poly).Vertex[vtx].X,
						breaker.FinalPolys(poly).Vertex[vtx].Y,
						0.0f ) );
				}
				Cmd += TEXT("End Polygon\n");

				Cmd += TEXT("Begin Polygon Flags=0\n");
				for( vtx = 0 ; vtx < breaker.FinalPolys(poly).NumVertices ; vtx++ )
				{
					Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
						breaker.FinalPolys(poly).Vertex[vtx].X * Dist,
						breaker.FinalPolys(poly).Vertex[vtx].Y * Dist,
						(FLOAT)CapHeight ) );
				}
				Cmd += TEXT("End Polygon\n");
			}

			// Sides ...
			//
			for( INT vtx = 0 ; vtx < m_shapes(shape).Verts.Num() ; vtx++ )
			{
				Cmd += TEXT("Begin Polygon Flags=0\n");

				FVector* pvtxPrev = &( m_shapes(shape).Verts( (vtx ? vtx - 1 : m_shapes(shape).Verts.Num() - 1 ) ) );
				FVector* pvtx = &( m_shapes(shape).Verts(vtx) );

				Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
					pvtxPrev->X, pvtxPrev->Y, pvtxPrev->Z ));
				Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
					pvtx->X, pvtx->Y, pvtx->Z ));

				Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
					pvtx->X * Dist, pvtx->Y * Dist, (FLOAT)CapHeight ));
				Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
					pvtxPrev->X * Dist, pvtxPrev->Y * Dist, (FLOAT)CapHeight ));

				Cmd += TEXT("End Polygon\n");
			}
		}

		GEditor->Exec( *Cmd );

		Flip(0);
	}
	void ProcessRevolve( INT TotalSides, INT Sides )
	{
		BOOL bPositive, bNegative, bBrushSetDone = FALSE;
		BOOL bFromLeftSide;

		// Make sure the origin is totally to the left or right of the shape.
		bPositive = bNegative = FALSE;
		for( INT shape = 0 ; shape < m_shapes.Num() ; shape++ )
			for( INT seg = 0 ; seg < m_shapes(shape).Segments.Num() ; seg++ )
				for( INT vtx = 0 ; vtx < 2 ; vtx++ )
				{
					if( m_origin.X > m_shapes(shape).Segments(seg).Vertex[vtx].X )		bPositive = TRUE;
					if( m_origin.X < m_shapes(shape).Segments(seg).Vertex[vtx].X )		bNegative = TRUE;
				}

		if( bPositive && bNegative )
		{
			appMsgf( TEXT("Origin must be completely to the left or right side of the shape.") );
			return;
		}

		// When revolving from the left side, we have to flip the polys around.
		bFromLeftSide = ( bNegative && !bPositive );

		// Flip the Y Axis
		Flip(0);

		FString Cmd;

		Cmd += TEXT("BRUSH SET\n\n");

		for( shape = 0 ; shape < m_shapes.Num() ; shape++ )
		{
			FPolyBreaker breaker;
			m_shapes(shape).Breakdown(m_origin, &breaker);

			if( Sides != TotalSides )	// Don't make end caps for a complete revolve
			{
				for( INT poly = 0 ; poly < breaker.FinalPolys.Num() ; poly++ )
				{
					if( bFromLeftSide )
					{
						Cmd += TEXT("Begin Polygon Flags=0\n");
						for( INT vtx = breaker.FinalPolys(poly).NumVertices-1 ; vtx > -1 ; vtx-- )
						{
							Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
								breaker.FinalPolys(poly).Vertex[vtx].X,
								breaker.FinalPolys(poly).Vertex[vtx].Y,
								breaker.FinalPolys(poly).Vertex[vtx].Z ) );
						}
						Cmd += TEXT("End Polygon\n");

						FRotator Rotation( (65536.0f / TotalSides) * Sides, 0, 0 );

						Cmd += TEXT("Begin Polygon Flags=0\n");
						for( vtx = 0 ; vtx < breaker.FinalPolys(poly).NumVertices ; vtx++ )
						{
							FVector NewVtx = breaker.FinalPolys(poly).Vertex[vtx].TransformVectorBy( GMath.UnitCoords * Rotation );

							Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
								NewVtx.X, NewVtx.Y, NewVtx.Z ) );
						}
						Cmd += TEXT("End Polygon\n");
					}
					else
					{
						Cmd += TEXT("Begin Polygon Flags=0\n");
						for( INT vtx = 0 ; vtx < breaker.FinalPolys(poly).NumVertices ; vtx++ )
						{
							Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
								breaker.FinalPolys(poly).Vertex[vtx].X,
								breaker.FinalPolys(poly).Vertex[vtx].Y,
								breaker.FinalPolys(poly).Vertex[vtx].Z ) );
						}
						Cmd += TEXT("End Polygon\n");

						FRotator Rotation( (65536.0f / TotalSides) * Sides, 0, 0 );

						Cmd += TEXT("Begin Polygon Flags=0\n");
						for( vtx = breaker.FinalPolys(poly).NumVertices-1 ; vtx > -1 ; vtx-- )
						{
							FVector NewVtx = breaker.FinalPolys(poly).Vertex[vtx].TransformVectorBy( GMath.UnitCoords * Rotation );

							Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
								NewVtx.X, NewVtx.Y, NewVtx.Z ) );
						}
						Cmd += TEXT("End Polygon\n");
					}
				}
			}

			// Sides ...
			//
			for( INT side = 0 ; side < Sides ; side++ )
				for( INT vtx = 0 ; vtx < m_shapes(shape).Verts.Num() ; vtx++ )
				{
					Cmd += TEXT("Begin Polygon Flags=0\n");

					FVector *pvtx, *pvtxPrev;

					pvtxPrev = &( m_shapes(shape).Verts( (vtx ? vtx - 1 : m_shapes(shape).Verts.Num() - 1 ) ) );
					pvtx = &( m_shapes(shape).Verts(vtx) );

					if( bFromLeftSide )	Exchange( pvtxPrev, pvtx );

					FRotator StepRotation( (65536.0f / TotalSides) * side, 0, 0 ), StepRotation2( (65536.0f / TotalSides) * (side+1), 0, 0 );

					FVector vtxPrev = pvtxPrev->TransformVectorBy( GMath.UnitCoords * StepRotation );
					FVector vtx = pvtx->TransformVectorBy( GMath.UnitCoords * StepRotation );
					FVector vtxPrev2 = pvtxPrev->TransformVectorBy( GMath.UnitCoords * StepRotation2 );
					FVector vtx2 = pvtx->TransformVectorBy( GMath.UnitCoords * StepRotation2 );

					Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
						vtx.X, vtx.Y, vtx.Z ));
					Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
						vtxPrev.X, vtxPrev.Y, vtxPrev.Z ));

					Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
						vtxPrev2.X, vtxPrev2.Y, vtxPrev2.Z ));
					Cmd += *(FString::Printf(TEXT("Vertex   %1.1f, %1.1f, %1.1f\n"),
						vtx2.X, vtx2.Y, vtx2.Z ));

					Cmd += TEXT("End Polygon\n");
				}
		}

		GEditor->Exec( *Cmd );

		Flip(0);
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
