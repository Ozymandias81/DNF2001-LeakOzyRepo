//=============================================================================
// dnEmailSystem (JP)
//
// Receiving mail + smack additions by Brandon
//=============================================================================
class dnEmailSystem expands dnKeyboardInput;

#exec OBJ LOAD FILE=..\Textures\ezmail.dtx

struct SFieldInfo
{
	var () string	FieldName;
	var () int		x;
	var () int		y;
	var () int		hx, hy;
	var () int		Width;
	var () int		Height;
	var () int		ClickWidth, ClickHeight;
	var () int		MaxLines;
	var () texture  ButtonTex;
	var () texture  ButtonDownTex;
	var () texture  HighlightTex;
	var () bool		NoEdit;
};

var () SFieldInfo	UsernameField;
var () SFieldInfo	PasswordField;
var () SFieldInfo	ToField;
var () SFieldInfo	FromField;
var () SFieldInfo	SubjectField;
var () SFieldInfo	MessageField;
var () SFieldInfo	SendButton;
var () SFieldInfo	ResetButton;
var () SFieldInfo	ExitButton;
var () SFieldInfo	LoginButton;
var () SFieldInfo	ClearButton;
var () SFieldInfo	EMailButton;
var () SFieldInfo	ReplyButton;
var () SFieldInfo	NextButton;
var () SFieldInfo	PrevButton;
var () SFieldInfo   RecvExitButton;
var () SFieldInfo   SwitchButton;

var () string		DefaultTo;
var () string		DefaultSubject;

var () string		FooterMsg1;
var () string		FooterMsg2;
var () string		FooterMsg3;

var (StoredMail) bool			HasEmail;

var () smackertexture TransitionToRecvMailSmack;
var () int			TransitionToRecvMailFrames;
var () smackertexture TransitionToSendMailSmack;
var () int			TransitionToSendMailFrames;
var () smackertexture TransitionFromLoginSmack;
var () int			TransitionFromLoginFrames;
var () smackertexture TransitionFromSaverSmack;
var () int			TransitionFromSaverFrames;

var () texture		SendMailBackground;
var () texture		RecvMailBackground;

// Stored mail.
struct SStoredEMail
{
	var () string	FromAddress;
	var () string	Subject;
	var () string	TextLines[10];
};
var (StoredMail) SStoredEMail	StoredMessages[8];
var int				CurrentMessage;

// Message events.
struct SMessageEvent
{
	var () string	MatchAddress;
	var () string	MatchPhrases[10];
	var () name		MatchEvent;
};
var (MessageEvent) SMessageEvent MessageEvents[10];
var (MessageEvent) bool MatchAny;
var () name			NewMailEvent;

// Popup messages.
enum EPopups
{
	POP_BadAddress,
	POP_MessageSent,
	POP_NothingToSend,
	POP_YouHaveMail,
	POP_YouHaveMailRecv
};

struct SPopup
{
	var int X, Y;
	var smackertexture PopupOpenTex;
	var int PopupOpenFrames;
	var smackertexture PopupCloseTex;
	var int PopupCloseFrames;
};
var SPopup Popups[5];

// Replying.
var string PendingMailSubject;
var string PendingMailAddress;

function PrimeOffscreenSmacks()
{
	Super.PrimeOffscreenSmacks();

	if ( TransitionToRecvMailSmack != None )
	{
		TransitionToRecvMailSmack.currentFrame = 0;
		TransitionToRecvMailSmack.pause = true;
		TransitionToRecvMailSmack.ForceTick(1.0);
	}
	if ( TransitionToSendMailSmack != None )
	{
		TransitionToSendMailSmack.currentFrame = 0;
		TransitionToSendMailSmack.pause = true;
		TransitionToSendMailSmack.ForceTick(1.0);
	}
	if ( TransitionFromLoginSmack != None )
	{
		TransitionFromLoginSmack.currentFrame = 0;
		TransitionFromLoginSmack.pause = true;
		TransitionFromLoginSmack.ForceTick(1.0);
	}
	if ( TransitionFromSaverSmack != None )
	{
		TransitionFromSaverSmack.currentFrame = 0;
		TransitionFromSaverSmack.pause = true;
		TransitionFromSaverSmack.ForceTick(1.0);
	}
}

simulated function EnableLoginWindow()
{
	MaxHighlightWindow = 1;

	NumWindows++;
	Windows[0].Name = UsernameField.FieldName;
	Windows[0].IsConsole = false;
	Windows[0].x = UsernameField.x; Windows[0].y = UsernameField.y;
	Windows[0].Width = UsernameField.Width; Windows[0].Height = UsernameField.Height;
	Windows[0].ClickWidth = UsernameField.ClickWidth; Windows[0].ClickHeight = UsernameField.ClickHeight;
	Windows[0].MaxLines = UsernameField.MaxLines;
	Windows[0].HighlightTex = UsernameField.HighlightTex;
	Windows[0].hx = UsernameField.hx;
	Windows[0].hy = UsernameField.hy;
	
	NumWindows++;
	Windows[1].Name = PasswordField.FieldName;
	Windows[1].IsConsole = false;
	Windows[1].x = PasswordField.x; Windows[1].y = PasswordField.y;
	Windows[1].Width = PasswordField.Width; Windows[1].Height = PasswordField.Height;
	Windows[1].ClickWidth = PasswordField.ClickWidth; Windows[1].ClickHeight = PasswordField.ClickHeight;
	Windows[1].MaxLines = PasswordField.MaxLines;
	Windows[1].HighlightTex = PasswordField.HighlightTex;
	Windows[1].hx = PasswordField.hx;
	Windows[1].hy = PasswordField.hy;
	Windows[1].PrivateEcho = true;

	NumWindows++;
	Windows[2].Name = LoginButton.FieldName;
	Windows[2].IsButton = true;
	Windows[2].x = LoginButton.x; Windows[2].y = LoginButton.y;
	Windows[2].Width = LoginButton.Width; Windows[2].Height = LoginButton.Height;
	Windows[2].ClickWidth = LoginButton.ClickWidth; Windows[2].ClickHeight = LoginButton.ClickHeight;
	Windows[2].ButtonDownTex = LoginButton.ButtonDownTex;

	NumWindows++;
	Windows[3].Name = ClearButton.FieldName;
	Windows[3].IsButton = true;
	Windows[3].x = ClearButton.x; Windows[3].y = ClearButton.y;
	Windows[3].Width = ClearButton.Width; Windows[3].Height = ClearButton.Height;
	Windows[3].ClickWidth = ClearButton.ClickWidth; Windows[3].ClickHeight = ClearButton.ClickHeight;
	Windows[3].ButtonDownTex = ClearButton.ButtonDownTex;
}

function bool HandleEnter()
{
	if ( LoggingIn && (CW == 0) )
	{
		CW++;
		return true;
	}
	else if ( LoggingIn && (CW == 1) )
	{
		Windows[2].ButtonDownTime = 0.15;
		TryLogin();
		return true;
	}

	return false;
}

//=============================================================================
//	PotentialConsoleCommand
//=============================================================================
function bool PotentialConsoleCommand(string Command, int WindowIndex)
{
	/*
	// Hacked in console commands
	if (Caps(Left(Command, 4)) == "SEND")
	{
		SendMail();											// Send the text buffer as mail
		return true;
	}
	else if (Caps(Left(Command, 5)) == "CLEAR")
	{
		Windows[CW].CurrentLine = 0;				// Reset mail
		Duke.ClientMessage("Message cleared.");
		return true;
	}
	else if (Caps(Left(Command, 2)) == "TO")
	{
		Windows[0].TextLines[0] = Right(Windows[CW].TypedStr, Len(Windows[CW].TypedStr)-5);
		Duke.ClientMessage("Addr changed to:"@Windows[0].TextLines[0]);
		return true;
	}
	*/
	return false;
}

//=============================================================================
//	ButtonPressed
//=============================================================================
function ButtonPressed( int WindowIndex )
{
	local int OldCW, i;

	if ( WindowIndex == 3 )
	{
		if ( Windows[2].TextLines[0] != "" )
		{
			OldCW = CW;
			CW = 2;
			KeyEvent( IK_Enter, IST_Press, 0.f );
			CW = OldCW;
		}
		SendMail();
		Windows[2].HighestEditLine = 0;
		Windows[2].CurrentLine = 0;
		Windows[2].CurrentPos = 0;
		for ( i=0; i<64; i++ )
		{
			Windows[2].TextLines[i] = "";
		}
	}
	else if ( WindowIndex == 4 )
	{
		Windows[2].HighestEditLine = 0;
		Windows[2].CurrentLine = 0;
		Windows[2].CurrentPos = 0;
		for ( i=0; i<64; i++ )
		{
			Windows[2].TextLines[i] = "";
		}
	}
	else if ( WindowIndex == 5 )
		DetachDuke();
	else if ( WindowIndex == 6 )
	{
		EmptyAllWindows();
		TransitionToBackground = true;
		TransitionToBackgroundSmack = TransitionToRecvMailSmack;
		TransitionToBackgroundFrames = TransitionToRecvMailFrames;
		TransitionToBackgroundSmack.currentFrame = 0;
		TransitionToBackgroundSmack.pause = false;
	}
	else if ( WindowIndex == 7 )
	{
		ClearMessage();
		ReadNextMessage();
	}
	else if ( WindowIndex == 8 )
	{
		ClearMessage();
		ReadNextMessage( true );
	}
	else if ( WindowIndex == 9 )
		DetachDuke();
	else if ( WindowIndex == 10 )
	{
		EmptyAllWindows();
		TransitionToBackground = true;
		TransitionToBackgroundSmack = TransitionToSendMailSmack;
		TransitionToBackgroundFrames = TransitionToSendMailFrames;
		TransitionToBackgroundSmack.currentFrame = 0;
		TransitionToBackgroundSmack.pause = false;
	}
	else if ( WindowIndex == 11 )
	{
		PendingMailAddress = Windows[0].TextLines[0];
		PendingMailSubject = "RE:"@Windows[1].TextLines[0];
		ButtonPressed( 10 ); // Switch to send mail.
	}
}

function AttachDuke( DukePlayer NewDuke )
{
	CurrentMessage = 0;
	if ( !LoginRequired )
	{
		TransitionToBackgroundSmack = TransitionFromSaverSmack;
		TransitionToBackgroundFrames = TransitionFromSaverFrames;
	}
	else
	{
		TransitionToBackgroundSmack = TransitionFromLoginSmack;
		TransitionToBackgroundFrames = TransitionFromLoginFrames;
	}

	Super.AttachDuke( NewDuke );

	BackgroundTexture = SendMailBackground;
}

function DetachDuke()
{
	local int i;

	Super.DetachDuke();

	for ( i=0; i<5; i++ )
	{
		Popups[i].PopupOpenTex.pause = true;
		Popups[i].PopupOpenTex.currentFrame = 0;
		Popups[i].PopupCloseTex.pause = true;
		Popups[i].PopupCloseTex.currentFrame = 0;
	}
}


//=============================================================================
//	VerifyAddr
//=============================================================================
function bool VerifyAddr(string Addr)
{
	local int		i, Length;

	Length = Len(Addr);

	for (i=0; i< Length; i++)
	{
		if (Mid(Addr, i, 1) == "@")
			break;
	}

	if (i == Length || Windows[0].TextLines[0] == "")
		return false;

	return true;
}

//=============================================================================
//	SendMail
//=============================================================================
function SendMail()
{
	local string	MessageBuffer;
	local int		i, NumSends, Length;
	local string	CurrentAddr[20];
	local bool		bMatchSpecialEvent;

	if ( (Windows[2].HighestEditLine == 0) && (Windows[2].TextLines[0] == "") )
	{
		CreatePopup( POP_NothingToSend );
		return;
	}

	NumSends = 0;
	Length = Len(Windows[0].TextLines[0]);
	
	for (i=0; i< Length; i++)
	{
		if (Mid(Windows[0].TextLines[0], i, 1) == ";" || Mid(Windows[0].TextLines[0], i, 1) == ",")
		{
			if (VerifyAddr(CurrentAddr[NumSends]))
				NumSends++;
		}
		else
			CurrentAddr[NumSends] = CurrentAddr[NumSends] $ Mid(Windows[0].TextLines[0], i, 1);

		if (NumSends >= 20)
			break;
	}

	if (i == Length && VerifyAddr(CurrentAddr[NumSends]))
		NumSends++;

	if (NumSends <= 0)
	{
		CreatePopup( POP_BadAddress );
		return;
	}

	// Check to see if the address matches any of our special events.
	for ( i=0; i<10; i++ )
	{
		if ( (MessageEvents[i].MatchAddress != "") && (MessageEvents[i].MatchAddress == Windows[0].TextLines[0]) )
		{
			bMatchSpecialEvent = true;
			ParseSpecialEvent(i);
		}
		if ( bMatchSpecialEvent )
		{
			CreatePopup( POP_MessageSent );
			return;
		}
	}

	// Build the message buffer with proper formatting
	MessageBuffer = Windows[2].TextLines[0];
	for ( i=1; i< Windows[2].HighestEditLine; i++ )
		MessageBuffer = MessageBuffer $ "\n" $ Windows[2].TextLines[i];

	// Add the footer msg's
	if (FooterMsg1 != "")
	{
		MessageBuffer = MessageBuffer $ "\n";
		for (i=0; i< Max(Len(FooterMsg1), Max(Len(FooterMsg2), Len(FooterMsg3)))+2; i++)
			MessageBuffer = MessageBuffer $ "-";

		MessageBuffer = MessageBuffer $ "\n" $ FooterMsg1;
		if (FooterMsg2 != "")
			MessageBuffer = MessageBuffer $ "\n" $ FooterMsg2;
		if (FooterMsg3 != "")
			MessageBuffer = MessageBuffer $ "\n" $ FooterMsg3;
	}

	for (i=0; i< NumSends; i++)
	{
		// Send the message buffer
		if (!SendMailMessage(CurrentAddr[i], MessageBuffer, Windows[1].TextLines[0]))
		{
			Duke.ClientMessage("Failed to send message.");
			return;
		}
	}
	
	// Notify.
	CreatePopup( POP_MessageSent );
}

function ParseSpecialEvent( int Index )
{
	local int i, j, matches[10], matchesneeded, matchesfound;
	local bool CompleteMatch;

	// Reset match buffer.
	for ( i=0; i<10; i++ )
	{
		matches[i] = -1;
	}

	// Search the current message for the given special event key words.
	for ( i=0; i<Windows[2].MaxLines; i++ )
	{
		if ( Windows[2].TextLines[i] != "" )
		{
			for ( j=0; j<10; j++ )
			{
				if ( (MessageEvents[Index].MatchPhrases[j] != "") && (matches[j] == -1) )
				{
					matches[j] = InStr( Caps(Windows[2].TextLines[i]), Caps(MessageEvents[Index].MatchPhrases[j]) );
				}
			}
		}
	}

	// Check to see if we got all of our matches.
	for ( i=0; i<10; i++ )
	{
		if ( MessageEvents[Index].MatchPhrases[i] != "" )
		{
			matchesneeded++;
			if ( matches[i] != -1 )
				matchesfound++;
		}
	}

	if ( MatchAny )
		matchesneeded = 1;

	// Check to see if we matched all of them.
	if ( matchesneeded <= matchesfound )
	{
		// Score.
		if ( MessageEvents[Index].MatchEvent != '' )
			GlobalTrigger( MessageEvents[Index].MatchEvent );
	}
}

function TryLogin()
{
	local string UserMatchA, UserMatchB, PassMatchA, PassMatchB;

	UserMatchA = Caps( Windows[0].TextLines[0] );
	UserMatchB = Caps( LoginUsername );
	PassMatchA = Caps( Windows[1].TextLines[0] );
	PassMatchB = Caps( LoginPassword );

	if ( (UserMatchA != UserMatchB) || (PassMatchA != PassMatchB) )
	{
		Windows[0].TextLines[0] = "";
		Windows[1].TextLines[0] = "";
		LoginFailed = true;
		LoginFailedTime = 3.0;
	}
	else
	{
		LoginFailed = false;
		LoginFailedtime = 0.0;
		Windows[0].TextLines[0] = "";
		Windows[1].TextLines[0] = "";
		NumWindows = 0;
		LoginSuccessful();
	}
}

//=============================================================================
//	MouseClick
//=============================================================================
function MouseClick()
{
	Super.MouseClick();

	if ( LoggingIn )
	{
		if ( ClickInside( LoginButton ) )
		{
			CW = 2;
			TryLogin();
			Windows[2].ButtonDownTime = 0.15;
		}
		else if ( ClickInside( ClearButton ) )
		{
			CW = 3;
			Windows[0].TextLines[0] = "";
			Windows[1].TextLines[0] = "";
			Windows[3].ButtonDownTime = 0.15;
		}
		else if ( ClickInside( UsernameField ) )
		{
			CW = 0;
			WindowClick();
		}
		else if ( ClickInside( PasswordField ) )
		{
			CW = 1;
			WindowClick();
		}
	}
	else
	{
		if ( BackgroundTexture == SendMailBackground )
		{
			if ( ClickInside( ToField ) )
			{
				if ( Windows[0].TextLines[0] ~= DefaultTo )
					Windows[0].TextLines[0] = "";
				CW = 0;
				WindowClick();
			}
			else if ( ClickInside( SubjectField ) )
			{
				CW = 1;
				WindowClick();
			}
			else if ( ClickInside( MessageField ) )
			{
				CW = 2;
				WindowClick();
			}
			else if ( ClickInside( SendButton ) )
			{
				ButtonPressed( 3 );
				Windows[3].ButtonDownTime = 0.15;
			}
			else if ( ClickInside( ResetButton ) )
			{
				ButtonPressed( 4 );
				Windows[4].ButtonDownTime = 0.15;
			}
			else if ( ClickInside( ExitButton ) )
			{
				ButtonPressed( 5 );
				Windows[5].ButtonDownTime = 0.15;
			}
			else if ( ClickInside( EMailButton ) )
			{
				if ( HasEmail )
					ButtonPressed( 6 );
			}
		}
		else if ( BackgroundTexture == RecvMailBackground )
		{
			if ( ClickInside( FromField ) )
			{
				CW = 0;
			}
			else if ( ClickInside( SubjectField ) )
			{
				CW = 1;
			}
			else if ( ClickInside( MessageField ) )
			{
				CW = 2;
			}
			else if ( ClickInside( ReplyButton ) )
			{
				ButtonPressed( 11 );
				Windows[6].ButtonDownTime = 0.15;
			}
			else if ( ClickInside( NextButton ) )
			{
				ButtonPressed( 7 );
				Windows[3].ButtonDownTime = 0.15;
			}
			else if ( ClickInside( PrevButton ) )
			{
				ButtonPressed( 8 );
				Windows[4].ButtonDownTime = 0.15;
			}
			else if ( ClickInside( RecvExitButton ) )
			{
				ButtonPressed( 9 );
				Windows[5].ButtonDownTime = 0.15;
			}
			else if ( ClickInside( SwitchButton ) )
			{
				ButtonPressed( 10 );
			}
		}
	}
}

// Support for checking SFieldInfo clicks.
function bool ClickInside( SFieldInfo inField )
{
	if ( ((MouseX > inField.x) && (MouseX < inField.x + inField.ClickWidth)) &&
		 ((MouseY > inField.y) && (MouseY < inField.y + inField.ClickHeight)) )
		 return true;
	else
		return false;
}

function EmptyAllWindows()
{
	local int i;

	Super.EmptyAllWindows();

	for ( i=0; i<5; i++ )
	{
		Popups[i].PopupOpenTex.pause = true;
		Popups[i].PopupOpenTex.currentFrame = 0;
		Popups[i].PopupCloseTex.pause = true;
		Popups[i].PopupCloseTex.currentFrame = 0;
	}
}

function TransitionToBackgroundFinished()
{
	Super.TransitionToBackgroundFinished();

	EmptyAllWindows();
	if ( TransitionToBackgroundSmack == TransitionToRecvMailSmack )
	{
		BackgroundTexture = RecvMailBackground;
		AddRecvMailWindows();
	}
	else if ( (TransitionToBackgroundSmack == TransitionFromLoginSmack) ||
			  (TransitionToBackgroundSmack == TransitionToSendMailSmack) ||
			  (TransitionToBackgroundSmack == TransitionFromSaverSmack) )
	{
		BackgroundTexture = SendMailBackground;
		AddSendMailWindows();
	}
}

function AddSendMailWindows()
{
	local int i;

	// Set number of windows Controls we are going to use
	NumWindows = 6;
	MaxHighlightWindow = 2;

	// Addr
	Windows[0].Name = ToField.FieldName;
	Windows[0].IsConsole = false;
	Windows[0].x = ToField.x; Windows[0].y = ToField.y;
	Windows[0].Width = ToField.Width; Windows[0].Height = ToField.Height;
	Windows[0].ClickWidth = ToField.ClickWidth; Windows[0].ClickHeight = ToField.ClickHeight;
	Windows[0].TextLines[0] = DefaultTo;
	Windows[0].MaxLines = ToField.MaxLines;
	Windows[0].HighlightTex = ToField.HighlightTex;
	Windows[0].hx = ToField.hx;
	Windows[0].hy = ToField.hy;
	
	// Check to see if we are replying.
	if ( PendingMailAddress != "" )
	{
		Windows[0].TextLines[0] = PendingMailAddress;
		PendingMailAddress = "";
	}

	// Subject
	Windows[1].Name = SubjectField.FieldName;
	Windows[1].IsConsole = false;
	Windows[1].x = SubjectField.x; Windows[1].y = SubjectField.y;
	Windows[1].Width = SubjectField.Width; Windows[1].Height = SubjectField.Height;
	Windows[1].ClickWidth = SubjectField.ClickWidth; Windows[1].ClickHeight = SubjectField.ClickHeight;
	Windows[1].TextLines[0] = DefaultSubject;
	Windows[1].MaxLines = SubjectField.MaxLines;
	Windows[1].HighlightTex = SubjectField.HighlightTex;
	Windows[1].hx = SubjectField.hx;
	Windows[1].hy = SubjectField.hy;
	Windows[1].PrivateEcho = false;

	// Check to see if we are replying.
	if ( PendingMailSubject != "" )
	{
		Windows[1].TextLines[0] = PendingMailSubject;
		PendingMailSubject = "";
	}

	// Message
	Windows[2].Name = MessageField.FieldName;
	Windows[2].IsConsole = true;
	Windows[2].x = MessageField.x; Windows[2].y = MessageField.y;
	Windows[2].Width = MessageField.Width; Windows[2].Height = MessageField.Height;
	Windows[2].ClickWidth = MessageField.ClickWidth; Windows[2].ClickHeight = MessageField.ClickHeight;
	Windows[2].MaxLines = MessageField.MaxLines;
	Windows[2].HighlightTex = MessageField.HighlightTex;
	Windows[2].hx = MessageField.hx;
	Windows[2].hy = MessageField.hy;

	// Send Button
	Windows[3].Name = SendButton.FieldName;
	Windows[3].IsButton = true;
	Windows[3].x = SendButton.x; Windows[3].y = SendButton.y;
	Windows[3].Width = SendButton.Width; Windows[3].Height = SendButton.Height;
	Windows[3].ClickWidth = SendButton.ClickWidth; Windows[3].ClickHeight = SendButton.ClickHeight;
	Windows[3].ButtonDownTex = SendButton.ButtonDownTex;

	// Reset Button
	Windows[4].Name = ResetButton.FieldName;
	Windows[4].IsButton = true;
	Windows[4].x = ResetButton.x; Windows[4].y = ResetButton.y;
	Windows[4].Width = ResetButton.Width; Windows[4].Height = ResetButton.Height;
	Windows[4].ClickWidth = ResetButton.ClickWidth; Windows[4].ClickHeight = ResetButton.ClickHeight;
	Windows[4].ButtonDownTex = ResetButton.ButtonDownTex;

	// Exit Button
	Windows[5].Name = ExitButton.FieldName;
	Windows[5].IsButton = true;
	Windows[5].x = ExitButton.x; Windows[5].y = ExitButton.y;
	Windows[5].Width = ExitButton.Width; Windows[5].Height = ExitButton.Height;
	Windows[5].ClickWidth = ExitButton.ClickWidth; Windows[5].ClickHeight = ExitButton.ClickHeight;
	Windows[5].ButtonDownTex = ExitButton.ButtonDownTex;

	// E-Mail Button
	if ( HasEmail )
	{
		NumWindows++;
		Windows[6].Name = EmailButton.FieldName;
		Windows[6].IsButton = true;
		Windows[6].x = EmailButton.x; Windows[6].y = EmailButton.y;
		Windows[6].Width = EmailButton.Width; Windows[6].Height = EmailButton.Height;
		Windows[6].ClickWidth = EmailButton.ClickWidth; Windows[6].ClickHeight = EmailButton.ClickHeight;
		Windows[6].ButtonTex = EmailButton.ButtonTex;
	}

	CW = 2;
}

function AddRecvMailWindows()
{
	local int i;

	// Set number of windows Controls we are going to use
	NumWindows = 7;
	MaxHighlightWindow = 2;

	// Addr
	Windows[0].Name = FromField.FieldName;
	Windows[0].IsConsole = false;
	Windows[0].x = FromField.x; Windows[0].y = FromField.y;
	Windows[0].Width = FromField.Width; Windows[0].Height = FromField.Height;
	Windows[0].ClickWidth = FromField.ClickWidth; Windows[0].ClickHeight = FromField.ClickHeight;
	Windows[0].MaxLines = FromField.MaxLines;
	Windows[0].HighlightTex = FromField.HighlightTex;
	Windows[0].hx = FromField.hx;
	Windows[0].hy = FromField.hy;
	Windows[0].NoEdit = true;
	
	// Subject
	Windows[1].Name = SubjectField.FieldName;
	Windows[1].IsConsole = false;
	Windows[1].x = SubjectField.x; Windows[1].y = SubjectField.y;
	Windows[1].Width = SubjectField.Width; Windows[1].Height = SubjectField.Height;
	Windows[1].ClickWidth = SubjectField.ClickWidth; Windows[1].ClickHeight = SubjectField.ClickHeight;
	Windows[1].MaxLines = SubjectField.MaxLines;
	Windows[1].HighlightTex = SubjectField.HighlightTex;
	Windows[1].hx = SubjectField.hx;
	Windows[1].hy = SubjectField.hy;
	Windows[1].PrivateEcho = false;
	Windows[1].NoEdit = true;

	// Message
	Windows[2].Name = MessageField.FieldName;
	Windows[2].IsConsole = true;
	Windows[2].x = MessageField.x; Windows[2].y = MessageField.y;
	Windows[2].Width = MessageField.Width; Windows[2].Height = MessageField.Height;
	Windows[2].ClickWidth = MessageField.ClickWidth; Windows[2].ClickHeight = MessageField.ClickHeight;
	Windows[2].MaxLines = MessageField.MaxLines;
	Windows[2].HighlightTex = MessageField.HighlightTex;
	Windows[2].hx = MessageField.hx;
	Windows[2].hy = MessageField.hy;
	Windows[2].NoEdit = true;

	// Next Button
	Windows[3].Name = NextButton.FieldName;
	Windows[3].IsButton = true;
	Windows[3].x = NextButton.x; Windows[3].y = NextButton.y;
	Windows[3].Width = NextButton.Width; Windows[3].Height = NextButton.Height;
	Windows[3].ClickWidth = NextButton.ClickWidth; Windows[3].ClickHeight = NextButton.ClickHeight;
	Windows[3].ButtonDownTex = NextButton.ButtonDownTex;

	// Prev Button
	Windows[4].Name = PrevButton.FieldName;
	Windows[4].IsButton = true;
	Windows[4].x = PrevButton.x; Windows[4].y = PrevButton.y;
	Windows[4].Width = PrevButton.Width; Windows[4].Height = PrevButton.Height;
	Windows[4].ClickWidth = PrevButton.ClickWidth; Windows[4].ClickHeight = PrevButton.ClickHeight;
	Windows[4].ButtonDownTex = PrevButton.ButtonDownTex;

	// Exit Button
	Windows[5].Name = RecvExitButton.FieldName;
	Windows[5].IsButton = true;
	Windows[5].x = RecvExitButton.x; Windows[5].y = RecvExitButton.y;
	Windows[5].Width = RecvExitButton.Width; Windows[5].Height = RecvExitButton.Height;
	Windows[5].ClickWidth = RecvExitButton.ClickWidth; Windows[5].ClickHeight = RecvExitButton.ClickHeight;
	Windows[5].ButtonDownTex = RecvExitButton.ButtonDownTex;

	// Reply Button
	Windows[6].Name = ReplyButton.FieldName;
	Windows[6].IsButton = true;
	Windows[6].x = ReplyButton.x; Windows[6].y = ReplyButton.y;
	Windows[6].Width = ReplyButton.Width; Windows[6].Height = ReplyButton.Height;
	Windows[6].ClickWidth = ReplyButton.ClickWidth; Windows[6].ClickHeight = ReplyButton.ClickHeight;
	Windows[6].ButtonDownTex = ReplyButton.ButtonDownTex;

	// Switch back button
	if ( HasEmail )
	{
		Windows[NumWindows].Name = SwitchButton.FieldName;
		Windows[NumWindows].IsButton = true;
		Windows[NumWindows].x = SwitchButton.x; Windows[NumWindows].y = SwitchButton.y;
		Windows[NumWindows].Width = SwitchButton.Width; Windows[NumWindows].Height = SwitchButton.Height;
		Windows[NumWindows].ClickWidth = SwitchButton.ClickWidth; Windows[NumWindows].ClickHeight = SwitchButton.ClickHeight;
		Windows[NumWindows].ButtonTex = SwitchButton.ButtonTex;
		NumWindows++;

		if ( StoredMessages[0].FromAddress != "" )
		{
			Windows[0].TextLines[0] = StoredMessages[0].FromAddress;
			Windows[1].TextLines[0] = StoredMessages[0].Subject;
			for (i=0; i<10; i++)
			{
				Windows[2].TextLines[i] = StoredMessages[0].TextLines[i];
			}
		}
	}

	CW = 2;
}

function ClearMessage()
{
	local int i;

	Windows[0].TextLines[0] = "";
	Windows[1].TextLines[0] = "";
	for (i=0; i<10; i++)
	{
		Windows[2].TextLines[i] = "";
	}
}

function ReadNextMessage( optional bool Backwards )
{
	local int SafetyNet, i;

	if ( Backwards )
	{
		CurrentMessage--;
		if ( CurrentMessage < 0 )
			CurrentMessage = 8;
	}
	else
	{
		CurrentMessage++;
		if ( CurrentMessage > 8 )
			CurrentMessage = 0;
	}
	while ( (StoredMessages[CurrentMessage].FromAddress == "") && (SafetyNet < 100) )
	{
		SafetyNet++;
		if ( Backwards )
		{
			CurrentMessage--;
			if ( CurrentMessage < 0 )
				CurrentMessage = 8;
		}
		else
		{
			CurrentMessage++;
			if ( CurrentMessage > 8 )
				CurrentMessage = 0;
		}
	}

	if ( SafetyNet == 100 )
	{
		BroadcastMessage("INFINITE LOOP! STUPID LEVEL DESIGNER YOU HAVE TO PUT EMAIL IN ME!");
		return;
	}

	Windows[0].TextLines[0] = StoredMessages[CurrentMessage].FromAddress;
	Windows[1].TextLines[0] = StoredMessages[CurrentMessage].Subject;
	for (i=0; i<10; i++)
	{
		Windows[2].TextLines[i] = StoredMessages[CurrentMessage].TextLines[i];
	}
}

function AddMessage( AddEmailTrigger Trig )
{
	local int i, j, k;

	HasEmail = true;

	k = -1;
	for (i=0; (i<8) && (k==-1); i++)
	{
		if ( StoredMessages[i].FromAddress == "" )
		{
			k = i;
		}
	}
	if ( k == -1 )
		return;
	StoredMessages[k].FromAddress = Trig.FromAddress;
	StoredMessages[k].Subject = Trig.Subject;
	for (j=0; j<10; j++)
	{
		StoredMessages[k].TextLines[j] = Trig.TextLines[j];
	}
	if ( Duke != None )
	{
		if ( BackgroundTexture == RecvMailBackground )
			CreatePopup( POP_YouHaveMailRecv );
		else
			CreatePopup( POP_YouHaveMail );
	}
	if ( NewMailEvent != '' )
		GlobalTrigger( NewMailEvent );
}

function CreatePopup( EPopups NewPopup )
{
	Popups[NewPopup].PopupCloseTex.pause = true;
	Popups[NewPopup].PopupCloseTex.currentFrame = 0;
	Popups[NewPopup].PopupOpenTex.pause = false;
	Popups[NewPopup].PopupOpenTex.currentFrame = 0;
}

function RenderScreen( float DeltaSeconds )
{
	local int i;

	Super.RenderScreen( DeltaSeconds );

	for ( i=0; i<5; i++ )
	{
		if ( !Popups[i].PopupOpenTex.pause )
		{
			if ( Popups[i].PopupOpenTex.currentFrame < Popups[i].PopupOpenFrames )
			{
				Popups[i].PopupOpenTex.ForceTick( DeltaSeconds );
				ScreenCanvas.DrawBitmap( Popups[i].X, Popups[i].Y, 0, 0, 0, 0, Popups[i].PopupOpenTex, true );
			}
			else
			{
				ScreenCanvas.DrawBitmap( Popups[i].X, Popups[i].Y, 0, 0, 0, 0, Popups[i].PopupOpenTex, true );
				Popups[i].PopupOpenTex.pause = true;
				Popups[i].PopupCloseTex.pause = false;
			}
		}
		else if ( !Popups[i].PopupCloseTex.pause )
		{
			if ( Popups[i].PopupCloseTex.currentFrame < Popups[i].PopupCloseFrames )
			{
				Popups[i].PopupCloseTex.ForceTick( DeltaSeconds );
				ScreenCanvas.DrawBitmap( Popups[i].X, Popups[i].Y, 0, 0, 0, 0, Popups[i].PopupCloseTex, true );
			}
			else
			{
				Popups[i].PopupCloseTex.pause = true;
			}
		}
	}
}


//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	UsernameField=(FieldName="Username",x=87,y=112,Width=128,Height=1,ClickWidth=128,ClickHeight=16,MaxLines=1,hx=77,hy=104,HighlightTex=texture'ezmail.login_user_hl');
	PasswordField=(FieldName="Password",x=87,y=132,Width=128,Height=1,ClickWidth=128,ClickHeight=16,MaxLines=1,hx=77,hy=124,HighlightTex=texture'ezmail.login_pass_hl');
	ToField=(FieldName="To",x=16,y=46,Width=146,Height=1,ClickWidth=149,ClickHeight=16,MaxLines=1,hx=0,hy=34,HighlightTex=texture'ezmail.emailto_hl');
	FromField=(FieldName="From",x=16,y=46,Width=146,Height=1,ClickWidth=149,ClickHeight=16,MaxLines=1,hx=0,hy=34,HighlightTex=texture'ezmail.emailfrom_hl');
	SubjectField=(FieldName="Subject",x=16,y=77,Width=226,Height=1,ClickWidth=226,ClickHeight=16,MaxLines=1,hx=0,hy=65,HighlightTex=texture'ezmail.emailsubject_hl');
	MessageField=(FieldName="Message",x=16,y=108,Width=226,Height=10,ClickWidth=226,ClickHeight=128,MaxLines=64,hx=0,hy=99,HighlightTex=texture'ezmail.emailmessage_hl');
	SendButton=(FieldName="Send",x=13,y=231,Width=45,Height=16,ClickWidth=45,ClickHeight=16,MaxLines=0,ButtonDownTex=texture'ezmail.emailsend');
	ResetButton=(FieldName="Reset Message",x=61,y=231,Width=69,Height=16,ClickWidth=69,ClickHeight=16,MaxLines=0,ButtonDownTex=texture'ezmail.emailresetmessage');
	ExitButton=(FieldName="EXIT",x=133,y=231,Width=39,Height=16,ClickWidth=39,ClickHeight=16,MaxLines=0,ButtonDownTex=texture'ezmail.emailexit');
	LoginButton=(FieldName="Login",x=150,y=146,Width=34,Height=13,ClickWidth=34,ClickHeight=13,MaxLines=0,ButtonDownTex=texture'ezmail.ezmaillogenter_hl');
	ClearButton=(FieldName="Clear",x=185,y=146,Width=34,Height=13,ClickWidth=34,ClickHeight=13,MaxLines=0,ButtonDownTex=texture'ezmail.ezmaillogclear_hl');
	EmailButton=(FieldName="E-Mail",x=175,y=23,Width=63,Height=49,ClickWidth=63,ClickHeight=49,MaxLines=0,ButtonTex=texture'ezmail.ezmail_icon');
	ReplyButton=(FieldName="Reply",x=14,y=231,Width=45,Height=17,ClickWidth=45,ClickHeight=17,MaxLines=0,ButtonDownTex=texture'ezmail.emailreply_recv_hl');
	NextButton=(FieldName="Next",x=110,y=231,Width=45,Height=17,ClickWidth=45,ClickHeight=17,MaxLines=0,ButtonDownTex=texture'ezmail.emailnext_recv_hl');
	PrevButton=(FieldName="Previous",x=62,y=231,Width=45,Height=17,ClickWidth=45,ClickHeight=17,MaxLines=0,ButtonDownTex=texture'ezmail.emailprevious_recv_hl');
	RecvExitButton=(FieldName="EXIT",x=157,y=231,Width=41,Height=17,ClickWidth=41,ClickHeight=17,MaxLines=0,ButtonDownTex=texture'ezmail.emailexit_recv_hl');
	SwitchButton=(FieldName="Switch",x=177,y=24,Width=63,Height=49,ClickWidth=63,ClickHeight=49,MaxLines=0);

	DefaultTo="Enter To Address Here"
	DefaultSubject="A Message From Duke Nukem"

	FooterMsg1="The sender is playing Duke Nukem Forever."
	FooterMsg2="Why aren't you? http://www.3drealms.com"
	FooterMsg3=""

	BackgroundTexture=texture'ezmail.emailbackground'
	MouseTexture=texture'ezmail.email_cursor'
	LoginSmack=smackertexture'ezmail.email_login'
	LoginFailedTexture=texture'ezmail.email_incorrectlog'
	LoginFailedX=52
	LoginFailedy=16
	TransitionToBackgroundSmack=smackertexture'ezmail.login2sndmail'
	TransitionToBackgroundFrames=14
	TransitionFromLoginSmack=smackertexture'ezmail.login2sndmail'
	TransitionFromLoginFrames=14
	TransitionToRecvMailSmack=smackertexture'ezmail.sndmail2rcvmail'
	TransitionToRecvMailFrames=13
	TransitionToSendMailSmack=smackertexture'ezmail.rcvmail2sndmail'
	TransitionToSendMailFrames=14
	TransitionFromSaverSmack=smackertexture'ezmail.saver2sndmail'
	TransitionFromSaverFrames=14
	SendMailBackground=texture'ezmail.emailbackground'
	RecvMailBackground=texture'ezmail.emailbackground_rcv'

	Popups(0)=(X=173,Y=229,PopupOpenTex=smackertexture'badadd_open',PopupOpenFrames=29,PopupCloseTex=smackertexture'badadd_close',PopupCloseFrames=4);
	Popups(1)=(X=173,Y=229,PopupOpenTex=smackertexture'msgsent_open',PopupOpenFrames=29,PopupCloseTex=smackertexture'msgsent_close',PopupCloseFrames=4);
	Popups(2)=(X=173,Y=229,PopupOpenTex=smackertexture'nothingsend_open',PopupOpenFrames=29,PopupCloseTex=smackertexture'nothingsend_close',PopupCloseFrames=4);
	Popups(3)=(X=169,Y=23,PopupOpenTex=smackertexture'youhave_open',PopupOpenFrames=29,PopupCloseTex=smackertexture'youhave_close',PopupCloseFrames=4);
	Popups(4)=(X=169,Y=23,PopupOpenTex=smackertexture'youhave_recv_open',PopupOpenFrames=29,PopupCloseTex=smackertexture'youhave_recv_close',PopupCloseFrames=4);
}
