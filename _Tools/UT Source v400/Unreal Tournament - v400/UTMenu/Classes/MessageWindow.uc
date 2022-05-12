class MessageWindow extends UWindowWindow;

var UTFadeTextArea TextArea;
var Color TextColor;

function Created()
{
	local float AreaLeft, AreaTop, AreaWidth, AreaHeight;

	Super.Created();

	bLeaveOnScreen = True;
	bAlwaysOnTop = True;

	WinLeft = Root.WinWidth/4;
	WinTop = Root.WinHeight/4;
	WinWidth = Root.WinWidth/2;
	WinHeight = Root.WinHeight/2;

	AreaLeft = 0;
	AreaTop = 0;
	AreaWidth = WinWidth;
	AreaHeight = WinHeight;

	TextArea = UTFadeTextArea(CreateWindow(Class<UWindowWindow>(DynamicLoadObject("UTMenu.UTFadeTextArea", Class'Class')), AreaLeft, AreaTop, AreaWidth, AreaHeight));
	TextArea.FadeFactor = 3;
	TextArea.MyFont = class'UTLadderStub'.Static.GetBigFont(Root);
	TextColor.R = 255;
	TextColor.G = 255;
	TextColor.B = 255;
	TextArea.SetTextColor(TextColor);
}

function BeforePaint( Canvas C, float X, float Y )
{
	local float AreaLeft, AreaTop, AreaWidth, AreaHeight;

	Super.BeforePaint(C, X, Y);

	WinLeft = Root.WinWidth/4;
	WinTop = Root.WinHeight/4;
	WinWidth = Root.WinWidth/2;
	WinHeight = Root.WinHeight/2;

	AreaLeft = 0;
	AreaTop = 0;
	AreaWidth = WinWidth;
	AreaHeight = WinHeight;

	TextArea.SetSize( AreaWidth, AreaHeight );
	TextArea.WinLeft = AreaLeft;
	TextArea.WinTop = AreaTop;
}

function AddMessage( string NewMessage )
{
	TextArea.Clear();
	TextArea.AddText( NewMessage );
}