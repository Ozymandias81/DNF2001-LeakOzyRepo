class UTPasswordCW expands UWindowDialogClientWindow;

var string URL;

var UWindowComboControl PasswordCombo;
var localized string	PasswordText;

var config string		PasswordHistory[10];

function Created()
{
	local float EditWidth;
	local int i;
	local Color TC;

	Super.Created();

	EditWidth = WinWidth - 140;
	PasswordCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 20, 20, EditWidth, 1));
	PasswordCombo.SetText(PasswordText);
	PasswordCombo.SetFont(F_Normal);
	PasswordCombo.SetEditable(True);
	for (i=0; i<10; i++)
		if (PasswordHistory[i] != "")
			PasswordCombo.AddItem(PasswordHistory[i]);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float EditWidth;
	local float XL, YL;

	C.Font = Root.Fonts[PasswordCombo.Font];
	TextSize(C, PasswordCombo.Text, XL, YL);

	EditWidth = WinWidth - 50;

	PasswordCombo.WinLeft = (WinWidth - EditWidth) / 2;
	PasswordCombo.WinTop = (WinHeight-PasswordCombo.WinHeight) / 2;
	PasswordCombo.SetSize(EditWidth, PasswordCombo.WinHeight);
	PasswordCombo.EditBoxWidth = PasswordCombo.WinWidth - XL - 20;

	Super.BeforePaint(C, X, Y);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if((C == PasswordCombo && E == DE_EnterPressed) ||
	   (C == UTPasswordWindow(ParentWindow).OKButton && E == DE_Click))
		Connect();
}

function Connect()
{
	local int i;
	local bool HistoryItem;
	local UWindowComboListItem Item;
	local string P;

	P = PasswordCombo.GetValue();
	if(P == "")
	{
		PasswordCombo.BringToFront();
		return;
	}
	
	for (i=0; i<10; i++)
	{
		if (PasswordHistory[i] ~= P)
			HistoryItem = True;
	}
	if (!HistoryItem)
	{
		PasswordCombo.InsertItem(P);
		while(PasswordCombo.List.Items.Count() > 10)
			PasswordCombo.List.Items.Last.Remove();

		Item = UWindowComboListItem(PasswordCombo.List.Items.Next);
		for (i=0; i<10; i++)
		{
			if(Item != None)
			{
				PasswordHistory[i] = Item.Value;
				Item = UWindowComboListItem(Item.Next);
			}
			else
				PasswordHistory[i] = "";
		}			
	}
	SaveConfig();
	PasswordCombo.ClearValue();
	GetParent(class'UWindowFramedWindow').Close();
	UTConsole(Root.Console).ConnectWithPassword(URL, P);
}

defaultproperties
{
	PasswordText="Password:"
}