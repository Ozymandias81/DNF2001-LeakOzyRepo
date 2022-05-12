class DoorArea extends UWindowWindow;

var bool bClosed, bOpening;

var float DoorPos, PendingPos;

function Paint(Canvas C, float X, float Y)
{
	if (bClosed)
		DoorPos = 0;

	DrawStretchedTexture(C, DoorPos, 0, WinWidth/2, WinHeight, texture'DoorL');
	DrawStretchedTexture(C, WinWidth/2 - DoorPos, 0, WinWidth/2, WinHeight, texture'DoorR');
}

function Open()
{
	DoorPos = 0;
	PendingPos = -(WinWidth/2);
	bClosed = False;
	bOpening = True;
}

function Tick(float Delta)
{
	if (PendingPos < DoorPos)
		DoorPos -= Delta*60;
	else if (bOpening)
		HideWindow();
}