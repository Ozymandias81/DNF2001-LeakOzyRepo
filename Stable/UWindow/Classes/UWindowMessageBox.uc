class UWindowMessageBox expands UWindowFramedWindow;

var MessageBoxResult	Result;
var string				StringResult;
var float				TimeOutTime;
var int					TimeOut;
var bool				bSetupSize;
var int					FrameCount;

function SetupMessageBox(string Title, string Message, MessageBoxButtons Buttons, MessageBoxResult InESCResult, optional MessageBoxResult InEnterResult, optional int InTimeOut)
{
	WindowTitle = Title;
	UWindowMessageBoxCW(ClientArea).SetupMessageBoxClient(Message, Buttons, InEnterResult);
	Result = InESCResult;
	TimeOutTime = 0;
	TimeOut = InTimeOut;
	FrameCount = 0;
}

function BeforePaint( Canvas C, float X, float Y )
{
	local Region R;

	if ( !bSetupSize )
	{
		LookAndFeel.MessageBox_AutoSize( Self, C );
		bSetupSize = true;
	}

	Super.BeforePaint(C, X, Y);
}

function AfterPaint(Canvas C, float X, float Y)
{
	Super.AfterPaint(C, X, Y);

	if(TimeOut != 0)
	{
		FrameCount++;
		
		if(FrameCount >= 5)
		{
			TimeOutTime = GetEntryLevel().TimeSeconds + TimeOut;
			TimeOut = 0;
		}
	}

	if(TimeOutTime != 0 && GetEntryLevel().TimeSeconds > TimeOutTime)
	{
		TimeOutTime = 0;
		Close();
	}
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	OwnerWindow.MessageBoxDone(Self, Result);
}

defaultproperties
{
	ClientClass=class'UWindowMessageBoxCW'
	bMessageBoxFrame=true
}