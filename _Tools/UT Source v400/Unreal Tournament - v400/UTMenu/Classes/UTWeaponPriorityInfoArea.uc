class UTWeaponPriorityInfoArea expands UMenuDialogClientWindow;

var UWindowDynamicTextArea Description;
var UWindowControlFrame Frame;

function Created()
{
	Description = UWindowDynamicTextArea(CreateControl(class'UWindowDynamicTextArea', 0, 0, 100, 100));
	Description.SetTextColor(LookAndFeel.EditBoxTextColor);
	Description.bTopCentric = True;
	Frame = UWindowControlFrame(CreateWindow(class'UWindowControlFrame', 0, 0, 100, 100));
	Frame.SetFrame(Description);
}

function BeforePaint(Canvas C, float X, float Y)
{
	Frame.SetSize(WinWidth - 10, WinHeight - 10);
	Frame.WinTop = 5;
	Frame.WinLeft = 5;
}
