class UMenuWeaponPriorityCW extends UMenuDialogClientWindow;

var string ListAreaClass;
var UWindowHSplitter HSplitter;

function Created()
{
	Super.Created();

	HSplitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
	
	HSplitter.RightClientWindow = HSplitter.CreateWindow(class'UMenuWeaponPriorityMesh', 0, 0, 100, 100);
	HSplitter.LeftClientWindow = HSplitter.CreateWindow(class<UWindowWindow>(DynamicLoadObject(ListAreaClass, class'Class')), 0, 0, 100, 100, OwnerWindow);

	HSplitter.bRightGrow = True;
	HSplitter.SplitPos = 150;
	HSplitter.MinWinWidth = 140;
}

function Resized()
{
	Super.Resized();
	HSplitter.SetSize(WinWidth, WinHeight);
}

defaultproperties
{
	ListAreaClass="UMenu.UMenuWeaponPriorityListArea"
}