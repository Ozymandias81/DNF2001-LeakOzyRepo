class UWindowMessageBoxCW expands UWindowDialogClientWindow;

var MessageBoxButtons Buttons;

var MessageBoxResult EnterResult;
var UWindowSmallButton YesButton, NoButton, OKButton, CancelButton;
var localized string YesText, NoText, OKText, CancelText;
var UWindowMessageBoxArea MessageArea;
var UWindowEditControl    EditArea;

function Created()
{
	Super.Created();
	SetAcceptsFocus();

	MessageArea = UWindowMessageBoxArea(CreateWindow(class'UWindowMessageBoxArea', 10, 10, WinWidth-20, WinHeight-44));
}

function KeyDown(int Key, float X, float Y)
{
	local UWindowMessageBox P;

	P = UWindowMessageBox(ParentWindow);

	if(Key == GetPlayerOwner().EInputKey.IK_Enter && EnterResult != MR_None)
	{
		P = UWindowMessageBox(ParentWindow);
		P.Result = EnterResult;
		P.Close();
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	switch(Buttons)
	{
	case MB_YesNoCancel:
		YesButton.AutoSize(C);
		NoButton.AutoSize(C);
		CancelButton.AutoSize(C);

		MessageArea.SetSize( WinWidth-10, WinHeight-YesButton.WinHeight-10 );
		CancelButton.WinLeft = WinWidth - 20 - CancelButton.WinWidth;
		CancelButton.WinTop = WinHeight - CancelButton.WinHeight - 10;
		NoButton.WinLeft = CancelButton.WinLeft - 5 - NoButton.WinWidth;
		NoButton.WinTop = WinHeight - NoButton.WinHeight - 10;
		YesButton.WinLeft = NoButton.WinLeft - 5 - YesButton.WinWidth;
		YesButton.WinTop = WinHeight - YesButton.WinHeight - 10;
		break;
	case MB_YesNo:
		YesButton.AutoSize(C);
		NoButton.AutoSize(C);

		MessageArea.SetSize( WinWidth-10, WinHeight-YesButton.WinHeight-10 );
		NoButton.WinLeft = WinWidth - 20 - NoButton.WinWidth;
		NoButton.WinTop = WinHeight - NoButton.WinHeight - 10;
		YesButton.WinLeft = NoButton.WinLeft - 5 - YesButton.WinWidth;
		YesButton.WinTop = WinHeight - YesButton.WinHeight - 10;
		break;
	case MB_OKCancel:
    case MB_OKCancelEdit:
		OKButton.AutoSize(C);
		CancelButton.AutoSize(C);
		
		CancelButton.WinLeft = WinWidth - 20 - CancelButton.WinWidth;
		CancelButton.WinTop  = WinHeight - CancelButton.WinHeight - 10;
		OKButton.WinLeft     = CancelButton.WinLeft - 5 - OKButton.WinWidth;
		OKButton.WinTop      = WinHeight - OKButton.WinHeight - 10;

		if ( Buttons == MB_OKCancelEdit )
		{			
			EditArea.WinLeft = 10;			
			EditArea.WinTop  = OKButton.WinTop - EditArea.WinHeight;			
			
			MessageArea.SetSize( WinWidth-10, WinHeight-EditArea.WinHeight-OKButton.WinHeight-10 );			
			MessageArea.WinLeft = 10;
			MessageArea.WinTop  = 0;
		}
		else
		{
			MessageArea.SetSize( WinWidth-10, WinHeight-OKButton.WinHeight-10 );
		}

		break;
	case MB_OK:
		OKButton.AutoSize(C);

		MessageArea.SetSize( WinWidth-10, WinHeight-OKButton.WinHeight-10 );
		OKButton.WinLeft = WinWidth - 20 - OKButton.WinWidth;
		OKButton.WinTop = WinHeight - OKButton.WinHeight - 10;
		break;
	}
}

function Resized()
{
	Super.Resized();
	MessageArea.SetSize( WinWidth-20, WinHeight-44 );
	EditArea.SetSize( WinWidth-20, 1 );
}

function float GetHeight( Canvas C )
{
	switch(Buttons)
	{
	case MB_YesNoCancel:
	case MB_YesNo:
		return MessageArea.GetHeight( C ) + YesButton.WinHeight + 10;
		break;
	case MB_OKCancel:
	case MB_OK:
		return MessageArea.GetHeight( C ) + OKButton.WinHeight + 10;
		break;
	case MB_OkCancelEdit:
		return MessageArea.GetHeight( C ) + EditArea.WinHeight + OKButton.WinHeight + 30;
	}
	return 0;
}

function SetupMessageBoxClient(string InMessage, MessageBoxButtons InButtons, MessageBoxResult InEnterResult)
{
	MessageArea.Message = InMessage;
	Buttons = InButtons;
	EnterResult = InEnterResult;

	// Create buttons
	switch(Buttons)
	{
	case MB_YesNoCancel:
		CancelButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 52, WinHeight - 20, 48, 48));
		CancelButton.SetText(CancelText);
		if(EnterResult == MR_Cancel)
			CancelButton.SetFont(F_Bold);
		else
			CancelButton.SetFont(F_Normal);
		NoButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 104, WinHeight - 20, 48, 48));
		NoButton.SetText(NoText);
		if(EnterResult == MR_No)
			NoButton.SetFont(F_Bold);
		else
			NoButton.SetFont(F_Normal);
		YesButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 156, WinHeight - 20, 48, 48));
		YesButton.SetText(YesText);
		if(EnterResult == MR_Yes)
			YesButton.SetFont(F_Bold);
		else
			YesButton.SetFont(F_Normal);
		break;
	case MB_YesNo:
		NoButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 52, WinHeight - 20, 48, 48));
		NoButton.SetText(NoText);
		if(EnterResult == MR_No)
			NoButton.SetFont(F_Bold);
		else
			NoButton.SetFont(F_Normal);
		YesButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 104, WinHeight - 20, 48, 48));
		YesButton.SetText(YesText);
		if(EnterResult == MR_Yes)
			YesButton.SetFont(F_Bold);
		else
			YesButton.SetFont(F_Normal);
		break;
	case MB_OKCancel:
	case MB_OKCancelEdit:
		CancelButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 52, WinHeight - 20, 48, 48));
		CancelButton.SetText(CancelText);
		if(EnterResult == MR_Cancel)
			CancelButton.SetFont(F_Bold);
		else
			CancelButton.SetFont(F_Normal);
		OKButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 104, WinHeight - 20, 48, 48));
		OKButton.SetText(OKText);
		if(EnterResult == MR_OK)
			OKButton.SetFont(F_Bold);
		else
			OKButton.SetFont(F_Normal);

		if ( Buttons == MB_OKCancelEdit )
		{
			EditArea = UWindowEditControl( CreateControl( class'UWindowEditControl', 1,1,WinWidth-10,32 ) );
			EditArea.SetNoShrinkFont( true );
			EditArea.SetMaxLength( 120 );
			EditArea.SetNumericOnly( false );
			EditArea.Align = TA_Right;
		}
		break;
	case MB_OK:
		OKButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth - 52, WinHeight - 20, 48, 48));
		OKButton.SetText(OKText);
		if(EnterResult == MR_OK)
			OKButton.SetFont(F_Bold);
		else
			OKButton.SetFont(F_Normal);
		break;
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	local UWindowMessageBox P;

	P = UWindowMessageBox(ParentWindow);

	if(E == DE_Click)
	{
		switch(C)
		{
		case YesButton:
			P.Result = MR_Yes;
			P.Close();			
			break;
		case NoButton:
			P.Result = MR_No;
			P.Close();
			break;
		case OKButton:
			P.Result = MR_OK;
			P.Close();
			break;
		case CancelButton:
			P.Result = MR_Cancel;
			P.Close();
			break;
		}
	}
	else if ( E == DE_EnterPressed  )
	{
		if ( C == EditArea )
		{
			P.Result = MR_OK;
			P.StringResult = EditArea.EditBox.Value;
			P.Close();
		}
	}
}

defaultproperties
{
	YesText="Yes"
	NoText="No"
	OKText="OK"
	CancelText="Cancel"
}
