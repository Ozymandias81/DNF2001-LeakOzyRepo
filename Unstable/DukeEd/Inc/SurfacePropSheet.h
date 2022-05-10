/*=============================================================================
	SurfacePropSheet : Property sheet for surface properties.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Warren Marshall

    Work-in-progress todo's:

=============================================================================*/

// --------------------------------------------------------------
//
// WSurfacePropPage
//
// Base class for all the pages on this sheet.
//
// --------------------------------------------------------------

class WSurfacePropPage : public WPropertyPage
{
	DECLARE_WINDOWCLASS(WSurfacePropPage,WPropertyPage,Window)
	WSurfacePropPage ( WWindow* InOwnerWindow )
	:	WPropertyPage( InOwnerWindow )
	{
	}

	virtual void Refresh()
	{
		// Figure out a good caption for the sheet.
		FStringOutputDevice GetPropResult = FStringOutputDevice();
		GetPropResult.Empty();
		if( GEditor )
			GEditor->Get( TEXT("POLYS"), TEXT("NUMSELECTED"), GetPropResult );
		INT NumSelected = appAtoi(*GetPropResult);

		// Disable all controls if no surfaces are selected.
		HWND hwndChild = GetWindow( hWnd, GW_CHILD );
		while( hwndChild )
		{
			EnableWindow( hwndChild, NumSelected );
			hwndChild = GetWindow( hwndChild, GW_HWNDNEXT );
		}
	}
};

// --------------------------------------------------------------
//
// WPageFlags
//
// --------------------------------------------------------------

#define dNUM_FLAGS	19
struct 
{
	INT Flag;		// Unreal's bit flag
	INT ID;			// Windows control ID
	INT Count;		// Temp var
} GPolyFlags[] = 
{
	PF_Invisible,			IDCK_INVISIBLE,			0,
	PF_Masked,				IDCK_MASKED,			0,
	PF_Translucent,			IDCK_TRANSLUCENT,		0,
	PF_ForceViewZone,		IDCK_FORCEVIEWZONE,		0,
	PF_Modulated,			IDCK_MODULATED,			0,
	PF_FakeBackdrop,		IDCK_FAKEBACKDROP,		0,
	PF_TwoSided,			IDCK_2SIDED,			0,
	PF_AutoUPan,			IDCK_UPAN,				0,
	PF_AutoVPan,			IDCK_VPAN,				0,
	PF_NoSmooth,			IDCK_NOSMOOTH,			0,
	PF_SmallWavy,			IDCK_SMALLWAVY,			0,
	PF_LowShadowDetail,		IDCK_LOWSHADOWDETAIL,	0,
	PF_BrightCorners,		IDCK_BRIGHTCORNERS,		0,
	PF_SpecialLit,			IDCK_SPECIALLIT,		0,
	PF_NoBoundRejection,	IDCK_NOBOUNDREJECTION,	0,
	PF_Unlit,				IDCK_UNLIT,				0,
	PF_HighShadowDetail,	IDCK_HISHADOWDETAIL,	0,
	PF_Portal,				IDCK_PORTAL,			0,
	PF_Mirrored,			IDCK_MIRROR,			0
};

class WPageFlags : public WSurfacePropPage
{
	DECLARE_WINDOWCLASS(WPageFlags,WSurfacePropPage,Window)

	WCheckBox *RelativeCheck, *MaskedCheck, *TranslucentCheck, *ForceViewzoneCheck,
		*ModulatedCheck, *FakeBackdropCheck, *TwoSidedCheck, *UPanCheck, *VPanCheck,
		*HighShadowDetailCheck, *LowShadowDetailCheck, *NoSmoothCheck,
		*SmallWavyCheck, *BrightCornersCheck, *SpecialLitCheck,
		*NoBoundsRejectCheck, *UnlitCheck, *PortalCheck, *MirrorCheck;
	WEdit *TagEdit;

	INT SurfsSelected;

	// Structors.
	WPageFlags ( WWindow* InOwnerWindow )
	:	WSurfacePropPage( InOwnerWindow )
	{
		RelativeCheck = MaskedCheck = TranslucentCheck = ForceViewzoneCheck
			= ModulatedCheck = FakeBackdropCheck = TwoSidedCheck = UPanCheck
			= VPanCheck = HighShadowDetailCheck = LowShadowDetailCheck = NoSmoothCheck
			= SmallWavyCheck = BrightCornersCheck
			= SpecialLitCheck = NoBoundsRejectCheck = UnlitCheck = PortalCheck = MirrorCheck = NULL;
		TagEdit = NULL;
		SurfsSelected = 0;
	}

	virtual void OpenWindow( INT InDlgId, HMODULE InHMOD )
	{
		WSurfacePropPage::OpenWindow( InDlgId, InHMOD );

		// Create child controls and let the base class determine their proper positions.
		RelativeCheck = new WCheckBox( this, IDCK_INVISIBLE );
		RelativeCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		MaskedCheck = new WCheckBox( this, IDCK_MASKED );
		MaskedCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		TranslucentCheck = new WCheckBox( this, IDCK_TRANSLUCENT );
		TranslucentCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		ForceViewzoneCheck = new WCheckBox( this, IDCK_FORCEVIEWZONE );
		ForceViewzoneCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		ModulatedCheck = new WCheckBox( this, IDCK_MODULATED );
		ModulatedCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		FakeBackdropCheck = new WCheckBox( this, IDCK_FAKEBACKDROP );
		FakeBackdropCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		TwoSidedCheck = new WCheckBox( this, IDCK_2SIDED );
		TwoSidedCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		UPanCheck = new WCheckBox( this, IDCK_UPAN );
		UPanCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		VPanCheck = new WCheckBox( this, IDCK_VPAN );
		VPanCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		HighShadowDetailCheck = new WCheckBox( this, IDCK_HISHADOWDETAIL );
		HighShadowDetailCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		LowShadowDetailCheck = new WCheckBox( this, IDCK_LOWSHADOWDETAIL );
		LowShadowDetailCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		NoSmoothCheck = new WCheckBox( this, IDCK_NOSMOOTH );
		NoSmoothCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		SmallWavyCheck = new WCheckBox( this, IDCK_SMALLWAVY );
		SmallWavyCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		BrightCornersCheck = new WCheckBox( this, IDCK_BRIGHTCORNERS );
		BrightCornersCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		SpecialLitCheck = new WCheckBox( this, IDCK_SPECIALLIT );
		SpecialLitCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		NoBoundsRejectCheck = new WCheckBox( this, IDCK_NOBOUNDREJECTION );
		NoBoundsRejectCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		UnlitCheck = new WCheckBox( this, IDCK_UNLIT );
		UnlitCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		PortalCheck = new WCheckBox( this, IDCK_PORTAL );
		PortalCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		MirrorCheck = new WCheckBox( this, IDCK_MIRROR );
		MirrorCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );

		TagEdit = new WEdit( this, IDC_EDIT_TAG );
		TagEdit->OpenWindow( 1, 0, 0 );

		PlaceControl( RelativeCheck );
		PlaceControl( MaskedCheck );
		PlaceControl( TranslucentCheck );
		PlaceControl( ForceViewzoneCheck );
		PlaceControl( ModulatedCheck );
		PlaceControl( FakeBackdropCheck );
		PlaceControl( TwoSidedCheck );
		PlaceControl( UPanCheck );
		PlaceControl( VPanCheck );
		PlaceControl( HighShadowDetailCheck );
		PlaceControl( LowShadowDetailCheck );
		PlaceControl( NoSmoothCheck );
		PlaceControl( SmallWavyCheck );
		PlaceControl( BrightCornersCheck );
		PlaceControl( SpecialLitCheck );
		PlaceControl( NoBoundsRejectCheck );
		PlaceControl( UnlitCheck );
		PlaceControl( PortalCheck );
		PlaceControl( MirrorCheck );

		PlaceControl( TagEdit );

		Finalize();

		// Delegates.
		RelativeCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		MaskedCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		TranslucentCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		ForceViewzoneCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		ModulatedCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		FakeBackdropCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		TwoSidedCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		UPanCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		VPanCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		HighShadowDetailCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		LowShadowDetailCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		NoSmoothCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		SmallWavyCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		BrightCornersCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		SpecialLitCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		NoBoundsRejectCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		UnlitCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		PortalCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		MirrorCheck->ClickDelegate = FDelegate(this, (TDelegate)OnButtonClicked);
		TagEdit->ChangeDelegate = FDelegate(this, (TDelegate)OnTagChanged);
	}
	void OnDestroy()
	{
		::DestroyWindow( RelativeCheck->hWnd );
		::DestroyWindow( MaskedCheck->hWnd );
		::DestroyWindow( TranslucentCheck->hWnd );
		::DestroyWindow( ForceViewzoneCheck->hWnd );
		::DestroyWindow( ModulatedCheck->hWnd );
		::DestroyWindow( FakeBackdropCheck->hWnd );
		::DestroyWindow( TwoSidedCheck->hWnd );
		::DestroyWindow( UPanCheck->hWnd );
		::DestroyWindow( VPanCheck->hWnd );
		::DestroyWindow( HighShadowDetailCheck->hWnd );
		::DestroyWindow( LowShadowDetailCheck->hWnd );
		::DestroyWindow( NoSmoothCheck->hWnd );
		::DestroyWindow( SmallWavyCheck->hWnd );
		::DestroyWindow( BrightCornersCheck->hWnd );
		::DestroyWindow( SpecialLitCheck->hWnd );
		::DestroyWindow( NoBoundsRejectCheck->hWnd );
		::DestroyWindow( UnlitCheck->hWnd );
		::DestroyWindow( PortalCheck->hWnd );
		::DestroyWindow( MirrorCheck->hWnd );
		::DestroyWindow( TagEdit->hWnd );

		delete RelativeCheck;
		delete MaskedCheck;
		delete TranslucentCheck;
		delete ForceViewzoneCheck;
		delete ModulatedCheck;
		delete FakeBackdropCheck;
		delete TwoSidedCheck;
		delete UPanCheck;
		delete VPanCheck;
		delete HighShadowDetailCheck;
		delete LowShadowDetailCheck;
		delete NoSmoothCheck;
		delete SmallWavyCheck;
		delete BrightCornersCheck;
		delete SpecialLitCheck;
		delete NoBoundsRejectCheck;
		delete UnlitCheck;
		delete PortalCheck;
		delete MirrorCheck;
		delete TagEdit;

		WSurfacePropPage::OnDestroy();
	}
	virtual void Refresh()
	{
		WSurfacePropPage::Refresh();

		// Figure out a good caption for the sheet.
		FStringOutputDevice GetPropResult = FStringOutputDevice();
		GetPropResult.Empty();
		if( GEditor )
			GEditor->Get( TEXT("POLYS"), TEXT("NUMSELECTED"), GetPropResult );
		SurfsSelected = appAtoi(*GetPropResult);

		// Update the data.
		GetDataFromSurfs();

		// Change caption to show how many surfaces are selected.
		GetPropResult.Empty();
		if( GEditor )
			GEditor->Get( TEXT("POLYS"), TEXT("TEXTURENAME"), GetPropResult );
		FString Caption;
		if( SurfsSelected == 1 )
			Caption = FString::Printf(TEXT("%d Surface%s%s"), SurfsSelected, GetPropResult.Len() ? TEXT(" : ") : TEXT(""), *GetPropResult );
		else
			Caption = FString::Printf(TEXT("%d Surfaces%s%s"), SurfsSelected, GetPropResult.Len() ? TEXT(" : ") : TEXT(""), *GetPropResult );
		if( GetParent(GetParent(GetParent(hWnd))) )
			SendMessageA( GetParent(GetParent(GetParent(hWnd))), WM_SETTEXT, 0, (LPARAM)appToAnsi( *Caption ) );
	}
	void OnTagChanged()
	{
		SendDataToSurfs();
	}
	void OnButtonClicked()
	{
		HWND hwndButton = (HWND)LastlParam;

		if( SendMessageA( hwndButton, BM_GETCHECK, 0, 0 ) == BST_CHECKED )
			SendMessageA( hwndButton, BM_SETCHECK, BST_CHECKED, 0 );
		else
			SendMessageA( hwndButton, BM_SETCHECK, BST_UNCHECKED, 0 );

		SendDataToSurfs();
	}
	void GetDataFromSurfs()
	{
		INT TotalSurfs = 0;

		// Init counts.
		//
		for( INT x = 0 ; x < dNUM_FLAGS ; x++ )
			GPolyFlags[x].Count = 0;

		// Check to see which flags are used on all selected surfaces.
		//
		FBspSurf* SingleSurf = NULL;
		for( INT i = 0 ; i < GEditor->Level->Model->Surfs.Num() ; i++ )
		{
			FBspSurf *Poly = &GEditor->Level->Model->Surfs(i);
			if( Poly->PolyFlags & PF_Selected )
			{
				SingleSurf = Poly;
				for( x = 0 ; x < dNUM_FLAGS ; x++ )
					if( Poly->PolyFlags & GPolyFlags[x].Flag )
						GPolyFlags[x].Count++;
				TotalSurfs++;
			}
		}

		// Update checkboxes on dialog to match selections.
		//
		for( x = 0 ; x < dNUM_FLAGS ; x++ )
		{
			HWND ItemHandle = GetDlgItem( hWnd, GPolyFlags[x].ID );
			if (ItemHandle)
				SendMessageA( ItemHandle, BM_SETCHECK, BST_UNCHECKED, 0 );

			if( TotalSurfs > 0
					&& GPolyFlags[x].Count > 0 )
			{
				if( GPolyFlags[x].Count == TotalSurfs )
				{
					if (ItemHandle)
						SendMessageA( ItemHandle, BM_SETCHECK, BST_CHECKED, 0 );
				} else {
					if (ItemHandle)
						SendMessageA( ItemHandle, BM_SETCHECK, BST_INDETERMINATE, 0 );
				}
			}
		}

		// If only one surface is selected, display the tag.
		if (SurfsSelected == 1)
			SetDlgItemTextA( hWnd, IDC_EDIT_TAG, appToAnsi(*SingleSurf->SurfaceTag) );
	}
	void SendDataToSurfs()
	{    
		INT OnFlags, OffFlags;

		OnFlags = OffFlags = 0;

		for( INT x = 0 ; x < dNUM_FLAGS ; x++ )
		{
			if( SendMessageA( GetDlgItem( hWnd, GPolyFlags[x].ID ), BM_GETCHECK, 0, 0 ) == BST_CHECKED )
				OnFlags += GPolyFlags[x].Flag;
			if( SendMessageA( GetDlgItem( hWnd, GPolyFlags[x].ID ), BM_GETCHECK, 0, 0 ) == BST_UNCHECKED )
				OffFlags += GPolyFlags[x].Flag;
		}

		ANSICHAR SurfTagAnsi[256];
		GetDlgItemTextA( hWnd, IDC_EDIT_TAG, SurfTagAnsi, sizeof(ANSICHAR)*256 );
		TCHAR* SurfaceTag = (TCHAR*) appFromAnsi( SurfTagAnsi );

		// Check to make sure that if multiple surfaces are selected, we don't lose any of the surfacetags.
		if ((SurfsSelected == 1) || (SurfaceTag[0] != '\0'))
			GEditor->Exec( *(FString::Printf(TEXT("POLY SET SETFLAGS=%d CLEARFLAGS=%d SURFACETAG=%s"), OnFlags, OffFlags, SurfaceTag)) );
		else
			GEditor->Exec( *(FString::Printf(TEXT("POLY SET SETFLAGS=%d CLEARFLAGS=%d"), OnFlags, OffFlags)) );
	}
};

// --------------------------------------------------------------
//
// WPagePanRotScale
//
// --------------------------------------------------------------

class WPagePanRotScale : public WSurfacePropPage
{
	DECLARE_WINDOWCLASS(WPagePanRotScale,WSurfacePropPage,Window)

	WCheckBox *RelativeCheck;
	WGroupBox *PanBox, *AlignmentBox, *OptionsBox;
	WButton *PanU1Button, *PanU4Button, *PanU16Button, *PanU64Button,
		*PanV1Button, *PanV4Button, *PanV16Button, *PanV64Button,
		*Rot45Button, *Rot90Button, *FlipUButton, *FlipVButton,
		*ApplyButton, *Apply2Button, *GetScaleButton;
	WComboBox *SimpleScaleCombo;
	WEdit *ScaleUEdit, *ScaleVEdit;

	// Structors.
	WPagePanRotScale ( WWindow* InOwnerWindow )
	:	WSurfacePropPage( InOwnerWindow )
	{
		RelativeCheck = NULL;
		PanBox = AlignmentBox = OptionsBox = NULL;
		PanU1Button = PanU4Button = PanU16Button = PanU64Button
			= PanV1Button = PanV4Button = PanV16Button = PanV64Button
			= Rot45Button = Rot90Button = FlipUButton = FlipVButton
			= ApplyButton = Apply2Button = GetScaleButton = NULL;
		SimpleScaleCombo = NULL;
		ScaleUEdit = ScaleVEdit = NULL;
	}

	virtual void OpenWindow( INT InDlgId, HMODULE InHMOD )
	{
		WSurfacePropPage::OpenWindow( InDlgId, InHMOD );

		// Create child controls and let the base class determine their proper positions.
		RelativeCheck = new WCheckBox( this, IDCK_RELATIVE );
		RelativeCheck->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		PanBox = new WGroupBox( this, IDGP_PAN );
		PanBox->OpenWindow( 1, 0 );
		AlignmentBox = new WGroupBox( this, IDGP_ROTATION );
		AlignmentBox->OpenWindow( 1, 0 );
		OptionsBox = new WGroupBox( this, IDGP_SCALING );
		OptionsBox->OpenWindow( 1, 0 );
		PanU1Button = new WButton( this, IDPB_PAN_U_1 );
		PanU1Button->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		PanU4Button = new WButton( this, IDPB_PAN_U_4 );
		PanU4Button->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		PanU16Button = new WButton( this, IDPB_PAN_U_16 );
		PanU16Button->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		PanU64Button = new WButton( this, IDPB_PAN_U_64 );
		PanU64Button->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		PanV1Button = new WButton( this, IDPB_PAN_V_1 );
		PanV1Button->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		PanV4Button = new WButton( this, IDPB_PAN_V_4 );
		PanV4Button->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		PanV16Button = new WButton( this, IDPB_PAN_V_16 );
		PanV16Button->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		PanV64Button = new WButton( this, IDPB_PAN_V_64 );
		PanV64Button->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		Rot45Button = new WButton( this, IDPB_ROT_45 );
		Rot45Button->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		Rot90Button = new WButton( this, IDPB_ROT_90 );
		Rot90Button->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		FlipUButton = new WButton( this, IDPB_ROT_FLIP_U );
		FlipUButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		FlipVButton = new WButton( this, IDPB_ROT_FLIP_V );
		FlipVButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		ApplyButton = new WButton( this, IDPB_SCALE_APPLY );
		ApplyButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		Apply2Button = new WButton( this, IDPB_SCALE_APPLY2 );
		Apply2Button->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		GetScaleButton = new WButton( this, IDC_GETSCALE );
		GetScaleButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		SimpleScaleCombo = new WComboBox( this, IDCB_SIMPLE_SCALE );
		SimpleScaleCombo->OpenWindow( 1, 0, CBS_DROPDOWN );
		ScaleUEdit = new WEdit( this, IDEC_SCALE_U );
		ScaleUEdit->OpenWindow( 1, 0, 0 );
		ScaleVEdit = new WEdit( this, IDEC_SCALE_V );
		ScaleVEdit->OpenWindow( 1, 0, 0 );

		PlaceControl( RelativeCheck );
		PlaceControl( PanBox );
		PlaceControl( AlignmentBox );
		PlaceControl( OptionsBox );
		PlaceControl( PanU1Button );
		PlaceControl( PanU4Button );
		PlaceControl( PanU16Button );
		PlaceControl( PanU64Button );
		PlaceControl( PanV1Button );
		PlaceControl( PanV4Button );
		PlaceControl( PanV16Button );
		PlaceControl( PanV64Button );
		PlaceControl( Rot45Button );
		PlaceControl( Rot90Button );
		PlaceControl( FlipUButton );
		PlaceControl( FlipVButton );
		PlaceControl( ApplyButton );
		PlaceControl( Apply2Button );
		PlaceControl( GetScaleButton );
		PlaceControl( SimpleScaleCombo );
		PlaceControl( ScaleUEdit );
		PlaceControl( ScaleVEdit );

		Finalize();

		// Delegates.
		PanU1Button->ClickDelegate = FDelegate(this, (TDelegate)OnPanU1Clicked);
		PanU4Button->ClickDelegate = FDelegate(this, (TDelegate)OnPanU4Clicked);
		PanU16Button->ClickDelegate = FDelegate(this, (TDelegate)OnPanU16Clicked);
		PanU64Button->ClickDelegate = FDelegate(this, (TDelegate)OnPanU64Clicked);
		PanV1Button->ClickDelegate = FDelegate(this, (TDelegate)OnPanV1Clicked);
		PanV4Button->ClickDelegate = FDelegate(this, (TDelegate)OnPanV4Clicked);
		PanV16Button->ClickDelegate = FDelegate(this, (TDelegate)OnPanV16Clicked);
		PanV64Button->ClickDelegate = FDelegate(this, (TDelegate)OnPanV64Clicked);
		ApplyButton->ClickDelegate = FDelegate(this, (TDelegate)OnApplyClicked);
		Apply2Button->ClickDelegate = FDelegate(this, (TDelegate)OnApply2Clicked);
		FlipUButton->ClickDelegate = FDelegate(this, (TDelegate)OnFlipUClicked);
		FlipVButton->ClickDelegate = FDelegate(this, (TDelegate)OnFlipVClicked);
		Rot45Button->ClickDelegate = FDelegate(this, (TDelegate)OnRot45Clicked);
		Rot90Button->ClickDelegate = FDelegate(this, (TDelegate)OnRot90Clicked);
		GetScaleButton->ClickDelegate = FDelegate(this, (TDelegate)OnGetScaleClicked);

		// Initialize controls.
		SimpleScaleCombo->AddString( TEXT("0.0625" ) );
		SimpleScaleCombo->AddString( TEXT("0.125" ) );
		SimpleScaleCombo->AddString( TEXT("0.25" ) );
		SimpleScaleCombo->AddString( TEXT("0.5" ) );
		SimpleScaleCombo->AddString( TEXT("1.0" ) );
		SimpleScaleCombo->AddString( TEXT("2.0" ) );
		SimpleScaleCombo->AddString( TEXT("4.0" ) );
		SimpleScaleCombo->AddString( TEXT("8.0" ) );
		SimpleScaleCombo->AddString( TEXT("16.0" ) );		
	}
	void OnDestroy()
	{
		::DestroyWindow( RelativeCheck->hWnd );
		::DestroyWindow( PanBox->hWnd );
		::DestroyWindow( AlignmentBox->hWnd );
		::DestroyWindow( OptionsBox->hWnd );
		::DestroyWindow( PanU1Button->hWnd );
		::DestroyWindow( PanU4Button->hWnd );
		::DestroyWindow( PanU16Button->hWnd );
		::DestroyWindow( PanU64Button->hWnd );
		::DestroyWindow( PanV1Button->hWnd );
		::DestroyWindow( PanV4Button->hWnd );
		::DestroyWindow( PanV16Button->hWnd );
		::DestroyWindow( PanV64Button->hWnd );
		::DestroyWindow( Rot45Button->hWnd );
		::DestroyWindow( Rot90Button->hWnd );
		::DestroyWindow( FlipUButton->hWnd );
		::DestroyWindow( FlipVButton->hWnd );
		::DestroyWindow( ApplyButton->hWnd );
		::DestroyWindow( Apply2Button->hWnd );
		::DestroyWindow( GetScaleButton->hWnd );
		::DestroyWindow( SimpleScaleCombo->hWnd );
		::DestroyWindow( ScaleUEdit->hWnd );
		::DestroyWindow( ScaleVEdit->hWnd );

		delete RelativeCheck;
		delete PanBox;
		delete AlignmentBox;
		delete OptionsBox;
		delete PanU1Button;
		delete PanU4Button;
		delete PanU16Button;
		delete PanU64Button;
		delete PanV1Button;
		delete PanV4Button;
		delete PanV16Button;
		delete PanV64Button;
		delete Rot45Button;
		delete Rot90Button;
		delete FlipUButton;
		delete FlipVButton;
		delete ApplyButton;
		delete Apply2Button;
		delete GetScaleButton;
		delete SimpleScaleCombo;
		delete ScaleUEdit;
		delete ScaleVEdit;

		WSurfacePropPage::OnDestroy();
	}
	void OnGetScaleClicked()
	{
		// Check to see if we can display U/V information.
		FLOAT USelected = 0, VSelected = 0;
		INT NumSelected = 0;
		FBspSurf* SingleSurf = NULL;
		for( INT i = 0 ; i < GEditor->Level->Model->Surfs.Num() ; i++ )
		{
			FBspSurf *Poly = &GEditor->Level->Model->Surfs(i);
			if( Poly->PolyFlags & PF_Selected )
			{
				NumSelected++;

				FVector OriginalU = GEditor->Level->Model->Vectors(Poly->vTextureU);
				FVector OriginalV = GEditor->Level->Model->Vectors(Poly->vTextureV);

				USelected = 1.f / OriginalU.Size();
				VSelected = 1.f / OriginalV.Size();
			}
		}
		if ( NumSelected == 1 )
		{
			FString ScaleText = FString::Printf( TEXT("%f"), USelected );
			ScaleUEdit->SetText( *ScaleText );
			ScaleText = FString::Printf( TEXT("%f"), VSelected );
			ScaleVEdit->SetText( *ScaleText );
		} else {
			FString ScaleText = FString::Printf( TEXT(""), USelected );
			ScaleUEdit->SetText( *ScaleText );
			ScaleText = FString::Printf( TEXT(""), VSelected );
			ScaleVEdit->SetText( *ScaleText );
		}
	}
	void PanU( INT InPan )
	{
		FLOAT Mod = GetAsyncKeyState(VK_SHIFT) & 0x8000 ? -1 : 1;
		GEditor->Exec( *FString::Printf( TEXT("POLY TEXPAN U=%f"), InPan * Mod ) );
	}
	void OnPanU1Clicked() { PanU(1); }
	void OnPanU4Clicked() { PanU(4); }
	void OnPanU16Clicked() { PanU(16); }
	void OnPanU64Clicked() { PanU(64); }

	void PanV( INT InPan )
	{
		FLOAT Mod = GetAsyncKeyState(VK_SHIFT) & 0x8000 ? -1 : 1;
		GEditor->Exec( *FString::Printf( TEXT("POLY TEXPAN V=%f"), InPan * Mod ) );
	}
	void OnPanV1Clicked() { PanV(1); }
	void OnPanV4Clicked() { PanV(4); }
	void OnPanV16Clicked() { PanV(16); }
	void OnPanV64Clicked() { PanV(64); }

	void Scale( FLOAT InScaleU, FLOAT InScaleV, UBOOL InRelative )
	{
		if( !InScaleU || !InScaleV ) { return; }

		InScaleU = 1.0f / InScaleU;
		InScaleV = 1.0f / InScaleV;

		GEditor->Exec( *FString::Printf( TEXT("POLY TEXSCALE %s UU=%f VV=%f"), InRelative?TEXT("RELATIVE"):TEXT(""), InScaleU, InScaleV ) );
	}
	void OnApplyClicked()
	{
		FLOAT ScaleU = appAtof( *ScaleUEdit->GetText() );
		FLOAT ScaleV = appAtof( *ScaleVEdit->GetText() );
		Scale( ScaleU, ScaleV, RelativeCheck->IsChecked() );
	}
	void OnApply2Clicked()
	{
		FLOAT ScaleValue = appAtof( *SimpleScaleCombo->GetText() );
		Scale( ScaleValue, ScaleValue, RelativeCheck->IsChecked() );
	}

	void OnFlipUClicked()
	{
		GEditor->Exec( TEXT("POLY TEXMULT UU=-1 VV=1") );
	}
	void OnFlipVClicked()
	{
		GEditor->Exec( TEXT("POLY TEXMULT UU=1 VV=-1") );
	}
	void OnRot45Clicked()
	{
		FLOAT Mod = GetAsyncKeyState(VK_SHIFT) & 0x8000 ? -1 : 1;
		FLOAT UU = 1.0f / appSqrt(2);
		FLOAT VV = 1.0f / appSqrt(2);
		FLOAT UV = (1.0f / appSqrt(2)) * Mod;
		FLOAT VU = -(1.0f / appSqrt(2)) * Mod;
		GEditor->Exec( *FString::Printf( TEXT("POLY TEXMULT UU=%f VV=%f UV=%f VU=%f"), UU, VV, UV, VU ) );
	}
	void OnRot90Clicked()
	{
		FLOAT Mod = GetAsyncKeyState(VK_SHIFT) & 0x8000 ? -1 : 1;
		FLOAT UU = 0;
		FLOAT VV = 0;
		FLOAT UV = 1 * Mod;
		FLOAT VU = -1 * Mod;
		GEditor->Exec( *FString::Printf( TEXT("POLY TEXMULT UU=%f VV=%f UV=%f VU=%f"), UU, VV, UV, VU ) );
	}
};

// --------------------------------------------------------------
//
// WPageAlignment
//
// --------------------------------------------------------------

struct {
	TCHAR* Desc;
	INT ID;
	INT ProxyID;
} GAlignTypes[] =
{
	TEXT("Unalign"), TEXALIGN_Default, -1,
	TEXT("Wall Direction"), TEXALIGN_WallDir, -1,
	TEXT("Cylinder"), TEXALIGN_Cylinder, -1,
	TEXT("Planar"), TEXALIGN_Planar, PROXY_OPTIONSTEXALIGNPLANAR,
	TEXT("Face"), TEXALIGN_Face, -1,
	NULL, -1, -1
};

class WPageAlignment : public WSurfacePropPage
{
	DECLARE_WINDOWCLASS(WPageAlignment,WSurfacePropPage,Window)

	WObjectProperties* PropertyWindow;
	WGroupBox *AlignmentBox, *OptionsBox;
	WButton *AlignButton;
	WListBox *AlignList;
	UOptionsProxy* Proxy;

	// Structors.
	WPageAlignment ( WWindow* InOwnerWindow )
	:	WSurfacePropPage( InOwnerWindow )
	{
		AlignmentBox = OptionsBox = NULL;
		AlignButton = NULL;
		AlignList = NULL;
	}

	virtual void OpenWindow( INT InDlgId, HMODULE InHMOD )
	{
		WSurfacePropPage::OpenWindow( InDlgId, InHMOD );

		// Create child controls and let the base class determine their proper positions.
		AlignmentBox = new WGroupBox( this, IDGP_ALIGN );
		AlignmentBox->OpenWindow( 1, 0 );
		OptionsBox = new WGroupBox( this, IDGP_OPTIONS );
		OptionsBox->OpenWindow( 1, 0 );
		AlignButton = new WButton( this, IDPB_ALIGN );
		AlignButton->OpenWindow( 1, 0, 0, 0, 0, TEXT("") );
		AlignList = new WListBox( this, IDLB_ALIGN );
		AlignList->OpenWindow( 1, 0, 0, 0 );

		PlaceControl( AlignmentBox );
		PlaceControl( OptionsBox );
		PlaceControl( AlignButton );
		PlaceControl( AlignList );

		Finalize();

		// Delegates.
		AlignButton->ClickDelegate = FDelegate(this, (TDelegate)OnAlignClick);
		AlignList->DoubleClickDelegate = FDelegate(this, (TDelegate)OnAlignClick);
		AlignList->SelectionChangeDelegate = FDelegate(this, (TDelegate)AlignListSelectionChange);

		// Initialize controls.
		for( INT x = 0 ; GAlignTypes[x].ID != -1 ; x++ )
			AlignList->AddString( GAlignTypes[x].Desc );
		AlignList->SetCurrent( 0 );

		PropertyWindow = NULL;

		RefreshPropertyWindow();
	}
	void RefreshPropertyWindow()
	{
		if( PropertyWindow )
			::DestroyWindow( PropertyWindow->hWnd );
		delete PropertyWindow;
		PropertyWindow = NULL;

		Proxy = NULL;
		INT Sel = AlignList->GetCurrent();
		if( GAlignTypes[Sel].ProxyID == -1 )
			return;

		PropertyWindow = new WObjectProperties( NAME_None, CPF_Edit, TEXT(""), this, 1 );
		PropertyWindow->ShowTreeLines = 1;
		PropertyWindow->Root.Sorted = 0;
		PropertyWindow->OpenChildWindow( IDSC_PROPS );

		// Figure out which proxy should be in the properties.
		if( GAlignTypes[Sel].ProxyID != -1 )
		{
			Proxy = GProxies( GAlignTypes[Sel].ProxyID );
			PropertyWindow->Root._Objects.AddItem( Proxy );
		}
		else
			PropertyWindow->Root._Objects.AddItem( NULL );

		for( TFieldIterator<UProperty> It(Proxy->GetClass()); It; ++It )
			if( ( It->Category==FName(Proxy->GetClass()->GetName())
					|| It->Category==FName(TEXT("OptionsTexAlign")) )
					&& PropertyWindow->Root.AcceptFlags( It->PropertyFlags ) )
				PropertyWindow->Root.Children.AddItem( new(TEXT("FPropertyItem"))FPropertyItem( PropertyWindow, &(PropertyWindow->Root), *It, It->GetFName(), It->Offset, -1 ) );
		PropertyWindow->Root.Expand();
		PropertyWindow->ResizeList();
		PropertyWindow->bAllowForceRefresh = 0;
	}
	void OnDestroy()
	{
		::DestroyWindow( AlignmentBox->hWnd );
		::DestroyWindow( OptionsBox->hWnd );
		::DestroyWindow( AlignButton->hWnd );
		::DestroyWindow( AlignList->hWnd );
		if( PropertyWindow )
			::DestroyWindow( PropertyWindow->hWnd );

		delete PropertyWindow;
		delete AlignmentBox;
		delete OptionsBox;
		delete AlignButton;
		delete AlignList;

		WSurfacePropPage::OnDestroy();
	}
	void Align( INT InType )
	{
		switch( InType )
		{
			case TEXALIGN_Default:
				GEditor->Exec( TEXT("POLY TEXALIGN DEFAULT") );
				break;

			case TEXALIGN_WallDir:
				GEditor->Exec( TEXT("POLY TEXALIGN WALLDIR") );
				break;

			case TEXALIGN_Cylinder:
				GEditor->Exec( TEXT("POLY TEXALIGN CYLINDER") );
				break;

			case TEXALIGN_Planar:
				GEditor->Exec( *FString::Printf( TEXT("POLY TEXALIGN PLANAR OPTIONS=%d"), (UOptionsTexAlignPlanar*)(GProxies( PROXY_OPTIONSTEXALIGNPLANAR ) ) ) );
				break;

			case TEXALIGN_PlanarAuto:
				GEditor->Exec( TEXT("POLY TEXALIGN PLANARAUTO") );
				break;

			case TEXALIGN_PlanarWall:
				GEditor->Exec( TEXT("POLY TEXALIGN PLANARWALL") );
				break;

			case TEXALIGN_PlanarFloor:
				GEditor->Exec( TEXT("POLY TEXALIGN PLANARFLOOR") );
				break;

			case TEXALIGN_Face:
				GEditor->Exec( TEXT("POLY TEXALIGN FACE") );
				break;
		}
	}
	virtual void Refresh()
	{
		WSurfacePropPage::Refresh();

		RefreshPropertyWindow();
	}

	void AlignListSelectionChange()
	{
		RefreshPropertyWindow();
	}
	void OnAlignClick()
	{
		Align( GAlignTypes[ AlignList->GetCurrent() ].ID );
	}
};

// --------------------------------------------------------------
//
// WPageStats
//
// --------------------------------------------------------------

class WPageStats : public WSurfacePropPage
{
	DECLARE_WINDOWCLASS(WPageStats,WSurfacePropPage,Window)

	WGroupBox *LightingBox;
	WLabel *StaticLightsLabel, *MeshelsLabel, *MeshSizeLabel;

	// Structors.
	WPageStats ( WWindow* InOwnerWindow )
	:	WSurfacePropPage( InOwnerWindow )
	{
		LightingBox = NULL;
		StaticLightsLabel = MeshelsLabel = MeshSizeLabel = NULL;
	}

	virtual void OpenWindow( INT InDlgId, HMODULE InHMOD )
	{
		WSurfacePropPage::OpenWindow( InDlgId, InHMOD );

		// Create child controls and let the base class determine their proper positions.
		LightingBox = new WGroupBox( this, IDGP_LIGHTING );
		LightingBox->OpenWindow( 1, 0 );
		StaticLightsLabel = new WLabel( this, IDSC_STATIC_LIGHTS );
		StaticLightsLabel->OpenWindow( 1, 0 );
		MeshelsLabel = new WLabel( this, IDSC_MESHELS );
		MeshelsLabel->OpenWindow( 1, 0 );
		MeshSizeLabel = new WLabel( this, IDSC_MESH_SIZE );
		MeshSizeLabel->OpenWindow( 1, 0 );

		PlaceControl( LightingBox );
		PlaceControl( StaticLightsLabel );
		PlaceControl( MeshelsLabel );
		PlaceControl( MeshSizeLabel );

		Finalize();
	}
	void OnDestroy()
	{
		::DestroyWindow( LightingBox->hWnd );
		::DestroyWindow( StaticLightsLabel->hWnd );
		::DestroyWindow( MeshelsLabel->hWnd );
		::DestroyWindow( MeshSizeLabel->hWnd );

		delete LightingBox;
		delete StaticLightsLabel;
		delete MeshelsLabel;
		delete MeshSizeLabel;

		WSurfacePropPage::OnDestroy();
	}
	virtual void Refresh()
	{
		WSurfacePropPage::Refresh();

		FStringOutputDevice GetPropResult = FStringOutputDevice();

		GetPropResult.Empty();	GEditor->Get( TEXT("POLYS"), TEXT("STATICLIGHTS"), GetPropResult );
		StaticLightsLabel->SetText( *GetPropResult );
		GetPropResult.Empty();	GEditor->Get( TEXT("POLYS"), TEXT("MESHELS"), GetPropResult );
		MeshelsLabel->SetText( *GetPropResult );
		GetPropResult.Empty();	GEditor->Get( TEXT("POLYS"), TEXT("MESHSIZE"), GetPropResult );
		MeshSizeLabel->SetText( *GetPropResult );
	}
};

// --------------------------------------------------------------
//
// WSurfacePropSheet
//
// --------------------------------------------------------------

class WSurfacePropSheet : public WWindow
{
	DECLARE_WINDOWCLASS(WSurfacePropSheet,WWindow,Window)

	WPropertySheet* PropSheet;
	WPageFlags* FlagsPage;
	WPagePanRotScale* PanRotScalePage;
	WPageAlignment* AlignmentPage;
	WPageStats* StatsPage;

	// Structors.
	WSurfacePropSheet( FName InPersistentName, WWindow* InOwnerWindow )
	:	WWindow( InPersistentName, InOwnerWindow )
	{
	}

	// WSurfacePropSheet interface.
	void OpenWindow()
	{
		MdiChild = 0;
		PerformCreateWindowEx
		(
			NULL,
			TEXT("Surface Properties"),
			WS_OVERLAPPED | WS_VISIBLE | WS_CAPTION | WS_SYSMENU,
			0, 0,
			0, 0,
			OwnerWindow ? OwnerWindow->hWnd : NULL,
			NULL,
			hInstance
		); 
	}
	void OnCreate()
	{
		WWindow::OnCreate();

		// Create the sheet
		PropSheet = new WPropertySheet( this, IDPS_SURFACE_PROPS );
		PropSheet->OpenWindow( 1, 0 );

		// Create the pages for the sheet
		FlagsPage = new WPageFlags( PropSheet->Tabs );
		FlagsPage->OpenWindow( IDPP_SP_FLAGS1, GetModuleHandleA("dukeed.exe") );
		PropSheet->AddPage( FlagsPage );

		PanRotScalePage = new WPagePanRotScale( PropSheet->Tabs );
		PanRotScalePage->OpenWindow( IDPP_SP_PANROTSCALE, GetModuleHandleA("dukeed.exe") );
		PropSheet->AddPage( PanRotScalePage );

		AlignmentPage = new WPageAlignment( PropSheet->Tabs );
		AlignmentPage->OpenWindow( IDPP_SP_ALIGNMENT, GetModuleHandleA("dukeed.exe") );
		PropSheet->AddPage( AlignmentPage );

		StatsPage = new WPageStats( PropSheet->Tabs );
		StatsPage->OpenWindow( IDPP_SP_STATS, GetModuleHandleA("dukeed.exe") );
		PropSheet->AddPage( StatsPage );

		PropSheet->SetCurrent( 0 );

		// Resize the property sheet to surround the pages properly.
		RECT rect;
		::GetClientRect( FlagsPage->hWnd, &rect );
		::SetWindowPos( hWnd, HWND_TOP, 0, 0, rect.right + 32, rect.bottom + 64, SWP_NOMOVE );

		PositionChildControls();
	}
	void OnDestroy()
	{
		WWindow::OnDestroy();

		delete FlagsPage;
		delete PanRotScalePage;
		delete AlignmentPage;
		delete StatsPage;
		delete PropSheet;
	}
	void OnSize( DWORD Flags, INT NewX, INT NewY )
	{
		WWindow::OnSize(Flags, NewX, NewY);
		PositionChildControls();
		InvalidateRect( hWnd, NULL, FALSE );
	}
	void PositionChildControls()
	{
		if( !PropSheet || !::IsWindow( PropSheet->hWnd )
				)
			return;

		FRect CR = GetClientRect();
		::MoveWindow( PropSheet->hWnd, 0, 0, CR.Width(), CR.Height(), 1 );
	}
	INT OnSysCommand( INT Command )
	{
		if( Command == SC_CLOSE )
		{
			Show(0);
			return 1;
		}

		return 0;
	}
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
