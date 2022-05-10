/*=============================================================================
	ButtonBar : Class for handling the left hand button bar
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

extern WEditorFrame* GEditorFrame;
extern WDlgAddSpecial* GDlgAddSpecial;
void ParseStringToArray( const TCHAR* pchDelim, FString String, TArray<FString>* _pArray);

#define dBUTTON_WIDTH	32
#define dBUTTON_HEIGHT	32
#define dCAPTION_HEIGHT	20

#define IDPB_MODE_CAMERA		19000
#define IDPB_MODE_SCALE			19001
#define IDPB_MODE_ROTATE		19002
#define IDPB_MODE_VERTEX_EDIT	19003
#define IDPB_MODE_BRUSH_CLIP	19004
#define IDPB_MODE_FACE_DRAG		19005
#define IDPB_TEXTURE_PAN		19006
#define IDPB_TEXTURE_ROTATE		19007
#define IDPB_MODE_ADD			19008
#define IDPB_MODE_SUBTRACT		19009
#define IDPB_MODE_INTERSECT		19010
#define IDPB_MODE_DEINTERSECT	19011
#define IDPB_MODE_POLYGON		19012
#define IDPB_MODE_TERRAINEDIT	19013
#define IDPB_ADD_SPECIAL		19020
#define IDPB_ADD_MOVER			19021
#define IDSC_LABEL				19022
#define IDPB_SHOW_SELECTED		19023
#define IDPB_HIDE_SELECTED		19024
#define IDPB_SHOW_ALL			19025
#define IDPB_INVERT_SELECTION	19026
#define IDPB_BRUSHCLIP			19027
#define IDPB_BRUSHCLIP_SPLIT	19028
#define IDPB_BRUSHCLIP_FLIP		19029
#define IDPB_BRUSHCLIP_DELETE	19030
#define IDPB_EXPAND				19031
#define IDSB_SCROLLBAR2			19032
#define IDPB_CAMERA_SPEED		19033
#define IDPB_MODE_ADDHARDWARE	19034
#define IDPB_USER_DEFINED		19050
#define IDPB_USER_DEFINED_MAX	19099
#define IDPB_BRUSH_BUILDERS		19100
#define IDMN_MOVER_TYPES		19200
#define IDMN_MOVER_TYPES_MAX	19250

typedef struct {
	INT ID;				// The command that is sent when the button is clicked
	HBITMAP hbm;		// The graphic that goes on the button
	FString Text;		// Differs based on Type (ToolTip or Label text)
	HWND hWnd;
	UBrushBuilder* Builder;
	UClass* Class;
	RECT rc;
	WWindow* pControl;
	FString ExecCommand;
} WBB_Button;

typedef struct {
	FString Name;
	INT ID;			// Starting at IDMN_MOVER_TYPES
} WBB_MoverType;

extern INT GScrollBarWidth;

// --------------------------------------------------------------
//
// WBUTTONGROUP
// - Holds a group of related buttons
// - can be expanded/contracted
//
// --------------------------------------------------------------

enum eBGSTATE {
	eBGSTATE_DOWN	= 0,
	eBGSTATE_UP		= 1
};

class WButtonGroup : public WWindow
{
	DECLARE_WINDOWCLASS(WButtonGroup,WWindow,Window)
	
	FString Caption;
	WButton* pExpandButton;
	TArray<WBB_Button> Buttons;
	HBITMAP hbmDown, hbmUp;
	INT iState, LastX, LastY;
	WToolTip* ToolTipCtrl;
	FString GroupName;
	TArray<WBB_MoverType> MoverTypes;
	WDlgBrushBuilder* pDBB;
	HBITMAP hbmCamSpeed[3];

	// Structors.
	WButtonGroup( FName InPersistentName, WWindow* InOwnerWindow )
	:	WWindow( InPersistentName, InOwnerWindow )
	{
		iState = eBGSTATE_DOWN;
		hbmDown = (HBITMAP)LoadImageA( hInstance, MAKEINTRESOURCEA(IDBM_DOWN_ARROW), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );	check(hbmDown);
		hbmUp = (HBITMAP)LoadImageA( hInstance, MAKEINTRESOURCEA(IDBM_UP_ARROW), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );	check(hbmUp);
		hbmCamSpeed[0] = (HBITMAP)LoadImageA( hInstance, MAKEINTRESOURCEA(IDBM_CAMSPEED1), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );	check(hbmCamSpeed[0]);
		hbmCamSpeed[1] = (HBITMAP)LoadImageA( hInstance, MAKEINTRESOURCEA(IDBM_CAMSPEED2), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );	check(hbmCamSpeed[1]);
		hbmCamSpeed[2] = (HBITMAP)LoadImageA( hInstance, MAKEINTRESOURCEA(IDBM_CAMSPEED3), IMAGE_BITMAP, 0, 0, LR_DEFAULTCOLOR );	check(hbmCamSpeed[2]);
		LastX = 2;
		LastY = dCAPTION_HEIGHT;
		pExpandButton = NULL;
		pDBB = NULL;
	}

	// WWindow interface.
	void OpenWindow()
	{
		MdiChild = 0;

		PerformCreateWindowEx
		(
			0,
			NULL,
			WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS,
			0,
			0,
			320,
			200,
			OwnerWindow ? OwnerWindow->hWnd : NULL,
			NULL,
			hInstance
		);
		SendMessageX( *this, WM_SETFONT, (WPARAM)GetStockObject(DEFAULT_GUI_FONT), MAKELPARAM(0,0) );

		if(!GConfig->GetInt( TEXT("Groups"), *GroupName, iState, TEXT("DukeEd.ini") ))	iState = eBGSTATE_DOWN;
		UpdateButton();
	}
	void OnDestroy()
	{
		for( INT x = 0 ; x < Buttons.Num() ; x++ )
		{
			::DeleteObject( Buttons(x).hbm );
			::DestroyWindow( Buttons(x).hWnd );
			delete Buttons(x).pControl;
		}
		if( pExpandButton )
		{
			DestroyWindow( pExpandButton->hWnd );
			delete pExpandButton;
		}
		delete pDBB;
		DeleteObject(hbmDown);
		DeleteObject(hbmUp);
		DeleteObject(hbmCamSpeed[0]);
		DeleteObject(hbmCamSpeed[1]);
		DeleteObject(hbmCamSpeed[2]);
		delete ToolTipCtrl;
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
		ToolTipCtrl = new WToolTip(this);
		ToolTipCtrl->OpenWindow();

		pExpandButton = new WButton( this, IDPB_EXPAND, FDelegate(this, (TDelegate)OnExpandButton) );
		pExpandButton->OpenWindow( 1, 0, 0, 19, 19, TEXT(""), 1, BS_OWNERDRAW );
		UpdateButton();

		WWindow::OnCreate();
	}
	void OnExpandButton()
	{
		iState = (iState == eBGSTATE_DOWN) ? eBGSTATE_UP : eBGSTATE_DOWN;
		SendMessageX( OwnerWindow->hWnd, WM_COMMAND, WM_EXPANDBUTTON_CLICKED, 0L );
		UpdateButton();
	}
	void UpdateButton()
	{
		pExpandButton->SetBitmap( (iState == eBGSTATE_DOWN) ? hbmUp : hbmDown );
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WWindow::OnSize(Flags, NewX, NewY);
		RECT rect;
		::GetClientRect( hWnd, &rect );

		::MoveWindow( pExpandButton->hWnd, rect.right - 19, 0, 19, 19, 1 );

		InvalidateRect( hWnd, NULL, FALSE );
	}
	void OnPaint()
	{
		PAINTSTRUCT PS;
		HDC hDC = BeginPaint( *this, &PS );
		HBRUSH brushBack = CreateSolidBrush( RGB(128,128,128) );

		RECT rect;
		::GetClientRect( hWnd, &rect );

		FillRect( hDC, &rect, brushBack );
		MyDrawEdge( hDC, &rect, 1 );

		rect.top += 6;		rect.bottom = rect.top + 3;
		rect.left += 3;		rect.right -= 22;
		MyDrawEdge( hDC, &rect, 1 );
		rect.top += 6;		rect.bottom = rect.top + 3;
		MyDrawEdge( hDC, &rect, 1 );

		EndPaint( *this, &PS );

		DeleteObject( brushBack );
	}
	// Adds a button onto the bar.  The button will be positioned automatically.
	void AddButton( INT _iID, UBOOL bAutoCheck, FString BMPFilename, FString Text, UClass* Class, UBOOL bNewLine, FString ExecCommand = TEXT("") )
	{
		if( bNewLine )
		{
			LastY += dBUTTON_HEIGHT / 2;
			if( LastX >= dBUTTON_WIDTH && LastX < (dBUTTON_WIDTH * 2) )
				LastY += dBUTTON_HEIGHT;

			LastX = 2;
		}

		// Add the button into the array and set it up
		new(Buttons)WBB_Button;
		WBB_Button* pWBButton = &(Buttons(Buttons.Num() - 1));
		check(pWBButton);

		if( BMPFilename.Len() )
		{
			FString Filename = *(FString::Printf(TEXT("editorres\\%s.bmp"), *BMPFilename));
			pWBButton->hbm = (HBITMAP)LoadImageA( hInstance, appToAnsi( *Filename ), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE );
			if(!pWBButton->hbm)
				pWBButton->hbm = (HBITMAP)LoadImageA( hInstance, "BBGeneric", IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE );
		}
		else
			pWBButton->hbm = NULL;

		pWBButton->ExecCommand = ExecCommand;
		pWBButton->ID = _iID;
		pWBButton->Text = Text;
		pWBButton->Class = Class;

		if( pWBButton->ID >= IDPB_BRUSH_BUILDERS )
			pWBButton->Builder = ConstructObject<UBrushBuilder>(Class);
		else
			pWBButton->Builder = NULL;

		// Create the physical button/label
		WCheckBox* pButton = new WCheckBox( this, _iID );
		pWBButton->pControl = pButton;
		pButton->OpenWindow( 1, LastX, LastY, dBUTTON_WIDTH, dBUTTON_HEIGHT, NULL, bAutoCheck, 1, BS_PUSHLIKE | BS_OWNERDRAW );
		pButton->SetBitmap( pWBButton->hbm );

		pWBButton->hWnd = pButton->hWnd;

		// Update position data
		LastX += dBUTTON_WIDTH;
		if( LastX >= dBUTTON_WIDTH * 2 )
		{
			LastX = 2;
			LastY += dBUTTON_HEIGHT;
		}

		ToolTipCtrl->AddTool( pButton->hWnd, Text, _iID );
	}
	INT GetFullHeight()
	{
		if( iState == eBGSTATE_DOWN )
			return dCAPTION_HEIGHT + (((Buttons.Num() + 1) / 2) * dBUTTON_HEIGHT);
		else
			return dCAPTION_HEIGHT;
	}
	void OnCommand( INT Command )
	{
		if( Command >= IDMN_MOVER_TYPES && Command <= IDMN_MOVER_TYPES_MAX )
		{
			// Figure out which mover was chosen
			for( INT x = 0 ; x < MoverTypes.Num() ; x++ )
			{
				WBB_MoverType* pwbbmt = &(MoverTypes(x));
				if( pwbbmt->ID == Command )
				{
					GEditor->Exec( *(FString::Printf(TEXT("BRUSH ADDMOVER CLASS=%s"), pwbbmt->Name ) ) );
					break;
				}
			}
		}

		switch( Command )
		{
			case WM_BB_RCLICK:
				{
					switch( LastlParam ) {

						case IDPB_ADD_MOVER:
						{
							// Create a context menu with all the available kinds of movers on it.
							CreateMoverTypeList();

							HMENU menu = CreatePopupMenu();
							MENUITEMINFOA mif;

							mif.cbSize = sizeof(MENUITEMINFO);
							mif.fMask = MIIM_TYPE | MIIM_ID;
							mif.fType = MFT_STRING;

							for( INT x = 0 ; x < MoverTypes.Num() ; x++ )
							{
								WBB_MoverType* pwbbmt = &(MoverTypes(x));

								mif.dwTypeData = TCHAR_TO_ANSI( *(pwbbmt->Name) );
								mif.wID = pwbbmt->ID;

								InsertMenuItemA( menu, 99999, FALSE, &mif );
							}

							POINT point;
							::GetCursorPos(&point);
							TrackPopupMenu( menu,
								TPM_LEFTALIGN | TPM_TOPALIGN | TPM_RIGHTBUTTON,
								point.x, point.y, 0,
								hWnd, NULL);
						}
						break;

						default:
						{
							// Right clicking a brush builder button will bring up it's editable fields.
							WBB_Button* pwbb;

							for( INT x = 0 ; x < Buttons.Num() ; x++ )
							{
								pwbb = &(Buttons(x));
								if( pwbb->ID == LastlParam
										&& pwbb->Builder)
								{
									delete pDBB;
									pDBB = new WDlgBrushBuilder( NULL, this, pwbb->Builder );
									pDBB->DoModeless();
									break;
								}
							}
						}
						break;
					}
				}
				break;

			default:
				switch( HIWORD(Command) ) {

					case BN_CLICKED:
						ButtonClicked(LOWORD(Command));
						break;

					default:
						WWindow::OnCommand(Command);
						break;
				}
				break;
		}
	}
	void CreateMoverTypeList(void)
	{
		MoverTypes.Empty();

		INT ID = IDMN_MOVER_TYPES;

		// Add the normal mover on top
		new(MoverTypes)WBB_MoverType();
		WBB_MoverType* pwbbmt = &(MoverTypes(MoverTypes.Num() - 1));
		pwbbmt->ID = ID;
		pwbbmt->Name = TEXT("Mover");
		ID++;

		// Now add the child classes of "mover"
		UClass *Parent = NULL;
		ParseObject<UClass>(TEXT("PARENT=MOVER"),TEXT("PARENT="),Parent,ANY_PACKAGE);

		for( TObjectIterator<UClass> It ; It ; ++It )
			if(It->IsChildOf(AMover::StaticClass()))
			{
				new(MoverTypes)WBB_MoverType();
				WBB_MoverType* pwbbmt = &(MoverTypes(MoverTypes.Num() - 1));
				pwbbmt->ID = ID;
				pwbbmt->Name = It->GetName();
				ID++;
			}
	}
	// Searches the list for the button that was clicked, and executes the appropriate command.
	void ButtonClicked( INT ID )
	{
		if( ID >= IDPB_USER_DEFINED && ID <= IDPB_USER_DEFINED_MAX )
		{
			for( INT x = 0 ; x < Buttons.Num() ; x++ )
			{
				WBB_Button* pwbb = &(Buttons(x));
				if( pwbb->ID == ID )
				{
					GEditor->Exec( *(pwbb->ExecCommand) );
					return;
				}
			}
		}

		switch( ID )
		{
			case IDPB_CAMERA_SPEED:
				{
					WCheckBox* pButton = GetButton(IDPB_CAMERA_SPEED);	check(pButton);
					if( GEditor->MovementSpeed == 1 )		GEditor->Exec( TEXT("MODE SPEED=4") );
					else if( GEditor->MovementSpeed == 4 )	GEditor->Exec( TEXT("MODE SPEED=16") );
					else									GEditor->Exec( TEXT("MODE SPEED=1") );
				}
				break;

			case IDPB_MODE_CAMERA:
				GEditor->Exec(TEXT("MODE CAMERAMOVE"));
				break;

			case IDPB_MODE_SCALE:
				GEditor->Exec(TEXT("MODE BRUSHSNAP"));
				break;

			case IDPB_MODE_ROTATE:
				GEditor->Exec(TEXT("MODE BRUSHROTATE"));
				break;

			case IDPB_MODE_VERTEX_EDIT:
				GEditor->Exec(TEXT("MODE VERTEXEDIT"));
				break;

			case IDPB_MODE_POLYGON:
				GEditor->Exec(TEXT("MODE POLYGON"));
				break;

			case IDPB_MODE_TERRAINEDIT:
				GEditor->Exec(TEXT("MODE TERRAINEDIT"));
				break;

			case IDPB_MODE_BRUSH_CLIP:
				GEditor->Exec(TEXT("MODE BRUSHCLIP"));
				break;

			case IDPB_MODE_FACE_DRAG:
				GEditor->Exec(TEXT("MODE FACEDRAG"));
				break;

			case IDPB_SHOW_SELECTED:
				GEditor->Exec( TEXT("ACTOR HIDE UNSELECTED") );
				break;

			case IDPB_HIDE_SELECTED:
				GEditor->Exec( TEXT("ACTOR HIDE SELECTED") );
				break;

			case IDPB_SHOW_ALL:
				GEditor->Exec( TEXT("ACTOR UNHIDE ALL") );
				break;

			case IDPB_INVERT_SELECTION:
				GEditor->Exec( TEXT("ACTOR SELECT INVERT") );
				break;

			case IDPB_BRUSHCLIP:
				GEditor->Exec( TEXT("BRUSHCLIP") );
				GEditor->RedrawLevel( GEditor->Level );
				break;

			case IDPB_BRUSHCLIP_SPLIT:
				GEditor->Exec( TEXT("BRUSHCLIP SPLIT") );
				GEditor->RedrawLevel( GEditor->Level );
				break;

			case IDPB_BRUSHCLIP_FLIP:
				GEditor->Exec( TEXT("BRUSHCLIP FLIP") );
				GEditor->RedrawLevel( GEditor->Level );
				break;

			case IDPB_BRUSHCLIP_DELETE:
				GEditor->Exec( TEXT("BRUSHCLIP DELETE") );
				GEditor->RedrawLevel( GEditor->Level );
				break;

			case IDPB_TEXTURE_PAN:
				GEditor->Exec(TEXT("MODE TEXTUREPAN"));
				break;

			case IDPB_TEXTURE_ROTATE:
				GEditor->Exec(TEXT("MODE TEXTUREROTATE"));
				break;

			case IDPB_MODE_ADD:
				GEditor->Exec( TEXT("BRUSH ADD") );
				break;

			case IDPB_MODE_ADDHARDWARE:
				GEditor->Exec( TEXT("STATICMESH FROM BRUSH") );
				break;

			case IDPB_MODE_SUBTRACT:
				GEditor->Exec( TEXT("BRUSH SUBTRACT") );
				break;

			case IDPB_MODE_INTERSECT:
				GEditor->Exec( TEXT("BRUSH FROM INTERSECTION") );
				break;

			case IDPB_MODE_DEINTERSECT:
				GEditor->Exec( TEXT("BRUSH FROM DEINTERSECTION") );
				break;

			case IDPB_ADD_SPECIAL:
				{
					if( !GDlgAddSpecial )
					{
						GDlgAddSpecial = new WDlgAddSpecial( NULL, this );
						GDlgAddSpecial->DoModeless();
					}
					else
						GDlgAddSpecial->Show(1);
				}
				break;

			case IDPB_ADD_MOVER:
				GEditor->Exec( TEXT("BRUSH ADDMOVER") );
				break;

			default:
				// A brush builder must have been clicked.  Loop through the
				// list and see which one.
				WBB_Button* pwbb;

				for( INT x = 0 ; x < Buttons.Num() ; x++ )
				{
					pwbb = &(Buttons(x));
					if( pwbb->ID == ID )
					{
						check( pwbb->Builder );
						UBOOL GIsSavedScriptableSaved = 1;
						Exchange(GIsScriptable,GIsSavedScriptableSaved);
						pwbb->Builder->eventBuild();
						Exchange(GIsScriptable,GIsSavedScriptableSaved);
					}
				}
				break;
		}

		UpdateButtons();
	}
	// Updates the states of the buttons to match editor settings.
	void UpdateButtons()
	{
		if( GetDlgItem( hWnd, IDPB_MODE_CAMERA ) )	// Make sure we're in the mode group before bothering
		{
//			WCheckBox* pcheckbox;

			GetButton( IDPB_MODE_CAMERA )->SetCheck( GEditor->Mode==EM_ViewportMove );
			GetButton( IDPB_MODE_SCALE )->SetCheck( GEditor->Mode==EM_BrushSnap );
			GetButton( IDPB_MODE_ROTATE )->SetCheck( GEditor->Mode==EM_BrushRotate );
			GetButton( IDPB_TEXTURE_PAN )->SetCheck( GEditor->Mode==EM_TexturePan );
			GetButton( IDPB_TEXTURE_ROTATE )->SetCheck( GEditor->Mode==EM_TextureRotate );
			GetButton( IDPB_MODE_VERTEX_EDIT )->SetCheck( GEditor->Mode==EM_VertexEdit );
			GetButton( IDPB_MODE_BRUSH_CLIP )->SetCheck( GEditor->Mode==EM_BrushClip );
			GetButton( IDPB_MODE_POLYGON)->SetCheck( GEditor->Mode==EM_Polygon );
			GetButton( IDPB_MODE_FACE_DRAG )->SetCheck( GEditor->Mode==EM_FaceDrag );
			GetButton( IDPB_MODE_TERRAINEDIT)->SetCheck( GEditor->Mode==EM_TerrainEdit );

			// Force all the buttons to paint themselves
			InvalidateRect( GetDlgItem( hWnd, IDPB_MODE_CAMERA ), NULL, 1 );
			InvalidateRect( GetDlgItem( hWnd, IDPB_MODE_SCALE ), NULL, 1 );
			InvalidateRect( GetDlgItem( hWnd, IDPB_MODE_ROTATE ), NULL, 1 );
			InvalidateRect( GetDlgItem( hWnd, IDPB_TEXTURE_PAN ), NULL, 1 );
			InvalidateRect( GetDlgItem( hWnd, IDPB_TEXTURE_ROTATE ), NULL, 1 );
			InvalidateRect( GetDlgItem( hWnd, IDPB_MODE_VERTEX_EDIT ), NULL, 1 );
			InvalidateRect( GetDlgItem( hWnd, IDPB_MODE_BRUSH_CLIP ), NULL, 1 );
			InvalidateRect( GetDlgItem( hWnd, IDPB_MODE_FACE_DRAG ), NULL, 1 );
			InvalidateRect( GetDlgItem( hWnd, IDPB_MODE_POLYGON ), NULL, 1 );
			InvalidateRect( GetDlgItem( hWnd, IDPB_MODE_TERRAINEDIT ), NULL, 1 );
		}

		if( GetDlgItem( hWnd, IDPB_CAMERA_SPEED ) )
		{
			WCheckBox* pButton = GetButton(IDPB_CAMERA_SPEED);

			if( GEditor->MovementSpeed == 1 )
				pButton->SetBitmap( hbmCamSpeed[0] );
			else if( GEditor->MovementSpeed == 4 )
				pButton->SetBitmap( hbmCamSpeed[1] );
			else
				pButton->SetBitmap( hbmCamSpeed[2] );
			InvalidateRect( pButton->hWnd, NULL, 1 );
		}
	}
	WCheckBox* GetButton( INT InID )
	{
		for( INT x = 0 ; x < Buttons.Num() ; x++ )
		{
			WBB_Button* pwbb = &(Buttons(x));
			if(pwbb->ID == InID )
				return (WCheckBox*)pwbb->pControl;
		}

		check(0);	// this should never happen
		return NULL;
	}
	void RefreshBuilders()
	{
		for( INT x = 0 ; x < Buttons.Num() ; x++ )
		{
			WBB_Button* pwbb = &(Buttons(x));
			if(pwbb->ID >= IDPB_BRUSH_BUILDERS )
				pwbb->Builder = ConstructObject<UBrushBuilder>(pwbb->Class);
		}
	}
};

// --------------------------------------------------------------
//
// WBUTTONBAR
//
// --------------------------------------------------------------

class WButtonBar : public WWindow
{
	DECLARE_WINDOWCLASS(WButtonBar,WWindow,Window)

	TArray<WButtonGroup> Groups;
	INT LastX, LastY;
	WVScrollBar* pScrollBar;
	INT iScroll;

	// Structors.
	WButtonBar( FName InPersistentName, WWindow* InOwnerWindow )
	:	WWindow( InPersistentName, InOwnerWindow )
	{
		pScrollBar = NULL;
		iScroll = 0;
	}

	// WWindow interface.
	void OpenWindow()
	{
		MdiChild = 0;

		PerformCreateWindowEx
		(
			0,
			NULL,
			WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS,
			0,
			0,
			320,
			200,
			OwnerWindow ? OwnerWindow->hWnd : NULL,
			NULL,
			hInstance
		);
		SendMessageX( *this, WM_SETFONT, (WPARAM)GetStockObject(DEFAULT_GUI_FONT), MAKELPARAM(0,0) );
	}
	void RefreshScrollBar( void )
	{
		if( !pScrollBar ) return;

		RECT rect;
		::GetClientRect( hWnd, &rect );

		if( (rect.bottom < GetHeightOfAllGroups()
				&& !IsWindowEnabled( pScrollBar->hWnd ) )
				|| (rect.bottom >= GetHeightOfAllGroups()
				&& IsWindowEnabled( pScrollBar->hWnd ) ) )
			iScroll = 0;

		// Set the scroll bar to have a valid range.
		//
		SCROLLINFO si;
		si.cbSize = sizeof(SCROLLINFO);
		si.fMask = SIF_DISABLENOSCROLL | SIF_RANGE | SIF_POS;
		si.nMin = 0;
		si.nMax = GetHeightOfAllGroups();
		si.nPos = iScroll;
		iScroll = SetScrollInfo( pScrollBar->hWnd, SB_CTL, &si, TRUE );

		EnableWindow( pScrollBar->hWnd, (rect.bottom < GetHeightOfAllGroups()) );
		PositionChildControls();
	}
	INT GetHeightOfAllGroups()
	{
		INT Height = 0;

		for( INT x = 0 ; x < Groups.Num() ; x++ )
			Height += Groups(x).GetFullHeight();

		return Height;
	}
	void OnDestroy()
	{
		delete pScrollBar;
		WWindow::OnDestroy();
	}
	INT OnSetCursor()
	{
		WWindow::OnSetCursor();
		SetCursor(LoadCursorIdX(NULL,IDC_ARROW));
		return 0;
	}
	// Adds a button group.
	WButtonGroup* AddGroup( FString GroupName )
	{
		new(Groups)WButtonGroup( TEXT(""), this );
		WButtonGroup* pbuttongroup = &(Groups(Groups.Num() - 1));
		pbuttongroup->GroupName = GroupName;
		check(pbuttongroup);
		return pbuttongroup;
	}
	// Doing things like loading new maps and such will cause us to have to recreate
	// brush builder objects.
	void RefreshBuilders()
	{
		for( INT x = 0 ; x < Groups.Num() ; x++ )
			Groups(x).RefreshBuilders();
	}
	void OnCreate()
	{
		WWindow::OnCreate();

		pScrollBar = new WVScrollBar( this, IDSB_SCROLLBAR2 );
		pScrollBar->OpenWindow( 1, 0, 0, 320, 200 );

		// Load the buttons onto the bar.
		WButtonGroup* pGroup;

		pGroup = AddGroup( TEXT("Modes") );
		pGroup->OpenWindow();
		pGroup->AddButton( IDPB_MODE_CAMERA, 0, TEXT("ModeCamera"), TEXT("Camera Movement"), NULL, 0 );
		pGroup->AddButton( IDPB_MODE_VERTEX_EDIT, 0, TEXT("ModeVertex"), TEXT("Vertex Editing"), NULL, 0 );
		pGroup->AddButton( IDPB_MODE_SCALE, 0, TEXT("ModeScale"), TEXT("Brush Scaling"), NULL, 0 );
		pGroup->AddButton( IDPB_MODE_ROTATE, 0, TEXT("ModeRotate"), TEXT("Brush Rotate"), NULL, 0 );
		pGroup->AddButton( IDPB_TEXTURE_PAN, 0, TEXT("TexturePan"), TEXT("Texture Pan"), NULL, 0 );
		pGroup->AddButton( IDPB_TEXTURE_ROTATE, 0, TEXT("TextureRotate"), TEXT("Texture Rotate"), NULL, 0 );
		pGroup->AddButton( IDPB_MODE_BRUSH_CLIP, 0, TEXT("ModeBrushClip"), TEXT("Brush Clipping"), NULL, 0 );
		pGroup->AddButton( IDPB_MODE_POLYGON, 0, TEXT("ModePolygon"), TEXT("Freehand Polygon Drawing"), NULL, 0 );
		pGroup->AddButton( IDPB_MODE_FACE_DRAG, 0, TEXT("ModeFaceDrag"), TEXT("Face Drag"), NULL, 0 );
		pGroup->AddButton( IDPB_MODE_TERRAINEDIT, 0, TEXT("ModeTerrainEdit"), TEXT("Terrain Editing"), NULL, 0 );

		pGroup = AddGroup( TEXT("Clipping") );
		pGroup->OpenWindow();
		pGroup->AddButton( IDPB_BRUSHCLIP, 0, TEXT("BrushClip"), TEXT("Clip Selected Brushes"), NULL, 0 );
		pGroup->AddButton( IDPB_BRUSHCLIP_SPLIT, 0, TEXT("BrushClipSplit"), TEXT("Split Selected Brushes"), NULL, 0 );
		pGroup->AddButton( IDPB_BRUSHCLIP_FLIP, 0, TEXT("BrushClipFlip"), TEXT("Flip Clipping Normal"), NULL, 0 );
		pGroup->AddButton( IDPB_BRUSHCLIP_DELETE, 0, TEXT("BrushClipDelete"), TEXT("Delete Clipping Markers"), NULL, 0 );

		INT ID = IDPB_BRUSH_BUILDERS;

		pGroup = AddGroup( TEXT("Builders") );
		pGroup->OpenWindow();
		for( TObjectIterator<UClass> ItC; ItC; ++ItC )
			if( ItC->IsChildOf(UBrushBuilder::StaticClass()) && !(ItC->ClassFlags&CLASS_Abstract) )
			{
				UBrushBuilder* ubb = ConstructObject<UBrushBuilder>( *ItC );
				if( ubb )
				{
					pGroup->AddButton( ID, 0, ubb->BitmapFilename, ubb->ToolTip, *ItC, 0 );
					ID++;
				}
			}

		pGroup = AddGroup( TEXT("CSG") );
		pGroup->OpenWindow();
		pGroup->AddButton( IDPB_MODE_ADD, 0, TEXT("ModeAdd"), TEXT("Add"), NULL, 0 );
		pGroup->AddButton( IDPB_MODE_SUBTRACT, 0, TEXT("ModeSubtract"), TEXT("Subtract"), NULL, 0 );
		pGroup->AddButton( IDPB_MODE_INTERSECT, 0, TEXT("ModeIntersect"), TEXT("Intersect"), NULL, 0 );
		pGroup->AddButton( IDPB_MODE_DEINTERSECT, 0, TEXT("ModeDeintersect"), TEXT("Deintersect"), NULL, 0 );
		pGroup->AddButton( IDPB_ADD_SPECIAL, 0, TEXT("AddSpecial"), TEXT("Add Special Brush"), NULL, 0 );
		pGroup->AddButton( IDPB_MODE_ADDHARDWARE, 0, TEXT("ModeAddHardware"), TEXT("Add Hardware Brush"), NULL, 0 );
		pGroup->AddButton( IDPB_ADD_MOVER, 0, TEXT("AddMover"), TEXT("Add Mover Brush (right click for all mover types)"), NULL, 0 );

		pGroup = AddGroup( TEXT("Misc") );
		pGroup->OpenWindow();
		pGroup->AddButton( IDPB_SHOW_SELECTED, 0, TEXT("ShowSelected"), TEXT("Show Selected Actors Only"), NULL, 0 );
		pGroup->AddButton( IDPB_HIDE_SELECTED, 0, TEXT("HideSelected"), TEXT("Hide Selected Actors"), NULL, 0 );
		pGroup->AddButton( IDPB_SHOW_ALL, 0, TEXT("ShowAll"), TEXT("Show All Actors"), NULL, 0 );
		pGroup->AddButton( IDPB_INVERT_SELECTION, 0, TEXT("InvertSelections"), TEXT("Invert Selection"), NULL, 0 );
		pGroup->AddButton( IDPB_CAMERA_SPEED, 0, TEXT("ModeCamera"), TEXT("Change Camera Speed"), NULL, 0 );

		pGroup = AddGroup( TEXT("UserDefined") );
		pGroup->OpenWindow();

		INT NumButtons;
		if(!GConfig->GetInt( TEXT("UserDefinedGroup"), TEXT("NumButtons"), NumButtons, TEXT("DukeEd.ini") ))	NumButtons = 0;

		if( NumButtons )
		{
			for( INT x = 0 ; x < NumButtons ; x++ )
			{
				FString ButtonDef;
				FString ButtonName = FString::Printf(TEXT("Button%d"), x);

				TArray<FString> Fields;
				GConfig->GetString( TEXT("UserDefinedGroup"), *ButtonName, ButtonDef, TEXT("DukeEd.ini") );
				ParseStringToArray( TEXT(","), ButtonDef, &Fields );

				pGroup->AddButton( IDPB_USER_DEFINED + x, 0, *Fields(1), *Fields(0), NULL, 0, *Fields(2) );
			}
		}

		PositionChildControls();
		UpdateButtons();
	}
	void PositionChildControls()
	{
		RECT rect;
		INT LastY = -iScroll;

		::GetClientRect( hWnd, &rect );

		// Figure out where each buttongroup window should go.
		for( INT x = 0 ; x < Groups.Num() ; x++ )
		{
			::MoveWindow( Groups(x).hWnd, 0, LastY, rect.right - GScrollBarWidth, Groups(x).GetFullHeight(), 1 );
			LastY += Groups(x).GetFullHeight();
		}

		::MoveWindow( pScrollBar->hWnd, rect.right - GScrollBarWidth, 0, GScrollBarWidth, rect.bottom, 1 );
	}
	virtual void OnVScroll( WPARAM wParam, LPARAM lParam )
	{
		if( (HWND)lParam == pScrollBar->hWnd ) {

			switch(LOWORD(wParam)) {

				case SB_LINEUP:
					iScroll -= 64;
					RefreshScrollBar();
					PositionChildControls();
					break;

				case SB_LINEDOWN:
					iScroll += 64;
					RefreshScrollBar();
					PositionChildControls();
					break;

				case SB_PAGEUP:
					iScroll -= 256;
					RefreshScrollBar();
					PositionChildControls();
					break;

				case SB_PAGEDOWN:
					iScroll += 256;
					RefreshScrollBar();
					PositionChildControls();
					break;

				case SB_THUMBTRACK:
					iScroll = (short int)HIWORD(wParam);
					RefreshScrollBar();
					PositionChildControls();
					break;
			}
		}
	}
	void OnPaint()
	{
		PAINTSTRUCT PS;
		HDC hDC = BeginPaint( *this, &PS );
		HBRUSH brushBack = CreateSolidBrush( RGB(128,128,128) );

		FRect Rect = GetClientRect();
		FillRect( hDC, Rect, brushBack );
		MyDrawEdge( hDC, Rect, 1 );

		EndPaint( *this, &PS );

		DeleteObject( brushBack );
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WWindow::OnSize(Flags, NewX, NewY);
		PositionChildControls();
		RefreshScrollBar();
		InvalidateRect( hWnd, NULL, FALSE );
	}
	void OnCommand( INT Command )
	{
		switch( Command )
		{
			case WM_EXPANDBUTTON_CLICKED:
			{
				RefreshScrollBar();
				PositionChildControls();
			}
			break;

			default:
				WWindow::OnCommand(Command);
				break;
		}
	}
	void UpdateButtons()
	{
		for( INT x = 0 ; x < Groups.Num() ; x++ )
			Groups(x).UpdateButtons();
	}
};
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
