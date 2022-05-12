class UMenuSlotClientWindow extends UMenuDialogClientWindow
	config(user);

var globalconfig string SlotNames[9];
var localized string MonthNames[12];
var localized string SlotHelp;

var UMenuRaisedButton Slots[9];

function Created()
{
	local int ButtonWidth, ButtonLeft, ButtonTop, I;

	Super.Created();

	ButtonWidth = WinWidth - 60;
	ButtonLeft = (WinWidth - ButtonWidth)/2;

	DesiredWidth = 200;
	DesiredHeight = 320;

	for (I=0; I<9; I++)
	{
		ButtonTop = 25 + 25*I;
		Slots[I] = UMenuRaisedButton(CreateControl(class'UMenuRaisedButton', ButtonLeft, ButtonTop, ButtonWidth, 1));
		Slots[I].SetText(SlotNames[I]);
		Slots[I].SetHelpText(SlotHelp);
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ButtonWidth, ButtonLeft, I;

	ButtonWidth = WinWidth - 60;
	ButtonLeft = (WinWidth - ButtonWidth)/2;

	for (I=0; I<9; I++)
	{
		Slots[I].SetSize(ButtonWidth, 1);
		Slots[I].WinLeft = ButtonLeft;
	}
}

defaultproperties
{
     SlotNames(0)="..Empty.."
     SlotNames(1)="..Empty.."
     SlotNames(2)="..Empty.."
     SlotNames(3)="..Empty.."
     SlotNames(4)="..Empty.."
     SlotNames(5)="..Empty.."
     SlotNames(6)="..Empty.."
     SlotNames(7)="..Empty.."
     SlotNames(8)="..Empty.."
     MonthNames(0)="January"
     MonthNames(1)="February"
     MonthNames(2)="March"
     MonthNames(3)="April"
     MonthNames(4)="May"
     MonthNames(5)="June"
     MonthNames(6)="July"
     MonthNames(7)="August"
     MonthNames(8)="September"
     MonthNames(9)="October"
     MonthNames(10)="November"
     MonthNames(11)="December"
	 SlotHelp="Press to activate this slot. (Save/Load)"
}
