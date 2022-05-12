class UTWeaponPriorityCW extends UMenuWeaponPriorityCW;

var UWindowVSplitter VSplitter;
var UTWeaponPriorityInfoArea InfoWindow;

function Created()
{
	Super.Created();

	VSplitter = UWindowVSplitter(CreateWindow(class'UWindowVSplitter', 0, 0, WinWidth, WinHeight));
	HSplitter.SetParent(VSplitter);

	VSplitter.TopClientWindow = HSplitter;
	InfoWindow = UTWeaponPriorityInfoArea(CreateWindow(class'UTWeaponPriorityInfoArea', 0, 0, 100, 100));
	VSplitter.BottomClientWindow = InfoWindow;
	if(Root.WinHeight > 300)
		VSplitter.SplitPos = VSplitter.WinHeight - 80;
	else
		VSplitter.SplitPos = VSplitter.WinHeight - 50;
}

function Resized()
{
	VSplitter.SetSize(WinWidth, WinHeight);
}

defaultproperties
{
	ListAreaClass="UTMenu.UTWeaponPriorityListArea"
}