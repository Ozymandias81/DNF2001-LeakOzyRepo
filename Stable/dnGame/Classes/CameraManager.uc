/*-----------------------------------------------------------------------------
	CameraManager
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class CameraManager extends Info;

var CameraManager LeftSlave;
var CameraManager RightSlave;
var CameraManager RelinquishSlave;
var() name RelinquishTag;
var() int NumCams;

var int CurrentCam;

function PostBeginPlay()
{
	// Create slaves.
	if (CameraManager(Owner) == None)
	{
		LeftSlave = spawn(class'CameraManager', Self);
		LeftSlave.Tag = NameForString(Tag$"Left");
		RightSlave = spawn(class'CameraManager', Self);
		RightSlave.Tag = NameForString(Tag$"Right");
		RelinquishSlave = spawn(class'CameraManager', Self);
		RelinquishSlave.Tag = RelinquishTag;
	}
}

function Trigger( Actor Other, Pawn Instigator )
{
	if (CameraManager(Owner) != None)
		CameraManager(Owner).CameraEvent(Self);
	else {
		CurrentCam = 0;
		RenameAllSurfaces( Event, NameForString(Event$CurrentCam) );
	}
}

function CameraEvent( CameraManager EventSlave )
{
	local int OldCam;

	if ( EventSlave == LeftSlave )
	{
		OldCam = CurrentCam;
		CurrentCam--;
		if (CurrentCam < 0)
			CurrentCam = NumCams - 1;
		RenameAllSurfaces( NameForString(Event$OldCam), NameForString(Event$CurrentCam) );
	}
	else if ( EventSlave == RightSlave )
	{
		OldCam = CurrentCam;
		CurrentCam++;
		if (CurrentCam == NumCams)
			CurrentCam = 0;
		RenameAllSurfaces( NameForString(Event$OldCam), NameForString(Event$CurrentCam) );
	}
	else if ( EventSlave == RelinquishSlave )
	{
		OldCam = CurrentCam;
		RenameAllSurfaces( NameForString(Event$OldCam), Event );
	}
}